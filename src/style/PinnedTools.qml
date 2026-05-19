pragma Singleton

import QtQuick
import SepKits as SepKits

QtObject {
    id: _root

    signal pinnedChanged()

    property ListModel pinnedModel: ListModel {}

    Component.onCompleted: {
        var jsonData = SepKits.SettingsStore.value("pinnedData", "")
        if (jsonData !== "") {
            try {
                var data = JSON.parse(jsonData)
                for (var i = 0; i < data.length; i++) {
                    pinnedModel.append(data[i])
                }
            } catch (e) {
                console.warn("[PinnedTools] Failed to parse pinned data:", e)
                SepKits.SettingsStore.setValue("pinnedData", "")
            }
        }
    }

    function _save() {
        var data = []
        for (var i = 0; i < pinnedModel.count; i++)
            data.push(pinnedModel.get(i))
        SepKits.SettingsStore.setValue("pinnedData", JSON.stringify(data))
    }

    function isPinned(pageUrl) {
        for (var i = 0; i < pinnedModel.count; i++) {
            if (pinnedModel.get(i).pageUrl === pageUrl) return true
        }
        return false
    }

    function pin(data) {
        if (!isPinned(data.pageUrl)) {
            pinnedModel.append(data)
            pinnedChanged()
            _save()
        }
    }

    function unpin(pageUrl) {
        for (var i = 0; i < pinnedModel.count; i++) {
            if (pinnedModel.get(i).pageUrl === pageUrl) {
                pinnedModel.remove(i)
                pinnedChanged()
                _save()
                return
            }
        }
    }

    function move(from, to) {
        if (from < 0 || from >= pinnedModel.count || to < 0 || to >= pinnedModel.count) return
        pinnedModel.move(from, to, 1)
        pinnedChanged()
        _save()
    }
}
