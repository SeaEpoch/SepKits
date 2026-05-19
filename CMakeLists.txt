cmake_minimum_required(VERSION 3.16)

project(SepKits VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20) # C++ 20 标准
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON) # 自动 MOC
set(CMAKE_AUTORCC ON) # 自动 RCC
set(CMAKE_AUTOUIC ON) # 自动 UIC

find_package(Qt6 REQUIRED COMPONENTS Quick Widgets LinguistTools)

# QWindowKit
set(QWindowKit_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party/qwindowkit")
set(QWindowKit_DIR "${QWindowKit_ROOT_DIR}/lib/cmake/QWindowKit")
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


    src/views/HomePage.qml
    src/views/SystemToolsPage.qml
    src/views/SettingsPage.qml
    src/views/SystemCacheCleaner.qml
    src/views/WindowsAutoUpdateDisabler.qml
    src/views/CodeFormatterCompressor.qml
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
    src/backend/utils/SystemTrayHelper.cpp
    src/backend/utils/SystemTrayHelper.h
    src/backend/utils/SystemCacheCleaner.cpp
    src/backend/utils/SystemCacheCleaner.h
    src/backend/utils/LoremIpsumGenerator.cpp
    src/backend/utils/LoremIpsumGenerator.h
    src/backend/utils/NetworkSpeedTest.cpp
    src/backend/utils/NetworkSpeedTest.h
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

target_include_directories (SepKits PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/src/components" "${CMAKE_CURRENT_SOURCE_DIR}/src/backend/utils" "${CMAKE_CURRENT_SOURCE_DIR}/src/backend/models")

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

