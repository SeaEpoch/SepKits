import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import SepKits as SepKits

// Qt6 官方兼容模块（DropShadow 必须使用，无法完全避免）
Item {
    id: _root

    // ==================== 信号 ==================== \\
    signal clicked
    signal doubleClicked

    // ==================== 属性 ==================== \\
    property alias icon: _icon.iconSource
    property real radius: 4
    property real borderWidth: 1

    // 阴影/边框/图标显示开关
    property bool iconEnable: true
    property bool backgroundEnable: true
    property bool borderEnable: false
    property bool shadowEnable: false

    property real topPadding: 4
    property real rightPadding: 4
    property real bottomPadding: 4
    property real leftPadding: 4

    property real topInset: 0
    property real rightInset: 0
    property real bottomInset: 0
    property real leftInset: 0

    // 正常/悬浮/按下颜色属性
    // 注意：当颜色的变化携带动画时，透明度和颜色原值是无法同时发生变化的
    // 比如从 normalBackgroundColor -> hoverBackgroundColor
    // 必须保证透明度一致（#22f0f0f0 -> #22fafafa）或者颜色原值一致（#22f0f0f0 -> #33f0f0f0）！
    property color normalIconColor: SepKits.Color.textPrimary
    property color normalBackgroundColor: SepKits.Color.alpha(SepKits.Color.hoverBg, 0)
    property color normalBorderColor: SepKits.Color.alpha(SepKits.Color.border, 0)
    property color normalShadowColor: SepKits.Color.shadow

    property color hoverIconColor: SepKits.Color.primary
    property color hoverBackgroundColor: SepKits.Color.hoverBg
    property color hoverBorderColor: SepKits.Color.border
    property color hoverShadowColor: SepKits.Color.shadow

    property color pressedIconColor: SepKits.Color.primaryDark
    property color pressedBackgroundColor: SepKits.Color.pressedBg
    property color pressedBorderColor: SepKits.Color.border
    property color pressedShadowColor: SepKits.Color.shadow

    property color disabledIconColor: SepKits.Color.disabled(_root.normalIconColor)
    property color disabledBackgroundColor: SepKits.Color.disabled(_root.normalBackgroundColor)
    property color disabledBorderColor: SepKits.Color.disabled(_root.normalBorderColor)
    property color disabledShadowColor: SepKits.Color.disabled(_root.normalShadowColor)

    // 正真决定当下显示什么颜色
    property color currentIconColor: {
        if (!_button.enabled) {
            return _root.disabledIconColor
        } else if (_button.pressed) {
            return _root.pressedIconColor
        } else if (_button.hovered) {
            return _root.hoverIconColor
        } else {
            return _root.normalIconColor
        }
    }
    property color currentBackgroundColor: {
        if (!_button.enabled) {
            return _root.disabledBackgroundColor
        } else if (_button.pressed) {
            return _root.pressedBackgroundColor
        } else if (_button.hovered) {
            return _root.hoverBackgroundColor
        } else {
            return _root.normalBackgroundColor
        }
    }
    property color currentBorderColor: {
        if (!_button.enabled) {
            return _root.disabledBorderColor
        } else if (_button.pressed) {
            return _root.pressedBorderColor
        } else if (_button.hovered) {
            return _root.hoverBorderColor
        } else {
            return _root.normalBorderColor
        }
    }
    property color currentShadowColor: {
        if (!_button.enabled) {
            return _root.disabledShadowColor
        } else if (_button.pressed) {
            return _root.pressedShadowColor
        } else if (_button.hovered) {
            return _root.hoverShadowColor
        } else {
            return _root.normalShadowColor
        }
    }

    // 动画开关
    property bool colorAnimationEnable: true
    property bool scaleAnimationEnable: false
    property bool shakeAnimationEnable: false

    // 动画参数
    property real colorAnimationDuration: 122
    property real scaleAnimationDuration: 122
    property real shakeAnimationDuration: 122
    property real shakeAnimationAmplitude: 32

    // 阴影
    property Component shadow: DropShadow {
        color: _root.currentShadowColor
        radius: 6
        samples: 9
        horizontalOffset: 1
        verticalOffset: 2
        transparentBorder: true
    }

    // 缩放动画种类
    enum ScaleType {
        ScaleFull,
        ScaleZoomIn,
        ScaleZoomOut
    }
    property int scaleType: IconButton.ScaleFull

    // 代理按钮的 hovered 属性
    property alias hovered: _button.hovered

    scale: {
        // 先判断动画总开关：关闭直接返回1.0
        if (!_root.scaleAnimationEnable || !_root.enabled) {
            return 1.0
        }
        // 根据缩放类型判断
        if (_root.scaleType === IconButton.ScaleZoomIn) {
            // 放大类型：按下缩小
            return _button.pressed ? 0.88 : 1.0
        } else if (_root.scaleType === IconButton.ScaleZoomOut) {
            // 缩小类型：悬浮放大
            return _button.hovered ? 1.22 : 1.0
        } else {
            // 默认全部：悬浮放大 + 按下微缩
            // 注意一定先判断按压状态，因为 pressed === true 时一定有 hovered === true
            if (_button.pressed) {
                return 0.96
            } else if (_button.hovered) {
                return 1.22
            } else {
                return 1.0
            }
        }
    }

    enabled: true

    // 背景 + 边框（未改动）
    Button {
        id: _button
        anchors.fill: parent

        enabled: _root.enabled

        topPadding: _root.topPadding
        rightPadding: _root.rightPadding
        bottomPadding: _root.bottomPadding
        leftPadding: _root.leftPadding

        topInset: _root.topInset
        rightInset: _root.rightInset
        bottomInset: _root.bottomInset
        leftInset: _root.leftInset

        // ICON
        contentItem: HdSvgIcon {
            id: _icon
            color: _root.currentIconColor
            visible: _root.iconEnable
        }

        // 背景
        background: Item {
            id: _shadowWrapper

            layer.enabled: _root.shadowEnable && _root.backgroundEnable
            layer.effect: _root.shadow

            Rectangle {
                id: _background
                anchors.fill: parent
                visible: _root.backgroundEnable

                radius: _root.radius
                border.width: _root.borderEnable ? _root.borderWidth : 0
                border.color: _root.currentBorderColor
                color: _root.currentBackgroundColor
            }
        }

        onClicked: {
            // 点击事件转发
            _root.clicked()

            // 点击抖动动画
            if (_root.shakeAnimationEnable) {
                _shakeAnimation.start()
            }
        }
        onDoubleClicked: _root.doubleClicked()

    }

    // ==================== 动画 ==================== \\
    // 四个颜色动画
    Behavior on currentBackgroundColor {
        enabled: _root.colorAnimationEnable && _root.enabled
        ColorAnimation {
            duration: _root.colorAnimationDuration
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on currentIconColor {
        enabled: _root.colorAnimationEnable && _root.enabled
        ColorAnimation {
            duration: _root.colorAnimationDuration / 2
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on currentBorderColor {
        enabled: _root.colorAnimationEnable && _root.enabled
        ColorAnimation {
            duration: _root.colorAnimationDuration / 2
            easing.type: Easing.InOutQuad
        }
    }
    Behavior on currentShadowColor {
        enabled: _root.colorAnimationEnable && _root.enabled
        ColorAnimation {
            duration: _root.colorAnimationDuration / 2
            easing.type: Easing.InOutQuad
        }
    }

    // 缩放动画
    Behavior on scale {
        enabled: _root.scaleAnimationEnable && _root.enabled
        NumberAnimation {
            duration: _root.scaleAnimationDuration
            easing.type: Easing.InOutQuad
        }
    }

    // --- 抖动动画（关键） ---
    SequentialAnimation {
        id: _shakeAnimation
        running: false

        RotationAnimation {
            target: _icon
            from: 0
            to: -1.0 * _root.shakeAnimationAmplitude
            duration: _root.shakeAnimationDuration / 8
        }
        RotationAnimation {
            target: _icon
            from: -1.0 * _root.shakeAnimationAmplitude
            to: _root.shakeAnimationAmplitude
            duration: _root.shakeAnimationDuration / 4
        }
        RotationAnimation {
            target: _icon
            from: _root.shakeAnimationAmplitude
            to: -1.0 * _root.shakeAnimationAmplitude
            duration: _root.shakeAnimationDuration / 4
        }
        RotationAnimation {
            target: _icon
            from: -1.0 * _root.shakeAnimationAmplitude
            to: _root.shakeAnimationAmplitude
            duration: _root.shakeAnimationDuration / 4
        }
        RotationAnimation {
            target: _icon
            from: _root.shakeAnimationAmplitude
            to: 0
            duration: _root.shakeAnimationDuration / 8
        }
    }
}
