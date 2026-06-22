#include "NetworkSpeedTest.h"
#include "Logger.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

// ─── Path resolution ───────────────────────────────────────────────

QString NetworkSpeedTest::speedtestPath()
{
    const QString appDir = QCoreApplication::applicationDirPath();
    // Development: relative to build dir
    const QString devPath = appDir + QStringLiteral("/../../third_party/ookla-speedtest-1.2.0-win64/speedtest.exe");
    const QFileInfo devFi(devPath);
    if (devFi.exists() && devFi.isExecutable())
        return devFi.absoluteFilePath();
    // Production: alongside executable
    const QString prodPath = appDir + QStringLiteral("/bin/ookla-speedtest-1.2.0-win64/speedtest.exe");
    const QFileInfo prodFi(prodPath);
    if (prodFi.exists() && prodFi.isExecutable())
        return prodFi.absoluteFilePath();
    return {};
}

// ─── Speed conversion ──────────────────────────────────────────────

double NetworkSpeedTest::bytesPerSecToUnit(double bytesPerSec, const QString &unit)
{
    if (unit == QStringLiteral("bps"))       return bytesPerSec * 8.0;
    if (unit == QStringLiteral("kbps"))      return bytesPerSec * 8.0 / 1000.0;
    if (unit == QStringLiteral("Mbps"))      return bytesPerSec * 8.0 / 1000000.0;
    if (unit == QStringLiteral("Gbps"))      return bytesPerSec * 8.0 / 1000000000.0;
    if (unit == QStringLiteral("B/s"))       return bytesPerSec;
    if (unit == QStringLiteral("kB/s"))      return bytesPerSec / 1000.0;
    if (unit == QStringLiteral("MB/s"))      return bytesPerSec / 1000000.0;
    if (unit == QStringLiteral("GB/s"))      return bytesPerSec / 1000000000.0;
    return bytesPerSec * 8.0 / 1000000.0; // default Mbps
}

// ─── Constructor / Destructor ──────────────────────────────────────

NetworkSpeedTest::NetworkSpeedTest(QObject *parent)
    : QObject(parent)
    , m_speedUnit(QStringLiteral("Mbps"))
{
}

NetworkSpeedTest::~NetworkSpeedTest()
{
    if (m_process) {
        m_process->kill();
        m_process->waitForFinished(3000);
    }
}

// ─── Property accessors ────────────────────────────────────────────

bool NetworkSpeedTest::isRunning() const           { return m_process && m_process->state() != QProcess::NotRunning; }
QString NetworkSpeedTest::currentPhase() const     { return m_currentPhase; }
QVariantList NetworkSpeedTest::serverList() const   { return m_serverList; }
int NetworkSpeedTest::selectedServerId() const      { return m_selectedServerId; }
QString NetworkSpeedTest::isp() const               { return m_isp; }
QString NetworkSpeedTest::internalIp() const        { return m_internalIp; }
QString NetworkSpeedTest::externalIp() const        { return m_externalIp; }
double NetworkSpeedTest::pingLatency() const        { return m_pingLatency; }
double NetworkSpeedTest::pingJitter() const         { return m_pingJitter; }
double NetworkSpeedTest::packetLoss() const         { return m_packetLoss; }
double NetworkSpeedTest::downloadSpeed() const      { return m_downloadSpeed; }
double NetworkSpeedTest::uploadSpeed() const        { return m_uploadSpeed; }
double NetworkSpeedTest::downloadResult() const     { return m_downloadResult; }
double NetworkSpeedTest::uploadResult() const       { return m_uploadResult; }
double NetworkSpeedTest::progress() const           { return m_progress; }
QString NetworkSpeedTest::speedUnit() const         { return m_speedUnit; }
QString NetworkSpeedTest::resultUrl() const         { return m_resultUrl; }
double NetworkSpeedTest::gaugeMaxSpeed() const      { return m_gaugeMaxSpeed; }
QString NetworkSpeedTest::rawLog() const            { return m_rawLog; }

void NetworkSpeedTest::setSelectedServerId(int id)
{
    if (m_selectedServerId != id) {
        m_selectedServerId = id;
        emit selectedServerIdChanged();
    }
}

void NetworkSpeedTest::setSpeedUnit(const QString &unit)
{
    if (m_speedUnit != unit) {
        m_speedUnit = unit;
        emit speedUnitChanged();
    }
}

// ─── Internal helpers ──────────────────────────────────────────────

void NetworkSpeedTest::setPhase(const QString &phase)
{
    if (m_currentPhase != phase) {
        m_currentPhase = phase;
        emit currentPhaseChanged();
    }
}

