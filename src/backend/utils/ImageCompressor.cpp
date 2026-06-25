#include "ImageCompressor.h"
#include "Logger.h"
#include <QCoreApplication>
#include <QDir>
#include <QFileInfo>
#include <QRegularExpression>
#include <QStandardPaths>

static const QString FFMPEG_DIR = QStringLiteral("ffmpeg-2026-06-08-git-6028720d70-full_build");

QString ImageCompressor::ffmpegPath() {
    const QString appDir = QCoreApplication::applicationDirPath();
    const QString devPath = appDir + "/../../third_party/" + FFMPEG_DIR + "/bin/ffmpeg.exe";
    if (QFileInfo::exists(devPath)) return QFileInfo(devPath).absoluteFilePath();
    const QString prodPath = appDir + "/bin/" + FFMPEG_DIR + "/ffmpeg.exe";
    if (QFileInfo::exists(prodPath)) return QFileInfo(prodPath).absoluteFilePath();
    return {};
}
QString ImageCompressor::ffprobePath() {
    const QString appDir = QCoreApplication::applicationDirPath();
    const QString devPath = appDir + "/../../third_party/" + FFMPEG_DIR + "/bin/ffprobe.exe";
    if (QFileInfo::exists(devPath)) return QFileInfo(devPath).absoluteFilePath();
    const QString prodPath = appDir + "/bin/" + FFMPEG_DIR + "/ffprobe.exe";
    if (QFileInfo::exists(prodPath)) return QFileInfo(prodPath).absoluteFilePath();
    return {};
}

static QString detectType(const QString &path) {
    const QString ext = QFileInfo(path).suffix().toLower();
    static const QStringList imageExts = {
        "jpg","jpeg","png","bmp","webp","gif","tiff","tif",
        "jp2","j2k","dpx","exr","hdr","rgbe",
        "fits","fit","pam","pbm","pgm","ppm","pfm","phm","pgmyuv",
        "sgi","rgb","rgba","ras","sun",
        "tga","xbm","xwd","pcx","wbmp",
        "apng","avif"
    };
    if (imageExts.contains(ext)) return QStringLiteral("image");
    return QStringLiteral("unknown");
}
static QString formatSize(qint64 bytes) {
    if (bytes < 1024) return QString::number(bytes) + " B";
    if (bytes < 1024*1024) return QString::number(bytes/1024.0,'f',1) + " KB";
    if (bytes < 1024LL*1024*1024) return QString::number(bytes/(1024.0*1024.0),'f',1) + " MB";
    return QString::number(bytes/(1024.0*1024.0*1024.0),'f',2) + " GB";
}

ImageCompressor::ImageCompressor(QObject *parent) : QObject(parent) {
    m_outputDir = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
}
ImageCompressor::~ImageCompressor() {
    if (m_process) { m_process->kill(); m_process->waitForFinished(3000); }
    if (m_probeProcess) { m_probeProcess->kill(); m_probeProcess->waitForFinished(3000); }
}

QVariantList ImageCompressor::files() const {
    QVariantList list; list.reserve(m_files.size());
    for (const auto &f : m_files) list.append(fileToVariant(f));
    return list;
}
double ImageCompressor::progress() const { return m_progress; }
int ImageCompressor::currentFileIndex() const { return m_currentIndex; }
bool ImageCompressor::isRunning() const { return m_currentIndex >= 0 && !m_cancelled; }
QString ImageCompressor::outputDir() const { return m_outputDir; }
void ImageCompressor::setOutputDir(const QString &dir) { if (m_outputDir != dir) { m_outputDir = dir; emit outputDirChanged(); } }

void ImageCompressor::addFiles(const QStringList &paths) {
    for (const QString &path : paths) {
        const QFileInfo fi(path); if (!fi.exists() || !fi.isFile()) continue;
        const QString type = detectType(path); if (type == "unknown") continue;
        const bool dup = std::any_of(m_files.begin(), m_files.end(),
            [&](const FileEntry &f) { return f.path == fi.absoluteFilePath(); });
        if (dup) continue;
        FileEntry e; e.path = fi.absoluteFilePath(); e.type = type;
        e.fileSize = fi.size(); e.compressionQuality = 5;
        e.status = QStringLiteral("pending");
        m_files.append(e);
    }
    emit filesChanged();
}
void ImageCompressor::removeFile(int index) {
    if (index >= 0 && index < m_files.size()) { m_files.removeAt(index); emit filesChanged(); }
}
void ImageCompressor::setCompressionQuality(int index, int quality) {
    if (index >= 0 && index < m_files.size()) {
        int q = qBound(0, quality, 10);
        if (m_files[index].compressionQuality != q) {
            m_files[index].compressionQuality = q;
            m_files[index].status = QStringLiteral("pending");
            // Silent write: no filesChanged() here.
            // The Slider tracks its own value; the numeric label reads from the Slider directly.
            // Only applyQualityToAll() and processing status changes emit filesChanged().
        }
    }
}
void ImageCompressor::applyQualityToAll(int quality) {
    int q = qBound(0, quality, 10);
    for (auto &f : m_files) {
        f.compressionQuality = q; f.status = QStringLiteral("pending");
    }
    emit filesChanged();
}

