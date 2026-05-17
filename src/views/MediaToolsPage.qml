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
            iconKey: "updateDisabled"
            title: qsTr("Image Watermark")
            tagText: qsTr("MEDIA")
            description: qsTr("Add watermarks to images easily.")
            pageUrl: "views/WatermarkAdder.qml"
        }
        ListElement {
            iconKey: "restoreFromTrash"
            title: qsTr("Video Watermark")
            tagText: qsTr("MEDIA")
            description: qsTr("Add watermarks to video files.")
            pageUrl: "views/VideoWatermarkAdder.qml"
        }
        ListElement {
            iconKey: "restoreFromTrash"
            title: qsTr("Image Compression")
            tagText: qsTr("MEDIA")
            description: qsTr("Compress images without quality loss.")
            pageUrl: "views/FileSizeCompressor.qml"
        }
        ListElement {
            iconKey: "restoreFromTrash"
            title: qsTr("Video Format Converter")
            tagText: qsTr("MEDIA")
            description: qsTr("Convert video formats easily.")
            pageUrl: "views/MediaFormatConverter.qml"
        }
    }
}
