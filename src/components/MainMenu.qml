import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import SepKits as SepKits

Item {
    id: _root
    clip: true

    required property int menuWidth
    property alias menuList: _menuListView.model

    property bool opened: false

    // 打开菜单
    function openMenu() {
        _root.opened = true
    }

    // 关闭菜单
    function closeMenu() {
        _root.opened = false
    }

    // 切换菜单
    function toggleMenu(newList) {
        // 使用数组长度 + 第一个元素名称判断是否为同一菜单
        const currentList = _menuListView.model
        const isSameMenu = currentList && currentList.length === newList.length
                         && currentList.length > 0 && currentList[0].name === newList[0].name

        if (isSameMenu || !_root.opened) {
            _root.opened = !_root.opened
        }

        // 强制置空以触发 remove/populate 动画（推荐保留）
        _menuListView.model = null
        Qt.callLater(() => {
                         _menuListView.model = newList
                     }) // 使用 callLater 更稳定
    }

    // 点击非菜单区域关闭菜单项
    MouseArea {
        anchors.fill: parent
        onClicked: _root.closeMenu()
    }

    // 菜单项
    FocusScope {
        id: _menu
        anchors {
            top: parent.top
            bottom: parent.bottom
        }
        x: opened ? 0 : -_root.menuWidth - _shadow.radius - _shadow.horizontalOffset
        width: _root.menuWidth

        focus: _root.opened // 菜单项打开自动获取焦点，监听键盘事件
        Keys.onEscapePressed: _root.closeMenu() // 按下 ESC 按键自动关闭菜单项
        onFocusChanged: {
            // 只要菜单未关闭就应该保持焦点
            if (_root.opened && !activeFocus) {
                forceActiveFocus()
            }
        }

        // 分离子元素和背景（仅用于阴影渲染）
        Rectangle {
            id: _menuBackground
            anchors.fill: parent
            color: SepKits.Color.background
        }

        // 阴影
        DropShadow {
            id: _shadow
            anchors.fill: _menuBackground
            source: _menuBackground

            horizontalOffset: 3
            verticalOffset: 0

            radius: 6
            samples: 9
            color: SepKits.Color.shadow
        }

        // 菜单项（ListView 叠加在背景上方，保持原清晰度<不受 shadow 渲染影响>）
        ListView {
            id: _menuListView
            anchors.fill: _menu
            anchors {
                topMargin: 8
                rightMargin: 16
                bottomMargin: 8
                leftMargin: 16
            }
            spacing: 8

            delegate: _menuItem

            populate: Transition {
                id: _loadMenuListTrans
                SequentialAnimation {
                    // 先不显示元素
                    PropertyAnimation {
                        properties: "visible"
                        to: "false"
                        duration: 0
                    }
                    PauseAnimation {
                        duration: (_loadMenuListTrans.ViewTransition.index
                                   - _loadMenuListTrans.ViewTransition.targetIndexes[0]) * 32
                    }
                    // 准备开始动画，显示元素
                    PropertyAnimation {
                        properties: "visible"
                        to: "true"
                        duration: 0
                    }
                    NumberAnimation {
                        properties: "x"
                        from: -_menu.width
                        to: 0
                        duration: 256
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }

        // 菜单子项
        Component {
            id: _menuItem
            Rectangle {
                id: _menuListWrapper
                width: ListView.view.width
                height: 64
                color: SepKits.Color.background
                border.color: SepKits.Color.border
                border.width: 1
                radius: 4
                clip: true

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    // 菜单项——Icon 图标
                    Rectangle {
                        id: _iconWrapper
                        Layout.preferredWidth: height
                        Layout.fillHeight: true
                        color: SepKits.Color.info
                        radius: width / 2

                        SepKits.HdSvgIcon {
                            id: _icon
                            anchors.fill: parent
                            anchors.margins: parent.width * 0.2
                            iconSource: modelData.icon ?? ""
                            color: SepKits.Color.textInverse
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 128
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // 菜单项——标题
                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            text: modelData.name ?? ""
                            color: SepKits.Color.textPrimary
                            font.pointSize: 10

                            // 只有一行，并且超出自动截断省略
                            elide: Label.ElideRight
                            maximumLineCount: 1
                        }

                        // 菜单项——说明
                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignLeft
                            text: modelData.desc ?? ""
                            color: SepKits.Color.textSecondary
                            font.pointSize: 8

                            // 只有一行，并且超出自动截断省略
                            elide: Label.ElideRight
                            maximumLineCount: 1
                        }
                    }
                }

                // Hover 处理（变色）
                HoverHandler {
                    id: _hoverHandler
                    onHoveredChanged: {
                        _menuListWrapper.color = hovered ? SepKits.Color.hoverBg : SepKits.Color.background
                        _iconWrapper.color = hovered ? SepKits.Color.primaryDark : SepKits.Color.info
                    }
                }

                // 点击处理
                TapHandler {
                    id: _tapHandler
                    onTapped: {
                        _menuItemClickedAnimation.start()
                        console.log("[MainMenu] 已选择：", modelData.name)
                    }
                }

                SequentialAnimation {
                    id: _menuItemClickedAnimation
                    running: false

                    property real oldScaleValue: _menuListWrapper.scale

                    NumberAnimation {
                        target: _menuListWrapper
                        property: "scale"
                        to: 0.98
                        duration: 64
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: _menuListWrapper
                        property: "scale"
                        to: _menuItemClickedAnimation.oldScaleValue
                        duration: 64
                        easing.type: Easing.InOutQuad
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 128
                    }
                }
            }
        }

        // 动画
        Behavior on x {
            NumberAnimation {
                duration: 184
                easing.type: Easing.InOutQuad
            }
        }
    }
}
