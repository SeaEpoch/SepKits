pragma Singleton

import QtQuick
import SepKits as SepKits

QtObject {
    id: _root

    enum CloseBehavior {
        MinimizeToTray = 0,
        ExitDirectly = 1,
        AskEveryTime = 2
    }

    property int closeBehavior: SepKits.SettingsStore.value(
        "closeBehavior", AppSettings.CloseBehavior.AskEveryTime)

    readonly property var closeBehaviorModel: [
        qsTr("Minimize to tray"),
        qsTr("Exit directly"),
        qsTr("Ask every time")
    ]

    onCloseBehaviorChanged: {
        SepKits.SettingsStore.setValue("closeBehavior", _root.closeBehavior)
    }

}
