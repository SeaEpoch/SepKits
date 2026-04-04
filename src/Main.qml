import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QWindowKit
import SepKits as SepKits

Window {
    id: _window
    width: 1024
    height: 768
    visible: false
    title: qsTr("SeaEpoch Kits Demo")

    property bool showWhenReady: true
    readonly property var windowAgent: WindowAgent {}

    RowLayout {
        anchors.fill: parent
        spacing: 0

        SepKits.MainMenuBar {
            id: _menuBar
            Layout.fillHeight: true
            width: 64
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            SepKits.MainTitleBar {
                id: _titleBar
                Layout.fillWidth: true
                height: 72

                SepKits.Line {
                    anchors.fill: parent
                    position: SepKits.Line.Position.Bottom
                    color: SepKits.Color.divider
                    lineWidth: 1
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }

    Component.onCompleted: {
        ///// QWindowKit 设置  \\\\\
        windowAgent.setup(_window) // 注册窗口
        windowAgent.setTitleBar(_titleBar) // 注册标题栏
        // windowAgent.setSystemButton(WindowAgent.WindowIcon, _titleBar.icon) // 注册 icon
        windowAgent.setSystemButton(WindowAgent.Minimize, _titleBar.minButton) // 注册最小化按钮
        windowAgent.setSystemButton(WindowAgent.Maximize, _titleBar.maxButton) // 注册最大化/还原按钮
        windowAgent.setSystemButton(WindowAgent.Close, _titleBar.closeButton) // 注册关闭按钮

        // 全部初始化完毕后显示窗口
        if (_window.showWhenReady) {
            _window.visible = true
        }
    }
}
