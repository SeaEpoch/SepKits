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

        SepKits.BackButton {}

        Text {
            text: qsTr("Disable Auto Update")
            font.pixelSize: 32
            font.bold: true
            font.family: "Georgia"
            color: SepKits.Color.foreground
        }
    }
}
