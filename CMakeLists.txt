cmake_minimum_required(VERSION 3.16)

project(SepKits VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20) # C++ 20 标准
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON) # 自动 MOC
set(CMAKE_AUTORCC ON) # 自动 RCC
set(CMAKE_AUTOUIC ON) # 自动 UIC

set(QWindowKit_ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/third_party/qwindowkit")
set(QWindowKit_DIR "${QWindowKit_ROOT_DIR}/lib/cmake/QWindowKit")

find_package(Qt6 REQUIRED COMPONENTS Quick)
find_package(QWindowKit REQUIRED COMPONENTS Core Widgets Quick)

qt_standard_project_setup(REQUIRES 6.5)


# 原始 qml 文件
set(qml_plain_files
    src/Main.qml
    src/style/themes/DefaultTheme.qml
    src/components/MainTitleBar.qml
    src/components/MainMenuBar.qml
    src/components/HdSvgIcon.qml
    src/components/Line.qml
    src/components/IconButton.qml
    src/components/MainMenu.qml
)

# 单例 qml 文件
set(qml_singleton_files
    src/style/FontAwesome.qml
    src/style/MaterialSymbols.qml
    src/style/Color.qml
    src/shared/MainMenuLists.qml
    src/style/Font.qml
)
# 注册 qml 单例
set_source_files_properties(${qml_singleton_files}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_executable(SepKits
    main.cpp
)
qt_add_qml_module(SepKits
    URI SepKits
    VERSION 1.0
    DEPENDENCIES
        QWindowKit
    RESOURCES
        resources/fonts.qrc
        resources/icons.qrc
        resources/images.qrc
        resources/sounds.qrc
        resources/styles.qrc
        # src/SepKits.qrc
    QML_FILES
        ${qml_plain_files}
        ${qml_singleton_files}
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

