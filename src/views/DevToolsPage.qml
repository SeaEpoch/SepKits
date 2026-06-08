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

    resolveFromMeta: true

    model: ListModel {
        ListElement { pageUrl: "views/LoremIpsumGenerator.qml" }
    }
}
