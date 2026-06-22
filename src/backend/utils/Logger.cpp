#include "Logger.h"

#include <QCoreApplication>
#include <QDate>
#include <QDesktopServices>
#include <QDir>
#include <QStandardPaths>
#include <QTextStream>
#include <QThread>
#include <QUrl>

Logger *Logger::s_instance = nullptr;

Logger* Logger::instance()
{
    return s_instance;
}

Logger::Logger(QObject *parent)
    : QObject(parent)
{
    Q_ASSERT_X(s_instance == nullptr, "Logger", "Only one Logger instance allowed");
    s_instance = this;

    m_logDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation)
               + QStringLiteral("/logs");
    QDir().mkpath(m_logDir);
}

Logger::~Logger()
{
    QMutexLocker locker(&m_mutex);
    if (m_logFile.isOpen())
        m_logFile.close();
    if (s_instance == this)
        s_instance = nullptr;
}

QString Logger::currentLogPath() const
{
    return m_currentLogPath;
}

// ─── Rotation ───────────────────────────────────────────────────────

void Logger::rotateIfNeeded()
{
    const QString today = QDate::currentDate().toString(QStringLiteral("yyyy-MM-dd"));
    if (today == m_currentDate)
        return;

    if (m_logFile.isOpen())
        m_logFile.close();

    m_currentDate = today;
    m_currentLogPath = m_logDir + QStringLiteral("/SepKits_") + today + QStringLiteral(".log");
    m_logFile.setFileName(m_currentLogPath);
    emit currentLogPathChanged();
}

void Logger::ensureLogFile()
{
    rotateIfNeeded();
    if (m_logFile.isOpen())
        return;
    if (m_logFile.open(QIODevice::Append | QIODevice::Text))
        m_logFile.setTextModeEnabled(true);
}

// ─── Formatting ─────────────────────────────────────────────────────

QString Logger::levelString(Level level)
{
    switch (level) {
    case Debug:   return QStringLiteral("DEBUG");
    case Info:    return QStringLiteral("INFO");
    case Warning: return QStringLiteral("WARN");
    case Error:   return QStringLiteral("ERROR");
    }
    return QStringLiteral("INFO");
}

QString Logger::formatLine(Level level, const QString &module,
                           const QString &function, const QString &file,
                           int line, const QString &message, const QString &extra)
{
    // [timestamp] [level] [PID:TID] [module::function] [file:line] message | extra
    const QString ts = QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd hh:mm:ss.zzz"));
    const QString pidTid = QStringLiteral("%1:%2")
        .arg(QCoreApplication::applicationPid())
        .arg(reinterpret_cast<quintptr>(QThread::currentThreadId()));

    QString out;
    out += QStringLiteral("[%1] [%2] [%3] [%4::%5] [%6:%7] %8")
        .arg(ts, levelString(level), pidTid, module, function, file)
        .arg(line).arg(message);

    if (!extra.isEmpty()) {
        out += QStringLiteral(" | ") + extra;
    }

    return out;
}

// ─── Write ──────────────────────────────────────────────────────────

void Logger::writeLine(const QString &line)
{
    if (!m_logFile.isOpen())
        return;
    QTextStream stream(&m_logFile);
    stream << line << Qt::endl;
    stream.flush();
}

void Logger::log(Level level, const QString &module, const QString &function,
                 const QString &file, int line, const QString &message,
                 const QString &extra)
{
    QMutexLocker locker(&m_mutex);
    ensureLogFile();
    writeLine(formatLine(level, module, function, file, line, message, extra));
}

// ─── QML Convenience ────────────────────────────────────────────────

void Logger::info(const QString &module, const QString &message, const QString &extra)
{
    log(Info, module, QString(), QString(), 0, message, extra);
}

void Logger::warn(const QString &module, const QString &message, const QString &extra)
{
    log(Warning, module, QString(), QString(), 0, message, extra);
}

void Logger::error(const QString &module, const QString &message, const QString &extra)
{
    log(Error, module, QString(), QString(), 0, message, extra);
}

void Logger::debug(const QString &module, const QString &message, const QString &extra)
{
    log(Debug, module, QString(), QString(), 0, message, extra);
}

void Logger::openTodayLog()
{
    QMutexLocker locker(&m_mutex);
    ensureLogFile(); // ensure file exists so the editor opens something
    const QString path = m_currentLogPath;
    locker.unlock();
    if (!path.isEmpty())
        QDesktopServices::openUrl(QUrl::fromLocalFile(path));
}
