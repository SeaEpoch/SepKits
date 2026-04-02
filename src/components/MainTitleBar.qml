import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Layouts
import QWindowKit
import SepKits as SepKits

Item {
    id: _root

    // ==================== 属性 ==================== \\
    property color backgroundColor: SepKits.Color.transparent
    property url iconSource: _icon.source

    readonly property alias icon: _icon
    readonly property alias minButton: _minButton
    readonly property alias maxButton: _maxButton
    readonly property alias closeButton: _closeButton

    // ==================== 实现 ==================== \\
    Rectangle {
        id: _titleBarContainer
        anchors.fill: parent
        color: _root.backgroundColor

        // 标题图标
        Image {
            id: _icon
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 32
            }
            // width: 64
            height: 32
            mipmap: true
            source: "qrc:/assets/images/logo_str.png"
            fillMode: Image.PreserveAspectFit
        }

        // 系统按钮
        Row {
            id: _sysBtnsContainer
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 32
            }
            leftPadding: 32
            height: 32
            spacing: 12

            // 最小化按钮
            SepKits.SystemButton {
                id: _minButton
                width: height
                height: parent.height
                systemButtonType: WindowAgent.Minimize
                sysBtnIcon: SepKits.FontAwesome.windowMinimize
                onClicked: Window.window.showMinimized()
            }

            // 最大化按钮/还原按钮
            SepKits.SystemButton {
                id: _maxButton
                width: height
                height: parent.height
                systemButtonType: WindowAgent.Maximize
                sysBtnIcon: Window.window.visibility === Window.Maximized ? SepKits.FontAwesome.windowRestore : SepKits.FontAwesome.windowMaximize
                onClicked: {
                    if (Window.window.visibility === Window.Maximized) {
                        Window.window.showNormal()
                    } else {
                        Window.window.showMaximized()
                    }
                }
            }

            // 关闭按钮
            SepKits.SystemButton {
                id: _closeButton
                width: height
                height: parent.height
                systemButtonType: WindowAgent.Close
                sysBtnIcon: SepKits.FontAwesome.xmark
                onClicked: Window.window.close()
            }
        }

        // 分割线
        SepKits.Line {
            anchors.fill: _sysBtnsContainer
            lineWidth: 1
            position: SepKits.Line.Position.Left
            color: SepKits.Color.divider
        }
    }
}
