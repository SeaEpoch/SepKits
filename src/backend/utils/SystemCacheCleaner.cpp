#include "SystemCacheCleaner.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QDirIterator>
#include <QFile>
#include <QFileInfo>
#include <QStandardPaths>
#include <QTextStream>
#include <QTimer>

#ifdef Q_OS_WINDOWS
#  include <windows.h>
#  include <shellapi.h>
#  include <sddl.h>
#endif

// ─── Helpers ──────────────────────────────────────────────────────

static bool isWritableDir(const QString &path) {
    const QFileInfo fi(path);
    return fi.isDir() && fi.isWritable();
}

static QString env(const char *name) {
    return QDir::fromNativeSeparators(QString::fromLocal8Bit(qgetenv(name)));
}

static QString userTempPath() {
    return QStandardPaths::writableLocation(QStandardPaths::TempLocation);
}

// ─── Constructor / Destructor ─────────────────────────────────────

SystemCacheCleaner::SystemCacheCleaner(QObject *parent) : QObject(parent) {
    m_model = new CacheCleanerModel(this);
    m_flushTimer = new QTimer(this);
    m_flushTimer->setInterval(100);
    connect(m_flushTimer, &QTimer::timeout, this, &SystemCacheCleaner::flushMessageBuffer);
}

SystemCacheCleaner::~SystemCacheCleaner() {
    m_cancelled.storeRelaxed(1);
    if (m_worker && m_worker->joinable())
        m_worker->join();
}

// ─── Admin ────────────────────────────────────────────────────────

bool SystemCacheCleaner::isRunningAsAdmin() const {
#ifdef Q_OS_WINDOWS
    BOOL isAdmin = FALSE;
    PSID adminGroup = nullptr;
    SID_IDENTIFIER_AUTHORITY ntAuth = SECURITY_NT_AUTHORITY;
    if (AllocateAndInitializeSid(&ntAuth, 2,
                                 SECURITY_BUILTIN_DOMAIN_RID,
                                 DOMAIN_ALIAS_RID_ADMINS,
                                 0, 0, 0, 0, 0, 0, &adminGroup)) {
        CheckTokenMembership(nullptr, adminGroup, &isAdmin);
        FreeSid(adminGroup);
    }
    return isAdmin;
#else
    return true;
#endif
}

void SystemCacheCleaner::requestAdminRelaunch() {
#ifdef Q_OS_WINDOWS
    const auto exe = QCoreApplication::applicationFilePath().toStdWString();
    SHELLEXECUTEINFOW sei = {};
    sei.cbSize = sizeof(sei);
    sei.lpVerb = L"runas";
    sei.lpFile = exe.c_str();
    sei.nShow = SW_SHOWNORMAL;
    if (ShellExecuteExW(&sei))
        QCoreApplication::quit();
#endif
}

// ─── Cancel ───────────────────────────────────────────────────────

void SystemCacheCleaner::cancel() {
    m_cancelled.storeRelaxed(1);
}

// ─── Progress ─────────────────────────────────────────────────────

void SystemCacheCleaner::setProgress(qreal value, const QString &label) {
    QMetaObject::invokeMethod(this, [this, value, label]() {
        m_progressValue = value;
        emit progressValueChanged();
        if (!label.isEmpty())
            emit progressLabelChanged(label);
    }, Qt::QueuedConnection);
}

void SystemCacheCleaner::emitProgress(const QString &msg) {
    QMutexLocker l(&m_mutex);
    m_messageBuffer.append(msg);
}

void SystemCacheCleaner::flushMessageBuffer() {
    QStringList buf;
    {
        QMutexLocker l(&m_mutex);
        if (m_messageBuffer.isEmpty()) return;
        buf.swap(m_messageBuffer);
    }
    emit progressUpdated(buf.join('\n'));
}

// ─── Count (non-destructive) ──────────────────────────────────────