void NetworkSpeedTest::updateGaugeMax(double speed)
{
    if (speed > m_gaugeMaxSpeed * 0.8) {
        m_gaugeMaxSpeed *= 2.0;
        emit gaugeMaxSpeedChanged();
    }
}

void NetworkSpeedTest::resetState()
{
    m_downloadSpeed = 0;
    m_uploadSpeed = 0;
    m_downloadResult = 0;
    m_uploadResult = 0;
    m_pingLatency = 0;
    m_pingJitter = 0;
    m_packetLoss = 0;
    m_isp.clear();
    m_internalIp.clear();
    m_externalIp.clear();
    m_resultUrl.clear();
    m_progress = 0;
    m_gaugeMaxSpeed = 10.0;
    m_rawLog.clear();
    m_stderrBuffer.clear();
    m_lastProgressBytes = 0;
    m_lastProgressElapsed = 0;
    m_lastProgressType.clear();

    emit downloadSpeedChanged();
    emit uploadSpeedChanged();
    emit downloadResultChanged();
    emit uploadResultChanged();
    emit pingLatencyChanged();
    emit pingJitterChanged();
    emit packetLossChanged();
    emit ispChanged();
    emit internalIpChanged();
    emit externalIpChanged();
    emit resultUrlChanged();
    emit progressChanged();
    emit gaugeMaxSpeedChanged();
    emit rawLogChanged();
}

// ─── Public methods ────────────────────────────────────────────────

void NetworkSpeedTest::fetchServers()
{
    if (isRunning()) return;

    const QString path = speedtestPath();
    if (path.isEmpty()) return;

    auto *proc = new QProcess(this);
    proc->setProgram(path);
    proc->setArguments({QStringLiteral("--servers"), QStringLiteral("--format=json")});

    connect(proc, &QProcess::finished, this, [this, proc](int exitCode, QProcess::ExitStatus) {
        if (exitCode == 0) {
            const QByteArray data = proc->readAllStandardOutput();
            QJsonParseError err;
            const QJsonDocument doc = QJsonDocument::fromJson(data, &err);
            if (err.error == QJsonParseError::NoError && doc.isObject()) {
                const QJsonObject root = doc.object();
                const QJsonArray servers = root.value(QStringLiteral("servers")).toArray();
                m_serverList.clear();
                for (const QJsonValue &v : servers) {
                    const QJsonObject s = v.toObject();
                    QVariantMap item;
                    item[QStringLiteral("id")] = s.value(QStringLiteral("id")).toInt();
                    item[QStringLiteral("name")] = s.value(QStringLiteral("name")).toString();
                    item[QStringLiteral("location")] = s.value(QStringLiteral("location")).toString();
                    item[QStringLiteral("country")] = s.value(QStringLiteral("country")).toString();
                    item[QStringLiteral("host")] = s.value(QStringLiteral("host")).toString();
                    m_serverList.append(item);
                }
                emit serverListChanged();
            }
        }
        proc->deleteLater();
    });

    connect(proc, &QProcess::errorOccurred, this, [proc](QProcess::ProcessError) {
        proc->deleteLater();
    });

    proc->start();
}

void NetworkSpeedTest::startTest()
{
    if (isRunning()) return;

    const QString path = speedtestPath();
    if (path.isEmpty()) return;

    resetState();

    if (!m_process) {
        m_process = new QProcess(this);
        m_process->setProcessChannelMode(QProcess::SeparateChannels);
        connect(m_process, &QProcess::readyReadStandardOutput, this, &NetworkSpeedTest::onReadyRead);
        connect(m_process, &QProcess::readyReadStandardError, this, &NetworkSpeedTest::onReadyReadStderr);
        connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
                this, &NetworkSpeedTest::onFinished);
        connect(m_process, &QProcess::errorOccurred, this, &NetworkSpeedTest::onErrorOccurred);
    }

    QStringList args;
    args << QStringLiteral("--format=json")
         << QStringLiteral("--progress=yes")
         << QStringLiteral("--progress-update-interval=200");
    if (m_selectedServerId > 0)
        args << QStringLiteral("--server-id=") + QString::number(m_selectedServerId);

    m_process->setProgram(path);
    m_process->setArguments(args);

    Logger::instance()->info("NetworkSpeedTest", "startTest", "Speed test started");
    m_process->start();

    m_pendingBuffer.clear();
    m_lastProgressBytes = 0;
    m_lastProgressElapsed = 0;
    m_lastProgressType.clear();
    emit isRunningChanged();
}

