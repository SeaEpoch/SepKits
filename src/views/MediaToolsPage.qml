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

    model: ListModel {
        ListElement {
            iconKey: "brandingWatermark"
            title: qsTr("Watermark Adder")
            tagText: qsTr("MEDIA")
            description: qsTr("Add watermarks to media files.")
            pageUrl: "views/WatermarkAdder.qml"
        }
        ListElement {
            iconKey: "compress"
            title: qsTr("Image Compression")
            tagText: qsTr("MEDIA")
            description: qsTr("Compress images without quality loss.")
            pageUrl: "views/FileSizeCompressor.qml"
        }
        ListElement {
            iconKey: "driveFileMove"
            title: qsTr("Media Format Converter")
            tagText: qsTr("MEDIA")
            description: qsTr("Convert media formats easily.")
            pageUrl: "views/MediaFormatConverter.qml"
        }
    }
}
