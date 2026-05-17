import QtQuick
import SepKits as SepKits

SepKits.ToolsPage {
    categoryLabel: "💻 CATEGORY"
    title: qsTr("Dev Tools")
    subtitle: qsTr("Essential utilities for developers")
    sectionTitle: qsTr("All Dev Tools")
    toolCardIconGradientFrom: SepKits.Color.green600
    toolCardIconGradientTo: SepKits.Color.green500
    toolCardLabelBgColor: SepKits.Color.green50
    toolCardLabelFgColor: SepKits.Color.green600

    model: ListModel {
        ListElement {
            iconKey: "updateDisabled"
            title: qsTr("Code Formatter")
            tagText: qsTr("DEV")
            description: qsTr("Format JSON, XML, CSS, HTML code.")
            pageUrl: "views/CodeFormatterCompressor.qml"
        }
        ListElement {
            iconKey: "restoreFromTrash"
            title: qsTr("Lorem Ipsum Generator")
            tagText: qsTr("DEV")
            description: qsTr("Generate placeholder text quickly.")
            pageUrl: "views/LoremIpsumGenerator.qml"
        }
    }
}
