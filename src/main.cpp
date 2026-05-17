#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QWKQuick/qwkquickglobal.h>
#include "LanguageManager.h"
#include "SettingsStore.h"
#include "SystemTrayHelper.h"

int main(int argc, char* argv[])
{
    qputenv("QT_WIN_DEBUG_CONSOLE", "attach"); // or "new": create a separate console window
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

    SystemTrayHelper trayHelper(&app);
    qmlRegisterSingletonInstance("SepKits", 1, 0, "SystemTrayHelper", &trayHelper);

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() { QCoreApplication::exit(-1); }, Qt::QueuedConnection);
    engine.loadFromModule("SepKits", "Main");

    return app.exec();
}
