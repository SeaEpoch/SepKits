#pragma once
#include <QObject>
#include <QProcess>
#include <QColor>
#include <QSize>
#include <QVariantMap>
#include <QStringList>

class WatermarkProcessor : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantMap inputFile READ inputFile NOTIFY inputFileChanged)
    Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
    Q_PROPERTY(bool isRunning READ isRunning NOTIFY isRunningChanged)
    Q_PROPERTY(QString outputDir READ outputDir WRITE setOutputDir NOTIFY outputDirChanged)

public:
    explicit WatermarkProcessor(QObject *parent = nullptr);
    ~WatermarkProcessor() override;

    QVariantMap inputFile() const; double progress() const;
    bool isRunning() const; QString outputDir() const; void setOutputDir(const QString &dir);

    Q_INVOKABLE void setInputFile(const QString &path);
    Q_INVOKABLE void clearInputFile();
    Q_INVOKABLE void setWatermarkSettings(const QVariantMap &settings);
    Q_INVOKABLE void startProcessing();
    Q_INVOKABLE void cancelProcessing();
    Q_INVOKABLE QString generatePreview(const QString &filePath, const QVariantMap &settings);

    static QString ffmpegPath(); static QString ffprobePath();

signals:
    void inputFileChanged(); void progressChanged(); void isRunningChanged();
    void outputDirChanged(); void processingFinished(bool success, const QString &outPath);
    void thumbnailReady(const QString &thumbnailPath);
    void previewReady(const QString &previewPath);

private slots:
    void onProcessFinished(int exitCode, QProcess::ExitStatus status);
    void onProcessError(QProcess::ProcessError error); void onReadyReadStderr();

private:
    struct WatermarkSettings {
        QString type = "text";
        QString text; QString fontFamily; int fontSize = 48;
        QColor textColor = Qt::white; double textOpacity = 1.0;
        QString imagePath; double opacity = 1.0; double imageScale = 0.3;
        double rotation = 0.0; double posX = 0.5; double posY = 0.5;
        bool batchMode = false; double hSpacing = 0.5; double vSpacing = 0.5;
    };
    struct InputFile {
        QString path; QString type; qint64 fileSize = 0;
        int width = 0; int height = 0; QString thumbnailPath;
    };

    QString renderWatermarkLayer(const QSize &size, const WatermarkSettings &s);
    QStringList buildOverlayArgs(const QString &outPath, const QString &layerPath);
    QSize probeDimensions(const QString &path); double probeDuration(const QString &path);
    QString extractFirstFrame(const QString &videoPath);
    void parseProgress(const QString &line); void resetState();
    void cleanupTempFiles();

    InputFile m_file; WatermarkSettings m_settings;
    QProcess *m_process = nullptr; QProcess *m_probeProcess = nullptr;
    QString m_outputDir; double m_progress = 0.0;
    double m_currentDuration = 0.0; bool m_cancelled = false;
    QStringList m_tempFiles;
};
