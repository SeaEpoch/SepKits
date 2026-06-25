#include "WatermarkProcessor.h"
#include "Logger.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QFont>
#include <QFontMetrics>
#include <QImage>
#include <QPainter>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QUuid>

static const QString FFMPEG_DIR = QStringLiteral("ffmpeg-2026-06-08-git-6028720d70-full_build");

QString WatermarkProcessor::ffmpegPath() {
    const QString appDir = QCoreApplication::applicationDirPath();
    const QString devPath = appDir + "/../../third_party/" + FFMPEG_DIR + "/bin/ffmpeg.exe";
    if (QFileInfo::exists(devPath)) return QFileInfo(devPath).absoluteFilePath();
    const QString prodPath = appDir + "/bin/" + FFMPEG_DIR + "/ffmpeg.exe";
    if (QFileInfo::exists(prodPath)) return QFileInfo(prodPath).absoluteFilePath();
    return {};
}
QString WatermarkProcessor::ffprobePath() {
    const QString appDir = QCoreApplication::applicationDirPath();
    const QString devPath = appDir + "/../../third_party/" + FFMPEG_DIR + "/bin/ffprobe.exe";
    if (QFileInfo::exists(devPath)) return QFileInfo(devPath).absoluteFilePath();
    const QString prodPath = appDir + "/bin/" + FFMPEG_DIR + "/ffprobe.exe";
    if (QFileInfo::exists(prodPath)) return QFileInfo(prodPath).absoluteFilePath();
    return {};
}

static QString detectType(const QString &path) {
    const QString ext = QFileInfo(path).suffix().toLower();
    static const QStringList videoExts = {
        "mp4","avi","mkv","mov","webm","wmv","flv","m4v",
        "mpeg","mpg","ts","mts","3gp","ogv","divx",
        "hevc","h265","mpeg2","m2v","mjpeg","av1","swf",
        "avchd","vob","xvid","mxf","rm","f4v","asf","rmvb",
        "wtv","3g2","m2ts"
    };
    static const QStringList imageExts = {
        "jpg","jpeg","png","bmp","webp","gif","tiff","tif",
        "jp2","j2k","dpx","exr","hdr","rgbe",
        "fits","fit","pam","pbm","pgm","ppm","pfm","phm","pgmyuv",
        "sgi","rgb","rgba","ras","sun",
        "tga","xbm","xwd","pcx","wbmp",
        "apng","avif"
    };
    if (videoExts.contains(ext)) return QStringLiteral("video");
    if (imageExts.contains(ext)) return QStringLiteral("image");
    return QStringLiteral("unknown");
}
static QString formatSize(qint64 bytes) {
    if (bytes < 1024) return QString::number(bytes) + " B";
    if (bytes < 1024*1024) return QString::number(bytes/1024.0,'f',1) + " KB";
    if (bytes < 1024LL*1024*1024) return QString::number(bytes/(1024.0*1024.0),'f',1) + " MB";
    return QString::number(bytes/(1024.0*1024.0*1024.0),'f',2) + " GB";
}

WatermarkProcessor::WatermarkProcessor(QObject *parent) : QObject(parent) {
    m_outputDir = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
}
WatermarkProcessor::~WatermarkProcessor() {
    if (m_process) { m_process->kill(); m_process->waitForFinished(3000); }
    if (m_probeProcess) { m_probeProcess->kill(); m_probeProcess->waitForFinished(3000); }
    cleanupTempFiles();
}

QVariantMap WatermarkProcessor::inputFile() const {
    if (m_file.path.isEmpty()) return {};
    QVariantMap m;
    m["path"] = m_file.path;
    m["fileName"] = QFileInfo(m_file.path).fileName();
    m["type"] = m_file.type;
    m["fileSize"] = m_file.fileSize;
    m["fileSizeText"] = formatSize(m_file.fileSize);
    m["width"] = m_file.width;
    m["height"] = m_file.height;
    m["thumbnailPath"] = m_file.thumbnailPath;
    return m;
}
double WatermarkProcessor::progress() const { return m_progress; }
bool WatermarkProcessor::isRunning() const { return m_process && m_process->state() != QProcess::NotRunning; }
QString WatermarkProcessor::outputDir() const { return m_outputDir; }
void WatermarkProcessor::setOutputDir(const QString &dir) { if (m_outputDir != dir) { m_outputDir = dir; emit outputDirChanged(); } }

