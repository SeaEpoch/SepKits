import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import SepKits as SepKits
import QWindowKit

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
            SepKits.SystemTrayHelper.show()
            break
        case SepKits.AppSettings.CloseBehavior.ExitDirectly:
            Qt.quit()
            break
        case SepKits.AppSettings.CloseBehavior.AskEveryTime:
            close.accepted = false
            _closeDialog.open()
            break
        }
    }

    Connections {
        target: SepKits.SystemTrayHelper
        function onRestoreRequested() {
            SepKits.SystemTrayHelper.hide()
            _window.show()
            _window.raise()
            _window.requestActivate()
        }
        function onExitRequested() {
            SepKits.SystemTrayHelper.hide()
            Qt.quit()
        }
    }

    Dialog {
        id: _closeDialog
        title: qsTr("Close SepKits")
        standardButtons: Dialog.Yes | Dialog.No
        modal: true

        Text {
            text: qsTr("Minimize to system tray and continue running in the background?")
            color: SepKits.Color.foreground
            font.pixelSize: 14
        }

        onAccepted: {
            _window.hide()
            SepKits.SystemTrayHelper.show()
        }
        onRejected: {
            SepKits.SystemTrayHelper.hide()
            Qt.quit()
        }
    }

    Component.onCompleted: {
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
