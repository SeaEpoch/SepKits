import QtQuick
import SepKits as SepKits

SepKits.ToolsPage {
    categoryLabel: "Welcome"
    title: qsTr("Your Toolkit")
    subtitle: qsTr("Manage your pinned tools and access frequently used utilities.")
    sectionTitle: qsTr("Pinned Tools")
    model: SepKits.PinnedTools.pinnedModel
}