void WatermarkProcessor::setInputFile(const QString &path) {
    const QFileInfo fi(path);
    if (!fi.exists() || !fi.isFile()) return;
    const QString type = detectType(path);
    if (type == "unknown") return;

    // Clean up previous thumbnail
    if (!m_file.thumbnailPath.isEmpty()) QFile::remove(m_file.thumbnailPath);
    m_file = InputFile{};
    m_file.path = fi.absoluteFilePath();
    m_file.type = type;
    m_file.fileSize = fi.size();
    const QSize dims = probeDimensions(path);
    m_file.width = dims.width();
    m_file.height = dims.height();
    if (type == "video") {
        m_file.thumbnailPath = extractFirstFrame(path);
        if (!m_file.thumbnailPath.isEmpty())
            emit thumbnailReady(m_file.thumbnailPath);
    }
    emit inputFileChanged();
    Logger::instance()->log(Logger::Info, "WatermarkProcessor", __FUNCTION__, __FILE__, __LINE__,
        QStringLiteral("Input file: %1 (%2, %3x%4)").arg(fi.fileName(), type).arg(m_file.width).arg(m_file.height));
}
void WatermarkProcessor::clearInputFile() {
    if (!m_file.thumbnailPath.isEmpty()) QFile::remove(m_file.thumbnailPath);
    m_file = InputFile{};
    emit inputFileChanged();
}
void WatermarkProcessor::setWatermarkSettings(const QVariantMap &s) {
    m_settings.type = s.value("type", "text").toString();
    m_settings.text = s.value("text").toString();
    m_settings.fontFamily = s.value("fontFamily").toString();
    m_settings.fontSize = s.value("fontSize", 48).toInt();
    m_settings.textColor = s.value("textColor").value<QColor>();
    m_settings.textOpacity = s.value("textOpacity", 1.0).toDouble();
    m_settings.imagePath = s.value("imagePath").toString();
    m_settings.opacity = s.value("opacity", 1.0).toDouble();
    m_settings.imageScale = s.value("imageScale", 0.3).toDouble();
    m_settings.rotation = s.value("rotation", 0.0).toDouble();
    m_settings.posX = s.value("posX", 0.5).toDouble();
    m_settings.posY = s.value("posY", 0.5).toDouble();
    m_settings.batchMode = s.value("batchMode", false).toBool();
    m_settings.hSpacing = s.value("hSpacing", 0.5).toDouble();
    m_settings.vSpacing = s.value("vSpacing", 0.5).toDouble();
}

// ─── Preview generation (方案 A: QPainter layer at capped resolution) ───

