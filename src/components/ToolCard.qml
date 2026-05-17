import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import SepKits as SepKits

SepKits.Card {
    id: _root
    implicitWidth: 346.66666666666666666666666666667
    implicitHeight: 242

    property string iconSource: ""
    property string title: "Tool Title"
    property string description: "Description goes here..."
    property string tagText: "Unknown"
    property string pageUrl: ""
    property bool showDragHandle: false

    property color iconGradientFrom: SepKits.Color.blue500
    property color iconGradientTo: SepKits.Color.blue600
    property color labelBackgroundColor: SepKits.Color.blue50
    property color labelForegroundColor: SepKits.Color.blue600

    ColumnLayout {
        anchors.fill: parent
        spacing: 16

        Rectangle {
            width: 48
            height: 48
            radius: 12
            scale: hovered ? 1.1 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }
            }

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop {
                    position: 0.0
                    color: _root.iconGradientFrom
                }
                GradientStop {
                    position: 1.0
                    color: _root.iconGradientTo
                }
            }

            SepKits.SvgIcon {
                anchors.fill: parent
                anchors.margins: 12
                iconSource: _root.iconSource
                color: SepKits.Color.white
            }
        }

        Column {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: _root.title
                font.pixelSize: 18
                font.bold: true
                font.family: "Georgia"
                lineHeight: 28 / font.pixelSize
                color: SepKits.Color.cardForeground
            }

            Text {
                text: _root.description
                font.pixelSize: 14
                lineHeight: 20 / font.pixelSize
                color: SepKits.Color.mutedForeground
                width: parent.width
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: SepKits.Color.border
        }

        RowLayout {
            Layout.fillWidth: true

            Label {
                leftPadding: 12
                rightPadding: 12
                topPadding: 4
                bottomPadding: 4

                text: _root.tagText
                font.family: "Consolas"
                font.pixelSize: 12
                font.weight: 600
                color: _root.labelForegroundColor

                background: Rectangle {
                    radius: height / 2
                    color: _root.labelBackgroundColor
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: _pinBtn

                property bool _pinned: SepKits.PinnedTools.isPinned(_root.title)

                text: _pinned ? qsTr("✓Pinned") : qsTr("Pin")

                leftPadding: 12
                rightPadding: 12
                topPadding: 4
                bottomPadding: 4

                leftInset: 0
                rightInset: 0
                topInset: 0
                bottomInset: 0

                onClicked: {
                    if (_pinned) {
                        SepKits.PinnedTools.unpin(_root.title)
                    } else {
                        SepKits.PinnedTools.pin({
                            "iconSource": _root.iconSource,
                            "title": _root.title,
                            "description": _root.description,
                            "tagText": _root.tagText,
                            "pageUrl": _root.pageUrl,
                            "iconGradientFrom": _root.iconGradientFrom,
                            "iconGradientTo": _root.iconGradientTo,
                            "labelBackgroundColor": _root.labelBackgroundColor,
                            "labelForegroundColor": _root.labelForegroundColor
                        })
                    }
                }

                Connections {
                    target: SepKits.PinnedTools
                    function onPinnedChanged() {
                        _pinBtn._pinned = SepKits.PinnedTools.isPinned(_root.title)
                    }
                }

                contentItem: Text {
                    text: _pinBtn.text
                    font.family: "Consolas"
                    font.pixelSize: 12
                    font.weight: 500
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: (_pinBtn._pinned
                            || _pinBtn.hovered) ? SepKits.Color.accentForeground : SepKits.Color.mutedForeground
                }

                background: Rectangle {
                    radius: height / 2

                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop {
                            position: 0.0
                            color: (_pinBtn._pinned
                                    || _pinBtn.hovered) ? SepKits.Color.accent : SepKits.Color.muted
                        }
                        GradientStop {
                            position: 1.0
                            color: _pinBtn._pinned ? SepKits.Color.accentSecondary : _pinBtn.hovered ? SepKits.Color.accent : SepKits.Color.muted
                        }
                    }
                }
            }
        }
    }

    // 拖拽手柄视觉指示器（拖拽交互由 HomePage delegate 负责）
    Item {
        visible: _root.showDragHandle
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: _root.contentMargins - 16
        width: 16
        height: 20
        z: 10

        Column {
            anchors.centerIn: parent
            spacing: 3
            Repeater {
                model: 3
                Row {
                    spacing: 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    Rectangle {
                        width: 3; height: 3
                        radius: 1.5
                        color: SepKits.Color.mutedForeground
                        opacity: 0.5
                    }
                    Rectangle {
                        width: 3; height: 3
                        radius: 1.5
                        color: SepKits.Color.mutedForeground
                        opacity: 0.5
                    }
                }
            }
        }
    }
}
