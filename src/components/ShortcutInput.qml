// ShortcutInput.qml
import QtQuick
import QtQuick.Controls

TextField {
    id: root

    // 对外暴露当前快捷键字符串，只读
    readonly property alias shortcut: root.text

    readOnly:              true
    placeholderText:      "点击后按下快捷键"
    horizontalAlignment:  Text.AlignRight
    activeFocusOnPress:   true

    // 拦截所有键盘事件
    Keys.onPressed: function(event) {
        event.accepted = true

        // 单独按下修饰键时不记录
        if (isModifierOnly(event.key)) return

        // Escape：清空并失焦
        if (event.key === Qt.Key_Escape) {
            text = ""
            focus = false
            return
        }

        text = buildShortcut(event)
    }

    function isModifierOnly(key) {
        return key === Qt.Key_Control
            || key === Qt.Key_Shift
            || key === Qt.Key_Alt
            || key === Qt.Key_Meta
    }

    function buildShortcut(event) {
        var parts = []
        if (event.modifiers & Qt.ControlModifier) parts.push("Ctrl")
        if (event.modifiers & Qt.AltModifier)     parts.push("Alt")
        if (event.modifiers & Qt.ShiftModifier)   parts.push("Shift")
        if (event.modifiers & Qt.MetaModifier)    parts.push("Meta")
        parts.push(keyToString(event.key))
        return parts.join("+")
    }

    function keyToString(key) {
        const specialKeys = {
            [Qt.Key_Space]:     "Space",
            [Qt.Key_Return]:    "Return",
            [Qt.Key_Enter]:     "Enter",
            [Qt.Key_Backspace]: "Backspace",
            [Qt.Key_Delete]:    "Delete",
            [Qt.Key_Tab]:       "Tab",
            [Qt.Key_Home]:      "Home",
            [Qt.Key_End]:       "End",
            [Qt.Key_PageUp]:    "PgUp",
            [Qt.Key_PageDown]:  "PgDown",
            [Qt.Key_Left]:      "Left",
            [Qt.Key_Right]:     "Right",
            [Qt.Key_Up]:        "Up",
            [Qt.Key_Down]:      "Down",
            [Qt.Key_F1]:        "F1",  [Qt.Key_F2]:  "F2",
            [Qt.Key_F3]:        "F3",  [Qt.Key_F4]:  "F4",
            [Qt.Key_F5]:        "F5",  [Qt.Key_F6]:  "F6",
            [Qt.Key_F7]:        "F7",  [Qt.Key_F8]:  "F8",
            [Qt.Key_F9]:        "F9",  [Qt.Key_F10]: "F10",
            [Qt.Key_F11]:       "F11", [Qt.Key_F12]: "F12",
        }
        if (key in specialKeys) return specialKeys[key]
        // Qt.Key_A–Z / 0–9 的枚举值与 ASCII 码一致，可直接转换
        if (key >= Qt.Key_A && key <= Qt.Key_Z) return String.fromCharCode(key)
        if (key >= Qt.Key_0 && key <= Qt.Key_9) return String.fromCharCode(key)
        return "0x" + key.toString(16).toUpperCase()
    }
}