SystemCacheCleaner::Count SystemCacheCleaner::countFiles(
    const QString &path, const QStringList &patterns,
    bool recursive, const QSet<QString> &excludeDirs)
{
    Count c;
    QDir dir(path);
    if (!dir.exists()) return c;

    auto filters = QDir::Files | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System;
    auto itFlags = recursive ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags;

    QDirIterator it(path, patterns, filters, itFlags);
    while (it.hasNext()) {
        if (m_cancelled.loadRelaxed()) return c;
        it.next();

        if (!excludeDirs.isEmpty() && recursive) {
            const auto segs = it.fileInfo().absolutePath().split(QDir::separator());
            bool skip = false;
            for (const auto &seg : segs) {
                if (excludeDirs.contains(seg.toLower())) { skip = true; break; }
            }
            if (skip) continue;
        }

        c.files++;
        c.bytes += it.fileInfo().size();
    }
    return c;
}

// ─── Remove (destructive) ─────────────────────────────────────────

qint64 SystemCacheCleaner::removeFiles(
    const QString &path, const QStringList &patterns,
    bool recursive, const QSet<QString> &excludeDirs,
    bool recreateDir)
{
    qint64 freed = 0;
    QDir dir(path);
    if (!dir.exists()) return 0;

    auto filters = QDir::Files | QDir::NoDotAndDotDot | QDir::Hidden | QDir::System;
    auto itFlags = recursive ? QDirIterator::Subdirectories : QDirIterator::NoIteratorFlags;

    QDirIterator it(path, patterns, filters, itFlags);
    while (it.hasNext()) {
        if (m_cancelled.loadRelaxed()) return freed;
        it.next();
        const QFileInfo &fi = it.fileInfo();

        if (!excludeDirs.isEmpty() && recursive) {
            const auto segs = fi.absolutePath().split(QDir::separator());
            bool skip = false;
            for (const auto &seg : segs) {
                if (excludeDirs.contains(seg.toLower())) { skip = true; break; }
            }
            if (skip) continue;
        }

        const qint64 sz = fi.size();
        if (QFile::remove(fi.absoluteFilePath())) {
            freed += sz; ++m_cleanedCount;
            emitProgress(QStringLiteral("  ✓ %1 (%2)").arg(fi.absoluteFilePath(), formatSize(sz)));
        } else {
            QFile::setPermissions(fi.absoluteFilePath(),
                QFileDevice::ReadOwner | QFileDevice::WriteOwner |
                QFileDevice::ReadUser  | QFileDevice::WriteUser);
            if (QFile::remove(fi.absoluteFilePath())) {
                freed += sz; ++m_cleanedCount;
                emitProgress(QStringLiteral("  ✓ %1 (%2)").arg(fi.absoluteFilePath(), formatSize(sz)));
            } else {
                emitProgress(QStringLiteral("  ✗ %1 (%2)").arg(fi.absoluteFilePath(), formatSize(sz)));
            }
        }
    }

    if (recreateDir && !dir.exists())
        dir.mkpath(QStringLiteral("."));

    return freed;
}

bool SystemCacheCleaner::tryCleanDir(
    const QString &label, const QString &path,
    const QStringList &patterns, bool recursive,
    const QSet<QString> &excludeDirs, bool recreateDir)
{
    if (!QDir(path).exists()) {
        emitProgress(label + QStringLiteral(" Path not found"));
        return false;
    }
    if (!isWritableDir(path)) {
        emitProgress(label + QStringLiteral(" Access denied — run as administrator"));
        return false;
    }
    emitProgress(label + QStringLiteral(" ") + path);
    int before = m_cleanedCount;
    qint64 freed = removeFiles(path, patterns, recursive, excludeDirs, recreateDir);
    m_freedBytes += freed;
    emitProgress(label + QStringLiteral(" Done — %1 files, freed %2")
                     .arg(m_cleanedCount - before).arg(formatSize(freed)));
    return true;
}

// ─── Scan ─────────────────────────────────────────────────────────

void SystemCacheCleaner::startScan() {
    if (m_scanning.loadRelaxed() || m_running.loadRelaxed()) return;

    if (m_worker && m_worker->joinable())
        m_worker->join();
    m_worker.reset();

    m_model->resetAll();
    m_scanning.storeRelaxed(true);
    m_cancelled.storeRelaxed(0);
    emit scanningChanged();

    m_worker = std::make_unique<std::thread>([this]() {
        doScan();
        QMetaObject::invokeMethod(this, [this]() {
            m_scanning.storeRelaxed(false);
            emit scanningChanged();
            emit scanAllCompleted();
        }, Qt::QueuedConnection);
    });
}

