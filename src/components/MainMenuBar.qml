import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Sepkits as SepKits

Item {
    id: _root

    readonly property int iconButtonSize: 32
    readonly property int iconSize: iconButtonSize - 4
    readonly property int tooltipDelay: 1520

    signal returnBackButtonClicked

    signal systemToolsButtonClicked
    signal programmingToolsButtonClicked
    signal mediaToolsButtonClicked
    signal otherToolsButtonClicked

    signal infoButtonClicked
    signal modeSwitchButtonClicked
    signal settingsButtonClicked

    Rectangle {
        id: _container
        anchors.fill: parent
        color: SepKits.Color.surface

        ColumnLayout {
            anchors {
                top: parent.top
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                topMargin: 32
                bottomMargin: 32
            }
            spacing: 16

            // 返回按钮
            IconButton {
                id: _returnBackButton
                Layout.preferredWidth: _root.iconButtonSize
                Layout.preferredHeight: _root.iconButtonSize
                icon: SepKits.FontAwesome.chevronLeft
                normalIconColor: SepKits.Color.textSecondary
                hoverIconColor: SepKits.Color.primary
                pressedIconColor: SepKits.Color.primaryDark
                scaleAnimationEnable: true
                scaleType: SepKits.IconButton.ScaleZoomIn
                onClicked: _root.returnBackButtonClicked()
                enabled: false
            }

            // 弹簧组件
            Item {
                Layout.preferredHeight: 16
            }

            // 系统工具
            IconButton {
                id: _systemToolsButton
                Layout.preferredWidth: _root.iconButtonSize
                Layout.preferredHeight: _root.iconButtonSize
                icon: SepKits.FontAwesome.windows
                normalIconColor: SepKits.Color.textSecondary
                hoverIconColor: SepKits.Color.primary
                pressedIconColor: SepKits.Color.primaryDark
                scaleAnimationEnable: true
                shakeAnimationEnable: true
                onClicked: _root.systemToolsButtonClicked()
                onDoubleClicked: _root.systemToolsButtonClicked()
                ToolTip {
                    visible: parent.hovered
                    delay: _root.tooltipDelay
                    text: qsTr("System Tools")
                }
            }

            // 编程工具
            IconButton {
                id: _programmingToolsButton
                Layout.preferredWidth: _root.iconButtonSize
                Layout.preferredHeight: _root.iconButtonSize
                icon: SepKits.FontAwesome.laptopCode
                normalIconColor: SepKits.Color.textSecondary
                hoverIconColor: SepKits.Color.primary
                pressedIconColor: SepKits.Color.primaryDark
                scaleAnimationEnable: true
                shakeAnimationEnable: true
                onClicked: _root.programmingToolsButtonClicked()
                onDoubleClicked: _root.programmingToolsButtonClicked()
                ToolTip {
                    visible: parent.hovered
                    delay: _root.tooltipDelay
                    text: qsTr("Programming Tools")
                }
            }

            // 媒体工具
            IconButton {
                id: _mediaToolsButton
                Layout.preferredWidth: _root.iconButtonSize
                Layout.preferredHeight: _root.iconButtonSize
                icon: SepKits.FontAwesome.photoFilm
                normalIconColor: SepKits.Color.textSecondary
                hoverIconColor: SepKits.Color.primary
                pressedIconColor: SepKits.Color.primaryDark
                scaleAnimationEnable: true
                shakeAnimationEnable: true
                onClicked: _root.mediaToolsButtonClicked()
                onDoubleClicked: _root.mediaToolsButtonClicked()
                ToolTip {
                    visible: parent.hovered
                    delay: _root.tooltipDelay
                    text: qsTr("Media Tools")
                }
            }

            //其他工具
            IconButton {
                id: _otherToolsButton
                Layout.preferredWidth: _root.iconButtonSize
                Layout.preferredHeight: _root.iconButtonSize
                icon: SepKits.FontAwesome.boxOpen
                normalIconColor: SepKits.Color.textSecondary
                hoverIconColor: SepKits.Color.primary
                pressedIconColor: SepKits.Color.primaryDark
                scaleAnimationEnable: true
                shakeAnimationEnable: true
                onClicked: _root.otherToolsButtonClicked()
                onDoubleClicked: _root.otherToolsButtonClicked()
                ToolTip {
                    visible: parent.hovered
                    delay: _root.tooltipDelay
                    text: qsTr("Other Tools")
                }
            }

            // 弹簧组件
            Item {
                Layout.fillHeight: true
            }

            // 信息按钮
            IconButton {
                Layout.preferredWidth: _root.iconButtonSize
                Layout.preferredHeight: _root.iconButtonSize
                icon: SepKits.FontAwesome.infoCircle
                normalIconColor: SepKits.Color.textSecondary
                hoverIconColor: SepKits.Color.primary
                pressedIconColor: SepKits.Color.primaryDark
                scaleAnimationEnable: true
                shakeAnimationEnable: true
                onClicked: _root.infoButtonClicked()
            }

            // 模式按钮
            IconButton {
                Layout.preferredWidth: _root.iconButtonSize
                Layout.preferredHeight: _root.iconButtonSize
                icon: SepKits.FontAwesome.moon
                normalIconColor: SepKits.Color.textSecondary
                hoverIconColor: SepKits.Color.primary
                pressedIconColor: SepKits.Color.primaryDark
                scaleAnimationEnable: true
                shakeAnimationEnable: true
                onClicked: _root.modeSwitchButtonClicked()
            }

            // 设置按钮
            IconButton {
                Layout.preferredWidth: _root.iconButtonSize
                Layout.preferredHeight: _root.iconButtonSize
                icon: SepKits.FontAwesome.gear
                normalIconColor: SepKits.Color.textSecondary
                hoverIconColor: SepKits.Color.primary
                pressedIconColor: SepKits.Color.primaryDark
                scaleAnimationEnable: true
                shakeAnimationEnable: true
                onClicked: _root.settingsButtonClicked()
            }
        }
    }
}
