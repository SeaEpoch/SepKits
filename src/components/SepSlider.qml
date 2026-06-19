import QtQuick
import QtQuick.Controls
import SepKits as SepKits

Slider {
    id: _root

    property color fillColor: SepKits.Color.blue500
    property color fillColorEnd: SepKits.Color.purple500

    background: Rectangle {
        x: _root.leftPadding
        y: _root.topPadding + _root.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: _root.availableWidth
        height: implicitHeight
        radius: 2
        color: SepKits.Color.muted

        Rectangle {
            width: _root.visualPosition * parent.width
            height: parent.height
            radius: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: _root.fillColor }
                GradientStop { position: 1.0; color: _root.fillColorEnd }
            }
        }
    }

    handle: Rectangle {
        x: _root.leftPadding + _root.visualPosition * (_root.availableWidth - width)
        y: _root.topPadding + _root.availableHeight / 2 - height / 2
        implicitWidth: 14
        implicitHeight: 14
        radius: 7
        color: _root.pressed ? SepKits.Color.primary : SepKits.Color.card
        border.width: 2
        border.color: SepKits.Color.primary

        Behavior on color {
            ColorAnimation { duration: SepKits.Theme.animFast }
        }
    }
}
