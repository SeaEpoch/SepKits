#pragma once
#include <QObject>
#include <QProcess>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>

class MediaFormatConverter : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList files READ files NOTIFY filesChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(int currentFileIndex READ currentFileIndex NOTIFY currentFileIndexChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(QString outputDir READ outputDir WRITE setOutputDir NOTIFY outputDirChanged)

public:
    explicit MediaFormatConverter(QObject *parent = nullptr);
    ~MediaFormatConverter() override;
    QVariantList files() const; double progress() const; int currentFileIndex() const;
    bool isRunning() const; QString outputDir() const; void setOutputDir(const QString &dir);

    Q_INVOKABLE void addFiles(const QStringList &paths);
    Q_INVOKABLE void removeFile(int index);
    Q_INVOKABLE void setTargetFormat(int index, const QString &format);
    Q_INVOKABLE void setAudioTrim(int index, const QString &trimStart, const QString &trimEnd);
    Q_INVOKABLE void setAudioVolume(int index, double volume);
    Q_INVOKABLE void setAudioChannels(int index, int channels);
    Q_INVOKABLE void setAudioSampleRate(int index, int sampleRate);
    Q_INVOKABLE void setVideoTrim(int index, const QString &trimStart, const QString &trimEnd);
    Q_INVOKABLE void setVideoCodec(int index, const QString &codec);
    Q_INVOKABLE void applyAudioSettingsToAll(const QVariantMap &settings);
    Q_INVOKABLE void applyVideoSettingsToAll(const QVariantMap &settings);
    Q_INVOKABLE void startConversion();
    Q_INVOKABLE void cancelConversion();
    Q_INVOKABLE QString saveLog() const;
    static QString ffmpegPath(); static QString ffprobePath();

signals:
    void filesChanged(); void progressChanged(); void currentFileIndexChanged();
    void isRunningChanged(); void outputDirChanged();
    void conversionFinished(int successCount, int failCount); void logMessage(const QString &msg);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus status);
    void onProcessError(QProcess::ProcessError error); void onReadyReadStderr();

private:
    struct AudioSettings { QString trimStart; QString trimEnd; double volume = 0.0; int channels = 0; int sampleRate = 0; };
    struct VideoSettings { QString trimStart; QString trimEnd; QString videoCodec; AudioSettings audioSettings; };
    struct FileEntry { QString path; QString type; qint64 fileSize = 0; QString targetFormat; QString status; AudioSettings audioSettings; VideoSettings videoSettings; };

    void convertNext(); void updateFileStatus(int index, const QString &status);
    QStringList buildFFmpegArgs(const FileEntry &entry, const QString &outPath);
    double probeDuration(const QString &path); void parseProgress(const QString &line);
    void resetState(); QVariantMap fileToVariant(const FileEntry &entry) const;

    QList<FileEntry> m_files; QProcess *m_process = nullptr; QProcess *m_probeProcess = nullptr;
    QString m_outputDir; int m_currentIndex = -1; double m_progress = 0.0; double m_fileProgress = 0.0;
    double m_currentDuration = 0.0; int m_successCount = 0; int m_failCount = 0; bool m_cancelled = false;
    QStringList m_logLines; QString m_logFilePath;
};
