import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

Item {
    id: _root

    // ── Public API ──
    property color selectedColor: "#FFFFFF"
    signal colorSelected(color colorValue)

    readonly property var defaultPresets: [
        "#FFFFFF", "#000000", "#808080", "#C91F37", "#EF7A82", "#FF4E20",
        "#F9906F", "#FFF143", "#3DE1AD", "#177CB0", "#44CEF6", "#801DAE",
        "#CCA4E3", "#F2BE45", "#1685A9", "#9D2933"
    ]
    property var colorPresets: defaultPresets

    implicitWidth: 280
    implicitHeight: 84

    ColumnLayout {
        anchors.fill: parent
        spacing: SepKits.Theme.spacingSm

        // ── Preset color grid ──
        Grid {
            Layout.fillWidth: true
            columns: 8
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: _root.colorPresets
                delegate: Rectangle {
                    width: 28; height: 28; radius: 4
                    color: modelData
                    border.width: {
                        var selStr = _root.selectedColor.toString().substring(0, 7).toUpperCase()
                        var modelStr = String(modelData).toUpperCase()
                        return selStr === modelStr ? 2 : 1
                    }
                    border.color: {
                        var selStr = _root.selectedColor.toString().substring(0, 7).toUpperCase()
                        var modelStr = String(modelData).toUpperCase()
                        return selStr === modelStr ? SepKits.Color.primary : SepKits.Color.border
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            _root.selectedColor = modelData
                            _root.colorSelected(modelData)
                        }
                    }
                }
            }
        }

        // ── Hex input + preview swatch ──
        RowLayout {
            spacing: SepKits.Theme.spacingSm
            Text {
                text: "#"
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                color: SepKits.Color.mutedForeground
            }
            TextField {
                id: _hexInput
                Layout.fillWidth: true
                implicitHeight: 28
                topPadding: 4; bottomPadding: 4
                leftPadding: 8; rightPadding: 8
                text: {
                    var s = _root.selectedColor.toString()
                    if (s.length >= 7) return s.substring(1, 7).toUpperCase()
                    return "FFFFFF"
                }
                color: SepKits.Color.foreground
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                maximumLength: 6
                validator: RegularExpressionValidator { regularExpression: /^[0-9a-fA-F]{0,6}$/ }

                onEditingFinished: {
                    if (text.length === 6) {
                        var c = "#" + text
                        _root.selectedColor = c
                        _root.colorSelected(c)
                    }
                }

                background: Rectangle {
                    radius: 4
                    color: SepKits.Color.background
                    border.width: 1
                    border.color: _hexInput.activeFocus ? SepKits.Color.primary : SepKits.Color.border
                }
            }
            Rectangle {
                width: 28; height: 28; radius: 4
                color: _root.selectedColor
                border.width: 1
                border.color: SepKits.Color.border
            }
        }
    }
}
