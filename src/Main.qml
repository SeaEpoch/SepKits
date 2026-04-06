import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QWindowKit
import SepKits as SepKits

ApplicationWindow  {
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
            z: 1

            // 菜单栏点击事件处理
            onReturnBackButtonClicked: {
                console.log("returnBackButton 被点击")
            }
            onSystemToolsButtonClicked: {
                console.log("systemToolsButton 被点击")
                _menu.toggleMenu(SepKits.MainMenuLists.systemToolsMenuList)
            }
            onProgrammingToolsButtonClicked: {
                console.log("programmingToolsButton 被点击")
                _menu.toggleMenu(SepKits.MainMenuLists.programmingToolsMenuList)
            }
            onMediaToolsButtonClicked: {
                console.log("mediaToolsButton 被点击")
                _menu.toggleMenu(SepKits.MainMenuLists.mediaToolsMenuList)
            }
            onOtherToolsButtonClicked: {
                console.log("otherToolsButton 被点击")
                _menu.toggleMenu(SepKits.MainMenuLists.otherToolsMenuList)
            }
            onInfoButtonClicked: {
                console.log("infoButton 被点击")
            }
            onModeSwitchButtonClicked: {
                console.log("modeSwitchButton 被点击")
            }
            onSettingsButtonClicked: {
                console.log("settingsButton 被点击")
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            z: 0

            SepKits.MainTitleBar {
                id: _titleBar
                Layout.fillWidth: true
                height: 72
                z: 1

                SepKits.Line {
                    anchors.fill: parent
                    position: SepKits.Line.Position.Bottom
                    color: SepKits.Color.divider
                    lineWidth: 1
                    z: 2
                }
            }

            // 页面占位
            Rectangle {
                id: _mainContentArea
                Layout.fillWidth: true
                Layout.fillHeight: true

                // color: SepKits.Color.primaryUltraLight
                SepKits.MainMenu {
                    id: _menu
                    anchors.fill: _mainContentArea // 必须覆盖全区（为了实现点击其他区域关闭菜单）
                    menuWidth: 432
                }
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
