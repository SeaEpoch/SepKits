import QtQuick
import SepKits as SepKits

SepKits.ToolsPage {
    categoryLabel: "🎞 CATEGORY"
    title: qsTr("Media Tools")
    subtitle: qsTr("Process images and videos")
    sectionTitle: qsTr("All Media Tools")
    toolCardIconGradientFrom: SepKits.Color.purple600
    toolCardIconGradientTo: SepKits.Color.purple500
    toolCardLabelBgColor: SepKits.Color.purple50
    toolCardLabelFgColor: SepKits.Color.purple600

    resolveFromMeta: true

    model: ListModel {
        ListElement { pageUrl: "views/WatermarkAdder.qml" }
        ListElement { pageUrl: "views/FileSizeCompressor.qml" }
        ListElement { pageUrl: "views/MediaFormatConverter.qml" }
    }
}
