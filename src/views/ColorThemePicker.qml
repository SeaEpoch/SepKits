import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

Rectangle {
    color: SepKits.Color.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 24

        Button {
            text: qsTr("← Back")
            leftPadding: 12
            rightPadding: 12
            topPadding: 6
            bottomPadding: 6

            contentItem: Text {
                text: parent.text
                color: SepKits.Color.foreground
                font.pixelSize: 14
            }
            background: Rectangle {
                radius: 8
                color: parent.hovered ? SepKits.Color.muted : SepKits.Color.transparent
            }
            onClicked: Window.window.navigateBack()
        }

        Text {
            text: qsTr("Color Theme Picker")
            font.pixelSize: 32
            font.bold: true
            font.family: "Georgia"
            color: SepKits.Color.foreground
        }
    }
}
