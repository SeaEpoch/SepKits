import QtQuick
import QtQuick.Controls
import SepKits as SepKits

ProgressBar {
    id: _root
    property color barColor: SepKits.Color.blue500
    property color barColorEnd: SepKits.Color.purple500

    from: 0; to: 1

    background: Rectangle {
        implicitHeight: 6; radius: 3
        color: SepKits.Color.muted
    }
    contentItem: Item {
        implicitHeight: 6
        Rectangle {
            width: _root.position * parent.width
            height: parent.height; radius: 3
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: _root.barColor }
                GradientStop { position: 1.0; color: _root.barColorEnd }
            }
        }
    }
}
