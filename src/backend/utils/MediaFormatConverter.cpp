#include "MediaFormatConverter.h"
#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QRegularExpression>
#include <QStandardPaths>

static const QString FFMPEG_DIR = QStringLiteral("ffmpeg-2026-06-08-git-6028720d70-full_build");

QString MediaFormatConverter::ffmpegPath() {
    const QString appDir = QCoreApplication::applicationDirPath();
    const QString devPath = appDir + "/../../third_party/" + FFMPEG_DIR + "/bin/ffmpeg.exe";
    if (QFileInfo::exists(devPath)) return QFileInfo(devPath).absoluteFilePath();
    const QString prodPath = appDir + "/bin/" + FFMPEG_DIR + "/ffmpeg.exe";
    if (QFileInfo::exists(prodPath)) return QFileInfo(prodPath).absoluteFilePath();
    return {};
}
QString MediaFormatConverter::ffprobePath() {
    const QString appDir = QCoreApplication::applicationDirPath();
    const QString devPath = appDir + "/../../third_party/" + FFMPEG_DIR + "/bin/ffprobe.exe";
    if (QFileInfo::exists(devPath)) return QFileInfo(devPath).absoluteFilePath();
    const QString prodPath = appDir + "/bin/" + FFMPEG_DIR + "/ffprobe.exe";
    if (QFileInfo::exists(prodPath)) return QFileInfo(prodPath).absoluteFilePath();
    return {};
}

static QString detectType(const QString &path) {
    const QString ext = QFileInfo(path).suffix().toLower();
    static const QStringList audioExts = {"mp3","wav","flac","aac","ogg","wma","m4a","opus","aiff","alac","ac3","dts","amr"};
    static const QStringList videoExts = {"mp4","avi","mkv","mov","webm","wmv","flv","m4v","mpeg","mpg","ts","mts","3gp","ogv","divx"};
    static const QStringList imageExts = {"jpg","jpeg","png","bmp","webp","gif","tiff","tif","ico","svg"};
    if (audioExts.contains(ext)) return QStringLiteral("audio");
    if (videoExts.contains(ext)) return QStringLiteral("video");
    if (imageExts.contains(ext)) return QStringLiteral("image");
    return QStringLiteral("unknown");
}
static QString formatForType(const QString &type) {
    if (type == "audio") return QStringLiteral("mp3");
    if (type == "video") return QStringLiteral("mp4");
    if (type == "image") return QStringLiteral("png");
    return {};
}
static QString formatSize(qint64 bytes) {
    if (bytes < 1024) return QString::number(bytes) + " B";
    if (bytes < 1024*1024) return QString::number(bytes/1024.0,'f',1) + " KB";
    if (bytes < 1024LL*1024*1024) return QString::number(bytes/(1024.0*1024.0),'f',1) + " MB";
    return QString::number(bytes/(1024.0*1024.0*1024.0),'f',2) + " GB";
}

MediaFormatConverter::MediaFormatConverter(QObject *parent) : QObject(parent) {
    m_outputDir = QStandardPaths::writableLocation(QStandardPaths::DownloadLocation);
}
MediaFormatConverter::~MediaFormatConverter() {
    if (m_process) { m_process->kill(); m_process->waitForFinished(3000); }
    if (m_probeProcess) { m_probeProcess->kill(); m_probeProcess->waitForFinished(3000); }
}

QVariantList MediaFormatConverter::files() const {
    QVariantList list; list.reserve(m_files.size());
    for (const auto &f : m_files) list.append(fileToVariant(f));
    return list;
}
double MediaFormatConverter::progress() const { return m_progress; }
int MediaFormatConverter::currentFileIndex() const { return m_currentIndex; }
bool MediaFormatConverter::isRunning() const { return m_currentIndex >= 0 && !m_cancelled; }
QString MediaFormatConverter::outputDir() const { return m_outputDir; }
void MediaFormatConverter::setOutputDir(const QString &dir) { if (m_outputDir != dir) { m_outputDir = dir; emit outputDirChanged(); } }

