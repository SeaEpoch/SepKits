pragma Singleton

import QtQuick
import QtQuick.Controls
import SepKits as SepKits

Item {
    id: _mgr

    // Call once from Main.qml to graft into the window's visual tree
    function attachToWindow(win) {
        _mgr.parent = win.contentItem
        _mgr.anchors.fill = _mgr.parent
    }

    // ─── Internal: prepare and show the shared Dialog instance ───
    function _show(title, message, contentComp, acceptLabel, rejectLabel, onAccepted, onRejected) {
        _dialog.dialogTitle = title
        _dialog.dialogMessage = message || ""
        _dialog.contentComponent = contentComp || null
        _dialog.acceptText = acceptLabel || qsTr("OK")
        _dialog.rejectText = rejectLabel || qsTr("Cancel")
        _dialog._onAccepted = onAccepted || null
        _dialog._onRejected = onRejected || null
        _backdrop.visible = true
        _dialog.open()
    }

    // Show a confirmation dialog with accept/reject buttons
    function confirm(title, message, acceptLabel, rejectLabel, onAccepted, onRejected) {
        _show(title, message, null, acceptLabel, rejectLabel, onAccepted, onRejected)
    }

    // Show a dialog with custom content (Component loaded in place of the message text)
    function custom(title, contentComponent, acceptLabel, rejectLabel, onAccepted, onRejected) {
        _show(title, "", contentComponent, acceptLabel, rejectLabel, onAccepted, onRejected)
    }

    Rectangle {
        id: _backdrop
        anchors.fill: parent
        color: SepKits.Color.alpha(SepKits.Color.black, 0.5)
        visible: false
        z: _dialog.z - 1

        MouseArea {
            anchors.fill: parent
            // Blocks clicks from passing through to items behind, no action
        }
    }

    SepKits.Dialog {
        id: _dialog

        property var _onAccepted: null
        property var _onRejected: null

        modal: false
        closePolicy: Popup.CloseOnEscape

        // Center on window — _mgr fills contentItem after attachToWindow
        x: (_mgr.width - width) / 2
        y: (_mgr.height - height) / 2

        onAccepted: {
            _backdrop.visible = false
            if (_onAccepted)
            _onAccepted()
            _onAccepted = null
            _onRejected = null
        }
        onRejected: {
            _backdrop.visible = false
            if (_onRejected)
            _onRejected()
            _onAccepted = null
            _onRejected = null
        }
        onClosed: {
            contentComponent = null
            _onAccepted = null
            _onRejected = null
        }
    }
}
