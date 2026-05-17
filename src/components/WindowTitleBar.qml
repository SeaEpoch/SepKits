import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

Rectangle {
    id: _root
    property alias minButton: _minimizeBtn
    property alias maxButton: _maximizeBtn
    property alias closeButton: _closeBtn

    color: SepKits.Color.background

    component WindowButton: Button {
        id: _btn
        property var iconSource
        property color iconNormalColor: SepKits.Color.foreground
        property color iconHoverColor: iconNormalColor
        property color bgNormalColor: SepKits.Color.transparent
        property color bgHoverColor: SepKits.Color.muted

        Layout.preferredWidth: 34
        Layout.preferredHeight: 34

        topPadding: 8
        rightPadding: 8
        bottomPadding: 8
        leftPadding: 8

        topInset: 0
        rightInset: 0
        bottomInset: 0
        leftInset: 0

        contentItem: SepKits.SvgIcon {
            iconSource: _btn.iconSource
            color: _btn.hovered ? _btn.iconHoverColor : _btn.iconNormalColor
        }

        background: Rectangle {
            radius: SepKits.Theme.radius
            color: _btn.hovered ? _btn.bgHoverColor : _btn.bgNormalColor
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.bottomMargin: 1
        anchors.rightMargin: spacing * 2.0

        spacing: 8

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 34
            Layout.leftMargin: 8
            Layout.rightMargin: 8
            color: SepKits.Color.border
        }

        WindowButton {
            id: _minimizeBtn
            iconSource: SepKits.FontAwesome.windowMinimize
            onClicked: Window.window.showMinimized()
        }

        WindowButton {
            id: _maximizeBtn
            iconSource: Window.window.visibility === Window.Maximized
                ? SepKits.FontAwesome.windowRestore : SepKits.FontAwesome.windowMaximize
            onClicked: {
                if (Window.window.visibility === Window.Maximized) {
                    Window.window.showNormal()
                } else {
                    Window.window.showMaximized()
                }
            }
        }

        WindowButton {
            id: _closeBtn
            iconSource: SepKits.FontAwesome.xmark
            iconHoverColor: SepKits.Color.red500
            bgHoverColor: SepKits.Color.red100
            onClicked: Window.window.close()
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        height: 1
        color: SepKits.Color.border
    }
}