void MediaFormatConverter::addFiles(const QStringList &paths) {
    for (const QString &path : paths) {
        const QFileInfo fi(path); if (!fi.exists() || !fi.isFile()) continue;
        const QString type = detectType(path); if (type == "unknown") continue;
        const bool dup = std::any_of(m_files.begin(), m_files.end(), [&](const FileEntry &f) { return f.path == fi.absoluteFilePath(); });
        if (dup) continue;
        FileEntry e; e.path = fi.absoluteFilePath(); e.type = type; e.fileSize = fi.size();
        e.targetFormat = formatForType(type); e.status = QStringLiteral("pending"); m_files.append(e);
    }
    emit filesChanged();
}
void MediaFormatConverter::removeFile(int index) { if (index>=0&&index<m_files.size()){m_files.removeAt(index);emit filesChanged();} }
void MediaFormatConverter::setTargetFormat(int index, const QString &format) { if (index>=0&&index<m_files.size()&&m_files[index].targetFormat!=format){m_files[index].targetFormat=format;m_files[index].status=QStringLiteral("pending");emit filesChanged();} }
void MediaFormatConverter::setAudioTrim(int index, const QString &ts, const QString &te) { if (index>=0&&index<m_files.size()){auto&s=m_files[index].audioSettings;s.trimStart=ts;s.trimEnd=te;m_files[index].status=QStringLiteral("pending");emit filesChanged();} }
void MediaFormatConverter::setAudioVolume(int index, double v) { if (index>=0&&index<m_files.size()){m_files[index].audioSettings.volume=v;m_files[index].status=QStringLiteral("pending");emit filesChanged();} }
void MediaFormatConverter::setAudioChannels(int index, int c) { if (index>=0&&index<m_files.size()){m_files[index].audioSettings.channels=c;m_files[index].status=QStringLiteral("pending");emit filesChanged();} }
void MediaFormatConverter::setAudioSampleRate(int index, int sr) { if (index>=0&&index<m_files.size()){m_files[index].audioSettings.sampleRate=sr;m_files[index].status=QStringLiteral("pending");emit filesChanged();} }
void MediaFormatConverter::setVideoTrim(int index, const QString &ts, const QString &te) { if (index>=0&&index<m_files.size()){auto&s=m_files[index].videoSettings;s.trimStart=ts;s.trimEnd=te;m_files[index].status=QStringLiteral("pending");emit filesChanged();} }
void MediaFormatConverter::setVideoCodec(int index, const QString &c) { if (index>=0&&index<m_files.size()){m_files[index].videoSettings.videoCodec=c;m_files[index].status=QStringLiteral("pending");emit filesChanged();} }
void MediaFormatConverter::applyAudioSettingsToAll(const QVariantMap &s) {
    for (auto &f : m_files) { if (f.type!="audio") continue; auto &a=f.audioSettings;
        a.trimStart=s.value("trimStart",a.trimStart).toString(); a.trimEnd=s.value("trimEnd",a.trimEnd).toString();
        a.volume=s.value("volume",a.volume).toDouble(); a.channels=s.value("channels",a.channels).toInt();
        a.sampleRate=s.value("sampleRate",a.sampleRate).toInt(); f.status=QStringLiteral("pending"); }
    emit filesChanged();
}
void MediaFormatConverter::applyVideoSettingsToAll(const QVariantMap &s) {
    for (auto &f : m_files) { if (f.type!="video") continue; auto &v=f.videoSettings;
        v.trimStart=s.value("trimStart",v.trimStart).toString(); v.trimEnd=s.value("trimEnd",v.trimEnd).toString();
        v.videoCodec=s.value("videoCodec",v.videoCodec).toString();
        QVariantMap am = s.value("audioSettings").toMap(); if (!am.isEmpty()) {
            v.audioSettings.trimStart=am.value("trimStart",v.audioSettings.trimStart).toString();
            v.audioSettings.trimEnd=am.value("trimEnd",v.audioSettings.trimEnd).toString();
            v.audioSettings.volume=am.value("volume",v.audioSettings.volume).toDouble();
            v.audioSettings.channels=am.value("channels",v.audioSettings.channels).toInt();
            v.audioSettings.sampleRate=am.value("sampleRate",v.audioSettings.sampleRate).toInt(); }
        f.status=QStringLiteral("pending"); }
    emit filesChanged();
}