void NetworkSpeedTest::cancelTest()
{
    if (m_process && m_process->state() != QProcess::NotRunning) {
        m_process->kill();
    }
}

// ─── QProcess slots ────────────────────────────────────────────────

void NetworkSpeedTest::onReadyRead()
{
    m_pendingBuffer += QString::fromUtf8(m_process->readAllStandardOutput());
    // Process complete lines
    while (true) {
        int idx = m_pendingBuffer.indexOf(QLatin1Char('\n'));
        if (idx < 0) break;
        const QString line = m_pendingBuffer.left(idx).trimmed();
        m_pendingBuffer = m_pendingBuffer.mid(idx + 1);
        if (line.isEmpty()) continue;

        QJsonParseError err;
        const QJsonDocument doc = QJsonDocument::fromJson(line.toUtf8(), &err);
        if (err.error != QJsonParseError::NoError) continue;
        if (!doc.isObject()) continue;

        processLine(doc.object());

        // Accumulate raw JSON line for QML log display
        m_rawLog += line + QStringLiteral("\n");
        Logger::instance()->info("NetworkSpeedTest", "onReadyRead", line);
    }
    if (!m_rawLog.isEmpty())
        emit rawLogChanged();
}

void NetworkSpeedTest::onReadyReadStderr()
{
    if (m_process)
        m_stderrBuffer += QString::fromUtf8(m_process->readAllStandardError());
}

void NetworkSpeedTest::onFinished(int exitCode, QProcess::ExitStatus status)
{
    Q_UNUSED(status)

    // Process any remaining stdout data
    if (!m_pendingBuffer.trimmed().isEmpty()) {
        QJsonParseError err;
        const QJsonDocument doc = QJsonDocument::fromJson(m_pendingBuffer.trimmed().toUtf8(), &err);
        if (err.error == QJsonParseError::NoError && doc.isObject())
            processResult(doc.object());
    }

    if (exitCode != 0) {
        // speedtest.exe returned an error — show stderr in log
        if (!m_stderrBuffer.isEmpty()) {
            m_rawLog += QStringLiteral("[Error] ") + m_stderrBuffer.trimmed() + QStringLiteral("\n");
            Logger::instance()->error("NetworkSpeedTest", "speedtest.exe failed",
                m_stderrBuffer.trimmed());
            emit rawLogChanged();
        }
        setPhase(QStringLiteral("idle"));
        m_progress = 0;
        emit progressChanged();
        emit isRunningChanged();
        return;
    }

    setPhase(QStringLiteral("done"));
    m_progress = 1.0;
    emit progressChanged();
    emit isRunningChanged();
}

void NetworkSpeedTest::onErrorOccurred(QProcess::ProcessError error)
{
    Q_UNUSED(error)
    if (m_process) {
        if (m_process->state() != QProcess::NotRunning) {
            m_process->kill();
            m_process->waitForFinished(1000);
        }
    }
    setPhase(QStringLiteral("idle"));
    m_progress = 0;
    emit progressChanged();
    emit isRunningChanged();
}

// ─── JSON processing ───────────────────────────────────────────────

void NetworkSpeedTest::processLine(const QJsonObject &obj)
{
    const QString type = obj.value(QStringLiteral("type")).toString();

    if (type == QStringLiteral("download") || type == QStringLiteral("upload")) {
        processProgress(obj);
    } else if (type == QStringLiteral("result")) {
        processResult(obj);
    } else if (type == QStringLiteral("testStart")) {
        // Extract ISP & IP info from testStart (arrives before ping/download/upload)
        const QString isp = obj.value(QStringLiteral("isp")).toString();
        if (!isp.isEmpty() && m_isp != isp) {
            m_isp = isp;
            emit ispChanged();
        }
        const QJsonObject iface = obj.value(QStringLiteral("interface")).toObject();
        if (!iface.isEmpty()) {
            const QString intIp = iface.value(QStringLiteral("internalIp")).toString();
            const QString extIp = iface.value(QStringLiteral("externalIp")).toString();
            if (!intIp.isEmpty() && m_internalIp != intIp) {
                m_internalIp = intIp;
                emit internalIpChanged();
            }
            if (!extIp.isEmpty() && m_externalIp != extIp) {
                m_externalIp = extIp;
                emit externalIpChanged();
            }
        }
        setPhase(QStringLiteral("ping"));
        m_progress = 0.02;
        emit progressChanged();
    } else if (type == QStringLiteral("log")) {
        const QString level = obj.value(QStringLiteral("level")).toString();
        if (level == QStringLiteral("error")) {
            // Log errors but don't fail — speedtest may emit non-fatal errors
        }
    }
}

