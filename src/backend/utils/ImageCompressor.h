#pragma once
#include <QObject>
#include <QProcess>
#include <QVariantList>
#include <QVariantMap>
#include <QStringList>

class ImageCompressor : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList files READ files NOTIFY filesChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(int currentFileIndex READ currentFileIndex NOTIFY currentFileIndexChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(QString outputDir READ outputDir WRITE setOutputDir NOTIFY outputDirChanged)

public:
    explicit ImageCompressor(QObject *parent = nullptr);
    ~ImageCompressor() override;
    QVariantList files() const; double progress() const; int currentFileIndex() const;
    bool isRunning() const; QString outputDir() const; void setOutputDir(const QString &dir);

    Q_INVOKABLE void addFiles(const QStringList &paths);
    Q_INVOKABLE void removeFile(int index);
    Q_INVOKABLE void setCompressionQuality(int index, int quality);
    Q_INVOKABLE void applyQualityToAll(int quality);
    Q_INVOKABLE void startCompression();
    Q_INVOKABLE void cancelCompression();

    static QString ffmpegPath(); static QString ffprobePath();

signals:
    void filesChanged(); void progressChanged(); void currentFileIndexChanged();
    void isRunningChanged(); void outputDirChanged();
    void compressionFinished(int successCount, int failCount);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus status);
    void onProcessError(QProcess::ProcessError error); void onReadyReadStderr();

private:
    struct FileEntry {
        QString path; QString type; qint64 fileSize = 0;
        int compressionQuality = 5; QString status;
    };
    void convertNext(); void updateFileStatus(int index, const QString &status);
    void resetState(); QVariantMap fileToVariant(const FileEntry &e) const;
    double probeDuration(const QString &path);
    QStringList buildFFmpegArgs(const FileEntry &entry, const QString &outPath);
    void parseProgress(const QString &line);

    QList<FileEntry> m_files; QProcess *m_process = nullptr;
    QProcess *m_probeProcess = nullptr; QString m_outputDir;
    int m_currentIndex = -1; double m_progress = 0.0;
    double m_fileProgress = 0.0; double m_currentDuration = 0.0;
    int m_successCount = 0; int m_failCount = 0; bool m_cancelled = false;
};
