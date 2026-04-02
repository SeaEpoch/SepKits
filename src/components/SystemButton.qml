import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QWindowKit
import SepKits as SepKits

Item {
    id: _root

    // ==================== 信号 ==================== \\
    signal clicked

    // ==================== 属性 ==================== \\
    property alias sysBtnIcon: _icon.iconSource
    property var systemButtonType: WindowAgent.Unknown

    // ==================== 实现 ==================== \\
    Button {
        id: _button
        anchors.fill: parent
        width: height
        height: _root.height

        leftPadding: 4
        topPadding: 4
        rightPadding: 4
        bottomPadding: 4
        leftInset: 0
        topInset: 0
        rightInset: 0
        bottomInset: 0

        contentItem: SepKits.HdSvgIcon {
            id: _icon
            color: {
                if (_root.systemButtonType === WindowAgent.Close && _button.hovered) {
                    return SepKits.Color.white
                } else {
                    return SepKits.Color.black
                }
            }
        }

        background: Rectangle {
            radius: 4
            color: {
                if (!_button.enabled) {
                    return SepKits.Color.gray
                }
                if (_button.pressed || _button.hovered) {
                    if (_root.systemButtonType === WindowAgent.Close) {
                        return SepKits.Color.error
                    }
                    return SepKits.Color.alpha(SepKits.Color.black, 0.16)
                }
                return SepKits.Color.transparent
            }
        }

        onClicked: _root.clicked()
    }
}