QString WatermarkProcessor::generatePreview(const QString &filePath, const QVariantMap &settings) {
    WatermarkSettings s;
    s.type = settings.value("type", "text").toString();
    s.text = settings.value("text").toString();
    s.fontFamily = settings.value("fontFamily").toString();
    s.fontSize = settings.value("fontSize", 48).toInt();
    s.textColor = settings.value("textColor").value<QColor>();
    s.textOpacity = settings.value("textOpacity", 1.0).toDouble();
    s.imagePath = settings.value("imagePath").toString();
    s.opacity = settings.value("opacity", 1.0).toDouble();
    s.imageScale = settings.value("imageScale", 0.3).toDouble();
    s.rotation = settings.value("rotation", 0.0).toDouble();
    s.posX = settings.value("posX", 0.5).toDouble();
    s.posY = settings.value("posY", 0.5).toDouble();
    s.batchMode = settings.value("batchMode", false).toBool();
    s.hSpacing = settings.value("hSpacing", 0.5).toDouble();
    s.vSpacing = settings.value("vSpacing", 0.5).toDouble();

    const QSize mediaSize = probeDimensions(filePath);
    if (mediaSize.width() <= 0 || mediaSize.height() <= 0) return {};

    // Cap preview to max 800px on the longer side
    const int maxDim = 800;
    QSize previewSize = mediaSize;
    double scale = 1.0;
    if (mediaSize.width() > maxDim || mediaSize.height() > maxDim) {
        scale = qMin(static_cast<double>(maxDim) / mediaSize.width(),
                     static_cast<double>(maxDim) / mediaSize.height());
        previewSize = QSize(
            qMax(static_cast<int>(mediaSize.width() * scale), 1),
            qMax(static_cast<int>(mediaSize.height() * scale), 1));
    }
    // Scale font size proportionally for preview
    WatermarkSettings scaled = s;
    scaled.fontSize = qMax(static_cast<int>(s.fontSize * scale), 4);
    // Scale image watermark size proportionally
    // (imageScale is a ratio relative to media, so it stays the same)

    return renderWatermarkLayer(previewSize, scaled);
}

// ─── Watermark layer rendering (QPainter) ───

QString WatermarkProcessor::renderWatermarkLayer(const QSize &size, const WatermarkSettings &s) {
    QImage layer(size, QImage::Format_ARGB32_Premultiplied);
    layer.fill(Qt::transparent);
    QPainter painter(&layer);
    painter.setRenderHint(QPainter::Antialiasing);
    painter.setRenderHint(QPainter::TextAntialiasing);

    if (s.type == "text") {
        QFont font(s.fontFamily, s.fontSize);
        painter.setFont(font);
        painter.setPen(s.textColor);
        painter.setOpacity(s.textOpacity);

        if (s.batchMode) {
            QFontMetrics fm(font);
            const int textW = qMax(fm.horizontalAdvance(s.text), 1);
            const int textH = qMax(fm.height(), 1);
            const int stepX = qMax(static_cast<int>(textW * (1.0 + s.hSpacing)), 1);
            const int stepY = qMax(static_cast<int>(textH * (1.0 + s.vSpacing)), 1);
            for (int y = 0; y < size.height() + textH; y += stepY) {
                for (int x = 0; x < size.width() + textW; x += stepX) {
                    painter.save();
                    painter.translate(x, y);
                    if (s.rotation != 0.0) painter.rotate(s.rotation);
                    painter.drawText(0, textH - fm.descent(), s.text);
                    painter.restore();
                }
            }
        } else {
            const int px = static_cast<int>(s.posX * size.width());
            const int py = static_cast<int>(s.posY * size.height());
            painter.save();
            painter.translate(px, py);
            if (s.rotation != 0.0) painter.rotate(s.rotation);
            QFontMetrics fm(font);
            const int textW = fm.horizontalAdvance(s.text);
            const int textH = fm.height();
            painter.drawText(-textW / 2, textH / 4, s.text);
            painter.restore();
        }
    } else if (s.type == "image") {
        QImage wmImg(s.imagePath);
        if (!wmImg.isNull()) {
            const int scaledW = qMax(static_cast<int>(wmImg.width() * s.imageScale), 1);
            const int scaledH = qMax(static_cast<int>(wmImg.height() * s.imageScale), 1);
            wmImg = wmImg.scaled(scaledW, scaledH, Qt::KeepAspectRatio, Qt::SmoothTransformation);
            painter.save();
            const int px = static_cast<int>(s.posX * size.width());
            const int py = static_cast<int>(s.posY * size.height());
            painter.translate(px, py);
            if (s.rotation != 0.0) painter.rotate(s.rotation);
            painter.setOpacity(s.opacity);
            painter.drawImage(-wmImg.width() / 2, -wmImg.height() / 2, wmImg);
            painter.restore();
        }
    }
    painter.end();

    const QString layerPath = QDir::tempPath() + "/sepkit_wm_layer_"
        + QUuid::createUuid().toString(QUuid::Id128) + ".png";
    if (!layer.save(layerPath, "PNG")) return {};
    return layerPath;
}

