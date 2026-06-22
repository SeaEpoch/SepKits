#pragma once
#include <QObject>
#include <QAtomicInt>
#include <QMutex>
#include <QSet>
#include <QStringList>

#include <memory>
#include <thread>

#include "CacheCleanerModel.h"

class QTimer;

class SystemCacheCleaner : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)
    Q_PROPERTY(bool scanning READ isScanning NOTIFY scanningChanged)
    Q_PROPERTY(qreal progressValue READ progressValue NOTIFY progressValueChanged)
    Q_PROPERTY(CacheCleanerModel* model READ model CONSTANT)

public:
    explicit SystemCacheCleaner(QObject *parent = nullptr);
    ~SystemCacheCleaner() override;

    bool isRunning() const   { return m_running.loadRelaxed(); }
    bool isScanning() const  { return m_scanning.loadRelaxed(); }
    qreal progressValue() const { return m_progressValue; }
    CacheCleanerModel* model() const { return m_model; }

    Q_INVOKABLE bool isRunningAsAdmin() const;
    Q_INVOKABLE void requestAdminRelaunch();

public slots:
    void startScan();
    void startCleanup(const QStringList &enabled);
    void cancel();
    void retranslate();

signals:
    void runningChanged();
    void scanningChanged();
    void progressUpdated(const QString &message);
    void progressValueChanged();
    void progressLabelChanged(const QString &label);
    void cleanupFinished(int cleanedCount, qint64 freedBytes);
    void scanAllCompleted();

private slots:
    void flushMessageBuffer();

private:
    void doScan();
    void doCleanup(const QStringList &enabled);
    void setProgress(qreal value, const QString &label);
    void emitProgress(const QString &message);
    QString formatSize(qint64 bytes) const;

    // Non-destructive: count files + sum sizes
    struct Count {
        int files = 0;
        qint64 bytes = 0;
        Count &operator+=(const Count &o) {
            files += o.files;
            bytes += o.bytes;
            return *this;
        }
    };
    Count countFiles(const QString &path, const QStringList &patterns,
                     bool recursive, const QSet<QString> &excludeDirs = {});
    // Destructive: remove files
    qint64 removeFiles(const QString &path, const QStringList &patterns,
                       bool recursive, const QSet<QString> &excludeDirs = {},
                       bool recreateDir = false);
    bool tryCleanDir(const QString &label, const QString &path,
                     const QStringList &patterns, bool recursive,
                     const QSet<QString> &excludeDirs = {},
                     bool recreateDir = false);

    QAtomicInt m_cancelled{0};
    QAtomicInt m_running{0};
    QAtomicInt m_scanning{0};
    int m_cleanedCount = 0;
    qint64 m_freedBytes = 0;
    qreal m_progressValue = 0.0;
    CacheCleanerModel *m_model = nullptr;
    std::unique_ptr<std::thread> m_worker;

    mutable QMutex m_mutex;
    QStringList m_messageBuffer;
    QTimer *m_flushTimer = nullptr;
};
