cmake_minimum_required(VERSION 3.16)

project(SepKits VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20) # C++ 20 标准
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON) # 自动 MOC
set(CMAKE_AUTORCC ON) # 自动 RCC
set(CMAKE_AUTOUIC ON) # 自动 UIC

# 设置第三方库根路径（方便后续引用）
set(THIRD_PARTY_DIR "${CMAKE_SOURCE_DIR}/third_party")

# Qt
find_package(Qt6 REQUIRED COMPONENTS Quick Widgets LinguistTools)

# QWindowKit
set(QWindowKit_DIR "${THIRD_PARTY_DIR}/qwindowkit/lib/cmake/QWindowKit")
find_package(QWindowKit REQUIRED COMPONENTS Core Widgets Quick)

qt_standard_project_setup(
    REQUIRES 6.5
    I18N_TRANSLATED_LANGUAGES
        en
        zh_CN
        zh_TW
)

# 原始 qml 文件
set(QML_PLAIN_FILES
    src/Main.qml
    src/style/themes/LightTheme.qml
    src/style/themes/DarkTheme.qml

    src/components/SvgIcon.qml
    src/components/WindowTitleBar.qml
    src/components/WindowSidebar.qml
    src/components/ToolCard.qml
    src/components/CategoryPageHeader.qml
    src/components/LoadingPage.qml
    src/components/ToolsPage.qml
    src/components/Card.qml
    src/components/ComboBox.qml
    src/components/Dialog.qml
    src/components/SpeedGauge.qml
    src/components/BackButton.qml
    src/components/PathSelector.qml
    src/components/PrimaryButton.qml
    src/components/SecondaryButton.qml
    src/components/SepProgressBar.qml
    src/components/SepSlider.qml


    src/views/HomePage.qml
    src/views/SystemToolsPage.qml
    src/views/SettingsPage.qml
    src/views/SystemCacheCleaner.qml
    src/views/WindowsAutoUpdateDisabler.qml
    src/views/MediaFormatConverter.qml
    src/views/WatermarkAdder.qml
    src/views/FileSizeCompressor.qml
    src/views/LoremIpsumGenerator.qml

    src/views/ColorThemePicker.qml
    src/views/NetworkSpeedTest.qml
    src/views/ThemeGenerator.qml
    src/views/DevToolsPage.qml
    src/views/MediaToolsPage.qml
    src/views/OtherToolsPage.qml
    src/views/AboutPage.qml
)

# 单例 qml 文件
set(QML_SINGLETON_FILES
    src/style/FontAwesome.qml
    src/style/MaterialSymbols.qml
    src/style/Color.qml
    src/style/Font.qml
    src/style/Theme.qml
    src/style/PinnedTools.qml
    src/style/AppSettings.qml
    src/style/ToolMeta.qml
    src/components/DialogManager.qml
)
# 注册 qml 单例
set_source_files_properties(${QML_SINGLETON_FILES}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

# QML 模块 C++ 源文件
set(CPP_FILES
    src/backend/utils/LanguageManager.cpp
    src/backend/utils/LanguageManager.h
    src/backend/utils/SettingsStore.cpp
    src/backend/utils/SettingsStore.h
    src/backend/utils/SystemCacheCleaner.cpp
    src/backend/utils/SystemCacheCleaner.h
    src/backend/utils/TrayMenuHelper.cpp
    src/backend/utils/TrayMenuHelper.h
    src/backend/utils/LoremIpsumGenerator.cpp
    src/backend/utils/LoremIpsumGenerator.h
    src/backend/utils/NetworkSpeedTest.cpp
    src/backend/utils/NetworkSpeedTest.h
    src/backend/utils/MediaFormatConverter.cpp
    src/backend/utils/MediaFormatConverter.h
    src/backend/utils/Logger.cpp
    src/backend/utils/Logger.h
    src/backend/models/CacheCleanerModel.cpp
    src/backend/models/CacheCleanerModel.h
)

qt_add_executable(SepKits
    src/main.cpp
)
qt_add_qml_module(SepKits
    URI SepKits
    VERSION 1.0
    IMPORTS
        QWindowKit
    RESOURCES
        resources/fonts.qrc
        resources/icons.qrc
        resources/images.qrc
        resources/sounds.qrc
        resources/styles.qrc
        # src/SepKits.qrc
    QML_FILES
        ${QML_PLAIN_FILES}
        ${QML_SINGLETON_FILES}
    SOURCES
        ${CPP_FILES}
)

qt_add_translations(SepKits
    TS_FILE_DIR i18n
)

target_include_directories (SepKits PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/src/components"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/backend/utils"
    "${CMAKE_CURRENT_SOURCE_DIR}/src/backend/models"
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(SepKits PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.SepKits
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(SepKits
    PRIVATE
        Qt6::Quick
        Qt6::Widgets
        QWindowKit::Core
        QWindowKit::Quick
        QWindowKit::Widgets
)

include(GNUInstallDirs)
install(TARGETS SepKits
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# Windows VERSIONINFO resource for executable metadata (reduces AV false positives)
if(WIN32)
    target_sources(SepKits PRIVATE resources/versioninfo.rc)
endif()

# ── Deploy external binaries & DLLs to build output directory ──────────
add_custom_command(TARGET SepKits POST_BUILD
    # --- Ookla Speedtest CLI ---
    COMMAND ${CMAKE_COMMAND} -E make_directory
        "$<TARGET_FILE_DIR:SepKits>/bin/ookla-speedtest-1.2.0-win64"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/third_party/ookla-speedtest-1.2.0-win64/speedtest.exe"
        "$<TARGET_FILE_DIR:SepKits>/bin/ookla-speedtest-1.2.0-win64/"

    # --- FFmpeg ---
    COMMAND ${CMAKE_COMMAND} -E make_directory
        "$<TARGET_FILE_DIR:SepKits>/bin/ffmpeg-2026-06-08-git-6028720d70-full_build"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_SOURCE_DIR}/third_party/ffmpeg-2026-06-08-git-6028720d70-full_build/bin/ffmpeg.exe"
        "${CMAKE_SOURCE_DIR}/third_party/ffmpeg-2026-06-08-git-6028720d70-full_build/bin/ffplay.exe"
        "${CMAKE_SOURCE_DIR}/third_party/ffmpeg-2026-06-08-git-6028720d70-full_build/bin/ffprobe.exe"
        "$<TARGET_FILE_DIR:SepKits>/bin/ffmpeg-2026-06-08-git-6028720d70-full_build/"

    # --- QWindowKit DLLs (Debug/Release) ---
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<IF:$<CONFIG:Debug>,${CMAKE_SOURCE_DIR}/third_party/qwindowkit/bin/QWKCored.dll,${CMAKE_SOURCE_DIR}/third_party/qwindowkit/bin/QWKCore.dll>"
        "$<IF:$<CONFIG:Debug>,${CMAKE_SOURCE_DIR}/third_party/qwindowkit/bin/QWKQuickd.dll,${CMAKE_SOURCE_DIR}/third_party/qwindowkit/bin/QWKQuick.dll>"
        "$<IF:$<CONFIG:Debug>,${CMAKE_SOURCE_DIR}/third_party/qwindowkit/bin/QWKWidgetsd.dll,${CMAKE_SOURCE_DIR}/third_party/qwindowkit/bin/QWKWidgets.dll>"
        "$<TARGET_FILE_DIR:SepKits>/"
)