// ─── Processing ───

void WatermarkProcessor::startProcessing() {
    if (m_file.path.isEmpty()) return;
    if (isRunning()) return;
    if (ffmpegPath().isEmpty()) {
        Logger::instance()->log(Logger::Error, "WatermarkProcessor", __FUNCTION__, __FILE__, __LINE__,
            "FFmpeg not found.");
        return;
    }
    m_cancelled = false; m_progress = 0.0;
    emit progressChanged(); emit isRunningChanged();

    if (!m_process) {
        m_process = new QProcess(this);
        QObject::connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &WatermarkProcessor::onProcessFinished);
        QObject::connect(m_process, &QProcess::errorOccurred,
            this, &WatermarkProcessor::onProcessError);
        QObject::connect(m_process, &QProcess::readyReadStandardError,
            this, &WatermarkProcessor::onReadyReadStderr);
    }

    m_currentDuration = probeDuration(m_file.path);

    QSize dims(m_file.width, m_file.height);
    if (dims.width() <= 0 || dims.height() <= 0) {
        Logger::instance()->log(Logger::Error, "WatermarkProcessor", __FUNCTION__, __FILE__, __LINE__,
            "Invalid media dimensions.");
        resetState(); emit processingFinished(false, {}); return;
    }
    const QString layerPath = renderWatermarkLayer(dims, m_settings);
    if (layerPath.isEmpty()) {
        Logger::instance()->log(Logger::Error, "WatermarkProcessor", __FUNCTION__, __FILE__, __LINE__,
            "Failed to render watermark layer.");
        resetState(); emit processingFinished(false, {}); return;
    }
    m_tempFiles.append(layerPath);

    const QFileInfo fi(m_file.path);
    const QString outPath = m_outputDir + "/" + fi.completeBaseName() + "_watermarked." + fi.suffix();
    m_process->start(ffmpegPath(), buildOverlayArgs(outPath, layerPath));
}
void WatermarkProcessor::cancelProcessing() {
    m_cancelled = true;
    if (m_process && m_process->state() != QProcess::NotRunning) {
        m_process->kill(); m_process->waitForFinished(3000);
    }
    if (m_probeProcess && m_probeProcess->state() != QProcess::NotRunning) {
        m_probeProcess->kill(); m_probeProcess->waitForFinished(3000);
    }
    resetState(); cleanupTempFiles();
    Logger::instance()->log(Logger::Info, "WatermarkProcessor", __FUNCTION__, __FILE__, __LINE__,
        "Processing cancelled.");
}

// ─── FFmpeg args ───

QStringList WatermarkProcessor::buildOverlayArgs(const QString &outPath, const QString &layerPath) {
    QStringList args;
    args << "-y" << "-i" << m_file.path << "-i" << layerPath;
    args << "-filter_complex" << "[1:v]format=rgba[wm];[0:v][wm]overlay=0:0";
    if (m_file.type == "video") {
        args << "-c:v" << "libx264" << "-crf" << "16" << "-preset" << "medium";
        args << "-c:a" << "copy";
    } else {
        args << "-q:v" << "1";
    }
    args << outPath;
    return args;
}

// ─── Probing ───

