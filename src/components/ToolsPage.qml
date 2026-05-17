import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import SepKits as SepKits

SepKits.LoadingPage {
    id: _root
    contentComponent: _mainContent

    property string categoryLabel
    property string title
    property string subtitle
    property string sectionTitle
    property color toolCardIconGradientFrom: SepKits.Color.blue500
    property color toolCardIconGradientTo: SepKits.Color.blue600
    property color toolCardLabelBgColor: SepKits.Color.blue50
    property color toolCardLabelFgColor: SepKits.Color.blue600
    required property var model

    Component {
        id: _mainContent

        GridView {
            id: _grid

            readonly property int cols: 3
            readonly property int hMargin: Math.max(0, Math.floor((width - contentWidth) / 2))

            anchors.fill: parent
            clip: true

            contentWidth: 1088

            leftMargin: hMargin
            rightMargin: hMargin
            topMargin: 32
            bottomMargin: 32

            cellWidth: (width - 2 * hMargin) / cols
            cellHeight: 258

            Binding {
                target: _grid
                property: "contentX"
                value: -_grid.hMargin
                restoreMode: Binding.RestoreNone
            }

            WheelHandler {
                onWheel: event => _grid.flick(0, event.angleDelta.y * 8)
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: Item {
                width: _grid.cellWidth
                height: _grid.cellHeight

                SepKits.ToolCard {
                    anchors.fill: parent
                    anchors.leftMargin: index % _grid.cols === 0 ? 0 : (index % _grid.cols === 1 ? 8 : 16)
                    anchors.rightMargin: index % _grid.cols === 0 ? 16 : (index % _grid.cols === 1 ? 8 : 0)
                    anchors.topMargin: 8
                    anchors.bottomMargin: 8

                    iconSource: model.iconKey !== undefined
                        ? SepKits.MaterialSymbols[model.iconKey] : model.iconSource
                    title: model.title
                    tagText: model.tagText
                    description: model.description
                    pageUrl: model.pageUrl
                    iconGradientFrom: model.iconGradientFrom !== undefined
                        ? model.iconGradientFrom : _root.toolCardIconGradientFrom
                    iconGradientTo: model.iconGradientTo !== undefined
                        ? model.iconGradientTo : _root.toolCardIconGradientTo
                    labelBackgroundColor: model.labelBackgroundColor !== undefined
                        ? model.labelBackgroundColor : _root.toolCardLabelBgColor
                    labelForegroundColor: model.labelForegroundColor !== undefined
                        ? model.labelForegroundColor : _root.toolCardLabelFgColor

                    onClicked: Window.window.navigateTo(model.pageUrl)
                }
            }

            header: ColumnLayout {
                width: _grid.contentWidth
                spacing: 32

                SepKits.CategoryPageHeader {
                    Layout.fillWidth: true
                    categoryLabel: _root.categoryLabel
                    title: _root.title
                    subtitle: _root.subtitle
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 8

                    Text {
                        text: _root.sectionTitle
                        font.pixelSize: 24
                        font.family: "Georgia"
                        font.bold: true
                        color: SepKits.Color.foreground
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Text {
                        text: _grid.count + " tools"
                        font.pixelSize: 14
                        font.family: "Consolas"
                        color: SepKits.Color.mutedForeground
                    }
                }
            }

            model: _root.model
        }
    }
}
