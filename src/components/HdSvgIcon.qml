import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import SepKits as SepKits

Item {
    id: _root

    // ==================== 属性 ==================== \\
    property alias iconSource: _icon.source
    property color color: SepKits.Color.black

    // ==================== 实现 ==================== \\
    // 加载 SVG
    Image {
        id: _icon
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        mipmap: true
        smooth: true

        // 高清处理
        sourceSize.width: width * Screen.devicePixelRatio * 2
        sourceSize.height: height * Screen.devicePixelRatio * 2

        // 必须隐藏原渲染组件，以应用特效效果
        opacity: 0
    }

    // 特效
    MultiEffect {
        id: _effect
        anchors.fill: _icon
        source: _icon
        colorization: 1.0
        colorizationColor: _root.color
        brightness: 1.0
    }
}