void NetworkSpeedTest::processProgress(const QJsonObject &obj)
{
    const QString type = obj.value(QStringLiteral("type")).toString();
    const QJsonObject inner = obj.value(type).toObject();
    const qint64 bytes = static_cast<qint64>(inner.value(QStringLiteral("bytes")).toDouble());
    const double elapsed = inner.value(QStringLiteral("elapsed")).toDouble(); // milliseconds

    if (type != m_lastProgressType) {
        // Phase transition
        setPhase(type);
        m_lastProgressBytes = 0;
        m_lastProgressElapsed = 0;
    }

    // Calculate instantaneous speed (bytes per second)
    double instSpeed = 0;
    if (elapsed > m_lastProgressElapsed && bytes > m_lastProgressBytes) {
        double deltaBytes = static_cast<double>(bytes - m_lastProgressBytes);
        double deltaSec = (elapsed - m_lastProgressElapsed) / 1000.0;
        if (deltaSec > 0.01)
            instSpeed = deltaBytes / deltaSec;
    }

    double displaySpeed = bytesPerSecToUnit(instSpeed, m_speedUnit);

    if (type == QStringLiteral("download")) {
        m_downloadSpeed = displaySpeed;
        updateGaugeMax(displaySpeed);
        m_progress = 0.02 + 0.43 * (elapsed / 15000.0); // ping → download → upload → done
        emit downloadSpeedChanged();
    } else if (type == QStringLiteral("upload")) {
        m_uploadSpeed = displaySpeed;
        updateGaugeMax(displaySpeed);
        m_progress = 0.45 + 0.45 * (elapsed / 10000.0);
        emit uploadSpeedChanged();
    }
    emit progressChanged();

    m_lastProgressBytes = bytes;
    m_lastProgressElapsed = elapsed;
    m_lastProgressType = type;
}

void NetworkSpeedTest::processResult(const QJsonObject &obj)
{
    // ISP & IPs
    const QJsonObject iface = obj.value(QStringLiteral("interface")).toObject();
    if (!iface.isEmpty()) {
        m_internalIp = iface.value(QStringLiteral("internalIp")).toString();
        m_externalIp = iface.value(QStringLiteral("externalIp")).toString();
        emit internalIpChanged();
        emit externalIpChanged();
    }

    m_isp = obj.value(QStringLiteral("isp")).toString();
    emit ispChanged();

    // Ping
    const QJsonObject ping = obj.value(QStringLiteral("ping")).toObject();
    if (!ping.isEmpty()) {
        m_pingLatency = ping.value(QStringLiteral("latency")).toDouble();
        m_pingJitter = ping.value(QStringLiteral("jitter")).toDouble();
        emit pingLatencyChanged();
        emit pingJitterChanged();
    }

    // Download result
    const QJsonObject download = obj.value(QStringLiteral("download")).toObject();
    if (!download.isEmpty()) {
        double bw = download.value(QStringLiteral("bandwidth")).toDouble(); // bytes/sec
        m_downloadResult = bytesPerSecToUnit(bw, m_speedUnit);
        m_downloadSpeed = 0;
        emit downloadResultChanged();
        emit downloadSpeedChanged();
    }

    // Upload result
    const QJsonObject upload = obj.value(QStringLiteral("upload")).toObject();
    if (!upload.isEmpty()) {
        double bw = upload.value(QStringLiteral("bandwidth")).toDouble(); // bytes/sec
        m_uploadResult = bytesPerSecToUnit(bw, m_speedUnit);
        m_uploadSpeed = 0;
        emit uploadResultChanged();
        emit uploadSpeedChanged();
    }

    // Packet loss
    if (obj.contains(QStringLiteral("packetLoss"))) {
        m_packetLoss = obj.value(QStringLiteral("packetLoss")).toDouble();
        emit packetLossChanged();
    }

    // Result URL
    const QJsonObject result = obj.value(QStringLiteral("result")).toObject();
    if (!result.isEmpty()) {
        m_resultUrl = result.value(QStringLiteral("url")).toString();
        emit resultUrlChanged();
    }

    Logger::instance()->info("NetworkSpeedTest", "processResult",
        QStringLiteral("Download: %1 %2, Upload: %3 %4, Ping: %5 ms")
            .arg(m_downloadResult).arg(m_speedUnit)
            .arg(m_uploadResult).arg(m_speedUnit)
            .arg(m_pingLatency));
}