// ─── Quality helpers ───
static void appendAudioQuality(QStringList &args, const QString &fmt) {
    const QString f = fmt.toLower();
    if (f=="wav") { args<<"-c:a"<<"pcm_s16le"; }
    else if (f=="flac") { args<<"-c:a"<<"flac"<<"-compression_level"<<"12"; }
    else if (f=="mp3") { args<<"-c:a"<<"libmp3lame"<<"-q:a"<<"0"; }
    else if (f=="aac"||f=="m4a") { args<<"-c:a"<<"aac"<<"-b:a"<<"320k"; }
    else if (f=="ogg") { args<<"-c:a"<<"libvorbis"<<"-q:a"<<"10"; }
    else if (f=="opus") { args<<"-c:a"<<"libopus"<<"-b:a"<<"320k"; }
    else if (f=="wma") { args<<"-c:a"<<"wmav2"<<"-b:a"<<"320k"; }
}
static void appendVideoQuality(QStringList &args, const QString &, bool codecSpecified) {
    if (!codecSpecified) { args<<"-c:v"<<"libx264"<<"-crf"<<"16"<<"-preset"<<"medium"; }
    else { args<<"-crf"<<"16"; }
}
static void appendImageQuality(QStringList &args, const QString &fmt) {
    const QString f = fmt.toLower();
    if (f=="jpg"||f=="jpeg") { args<<"-q:v"<<"1"; }
    else if (f=="webp") { args<<"-lossless"<<"1"<<"-q:v"<<"100"; }
    else if (f=="png") { args<<"-compression_level"<<"0"; }
    else if (f=="tiff"||f=="tif") { args<<"-compression_algo"<<"raw"; }
    else { args<<"-q:v"<<"1"; }
}

QStringList MediaFormatConverter::buildFFmpegArgs(const FileEntry &entry, const QString &outPath) {
    QStringList args; args<<"-y"<<"-i"<<entry.path;
    const AudioSettings &audio = (entry.type=="video") ? entry.videoSettings.audioSettings : entry.audioSettings;
    if (entry.type=="audio") {
        if (!entry.audioSettings.trimStart.isEmpty()) args<<"-ss"<<entry.audioSettings.trimStart;
        if (!entry.audioSettings.trimEnd.isEmpty()) args<<"-to"<<entry.audioSettings.trimEnd;
        if (entry.audioSettings.volume!=0.0) args<<"-af"<<QStringLiteral("volume=%1dB").arg(entry.audioSettings.volume);
        if (entry.audioSettings.channels>0) args<<"-ac"<<QString::number(entry.audioSettings.channels);
        if (entry.audioSettings.sampleRate>0) args<<"-ar"<<QString::number(entry.audioSettings.sampleRate);
        appendAudioQuality(args, entry.targetFormat);
    } else if (entry.type=="video") {
        const VideoSettings &vid = entry.videoSettings;
        if (!vid.trimStart.isEmpty()) args<<"-ss"<<vid.trimStart;
        if (!vid.trimEnd.isEmpty()) args<<"-to"<<vid.trimEnd;
        bool cs = !vid.videoCodec.isEmpty(); if (cs) args<<"-c:v"<<vid.videoCodec;
        appendVideoQuality(args, entry.targetFormat, cs);
        if (audio.volume!=0.0) args<<"-af"<<QStringLiteral("volume=%1dB").arg(audio.volume);
        if (audio.channels>0) args<<"-ac"<<QString::number(audio.channels);
        if (audio.sampleRate>0) args<<"-ar"<<QString::number(audio.sampleRate);
    } else if (entry.type=="image") { appendImageQuality(args, entry.targetFormat); }
    args<<outPath; return args;
}

