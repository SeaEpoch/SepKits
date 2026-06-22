#pragma once
#include <QObject>
#include <QMutex>
#include <QFile>
#include <QDateTime>

class Logger : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString currentLogPath READ currentLogPath NOTIFY currentLogPathChanged)

public:
    enum Level { Debug = 0, Info, Warning, Error };
    Q_ENUM(Level)

    static Logger* instance();

    explicit Logger(QObject *parent = nullptr);
    ~Logger() override;

    QString currentLogPath() const;

    // Full-featured: C++ callers with compiler-provided file/line/function
    void log(Level level, const QString &module, const QString &function,
             const QString &file, int line, const QString &message,
             const QString &extra = {});

    // QML-friendly convenience (no file/line/function required)
    Q_INVOKABLE void info(const QString &module, const QString &message,
                          const QString &extra = {});
    Q_INVOKABLE void warn(const QString &module, const QString &message,
                          const QString &extra = {});
    Q_INVOKABLE void error(const QString &module, const QString &message,
                           const QString &extra = {});
    Q_INVOKABLE void debug(const QString &module, const QString &message,
                           const QString &extra = {});

    // Opens today's log file in the system default text editor
    Q_INVOKABLE void openTodayLog();

signals:
    void currentLogPathChanged();

private:
    void ensureLogFile();
    void rotateIfNeeded();
    void writeLine(const QString &line);
    static QString levelString(Level level);
    QString formatLine(Level level, const QString &module,
                       const QString &function, const QString &file,
                       int line, const QString &message, const QString &extra);

    QMutex  m_mutex;
    QString m_logDir;
    QString m_currentLogPath;
    QString m_currentDate;
    QFile   m_logFile;

    static Logger *s_instance;
};
