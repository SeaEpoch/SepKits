import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import SepKits as SepKits

Rectangle {
    id: _root

    signal selectedChanged(int selectedBtnIndex)

    // 全局选中索引
    property int currentIndex: 0

    QtObject {
        id: _private
        readonly property var functionMenuList: [{
                "name": qsTr("Home"),
                "icon": SepKits.FontAwesome.houseChimney
            }, {
                "name": qsTr("System Tools"),
                "icon": SepKits.FontAwesome.windows
            }, {
                "name": qsTr("Dev Tools"),
                "icon": SepKits.FontAwesome.laptopCode
            }, {
                "name": qsTr("Media Tools"),
                "icon": SepKits.FontAwesome.photoFilm
            }, {
                "name": qsTr("Other Tools"),
                "icon": SepKits.FontAwesome.boxOpen
            }]
        readonly property var appMenuList: [{
                "name": qsTr("Settings"),
                "icon": SepKits.FontAwesome.gear
            }, {
                "name": qsTr("About"),
                "icon": SepKits.FontAwesome.infoCircle
            }]
    }

    color: SepKits.Color.background

    ColumnLayout {
        anchors.fill: parent
        anchors.rightMargin: 1 // 为右侧边框留出位置
        spacing: 0

        // 顶部 App 信息区
        RowLayout {
            id: _appInfoWrapper
            Layout.fillWidth: true
            Layout.margins: 24
            spacing: 12

            Item {
                id: _logoWrapper
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48

                // Logo 的渐变色背景
                Rectangle {
                    id: _logoBg
                    anchors.fill: parent
                    radius: 8
                    layer.enabled: true
                    layer.effect: LinearGradient {
                        start: Qt.point(0, 0)
                        end: Qt.point(_logoBg.width, _logoBg.height)
                        gradient: Gradient {
                            GradientStop {
                                position: 0.0
                                color: "#0052FF"
                            }
                            GradientStop {
                                position: 0.5
                                color: "#22D3EE"
                            }
                            GradientStop {
                                position: 1.0
                                color: "#4D7CFF"
                            }
                        }
                    }
                }

                // Logo
                Image {
                    id: _logo
                    anchors.fill: parent
                    anchors.margins: 8
                    source: "qrc:/assets/images/sepwinkits-logo-modern.png"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    smooth: true
                }
            }

            // 文字说明
            Column {
                Text {
                    id: _appName
                    text: qsTr("SepKits")
                    font.pointSize: 16
                    font.bold: true
                    color: SepKits.Color.foreground
                }
                Text {
                    id: _version
                    text: qsTr("v1.0.0")
                    font.pointSize: 8
                    color: SepKits.Color.mutedForeground
                }
            }
        }

        // 分割线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: SepKits.Color.border
        }

        // 功能菜单
        ListView {
            id: _functionMenu
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.leftMargin: 0
            Layout.rightMargin: 0
            Layout.topMargin: 18
            Layout.bottomMargin: 18
            spacing: 0
            clip: true
            model: _private.functionMenuList
            boundsBehavior: Flickable.StopAtBounds // 禁止越界滚动

            delegate: MenuButton {
                width: _functionMenu.width // 显式绑定宽度，防止布局坍塌导致重叠
                // 注意：JS 数组模型中，数据通过 modelData 访问
                btnText: modelData.name
                iconSource: modelData.icon
                indexKey: index

                onClicked: key => {
                               _root.currentIndex = indexKey
                               _root.selectedChanged(_root.currentIndex)
                           }
            }
        }

        // 分割线
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: SepKits.Color.border
        }

        // 底部固定按钮
        ListView {
            id: _appMenu
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: contentHeight // 由子元素决定高度
            Layout.leftMargin: 0
            Layout.rightMargin: 0
            Layout.topMargin: 18
            Layout.bottomMargin: 12
            spacing: 0
            clip: true
            model: _private.appMenuList
            interactive: false // 禁止滚动交互

            delegate: MenuButton {
                width: _appMenu.width // 显式绑定宽度，防止布局坍塌导致重叠
                // 注意：JS 数组模型中，数据通过 modelData 访问
                btnText: modelData.name
                iconSource: modelData.icon
                indexKey: index + _private.functionMenuList.length

                onClicked: key => {
                               _root.currentIndex = indexKey
                               _root.selectedChanged(_root.currentIndex)
                           }
            }
        }
    }

    // --- 菜单通用按钮组件 ---
    component MenuButton: Item {
        id: _menuBtnRoot
        signal clicked(int ikey)

        property string btnText: ""
        property int indexKey: -1
        property var iconSource

        // margins(left, top, right, bottom)
        // 第一个Item margins 为 (12, 6, 12, 12)，后面的 Item margins 为 (12, 0, 12, 12)
        // 所以高度上第一个 Item 的高度要比其他 Item 高 6
        height: index === 0 ? 62 : 56 // 注意这里需要使用 index 而不是 indexKey

        readonly property bool isSelected: _root.currentIndex === indexKey

        DropShadow {
            anchors.fill: _menuBtnWrapper
            horizontalOffset: 0
            verticalOffset: 4 // 对应 box-shadow 中的 4px
            radius: 14 // 对应 box-shadow 中的 14px
            samples: 21 // 采样数，值越大阴影越细腻
            color: "#400052FF" // 0.25 透明度的蓝色 (0.25 * 255 ≈ 40 hex)
            visible: isSelected // 仅在选中状态下显示
            source: _menuBtnWrapper // 指向要产生阴影的源物体
        }

        Rectangle {
            id: _menuBtnWrapper
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            anchors.topMargin: index === 0 ? 6 : 0
            anchors.bottomMargin: 12
            radius: 8
            color: isSelected ? SepKits.Color.accent : (_menuBtnMouseArea.containsMouse ? SepKits.Color.muted : SepKits.Color.transparent)

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.topMargin: 12
                anchors.rightMargin: 16
                anchors.bottomMargin: 12
                spacing: 12

                SepKits.SvgIcon {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    iconSource: _menuBtnRoot.iconSource
                    color: isSelected ? SepKits.Color.white : SepKits.Color.foreground
                }

                Text {
                    text: btnText
                    Layout.fillWidth: true
                    font.pixelSize: 14
                    color: isSelected ? SepKits.Color.white : SepKits.Color.foreground
                    elide: Text.ElideRight
                }
            }

            MouseArea {
                id: _menuBtnMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    _menuBtnRoot.clicked(indexKey)
                }
            }
        }
    }

    // 右侧边框
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 1
        color: SepKits.Color.border
    }
}
