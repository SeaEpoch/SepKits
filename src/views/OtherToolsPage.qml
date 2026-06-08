import QtQuick
import SepKits as SepKits

SepKits.ToolsPage {
    categoryLabel: "📦 CATEGORY"
    title: qsTr("Other Tools")
    subtitle: qsTr("Additional utilities and more")
    sectionTitle: qsTr("All Other Tools")
    toolCardIconGradientFrom: SepKits.Color.orange600
    toolCardIconGradientTo: SepKits.Color.orange500
    toolCardLabelBgColor: SepKits.Color.orange50
    toolCardLabelFgColor: SepKits.Color.orange600

    resolveFromMeta: true

    model: ListModel {
        ListElement { pageUrl: "views/NetworkSpeedTest.qml" }
    }
}