void SystemCacheCleaner::doScan() {
    const QString home  = QDir::homePath();
    const QString root  = QDir::rootPath();
    const QString local = env("LOCALAPPDATA");
    const QString roaming = env("APPDATA");
    const QString win   = env("WINDIR");

    // Define: key, label, count-function, emit-key
    struct Step {
        QString key;
        std::function<Count()> fn;
    };

    const QList<Step> steps = {
        // 1
        {QStringLiteral("userTemp"), [&]() -> Count {
            return countFiles(userTempPath(), {QStringLiteral("*")}, true);
        }},
        // 2
        {QStringLiteral("legacyTemp"), [&]() -> Count {
            QString p = home + QStringLiteral("/Local Settings/Temp");
            if (!QDir(p).exists()) return {};
            if (QDir(p).canonicalPath() == QDir(userTempPath()).canonicalPath()) return {};
            return countFiles(p, {QStringLiteral("*")}, true);
        }},
        // 3
        {QStringLiteral("windowsTemp"), [&]() -> Count {
            return countFiles(win + QStringLiteral("/Temp"), {QStringLiteral("*")}, true);
        }},
        // 4
        {QStringLiteral("prefetch"), [&]() -> Count {
            return countFiles(win + QStringLiteral("/Prefetch"), {QStringLiteral("*")}, false,
                              {QStringLiteral("layout.ini")});
        }},
        // 5
        {QStringLiteral("systemDriveJunk"), [&]() -> Count {
            return countFiles(root,
                {QStringLiteral("*.tmp"), QStringLiteral("*._mp"), QStringLiteral("*.log"),
                 QStringLiteral("*.gid"), QStringLiteral("*.chk"), QStringLiteral("*.old")}, false);
        }},
        // 6
        {QStringLiteral("windowsBak"), [&]() -> Count {
            return countFiles(win, {QStringLiteral("*.bak")}, false);
        }},
        // 7
        {QStringLiteral("recycleBin"), [&]() -> Count {
            Count c;
            for (auto &p : {root + QStringLiteral("$Recycle.Bin"),
                            root + QStringLiteral("Recycled")})
                c += countFiles(p, {QStringLiteral("*")}, true);
            return c;
        }},
        // 8
        {QStringLiteral("cookies"), [&]() -> Count {
            Count c;
            for (auto &p : {home + QStringLiteral("/Cookies"),
                            local + QStringLiteral("/Microsoft/Windows/INetCookies"),
                            roaming + QStringLiteral("/Microsoft/Windows/Cookies")})
                c += countFiles(p, {QStringLiteral("*")}, false);
            return c;
        }},
        // 9
        {QStringLiteral("recentFiles"), [&]() -> Count {
            return countFiles(roaming + QStringLiteral("/Microsoft/Windows/Recent"),
                              {QStringLiteral("*")}, false);
        }},
        // 10
        {QStringLiteral("ieTemp"), [&]() -> Count {
            Count c;
            for (auto &p : {home + QStringLiteral("/Local Settings/Temporary Internet Files"),
                            local + QStringLiteral("/Microsoft/Windows/INetCache")})
                c += countFiles(p, {QStringLiteral("*")}, true);
            return c;
        }},
    };

    const int n = steps.size();
    for (int i = 0; i < n; ++i) {
        if (m_cancelled.loadRelaxed()) return;
        setProgress(qreal(i) / n, QStringLiteral("Scanning %1...").arg(steps[i].key));
        Count c = steps[i].fn();
        emitProgress(QStringLiteral("%1: %2 files, %3")
                         .arg(steps[i].key)
                         .arg(c.files)
                         .arg(formatSize(c.bytes)));
        QMetaObject::invokeMethod(m_model, [this, i, c]() {
            m_model->setScanResult(i, c.files, c.bytes);
        }, Qt::QueuedConnection);
    }
    setProgress(1.0, QStringLiteral("Scan complete"));
}

