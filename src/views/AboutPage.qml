import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import SepKits as SepKits

Item {
    id: _root

    Flickable {
        id: _wrapper
        anchors.fill: parent
        contentWidth: width
        contentHeight: _mainContent.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
        }
        clip: true

        WheelHandler {
            onWheel: event => _wrapper.flick(0, event.angleDelta.y * 8)
        }

        // 主要内容，限定宽度并居中
        Column {
            id: _mainContent
            anchors.horizontalCenter: parent.horizontalCenter
            topPadding: 32
            bottomPadding: 32
            width: 704
            spacing: 32

            // ── 头部：Logo + 标题 ──
            Item {
                width: parent.width
                height: _headerContent.implicitHeight
                Column {
                    id: _headerContent
                    anchors.centerIn: parent
                    spacing: 24

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 384
                        source: "qrc:/assets/images/sea-epoch-logo-modern.png"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        mipmap: true
                    }

                    Column {
                        spacing: 12
                        anchors.horizontalCenter: parent.horizontalCenter
                        bottomPadding: 16 // 与 _mainContent.spacing 共同组成 header 与 card 之间的 48 spacing

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("SepKits")
                            font.pixelSize: 48
                            font.bold: true
                            color: SepKits.Color.foreground
                            horizontalAlignment: Text.AlignHCenter
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("A comprehensive Windows utility toolkit")
                            font.pixelSize: 20
                            color: SepKits.Color.mutedForeground
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }

            // ── About 卡片 ──
            SepKits.Card {
                width: parent.width

                content: Column {
                    width: parent.width
                    spacing: 0

                    Text {
                        bottomPadding: 24
                        text: qsTr("About")
                        font.pixelSize: 22
                        font.bold: true
                        color: SepKits.Color.foreground
                    }

                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap
                        text: qsTr("SepKits is a powerful Windows utility toolkit designed to help you manage your system more efficiently. With a comprehensive collection of tools organized into four main categories, SepKits provides everything you need for system optimization, development, media processing, and more.\n\nOur mission is to make Windows management simple, intuitive, and accessible to everyone, from casual users to power users and developers.")
                        color: SepKits.Color.mutedForeground
                        font.pixelSize: 16
                    }
                }
            }

            // ── Features 卡片 ──
            SepKits.Card {
                width: parent.width

                content: Column {
                    width: parent.width
                    spacing: 0

                    Text {
                        bottomPadding: 24
                        text: qsTr("Features")
                        font.pixelSize: 22
                        font.bold: true
                        color: SepKits.Color.foreground
                    }

                    Flow {
                        width: parent.width
                        spacing: 16

                        Repeater {
                            model: [{
                                    "title": qsTr("System Tools"),
                                    "desc": qsTr("Optimize and customize your Windows system with tools for updates, caching, and appearance.")
                                }, {
                                    "title": qsTr("Dev Tools"),
                                    "desc": qsTr("Essential utilities for developers including code formatting and text generation.")
                                }, {
                                    "title": qsTr("Media Tools"),
                                    "desc": qsTr("Process images and videos with watermarking, format conversion, and compression.")
                                }, {
                                    "title": qsTr("Other Tools"),
                                    "desc": qsTr(
                                                "Additional utilities for theme generation, network testing, and more.")
                                }]

                            delegate: Rectangle {
                                width: (parent.width - parent.spacing) / 2
                                height: 128
                                color: SepKits.Color.muted
                                radius: 12

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 8

                                    Text {
                                        text: modelData.title
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: SepKits.Color.accent
                                    }

                                    Text {
                                        width: parent.width
                                        text: modelData.desc
                                        font.pixelSize: 14
                                        color: SepKits.Color.mutedForeground
                                        wrapMode: Text.WordWrap
                                        maximumLineCount: 3
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Version Information 卡片 ──
            SepKits.Card {
                width: parent.width

                content: Column {
                    width: parent.width
                    spacing: 0

                    Text {
                        bottomPadding: 24
                        text: qsTr("Version Information")
                        font.pixelSize: 22
                        font.bold: true
                        color: SepKits.Color.foreground
                    }

                    Column {
                        width: parent.width

                        Repeater {
                            model: [{
                                    "label": qsTr("Version"),
                                    "value": qsTr("1.0.0")
                                }, {
                                    "label": qsTr("Release Date"),
                                    "value": qsTr("April 20, 2026")
                                }, {
                                    "label": qsTr("License"),
                                    "value": qsTr("MIT")
                                }]

                            delegate: Column {
                                width: parent.width

                                // 仅非首行显示：16px 上间距 + 1px 分隔线 + 16px 下间距
                                Item {
                                    width: parent.width
                                    height: 33
                                    visible: index > 0

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width
                                        height: 1.05 // 设置 1 会引发一个 bug（粗细不一致），让其自己四舍五入
                                        color: SepKits.Color.border
                                    }
                                }

                                RowLayout {
                                    width: parent.width
                                    spacing: 12

                                    Text {
                                        text: modelData.label
                                        color: SepKits.Color.mutedForeground
                                        font.pixelSize: 14
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.value
                                        font.bold: true
                                        color: SepKits.Color.foreground
                                        font.pixelSize: 14
                                        horizontalAlignment: Text.AlignRight
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Built With 卡片 ──
            SepKits.Card {
                width: parent.width

                content: Column {
                    width: parent.width
                    spacing: 0

                    Text {
                        bottomPadding: 24
                        text: qsTr("Built With")
                        font.pixelSize: 22
                        font.bold: true
                        color: SepKits.Color.foreground
                    }

                    Text {
                        bottomPadding: 16
                        width: parent.width
                        font.pixelSize: 16
                        text: qsTr("SepKits is developed based on modern application technologies and open source libraries:")
                        color: SepKits.Color.mutedForeground
                        wrapMode: Text.WordWrap
                    }

                    Column {
                        width: parent.width
                        spacing: 8

                        Repeater {
                            model: [qsTr("Qt Quick - UI framework"), qsTr(
                                    "QWindowKit - frameless window"), qsTr(
                                    "FontAwesome - Icons"), qsTr("Material Symbols - Icons")]

                            delegate: Row {
                                spacing: 8

                                Rectangle {
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: SepKits.Color.accent
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: modelData
                                    color: SepKits.Color.mutedForeground
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
            }

            // ── Connect 卡片 ──
            SepKits.Card {
                width: parent.width

                content: Column {
                    width: parent.width
                    spacing: 0

                    Text {
                        bottomPadding: 24
                        text: qsTr("Connect")
                        font.pixelSize: 22
                        font.bold: true
                        color: SepKits.Color.foreground
                    }

                    Column {
                        width: parent.width
                        spacing: 12

                        Button {
                            id: _githubButton
                            width: parent.width
                            height: 48
                            onClicked: Qt.openUrlExternally("https://github.com/SeaEpoch/SepKits")
                            flat: false

                            leftPadding: 24
                            rightPadding: 24
                            topPadding: 12
                            bottomPadding: 12

                            leftInset: 0
                            rightInset: 0
                            topInset: 0
                            bottomInset: 0

                            y: hovered ? -4 : 0
                            Behavior on y {
                                NumberAnimation {
                                    duration: 200
                                }
                            }

                            background: Rectangle {
                                radius: 16
                                gradient: Gradient {
                                    GradientStop {
                                        position: 0.0
                                        color: SepKits.Color.accent
                                    }
                                    GradientStop {
                                        position: 1.0
                                        color: SepKits.Color.accentSecondary
                                    }
                                }

                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: SepKits.Color.black
                                    shadowBlur: _githubButton.hovered ? 1.8 : 0
                                    shadowOpacity: _githubButton.hovered ? 0.3 : 0
                                    shadowVerticalOffset: _githubButton.hovered ? 6 : 0
                                    shadowHorizontalOffset: _githubButton.hovered ? 3 : 0

                                    Behavior on shadowBlur {
                                        NumberAnimation {
                                            duration: 200
                                        }
                                    }
                                    Behavior on shadowOpacity {
                                        NumberAnimation {
                                            duration: 200
                                        }
                                    }
                                    Behavior on shadowVerticalOffset {
                                        NumberAnimation {
                                            duration: 200
                                        }
                                    }
                                    Behavior on shadowHorizontalOffset {
                                        NumberAnimation {
                                            duration: 200
                                        }
                                    }
                                }
                            }

                            contentItem: RowLayout {
                                spacing: 8

                                SepKits.SvgIcon {
                                    iconSource: SepKits.FontAwesome.githubAlt
                                    width: 18
                                    height: 18
                                    color: "white"
                                }

                                Text {
                                    text: qsTr("View on GitHub")
                                    color: "white"
                                    font.pixelSize: 16
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                SepKits.SvgIcon {
                                    iconSource: SepKits.FontAwesome.arrowUpRightFromSquare
                                    width: 16
                                    height: 16
                                    color: "white"
                                }
                            }
                        }

                        Button {
                            id: _supportButton
                            width: parent.width
                            height: 48
                            onClicked: Qt.openUrlExternally("https://www.seaepoch.com/coffeecompa")
                            flat: true

                            leftPadding: 24
                            rightPadding: 24
                            topPadding: 12
                            bottomPadding: 12

                            leftInset: 0
                            rightInset: 0
                            topInset: 0
                            bottomInset: 0

                            background: Rectangle {
                                radius: 16
                                border.color: SepKits.Color.border
                                color: _supportButton.hovered ? SepKits.Color.muted : SepKits.Color.alpha(
                                                                    SepKits.Color.muted, 0)

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 200
                                    }
                                }
                            }

                            contentItem: RowLayout {
                                spacing: 8

                                SepKits.SvgIcon {
                                    iconSource: SepKits.FontAwesome.heart
                                    width: 18
                                    height: 18
                                    color: SepKits.Color.foreground
                                }

                                Text {
                                    text: qsTr("Support Us")
                                    color: SepKits.Color.foreground
                                    font.pixelSize: 14
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                SepKits.SvgIcon {
                                    iconSource: SepKits.FontAwesome.arrowUpRightFromSquare
                                    width: 16
                                    height: 16
                                    color: SepKits.Color.foreground
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
                width: parent.width
                height: 0.5
                color: SepKits.Color.border
            }

            // ── 页脚 ──
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 4

                Text {
                    text: "Made with"
                    color: SepKits.Color.mutedForeground
                    font.pixelSize: 14
                }

                Text {
                    text: "❤"
                    color: SepKits.Color.accent
                    font.pixelSize: 14
                }

                Text {
                    text: "by SeaEpoch"
                    color: SepKits.Color.mutedForeground
                    font.pixelSize: 14
                }
            }

        }
    }
}
