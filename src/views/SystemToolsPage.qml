import QtQuick
import SepKits as SepKits

SepKits.ToolsPage {
    categoryLabel: "⚙️ CATEGORY"
    title: qsTr("System Tools")
    subtitle: qsTr("Optimize and customize your Windows system")
    sectionTitle: qsTr("All System Tools")
    toolCardIconGradientFrom: SepKits.Color.blue500
    toolCardIconGradientTo: SepKits.Color.blue600
    toolCardLabelBgColor: SepKits.Color.blue50
    toolCardLabelFgColor: SepKits.Color.blue600

    resolveFromMeta: true

    model: ListModel {
        ListElement { pageUrl: "views/WindowsAutoUpdateDisabler.qml" }
        ListElement { pageUrl: "views/SystemCacheCleaner.qml" }
    }
}
