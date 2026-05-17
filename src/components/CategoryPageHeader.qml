import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

ColumnLayout {
    id: _root
    spacing: 36

    property string categoryLabel: ""
    property string title: ""
    property string subtitle: ""

    RowLayout {
        spacing: 0

        // Category 胶囊标签
        Control {
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: 4

            leftPadding: 20
            rightPadding: 20
            topPadding: 8
            bottomPadding: 8

            background: Rectangle {
                radius: height * 0.5
                color: SepKits.Color.alpha(SepKits.Color.accent, 0.05)
                border.width: 0.5
                border.color: SepKits.Color.alpha(SepKits.Color.accent, 0.3)
            }

            contentItem: Row {
                spacing: 12

                Rectangle {
                    id: _labelDot
                    anchors.verticalCenter: parent.verticalCenter
                    width: 8
                    height: width
                    radius: width * 0.5
                    color: SepKits.Color.accent

                    SequentialAnimation {
                        running: _root.visible
                        loops: Animation.Infinite

                        ParallelAnimation {
                            NumberAnimation {
                                target: _labelDot
                                property: "scale"
                                from: 1.0; to: 1.3
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: _labelDot
                                property: "opacity"
                                from: 1.0; to: 0.7
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                        }

                        ParallelAnimation {
                            NumberAnimation {
                                target: _labelDot
                                property: "scale"
                                from: 1.3; to: 1.0
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                            NumberAnimation {
                                target: _labelDot
                                property: "opacity"
                                from: 0.7; to: 1.0
                                duration: 1000
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }
                }

                Text {
                    text: _root.categoryLabel
                    font.family: "Consolas"
                    font.pixelSize: 12
                    font.letterSpacing: 1.8
                    color: SepKits.Color.accent
                }
            }
        }

        Text {
            text: _root.title
            font.pixelSize: 48
            font.family: "Georgia"
            font.bold: true
            color: SepKits.Color.foreground

            Rectangle {
                id: _underline
                anchors.bottom: parent.bottom
                width: parent.width
                height: 16
                gradient: Gradient {
                    orientation: Gradient.Horizontal // 设置为横向渐变 (to right)
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(0 / 255, 82 / 255, 255 / 255, 0.15)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(77 / 255, 124 / 255, 255 / 255, 0.1)
                    }
                }
                radius: 2
                z: -1 // 确保下划线在文字下方（层级）
            }
        }
    }

    Text {
        text: _root.subtitle
        font.pixelSize: 18
        color: SepKits.Color.mutedForeground
    }
}