// ─── Cleanup ──────────────────────────────────────────────────────

void SystemCacheCleaner::startCleanup(const QStringList &enabled) {
    if (m_running.loadRelaxed()) return;

    if (m_worker && m_worker->joinable())
        m_worker->join();
    m_worker.reset();

    m_running.storeRelaxed(true);
    m_cancelled.storeRelaxed(0);
    m_cleanedCount = 0;
    m_freedBytes = 0;
    {
        QMutexLocker l(&m_mutex);
        m_messageBuffer.clear();
    }
    m_flushTimer->start();
    emit runningChanged();

    m_worker = std::make_unique<std::thread>([this, enabled]() {
        doCleanup(enabled);
        int n = m_cleanedCount;
        qint64 b = m_freedBytes;
        QMetaObject::invokeMethod(this, [this, n, b]() {
            m_flushTimer->stop();
            flushMessageBuffer();
            m_model->resetAll();
            m_running.storeRelaxed(false);
            setProgress(1.0, QString());
            emit runningChanged();
            emit cleanupFinished(n, b);
        }, Qt::QueuedConnection);
    });
}

void SystemCacheCleaner::doCleanup(const QStringList &enabled) {
    emitProgress(QStringLiteral("=== System Cache Cleanup Started ==="));

    const QString home  = QDir::homePath();
    const QString root  = QDir::rootPath();
    const QString local = env("LOCALAPPDATA");
    const QString roaming = env("APPDATA");
    const QString win   = env("WINDIR");

    const auto on = [&](const QString &k) { return enabled.contains(k); };
    const auto skip = [&](const QString &k) { emitProgress(QStringLiteral("[%1] Skipped").arg(k)); };

    auto enabledKeys = [&]() -> QStringList {
        static const QStringList all = {
            QStringLiteral("userTemp"), QStringLiteral("legacyTemp"),
            QStringLiteral("windowsTemp"), QStringLiteral("prefetch"),
            QStringLiteral("systemDriveJunk"), QStringLiteral("windowsBak"),
            QStringLiteral("recycleBin"), QStringLiteral("cookies"),
            QStringLiteral("recentFiles"), QStringLiteral("ieTemp")
        };
        QStringList out;
        for (auto &k : all) if (on(k)) out.append(k);
        return out;
    };

    const QStringList steps = enabledKeys();
    const int total = qMax(1, steps.size());

    for (int i = 0; i < steps.size(); ++i) {
        if (m_cancelled.loadRelaxed()) return;
        const QString &key = steps[i];
        setProgress(qreal(i) / total, QStringLiteral("Cleaning %1...").arg(key));

        if (key == QStringLiteral("userTemp")) {
            tryCleanDir(QStringLiteral("[User Temp]"), userTempPath(), {QStringLiteral("*")}, true);
        } else if (key == QStringLiteral("legacyTemp")) {
            QString p = home + QStringLiteral("/Local Settings/Temp");
            if (QDir(p).exists() && QDir(p).canonicalPath() != QDir(userTempPath()).canonicalPath())
                tryCleanDir(QStringLiteral("[Legacy Temp]"), p, {QStringLiteral("*")}, true);
            else
                emitProgress(QStringLiteral("[Legacy Temp] No separate legacy temp"));
        } else if (key == QStringLiteral("windowsTemp")) {
            tryCleanDir(QStringLiteral("[Windows Temp]"), win + QStringLiteral("/Temp"),
                        {QStringLiteral("*")}, true, {}, true);
        } else if (key == QStringLiteral("prefetch")) {
            tryCleanDir(QStringLiteral("[Prefetch]"), win + QStringLiteral("/Prefetch"),
                        {QStringLiteral("*")}, false, {QStringLiteral("layout.ini")});
        } else if (key == QStringLiteral("systemDriveJunk")) {
            tryCleanDir(QStringLiteral("[System Drive Root]"), root,
                        {QStringLiteral("*.tmp"), QStringLiteral("*._mp"), QStringLiteral("*.log"),
                         QStringLiteral("*.gid"), QStringLiteral("*.chk"), QStringLiteral("*.old")}, false);
        } else if (key == QStringLiteral("windowsBak")) {
            tryCleanDir(QStringLiteral("[Windows *.bak]"), win, {QStringLiteral("*.bak")}, false);
        } else if (key == QStringLiteral("recycleBin")) {
            for (auto &p : {root + QStringLiteral("$Recycle.Bin"),
                            root + QStringLiteral("Recycled")}) {
                if (QDir(p).exists())
                    tryCleanDir(QStringLiteral("[Recycle Bin]"), p, {QStringLiteral("*")}, true);
            }
        } else if (key == QStringLiteral("cookies")) {
            for (auto &p : {home + QStringLiteral("/Cookies"),
                            local + QStringLiteral("/Microsoft/Windows/INetCookies"),
                            roaming + QStringLiteral("/Microsoft/Windows/Cookies")}) {
                if (QDir(p).exists())
                    tryCleanDir(QStringLiteral("[Cookies]"), p, {QStringLiteral("*")}, false);
            }
        } else if (key == QStringLiteral("recentFiles")) {
            tryCleanDir(QStringLiteral("[Recent Files]"),
                        roaming + QStringLiteral("/Microsoft/Windows/Recent"),
                        {QStringLiteral("*")}, false);
        } else if (key == QStringLiteral("ieTemp")) {
            for (auto &p : {home + QStringLiteral("/Local Settings/Temporary Internet Files"),
                            local + QStringLiteral("/Microsoft/Windows/INetCache")}) {
                if (QDir(p).exists())
                    tryCleanDir(QStringLiteral("[IE Temp]"), p, {QStringLiteral("*")}, true);
            }
        }
    }

    // Emit Skipped for disabled categories
    for (auto &k : {QStringLiteral("userTemp"), QStringLiteral("legacyTemp"),
                    QStringLiteral("windowsTemp"), QStringLiteral("prefetch"),
                    QStringLiteral("systemDriveJunk"), QStringLiteral("windowsBak"),
                    QStringLiteral("recycleBin"), QStringLiteral("cookies"),
                    QStringLiteral("recentFiles"), QStringLiteral("ieTemp")}) {
        if (!on(k)) skip(k);
    }

    emitProgress({});
    emitProgress(QStringLiteral("=== Summary ==="));
    emitProgress(QStringLiteral("Total files removed: %1").arg(m_cleanedCount));
    emitProgress(QStringLiteral("Total space freed:  %1").arg(formatSize(m_freedBytes)));
    emitProgress(m_cleanedCount > 0
        ? QStringLiteral("Cleanup completed successfully.")
        : QStringLiteral("Cleanup completed. Tip: run as administrator to clean system paths."));
}

