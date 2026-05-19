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


            SepKits.CategoryPageHeader {
                width: parent.width
                categoryLabel: "CONFIGURATION"
                title: qsTr("Settings")
                subtitle: qsTr("Customize your SepWinKits experience")
            }

            // 基础设置
            SepKits.Card {
                width: parent.width

                content: Column {
                    width: parent.width
                    spacing: 24

                    Text {
                        bottomPadding: 24
                        text: qsTr("Basic Settings")
                        font.pixelSize: 22
                        font.bold: true
                        color: SepKits.Color.foreground
                    }

                    // 语言设置
                    SepKits.ComboBox {
                        width: parent.width
                        label: qsTr("Language")
                        model: SepKits.LanguageManager.model
                        currentIndex: SepKits.LanguageManager.currentIndex
                        onActivated: index => SepKits.LanguageManager.switchLanguage(index)
                    }

                    // 分隔线
                    Rectangle {
                        width: parent.width
                        height: 1.05
                        color: SepKits.Color.border
                    }

                    // 关闭程序时的行为
                    SepKits.ComboBox {
                        width: parent.width
                        label: qsTr("When closing the program")
                        model: SepKits.AppSettings.closeBehaviorModel
                        currentIndex: SepKits.AppSettings.closeBehavior
                        onActivated: index => SepKits.AppSettings.closeBehavior = index
                    }

                    // 分隔线
                    Rectangle {
                        width: parent.width
                        height: 1.05
                        color: SepKits.Color.border
                    }

                    // 模式切换
                    RowLayout {
                        width: parent.width

                        Column {
                            Layout.alignment: Qt.AlignLeft
                            Text {
                                text: qsTr("Dark / Light Theme")
                                color: SepKits.Color.foreground
                                font.pixelSize: 14
                            }

                            Text {
                                text: SepKits.Color.currTheme === SepKits.Color.ThemeName.Dark
                                      ? qsTr("Current Theme: Dark") : qsTr("Current Theme: Light")
                                color: SepKits.Color.mutedForeground
                                font.pixelSize: 12
                            }
                        }

                        Button {
                            id: _switchThemeBtn
                            Layout.alignment: Qt.AlignRight

                            leftPadding: 16
                            rightPadding: 16
                            topPadding: 8
                            bottomPadding: 8

                            leftInset: 0
                            rightInset: 0
                            topInset: 0
                            bottomInset: 0

                            onClicked: {
                                var nextTheme = SepKits.Color.currTheme === SepKits.Color.ThemeName.Dark
                                    ? SepKits.Color.ThemeName.Light
                                    : SepKits.Color.ThemeName.Dark
                                SepKits.Color.switchTheme(nextTheme)
                            }


                            background: Rectangle {
                                radius: 12
                                color: SepKits.Color.accent
                                opacity: _switchThemeBtn.hovered ? 0.9 : 1.0
                            }

                            contentItem: Text {
                                text: SepKits.Color.currTheme === SepKits.Color.ThemeName.Dark
                                      ? qsTr("Switch to Light") : qsTr("Switch to Dark")
                                color: SepKits.Color.accentForeground
                                font.pixelSize: 14
                            }
                        }
                    }

                    // 分隔线
                    Rectangle {
                        width: parent.width
                        height: 1.05
                        color: SepKits.Color.border
                    }

                    // 管理员启动
                    RowLayout {
                        width: parent.width

                        Column {
                            Layout.alignment: Qt.AlignLeft
                            Text {
                                text: qsTr("Launch as Administrator")
                                color: SepKits.Color.foreground
                                font.pixelSize: 14
                            }

                            Text {
                                text: qsTr("Auto-elevate on next startup")
                                color: SepKits.Color.mutedForeground
                                font.pixelSize: 12
                            }
                        }

                        Switch {
                            id: _launchAsAdminSwitch
                            Layout.alignment: Qt.AlignRight
                            checked: SepKits.SettingsStore.launchAsAdmin
                            onToggled: SepKits.SettingsStore.launchAsAdmin = checked

                            indicator: Rectangle {
                                implicitWidth: 44
                                implicitHeight: 24
                                radius: 12
                                color: _launchAsAdminSwitch.checked
                                    ? SepKits.Color.accent : SepKits.Color.muted
                                border.color: _launchAsAdminSwitch.checked
                                    ? SepKits.Color.accent : SepKits.Color.border

                                Rectangle {
                                    x: _launchAsAdminSwitch.checked ? parent.width - width - 3 : 3
                                    y: (parent.height - height) / 2
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: _launchAsAdminSwitch.checked
                                        ? SepKits.Color.accentForeground : SepKits.Color.mutedForeground
                                    Behavior on x {
                                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
