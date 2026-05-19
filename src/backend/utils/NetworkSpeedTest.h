#pragma once
#include <QObject>
#include <QProcess>
#include <QVariantList>
#include <QJsonObject>

class NetworkSpeedTest : public QObject {
    Q_OBJECT

    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(QString currentPhase READ currentPhase NOTIFY currentPhaseChanged)
    Q_PROPERTY(QVariantList serverList READ serverList NOTIFY serverListChanged)
    Q_PROPERTY(int selectedServerId READ selectedServerId WRITE setSelectedServerId NOTIFY selectedServerIdChanged)
    Q_PROPERTY(QString isp READ isp NOTIFY ispChanged)
    Q_PROPERTY(QString internalIp READ internalIp NOTIFY internalIpChanged)
    Q_PROPERTY(QString externalIp READ externalIp NOTIFY externalIpChanged)
    Q_PROPERTY(double pingLatency READ pingLatency NOTIFY pingLatencyChanged)
    Q_PROPERTY(double pingJitter READ pingJitter NOTIFY pingJitterChanged)
    Q_PROPERTY(double packetLoss READ packetLoss NOTIFY packetLossChanged)
    Q_PROPERTY(double downloadSpeed READ downloadSpeed NOTIFY downloadSpeedChanged)
    Q_PROPERTY(double uploadSpeed READ uploadSpeed NOTIFY uploadSpeedChanged)
    Q_PROPERTY(double downloadResult READ downloadResult NOTIFY downloadResultChanged)
    Q_PROPERTY(double uploadResult READ uploadResult NOTIFY uploadResultChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(QString speedUnit READ speedUnit WRITE setSpeedUnit NOTIFY speedUnitChanged)
    Q_PROPERTY(QString resultUrl READ resultUrl NOTIFY resultUrlChanged)
    Q_PROPERTY(double gaugeMaxSpeed READ gaugeMaxSpeed NOTIFY gaugeMaxSpeedChanged)
    Q_PROPERTY(QString rawLog READ rawLog NOTIFY rawLogChanged)

public:
    explicit NetworkSpeedTest(QObject *parent = nullptr);
    ~NetworkSpeedTest() override;

    bool isRunning() const;
    QString currentPhase() const;
    QVariantList serverList() const;
    int selectedServerId() const;
    QString isp() const;
    QString internalIp() const;
    QString externalIp() const;
    double pingLatency() const;
    double pingJitter() const;
    double packetLoss() const;
    double downloadSpeed() const;
    double uploadSpeed() const;
    double downloadResult() const;
    double uploadResult() const;
    double progress() const;
    QString speedUnit() const;
    QString resultUrl() const;
    double gaugeMaxSpeed() const;
    QString rawLog() const;

    void setSelectedServerId(int id);
    void setSpeedUnit(const QString &unit);

    Q_INVOKABLE void fetchServers();
    Q_INVOKABLE void startTest();
    Q_INVOKABLE void cancelTest();

signals:
    void isRunningChanged();
    void currentPhaseChanged();
    void serverListChanged();
    void selectedServerIdChanged();
    void ispChanged();
    void internalIpChanged();
    void externalIpChanged();
    void pingLatencyChanged();
    void pingJitterChanged();
    void packetLossChanged();
    void downloadSpeedChanged();
    void uploadSpeedChanged();
    void downloadResultChanged();
    void uploadResultChanged();
    void progressChanged();
    void speedUnitChanged();
    void resultUrlChanged();
    void gaugeMaxSpeedChanged();
    void rawLogChanged();

private slots:
    void onReadyRead();
    void onReadyReadStderr();
    void onFinished(int exitCode, QProcess::ExitStatus status);
    void onErrorOccurred(QProcess::ProcessError error);

private:
    static QString speedtestPath();
    static double bytesPerSecToUnit(double bytesPerSec, const QString &unit);

    void setPhase(const QString &phase);
    void processLine(const QJsonObject &obj);
    void processProgress(const QJsonObject &obj);
    void processResult(const QJsonObject &obj);
    void updateGaugeMax(double speed);
    void resetState();

    QProcess *m_process = nullptr;
    QString m_currentPhase;
    QVariantList m_serverList;
    int m_selectedServerId = -1;
    QString m_isp;
    QString m_internalIp;
    QString m_externalIp;
    double m_pingLatency = 0;
    double m_pingJitter = 0;
    double m_packetLoss = 0;
    double m_downloadSpeed = 0;
    double m_uploadSpeed = 0;
    double m_downloadResult = 0;
    double m_uploadResult = 0;
    double m_progress = 0;
    QString m_speedUnit;
    QString m_resultUrl;
    double m_gaugeMaxSpeed = 10.0;
    QString m_rawLog;

    // Progress tracking
    qint64 m_lastProgressBytes = 0;
    double m_lastProgressElapsed = 0;
    QString m_lastProgressType;
    QString m_pendingBuffer;
    QString m_stderrBuffer;
};