void ImageCompressor::startCompression() {
    if (m_currentIndex >= 0 || m_files.isEmpty()) return;
    if (ffmpegPath().isEmpty()) {
        Logger::instance()->log(Logger::Error, "ImageCompressor", __FUNCTION__, __FILE__, __LINE__,
            "FFmpeg not found."); return;
    }
    m_cancelled = false; m_successCount = 0; m_failCount = 0; m_progress = 0.0;
    for (auto &f : m_files) if (f.status != "done") f.status = QStringLiteral("pending");
    m_currentIndex = 0;
    emit filesChanged(); emit isRunningChanged(); emit progressChanged(); emit currentFileIndexChanged();
    if (!m_process) {
        m_process = new QProcess(this);
        QObject::connect(m_process, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished),
            this, &ImageCompressor::onProcessFinished);
        QObject::connect(m_process, &QProcess::errorOccurred,
            this, &ImageCompressor::onProcessError);
        QObject::connect(m_process, &QProcess::readyReadStandardError,
            this, &ImageCompressor::onReadyReadStderr);
    }
    convertNext();
}
void ImageCompressor::cancelCompression() {
    m_cancelled = true;
    if (m_process && m_process->state() != QProcess::NotRunning) {
        m_process->kill(); m_process->waitForFinished(3000);
    }
    if (m_probeProcess && m_probeProcess->state() != QProcess::NotRunning) {
        m_probeProcess->kill(); m_probeProcess->waitForFinished(3000);
    }
    resetState();
    Logger::instance()->log(Logger::Info, "ImageCompressor", __FUNCTION__, __FILE__, __LINE__,
        "Compression cancelled.");
}
void ImageCompressor::convertNext() {
    if (m_cancelled) { resetState(); return; }
    while (m_currentIndex < m_files.size()) {
        const auto &e = m_files[m_currentIndex];
        if (e.type != "unknown" && e.status != "done") break;
        m_currentIndex++;
    }
    if (m_currentIndex >= m_files.size()) {
        Logger::instance()->log(Logger::Info, "ImageCompressor", __FUNCTION__, __FILE__, __LINE__,
            QStringLiteral("Complete: %1 ok, %2 failed.").arg(m_successCount).arg(m_failCount));
        emit compressionFinished(m_successCount, m_failCount);
        resetState(); return;
    }
    updateFileStatus(m_currentIndex, "converting");
    emit currentFileIndexChanged();
    Logger::instance()->log(Logger::Info, "ImageCompressor", __FUNCTION__, __FILE__, __LINE__,
        QStringLiteral("Compressing: %1").arg(QFileInfo(m_files[m_currentIndex].path).fileName()));

    m_currentDuration = probeDuration(m_files[m_currentIndex].path);
    const QFileInfo fi(m_files[m_currentIndex].path);
    const QString outPath = m_outputDir + "/" + fi.completeBaseName()
        + "_compressed." + fi.suffix();
    m_process->start(ffmpegPath(), buildFFmpegArgs(m_files[m_currentIndex], outPath));
}

// ─── Quality mapping (0-10 slider → format-aware ffmpeg params) ───
// Slider 0 = min compression (highest quality), 10 = max compression (lowest quality)
static void appendQualityArgs(QStringList &args, const QString &ext, int slider) {
    const QString fmt = ext.toLower();
    // ── Inverse: lower value = higher quality ──
    if (fmt == "jpg" || fmt == "jpeg" || fmt == "jpe") {
        // mjpeg encoder: -q:v 1 (best) … 31 (worst). Map 0→2, 10→31
        int q = qBound(1, 2 + slider * 29 / 10, 31);
        args << "-q:v" << QString::number(q);
    }
    else if (fmt == "jp2" || fmt == "j2k") {
        // JPEG 2000: -q:v 1 (best) … ~30. Same inverse range
        int q = qBound(1, 2 + slider * 28 / 10, 30);
        args << "-q:v" << QString::number(q);
    }
    // ── Direct: higher value = higher quality ──
    else if (fmt == "webp") {
        // libwebp: -q:v 0 (worst) … 100 (best). Map 0→100, 10→0
        int q = qBound(0, 100 - slider * 10, 100);
        args << "-q:v" << QString::number(q);
    }
    // ── CRF-based (inverse, lower = better) ──
    else if (fmt == "avif") {
        // libaom-av1: -crf 0 (lossless) … 63 (worst). Map 0→5, 10→63
        int crf = qBound(0, 5 + slider * 58 / 10, 63);
        args << "-c:v" << "libaom-av1" << "-crf" << QString::number(crf);
    }
    // ── Lossless with compression level ──
    else if (fmt == "png") {
        // -compression_level 0 (none) … 9 (max). Map 0→0, 10→9
        int level = qBound(0, slider * 9 / 10, 9);
        args << "-compression_level" << QString::number(level);
    }
    else if (fmt == "tiff" || fmt == "tif") {
        // TIFF: -compression_algo. Map slider 0→raw, 5→lzw, 10→deflate
        if (slider <= 2)      args << "-compression_algo" << "raw";
        else if (slider <= 6) args << "-compression_algo" << "lzw";
        else                  args << "-compression_algo" << "deflate";
    }
    // ── Default fallback ──
    else {
        int q = qBound(1, 1 + slider * 3, 31);
        args << "-q:v" << QString::number(q);
    }
}