// ─── Export ───────────────────────────────────────────────────────

void SystemCacheCleaner::saveLogToFile(const QString &path, const QString &content) {
    QFile f(path);
    if (f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream(&f) << content;
        f.close();
    }
}

void SystemCacheCleaner::retranslate()
{
    if (m_model)
        m_model->retranslate();
}

QString SystemCacheCleaner::exportLog(const QString &content) {
    const QString dir = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)
                        + QStringLiteral("/SepKits");
    QDir().mkpath(dir);
    const QString ts = QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd_HHmmss"));
    const QString fp = dir + QStringLiteral("/SepKits_CleanupLog_") + ts + QStringLiteral(".txt");
    saveLogToFile(fp, content);
    return QFile::exists(fp) ? fp : QString();
}

// ─── Format ───────────────────────────────────────────────────────

QString SystemCacheCleaner::formatSize(qint64 bytes) const {
    if (bytes < 1024) return QString::number(bytes) + QStringLiteral(" B");
    if (bytes < 1048576) return QString::number(bytes / 1024.0, 'f', 1) + QStringLiteral(" KB");
    if (bytes < 1073741824LL) return QString::number(bytes / 1048576.0, 'f', 1) + QStringLiteral(" MB");
    return QString::number(bytes / 1073741824.0, 'f', 2) + QStringLiteral(" GB");
}
