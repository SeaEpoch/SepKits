import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Sepkits as SepKits

Item {
    id: _root

    readonly property int iconButtonSize: 32
    readonly property int iconSize: iconButtonSize - 4

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
                Layout.preferredWidth: _root.iconButtonSize
                Layout.preferredHeight: _root.iconButtonSize
                icon: SepKits.FontAwesome.chevronLeft
                normalIconColor: SepKits.Color.textSecondary
                hoverIconColor: SepKits.Color.primary
                pressedIconColor: SepKits.Color.primaryDark
                scaleAnimationEnable: true
                scaleType: SepKits.IconButton.ScaleZoomIn
                onClicked: console.log("clicked")
                enabled: false
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
                onClicked: console.log("clicked")
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
                onClicked: console.log("clicked")
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
                onClicked: console.log("clicked")
            }
        }
    }
}