QStringList ImageCompressor::buildFFmpegArgs(const FileEntry &entry, const QString &outPath) {
    QStringList args; args << "-y" << "-i" << entry.path;
    const QString ext = QFileInfo(outPath).suffix();
    appendQualityArgs(args, ext, entry.compressionQuality);
    args << outPath;
    return args;
}

double ImageCompressor::probeDuration(const QString &path) {
    // Images process near-instantly; probe is lightweight and we use it for optional progress
    if (!m_probeProcess) m_probeProcess = new QProcess(this);
    QStringList args; args << "-v" << "error" << "-show_entries" << "format=duration"
        << "-of" << "csv=p=0" << path;
    m_probeProcess->start(ffprobePath(), args);
    if (!m_probeProcess->waitForFinished(5000)) return 0.0;
    bool ok; double d = QString::fromUtf8(m_probeProcess->readAllStandardOutput()).trimmed().toDouble(&ok);
    return ok ? d : 0.0;
}
void ImageCompressor::parseProgress(const QString &line) {
    if (m_currentDuration <= 0.0) return;
    static const QRegularExpression re(R"(time=(\d+):(\d+):(\d+)\.(\d+))");
    auto m = re.match(line); if (!m.hasMatch()) return;
    double elapsed = m.captured(1).toInt()*3600.0 + m.captured(2).toInt()*60.0
        + m.captured(3).toInt() + m.captured(4).toDouble()/100.0;
    m_fileProgress = qMin(elapsed / m_currentDuration, 0.99);
    if (!m_files.isEmpty()) m_progress = (m_currentIndex + m_fileProgress) / m_files.size();
    emit progressChanged();
}

void ImageCompressor::onReadyReadStderr() {
    const QString data = QString::fromUtf8(m_process->readAllStandardError());
    for (const QString &line : data.split("\r\n", Qt::SkipEmptyParts)) {
        parseProgress(line);
        if (!line.trimmed().isEmpty())
            Logger::instance()->info("ImageCompressor", "onReadyReadStderr", line);
    }
}
void ImageCompressor::onProcessFinished(int exitCode, QProcess::ExitStatus status) {
    if (m_cancelled) return;
    if (status == QProcess::NormalExit && exitCode == 0) {
        m_successCount++; updateFileStatus(m_currentIndex, "done");
        m_fileProgress = 1.0;
        if (!m_files.isEmpty()) m_progress = double(m_currentIndex + 1) / m_files.size();
        emit progressChanged();
    } else {
        m_failCount++; updateFileStatus(m_currentIndex, "failed");
    }
    m_currentIndex++; convertNext();
}
void ImageCompressor::onProcessError(QProcess::ProcessError) {
    if (!m_cancelled)
        Logger::instance()->log(Logger::Error, "ImageCompressor", __FUNCTION__, __FILE__, __LINE__,
            m_process->errorString());
}

void ImageCompressor::resetState() {
    m_currentIndex = -1; m_progress = 0.0; m_fileProgress = 0.0;
    m_currentDuration = 0.0; m_cancelled = false;
    for (auto &f : m_files)
        if (f.status != "done" && f.status != "failed") f.status = QStringLiteral("pending");
    emit filesChanged(); emit isRunningChanged(); emit progressChanged(); emit currentFileIndexChanged();
}
void ImageCompressor::updateFileStatus(int i, const QString &s) {
    if (i >= 0 && i < m_files.size() && m_files[i].status != s) {
        m_files[i].status = s; emit filesChanged();
    }
}
QVariantMap ImageCompressor::fileToVariant(const FileEntry &e) const {
    QVariantMap m;
    m["path"] = e.path; m["fileName"] = QFileInfo(e.path).fileName();
    m["type"] = e.type; m["fileSize"] = e.fileSize;
    m["fileSizeText"] = formatSize(e.fileSize);
    m["compressionQuality"] = e.compressionQuality;
    m["status"] = e.status;
    return m;
}
