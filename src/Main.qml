import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import SepKits as SepKits
import QWindowKit
import Qt.labs.platform as Platform

Window {
    id: _window
    width: 1440
    height: 900
    minimumWidth: 1440
    minimumHeight: 900
    visible: false
    title: qsTr("SeaEpoch Kits Demo")

    property bool showWhenReady: true
    readonly property var windowAgent: WindowAgent {}

    readonly property var pages: [
        "views/HomePage.qml",
        "views/SystemToolsPage.qml",
        "views/DevToolsPage.qml",
        "views/MediaToolsPage.qml",
        "views/OtherToolsPage.qml",
        "views/SettingsPage.qml",
        "views/AboutPage.qml"
    ]

    function navigateTo(url) {
        _pageStack.push(url, {})
    }

    function navigateBack() {
        if (_pageStack.depth > 1) {
            _pageStack.pop()
        }
    }

    GridLayout {
        anchors.fill: parent
        columns: 2
        rows: 2
        rowSpacing: 0
        columnSpacing: 0

        SepKits.WindowSidebar {
            id: _sidebar
            Layout.row: 0
            Layout.column: 0
            Layout.rowSpan: 2
            Layout.columnSpan: 1
            Layout.preferredWidth: 288
            Layout.fillHeight: true

            onSelectedChanged: index => {
                _pageStack.clear()
                _pageStack.push(pages[index], {})
            }
        }

        SepKits.WindowTitleBar {
            id: _titleBar
            Layout.row: 0
            Layout.column: 1
            Layout.rowSpan: 1
            Layout.columnSpan: 1
            Layout.fillWidth: true
            Layout.preferredHeight: 64
        }

        Item {
            Layout.row: 1
            Layout.column: 1
            Layout.rowSpan: 1
            Layout.columnSpan: 1
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.fill: parent
                color: SepKits.Color.background
            }

            StackView {
                id: _pageStack
                anchors.fill: parent
                clip: true
            }
        }
    }

    // 关闭窗口行为
    onClosing: close => {
        switch (SepKits.AppSettings.closeBehavior) {
        case SepKits.AppSettings.CloseBehavior.MinimizeToTray:
            close.accepted = false
            _window.hide()
            _trayIcon.show()
            break
        case SepKits.AppSettings.CloseBehavior.ExitDirectly:
            Qt.quit()
            break
        case SepKits.AppSettings.CloseBehavior.AskEveryTime:
            close.accepted = false
            SepKits.DialogManager.confirm(
                qsTr("Close SepKits"),
                qsTr("Minimize to system tray and continue running in the background?"),
                qsTr("Minimize to Tray"),
                qsTr("Exit SepKits"),
                function() {
                    _window.hide()
                    _trayIcon.show()
                },
                function() {
                    _trayIcon.hide()
                    Qt.quit()
                }
            )
            break
        }
    }

    Platform.SystemTrayIcon {
        id: _trayIcon
        visible: false
        tooltip: "SepKits"
        icon.source: "qrc:/assets/images/sepwinkits-logo-modern.png"

        onActivated: reason => {
            if (reason === Platform.SystemTrayIcon.Trigger
                || reason === Platform.SystemTrayIcon.DoubleClick) {
                _trayIcon.hide()
                _window.show()
                _window.raise()
                _window.requestActivate()
            } else if (reason === Platform.SystemTrayIcon.Context) {
                SepKits.TrayMenuHelper.showContextMenu()
            }
        }
    }

    Connections {
        target: SepKits.TrayMenuHelper

        function onRestoreRequested() {
            _trayIcon.hide()
            _window.show()
            _window.raise()
            _window.requestActivate()
        }

        function onExitRequested() {
            _trayIcon.hide()
            Qt.quit()
        }
    }

    Component.onCompleted: {
        SepKits.DialogManager.attachToWindow(_window)

        windowAgent.setup(_window)
        windowAgent.setTitleBar(_titleBar)
        windowAgent.setSystemButton(WindowAgent.Minimize, _titleBar.minButton)
        windowAgent.setSystemButton(WindowAgent.Maximize, _titleBar.maxButton)
        windowAgent.setSystemButton(WindowAgent.Close, _titleBar.closeButton)

        _pageStack.push(pages[_sidebar.currentIndex], {})

        if (_window.showWhenReady) {
            _window.visible = true
        }
    }
}