double MediaFormatConverter::probeDuration(const QString &path) {
    if (!m_probeProcess) m_probeProcess = new QProcess(this);
    QStringList args; args<<"-v"<<"error"<<"-show_entries"<<"format=duration"<<"-of"<<"csv=p=0"<<path;
    m_probeProcess->start(ffprobePath(), args);
    if (!m_probeProcess->waitForFinished(10000)) return 0.0;
    bool ok; double d = QString::fromUtf8(m_probeProcess->readAllStandardOutput()).trimmed().toDouble(&ok);
    return ok ? d : 0.0;
}
void MediaFormatConverter::parseProgress(const QString &line) {
    if (m_currentDuration<=0.0) return;
    static const QRegularExpression re(R"(time=(\d+):(\d+):(\d+)\.(\d+))");
    auto m = re.match(line); if (!m.hasMatch()) return;
    double elapsed = m.captured(1).toInt()*3600.0 + m.captured(2).toInt()*60.0 + m.captured(3).toInt() + m.captured(4).toDouble()/100.0;
    m_fileProgress = qMin(elapsed/m_currentDuration, 0.99);
    if (!m_files.isEmpty()) m_progress = (m_currentIndex + m_fileProgress) / m_files.size();
    emit progressChanged();
}

void MediaFormatConverter::startConversion() {
    if (m_currentIndex>=0||m_files.isEmpty()) return;
    if (ffmpegPath().isEmpty()) { emit logMessage("[Error] FFmpeg not found."); return; }
    m_cancelled=false; m_successCount=0; m_failCount=0; m_progress=0.0; m_logLines.clear(); m_logFilePath.clear();
    for (auto &f : m_files) if (f.status!="done") f.status=QStringLiteral("pending");
    m_currentIndex=0; emit filesChanged(); emit isRunningChanged(); emit progressChanged(); emit currentFileIndexChanged();
    if (!m_process) { m_process=new QProcess(this);
        QObject::connect(m_process,QOverload<int,QProcess::ExitStatus>::of(&QProcess::finished),this,&MediaFormatConverter::onProcessFinished);
        QObject::connect(m_process,&QProcess::errorOccurred,this,&MediaFormatConverter::onProcessError);
        QObject::connect(m_process,&QProcess::readyReadStandardError,this,&MediaFormatConverter::onReadyReadStderr); }
    convertNext();
}
void MediaFormatConverter::cancelConversion() {
    m_cancelled=true; if(m_process&&m_process->state()!=QProcess::NotRunning){m_process->kill();m_process->waitForFinished(3000);}
    if(m_probeProcess&&m_probeProcess->state()!=QProcess::NotRunning){m_probeProcess->kill();m_probeProcess->waitForFinished(3000);}
    resetState(); emit logMessage("[Info] Conversion cancelled.");
}
void MediaFormatConverter::convertNext() {
    if (m_cancelled) { resetState(); return; }
    while (m_currentIndex<m_files.size()) { const auto &e=m_files[m_currentIndex]; if (e.type!="unknown"&&e.status!="done") break; m_currentIndex++; }
    if (m_currentIndex>=m_files.size()) { emit logMessage(QStringLiteral("[Info] Complete: %1 ok, %2 failed.").arg(m_successCount).arg(m_failCount)); emit conversionFinished(m_successCount,m_failCount); resetState(); return; }
    updateFileStatus(m_currentIndex, "converting");
    emit logMessage(QStringLiteral("[Info] Converting: %1").arg(QFileInfo(m_files[m_currentIndex].path).fileName()));
    emit currentFileIndexChanged();
    QString outPath = m_outputDir+"/"+QFileInfo(m_files[m_currentIndex].path).completeBaseName()+"."+m_files[m_currentIndex].targetFormat;
    m_currentDuration = probeDuration(m_files[m_currentIndex].path);
    m_process->start(ffmpegPath(), buildFFmpegArgs(m_files[m_currentIndex], outPath));
}
void MediaFormatConverter::onReadyReadStderr() {
    const QString data = QString::fromUtf8(m_process->readAllStandardError());
    for (const QString &line : data.split("\r\n", Qt::SkipEmptyParts)) { parseProgress(line); if (!line.trimmed().isEmpty()) { m_logLines.append(line); emit logMessage(line); } }
}
void MediaFormatConverter::onProcessFinished(int exitCode, QProcess::ExitStatus status) {
    if (m_cancelled) return;
    if (status==QProcess::NormalExit&&exitCode==0) { m_successCount++; updateFileStatus(m_currentIndex,"done"); m_fileProgress=1.0; if(!m_files.isEmpty())m_progress=double(m_currentIndex+1)/m_files.size(); emit progressChanged(); emit logMessage(QStringLiteral("[OK] %1 done.").arg(QFileInfo(m_files[m_currentIndex].path).fileName())); }
    else { m_failCount++; updateFileStatus(m_currentIndex,"failed"); emit logMessage(QStringLiteral("[Fail] %1 failed (exit %2).").arg(QFileInfo(m_files[m_currentIndex].path).fileName()).arg(exitCode)); }
    m_currentIndex++; convertNext();
}
void MediaFormatConverter::onProcessError(QProcess::ProcessError) { if (!m_cancelled) emit logMessage(QStringLiteral("[Error] %1").arg(m_process->errorString())); }

