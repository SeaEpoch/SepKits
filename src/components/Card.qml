// Card.qml
import QtQuick
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import SepKits as SepKits

Rectangle {
    id: _root
    implicitWidth: 346
    implicitHeight: _contentArea.implicitHeight + contentMargins * 2
    radius: 16
    color: SepKits.Color.card
    border.width: 1
    border.color: SepKits.Color.border

    // 内容区边距
    property int contentMargins: 32

    // 将子项路由到内容容器
    default property alias content: _contentArea.data

    // 暴露 hover 状态，供子内容响应（只读）
    readonly property bool hovered: _hover.hovered

    signal clicked()

    // ── Hover 检测 ──────────────────────────────────────────
    HoverHandler {
        id: _hover
    }

    // ── 点击检测 ──────────────────────────────────────────
    TapHandler {
        onTapped: _root.clicked()
    }

    // ── 阴影 ────────────────────────────────────────────────
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: SepKits.Color.black
        shadowBlur: _hover.hovered ? 1.8 : 0.6
        shadowOpacity: _hover.hovered ? 0.3 : 0.1
        shadowVerticalOffset: _hover.hovered ? 6 : 2
        shadowHorizontalOffset: _hover.hovered ? 3 : 1

        Behavior on shadowBlur        { NumberAnimation { duration: 200 } }
        Behavior on shadowOpacity     { NumberAnimation { duration: 200 } }
        Behavior on shadowVerticalOffset   { NumberAnimation { duration: 200 } }
        Behavior on shadowHorizontalOffset { NumberAnimation { duration: 200 } }
    }

    // ── Hover 渐变背景 ───────────────────────────────────────
    Rectangle {
        id: _gradientMask
        anchors.fill: parent
        radius: _root.radius
        visible: false
    }
    LinearGradient {
        anchors.fill: _gradientMask
        source: _gradientMask
        opacity: _hover.hovered ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        start: Qt.point(0, 0)
        end: Qt.point(width, height)
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(SepKits.Color.accent.r, SepKits.Color.accent.g,
                               SepKits.Color.accent.b, 0.03)
            }
            GradientStop { position: 1.0; color: SepKits.Color.transparent }
        }
    }

    // ── 内容区 ───────────────────────────────────────────────
    Item {
        id: _contentArea
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: _root.contentMargins
        }
        implicitHeight: childrenRect.height
    }
}