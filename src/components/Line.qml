import QtQuick
import SepKits as SepKits

Item {
    id: root

    // ==================== 枚举定义 ==================== \\
    enum Position {
        Top,
        Bottom,
        Left,
        Right
    }

    // ==================== 属性 ==================== \\
    property int   lineWidth: 1
    property color color: SepKits.Color.black
    property int   position: root.Position.Bottom     // 默认底部

    // ==================== 实现 ==================== \\
    Rectangle {
        id: lineRect

        color: root.color

        // 动态宽度/高度
        width:  (root.position === Line.Position.Left  || root.position === Line.Position.Right)  ? root.lineWidth : parent.width
        height: (root.position === Line.Position.Top   || root.position === Line.Position.Bottom) ? root.lineWidth : parent.height

        // 动态锚点绑定
        anchors.left:   root.position === Line.Position.Left   ? parent.left   : undefined
        anchors.right:  root.position === Line.Position.Right  ? parent.right  : undefined
        anchors.top:    root.position === Line.Position.Top    ? parent.top    : undefined
        anchors.bottom: root.position === Line.Position.Bottom ? parent.bottom : undefined
    }
}