QSize WatermarkProcessor::probeDimensions(const QString &path) {
    QProcess probe;
    QStringList args;
    args << "-v" << "error" << "-select_streams" << "v:0"
         << "-show_entries" << "stream=width,height" << "-of" << "csv=p=0" << path;
    probe.start(ffprobePath(), args);
    if (!probe.waitForFinished(5000)) return {};
    const QString out = QString::fromUtf8(probe.readAllStandardOutput()).trimmed();
    const QStringList parts = out.split(",");
    if (parts.size() >= 2) {
        bool wOk, hOk;
        int w = parts[0].toInt(&wOk), h = parts[1].toInt(&hOk);
        if (wOk && hOk) return QSize(w, h);
    }
    return {};
}
double WatermarkProcessor::probeDuration(const QString &path) {
    if (!m_probeProcess) m_probeProcess = new QProcess(this);
    QStringList args;
    args << "-v" << "error" << "-show_entries" << "format=duration" << "-of" << "csv=p=0" << path;
    m_probeProcess->start(ffprobePath(), args);
    if (!m_probeProcess->waitForFinished(10000)) return 0.0;
    bool ok; double d = QString::fromUtf8(m_probeProcess->readAllStandardOutput()).trimmed().toDouble(&ok);
    return ok ? d : 0.0;
}
QString WatermarkProcessor::extractFirstFrame(const QString &videoPath) {
    const QString thumbPath = QDir::tempPath() + "/sepkit_wm_thumb_"
        + QUuid::createUuid().toString(QUuid::Id128) + ".png";
    QProcess extract;
    QStringList args;
    args << "-y" << "-i" << videoPath << "-vframes" << "1" << "-q:v" << "2" << thumbPath;
    extract.start(ffmpegPath(), args);
    if (!extract.waitForFinished(15000)) return {};
    if (extract.exitStatus() != QProcess::NormalExit || extract.exitCode() != 0) return {};
    return QFileInfo::exists(thumbPath) ? thumbPath : QString();
}

// ─── Progress ───

void WatermarkProcessor::parseProgress(const QString &line) {
    if (m_currentDuration <= 0.0) return;
    static const QRegularExpression re(R"(time=(\d+):(\d+):(\d+)\.(\d+))");
    auto m = re.match(line); if (!m.hasMatch()) return;
    double elapsed = m.captured(1).toInt()*3600.0 + m.captured(2).toInt()*60.0
        + m.captured(3).toInt() + m.captured(4).toDouble()/100.0;
    m_progress = qMin(elapsed / m_currentDuration, 0.99);
    emit progressChanged();
}
void WatermarkProcessor::onReadyReadStderr() {
    const QString data = QString::fromUtf8(m_process->readAllStandardError());
    for (const QString &line : data.split("\r\n", Qt::SkipEmptyParts)) {
        parseProgress(line);
        if (!line.trimmed().isEmpty())
            Logger::instance()->info("WatermarkProcessor", "onReadyReadStderr", line);
    }
}
void WatermarkProcessor::onProcessFinished(int exitCode, QProcess::ExitStatus status) {
    if (m_cancelled) return;
    const QFileInfo fi(m_file.path);
    const QString outPath = m_outputDir + "/" + fi.completeBaseName() + "_watermarked." + fi.suffix();
    if (status == QProcess::NormalExit && exitCode == 0) {
        m_progress = 1.0; emit progressChanged();
        Logger::instance()->log(Logger::Info, "WatermarkProcessor", __FUNCTION__, __FILE__, __LINE__,
            QStringLiteral("%1 done.").arg(fi.fileName()));
        resetState();
        emit processingFinished(true, outPath);
    } else {
        Logger::instance()->log(Logger::Error, "WatermarkProcessor", __FUNCTION__, __FILE__, __LINE__,
            QStringLiteral("%1 failed (exit %2).").arg(fi.fileName()).arg(exitCode));
        resetState();
        emit processingFinished(false, {});
    }
    cleanupTempFiles();
}
void WatermarkProcessor::onProcessError(QProcess::ProcessError) {
    if (!m_cancelled)
        Logger::instance()->log(Logger::Error, "WatermarkProcessor", __FUNCTION__, __FILE__, __LINE__,
            m_process->errorString());
}

void WatermarkProcessor::resetState() {
    m_progress = 0.0; m_currentDuration = 0.0; m_cancelled = false;
    emit progressChanged(); emit isRunningChanged();
}
void WatermarkProcessor::cleanupTempFiles() {
    for (const QString &path : m_tempFiles) QFile::remove(path);
    m_tempFiles.clear();
}
