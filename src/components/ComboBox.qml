import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Controls
import SepKits as SepKits

// SepComboBox —— 基于官方 ComboBox 封装的下拉列表控件
// 用法示例：
//   SepComboBox {
//       label: "语言"
//       model: ["English", "简体中文", "繁體中文"]
//       currentIndex: 0
//       onActivated: (index) => console.log("selected:", index)
//   }

Column {
    id: _root
    spacing: 8

    // ── 公开属性（透传给内部 ComboBox）────────────────────────────────────
    property string label: ""
    property int comboHeight: 48
    property int comboRadius: 12
    property alias model: _combo.model
    property alias currentIndex: _combo.currentIndex
    property alias currentText: _combo.currentText
    property alias displayText: _combo.displayText
    signal activated(int index)

    // ── 标签 ──────────────────────────────────────────────────────────────
    Text {
        visible: _root.label !== ""
        text: _root.label
        font.pixelSize: 14
        color: SepKits.Color.foreground
    }

    // ── ComboBox 主体 ─────────────────────────────────────────────────────
    ComboBox {
        id: _combo
        width: _root.width
        height: _root.comboHeight
        font.pixelSize: _root.comboHeight <= 32 ? SepKits.Font.sizeTiny : 14

        onActivated: index => _root.activated(index)

        // —— 选择框背景 ————————————————————————————————————————————————————
        background: Rectangle {
            radius: _root.comboRadius
            color: _combo.hovered ? SepKits.Color.muted : SepKits.Color.background
            border.width: 1
            border.color: SepKits.Color.border
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }

        // —— 当前选中文字 ───────────────────────────────────────────────────
        contentItem: Text {
            leftPadding: _root.comboHeight <= 32 ? 8 : 16
            rightPadding: _root.comboHeight <= 32 ? 24 : 36
            text: _combo.displayText
            font: _combo.font
            color: SepKits.Color.foreground
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }

        // —— 右侧箭头 ───────────────────────────────────────────────────────
        indicator: SepKits.SvgIcon {
            anchors.verticalCenter: _combo.verticalCenter
            anchors.right: _combo.right
            anchors.rightMargin: _root.comboHeight <= 32 ? 6 : 16
            width: _root.comboHeight <= 32 ? 12 : 18
            height: _root.comboHeight <= 32 ? 12 : 18
            iconSource: SepKits.FontAwesome.chevronUp
            color: SepKits.Color.foreground
            rotation: _combo.popup.visible ? 0 : 180
            Behavior on rotation {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                }
            }
        }

        // —— 下拉弹出层 ────────────────────────────────────────────────────
        popup: Popup {
            y: _combo.height + 8
            width: _combo.width
            height: contentItem.implicitHeight
            padding: 0
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            contentItem: ListView {
                implicitHeight: contentHeight
                model: _combo.delegateModel
                currentIndex: _combo.highlightedIndex
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
            }

            background: Rectangle {
                radius: _root.comboRadius
                color: SepKits.Color.card
                border.width: 1
                border.color: SepKits.Color.border
            }
        }

        // —— 选项 delegate ─────────────────────────────────────────────────
        delegate: ItemDelegate {
            id: _itemDel
            width: _combo.width
            height: _root.comboHeight

            required property var modelData
            required property int index
            readonly property bool isSelected: index === _combo.currentIndex
            readonly property bool isFirst: index === 0
            readonly property bool isLast: index === _combo.count - 1

            background: Rectangle {
                color: _itemDel.isSelected ? SepKits.Color.accent : (_itemDel.hovered ? SepKits.Color.alpha(SepKits.Color.muted, 0.6) : SepKits.Color.alpha(SepKits.Color.muted, 0))
                topLeftRadius: _itemDel.isFirst ? _root.comboRadius : 0
                topRightRadius: _itemDel.isFirst ? _root.comboRadius : 0
                bottomLeftRadius: _itemDel.isLast ? _root.comboRadius : 0
                bottomRightRadius: _itemDel.isLast ? _root.comboRadius : 0
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }

                Rectangle {
                    visible: !_itemDel.isLast && !_itemDel.isSelected
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: SepKits.Color.border
                    opacity: 0.7
                }
            }

            contentItem: Text {
                text: _itemDel.modelData
                font: _combo.font
                color: _itemDel.isSelected ? SepKits.Color.accentForeground : SepKits.Color.foreground
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }
}
