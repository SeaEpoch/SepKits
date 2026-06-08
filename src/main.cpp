#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSettings>
#include <QStandardPaths>
#include <QDir>
#include <QWKQuick/qwkquickglobal.h>
#include "backend/utils/LanguageManager.h"
#include "backend/utils/SettingsStore.h"
#include "backend/utils/LoremIpsumGenerator.h"
#include "backend/utils/NetworkSpeedTest.h"
#include "backend/utils/SystemCacheCleaner.h"
#include "backend/utils/TrayMenuHelper.h"

#ifdef Q_OS_WINDOWS
#  include <windows.h>
#  include <shellapi.h>
#  include <sddl.h>

static bool isRunningAsAdmin()
{
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
}
#endif

int main(int argc, char* argv[])
{
#ifdef Q_OS_WINDOWS
    const bool alreadyAdmin = isRunningAsAdmin();

    if (!alreadyAdmin) {
        QCoreApplication::setOrganizationName(QStringLiteral("SeaEpoch"));
        QCoreApplication::setApplicationName(QStringLiteral("SepKits"));
        QString iniPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
        QDir().mkpath(iniPath);
        iniPath += QStringLiteral("/SepKits.ini");
        QSettings settings(iniPath, QSettings::IniFormat);
        if (settings.value(QStringLiteral("launchAsAdmin"), false).toBool()) {
            wchar_t exePath[MAX_PATH] = {};
            GetModuleFileNameW(nullptr, exePath, MAX_PATH);
            SHELLEXECUTEINFOW sei = {};
            sei.cbSize = sizeof(sei);
            sei.lpVerb = L"runas";
            sei.lpFile = exePath;
            sei.nShow = SW_SHOWNORMAL;
            if (ShellExecuteExW(&sei))
                return 0;
        }
    }
#endif

    // Attach debug console only for non-admin processes.
    // Admin processes cannot inherit the console across the UAC boundary —
    // stdin/stdout/stderr would be invalid, triggering a Qt assertion.
#ifdef Q_OS_WINDOWS
    if (!alreadyAdmin)
        qputenv("QT_WIN_DEBUG_CONSOLE", "attach");
#else
    qputenv("QT_WIN_DEBUG_CONSOLE", "attach");
#endif
    // qputenv("QSG_INFO", "1");                  // 打印 Qt Scene Graph 信息，用于性能调试
    // qputenv("QSG_NO_VSYNC", "1");              // 禁用垂直同步，提高帧率（仅限开发环境）

#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");
#else
    qputenv("QT_QUICK_CONTROLS_STYLE", "Default");
#endif

#ifdef Q_OS_WINDOWS
    qputenv("QSG_RHI_BACKEND", "d3d11");                // options: d3d11, d3d12, opengl, vulkan
    qputenv("QT_QPA_DISABLE_REDIRECTION_SURFACE", "1"); // 禁用窗口重定向表面
#endif
    //qputenv("QSG_RHI_HDR", "scrgb"); // other options: hdr10, p3

    QApplication app(argc, argv);
    app.setOrganizationName(QStringLiteral("SeaEpoch"));
    app.setApplicationName(QStringLiteral("SepKits"));
    // 防止所有窗口关闭时自动退出（系统托盘需要保持运行）
    app.setQuitOnLastWindowClosed(false);

    QQmlApplicationEngine engine;

#if QT_VERSION >= QT_VERSION_CHECK(6, 7, 0)
    const bool curveRenderingAvailable = true;
#else
    const bool curveRenderingAvailable = false;
#endif
    engine.rootContext()->setContextProperty(QStringLiteral("$curveRenderingAvailable"), QVariant(curveRenderingAvailable));
    QWK::registerTypes(&engine);

    LanguageManager langManager(&engine, &app);
    qmlRegisterSingletonInstance("SepKits", 1, 0, "LanguageManager", &langManager);

    SettingsStore settingsStore(&app);
    qmlRegisterSingletonInstance("SepKits", 1, 0, "SettingsStore", &settingsStore);

    LoremIpsumGenerator loremIpsumGen(&app);
    qmlRegisterSingletonInstance("SepKits", 1, 0, "LoremIpsumGenerator", &loremIpsumGen);

    NetworkSpeedTest networkSpeedTest(&app);
    qmlRegisterSingletonInstance("SepKits", 1, 0, "NetworkSpeedTest", &networkSpeedTest);

    SystemCacheCleaner cacheCleaner(&app);
    qmlRegisterSingletonInstance("SepKits", 1, 0, "SystemCacheCleaner", &cacheCleaner);

    TrayMenuHelper trayMenuHelper(&app);
    qmlRegisterSingletonInstance("SepKits", 1, 0, "TrayMenuHelper", &trayMenuHelper);

    QObject::connect(&langManager, &LanguageManager::languageChanged,
                     &cacheCleaner, &SystemCacheCleaner::retranslate);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule("SepKits", "Main");

    return app.exec();
}
