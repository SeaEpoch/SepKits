import QtQuick

QtObject {
    id: _themeDefault

    // 基础中性色（Neutral）
    readonly property color background: "#ffffff" // 主窗口/页面背景
    readonly property color surface: "#f8f9fa" // 卡片、面板等表面背景
    readonly property color border: "#e2e5e7" // 边框颜色
    readonly property color divider: "#f1f2f3" // 分割线

    // 文字颜色（Text）
    readonly property color textPrimary: "#18191c" // 主要正文文字
    readonly property color textSecondary: "#61666d" // 次要/说明文字
    readonly property color textPlaceholder: "#9499a8" // 输入框占位文字
    readonly property color textInverse: "#ffffff" // 深色/浅色背景上的反色文字

    // 交互状态色（States）
    readonly property color hoverBg: "#e2e5e7" // 悬停背景
    readonly property color pressedBg: "#e1e2e3" // 按下背景
    readonly property color focus: "#d0d0d0" // 焦点/键盘导航

    // 语义反馈色（Semantic）
    readonly property color primaryDark: "#e84b84" // 品牌主颜色（深色）
    readonly property color primary: "#ff6699" // 品牌主颜色
    readonly property color primaryLight: "#ff8caf" // 品牌主颜色（浅色）
    readonly property color primaryLighter: "#ffb3ca" // 品牌主颜色（更浅）
    readonly property color primaryExtraLight: "#ffe0e8" // 品牌主颜色（超浅）
    readonly property color primaryUltraLight: "#ffecf1" // 品牌主颜色（极浅）
    readonly property color success: "#67c23a" // 成功/通过
    readonly property color successLight: "#e1f3d8" // 成功/通过（浅色）
    readonly property color successLighter: "#f0f9eb" // 成功/通过（更浅）
    readonly property color warning: "#f7ba2a" // 警告/提示
    readonly property color warningLight: "#faecd8" // 警告/提示（浅色）
    readonly property color warningLighter: "#fdf6ec" // 警告/提示（更浅）
    readonly property color danger: "#ff4949" // 错误/危险
    readonly property color dangerLight: "#fde2e2" // 错误/危险（浅色）
    readonly property color dangerLighter: "#fef0f0" // 错误/危险（更浅）
    readonly property color info: "#409eff" // 信息/提示
    readonly property color infoLight: "#a0cfff" // 信息/提示（浅色）
    readonly property color infoLighter: "#d9ecff" // 信息/提示（更浅）

    // 特殊功能色（Special）
    readonly property color shadow: "#e2e5e7" // 阴影（带透明度）
    readonly property color overlay: "#80000000" // 模态遮罩/浮层
}
