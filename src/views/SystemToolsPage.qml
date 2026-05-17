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

    model: ListModel {
        ListElement {
            iconKey: "updateDisabled"
            title: qsTr("Disable Auto Update")
            tagText: qsTr("SYSTEM")
            description: qsTr("Prevents Windows updates automatically.")
            pageUrl: "views/WindowsAutoUpdateDisabler.qml"
        }
        ListElement {
            iconKey: "restoreFromTrash"
            title: qsTr("Cache Cleaner")
            tagText: qsTr("SYSTEM")
            description: qsTr("Cleans system cache & temp files.")
            pageUrl: "views/SystemCacheCleaner.qml"
        }
    }
}