void MediaFormatConverter::resetState() {
    m_currentIndex=-1; m_progress=0.0; m_fileProgress=0.0; m_currentDuration=0.0; m_cancelled=false;
    for (auto &f : m_files) if (f.status!="done") f.status=QStringLiteral("pending");
    emit filesChanged(); emit isRunningChanged(); emit progressChanged(); emit currentFileIndexChanged();
}
void MediaFormatConverter::updateFileStatus(int i, const QString &s) { if (i>=0&&i<m_files.size()&&m_files[i].status!=s) { m_files[i].status=s; emit filesChanged(); } }

QString MediaFormatConverter::saveLog() const {
    if (m_logLines.isEmpty()) return {};
    QString path = QStandardPaths::writableLocation(QStandardPaths::TempLocation)+"/SepKits_ffmpeg_log.txt";
    QFile f(path); if (f.open(QIODevice::WriteOnly|QIODevice::Truncate)) { f.write(m_logLines.join("\n").toUtf8()); f.close(); return path; }
    return {};
}

QVariantMap MediaFormatConverter::fileToVariant(const FileEntry &e) const {
    QVariantMap m; m["path"]=e.path; m["fileName"]=QFileInfo(e.path).fileName(); m["type"]=e.type;
    m["fileSize"]=e.fileSize; m["fileSizeText"]=formatSize(e.fileSize); m["targetFormat"]=e.targetFormat; m["status"]=e.status;
    QVariantMap am; am["trimStart"]=e.audioSettings.trimStart; am["trimEnd"]=e.audioSettings.trimEnd; am["volume"]=e.audioSettings.volume; am["channels"]=e.audioSettings.channels; am["sampleRate"]=e.audioSettings.sampleRate; m["audioSettings"]=am;
    QVariantMap vm; vm["trimStart"]=e.videoSettings.trimStart; vm["trimEnd"]=e.videoSettings.trimEnd; vm["videoCodec"]=e.videoSettings.videoCodec;
    QVariantMap va; va["trimStart"]=e.videoSettings.audioSettings.trimStart; va["trimEnd"]=e.videoSettings.audioSettings.trimEnd; va["volume"]=e.videoSettings.audioSettings.volume; va["channels"]=e.videoSettings.audioSettings.channels; va["sampleRate"]=e.videoSettings.audioSettings.sampleRate; vm["audioSettings"]=va; m["videoSettings"]=vm;
    return m;
}
