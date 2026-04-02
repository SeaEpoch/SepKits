import QtQuick

QtObject {
    id: _themeDefault

    // 基础中性色（Neutral）
    readonly property color background: "#ffffff" // 主窗口/页面背景
    readonly property color surface: "#f8f9fa" // 卡片、面板等表面背景
    readonly property color border: "#e0e0e0" // 边框颜色
    readonly property color divider: "#eeeeee" // 分割线

    // 文字颜色（Text）
    readonly property color textPrimary: "#212121" // 主要正文文字
    readonly property color textSecondary: "#666666" // 次要/说明文字
    readonly property color textDisabled: "#9e9e9e" // 禁用状态文字
    readonly property color textPlaceholder: "#9e9e9e" // 输入框占位文字
    readonly property color textInverse: "#ffffff" // 深色背景上的反色文字

    // 交互状态色（States）
    readonly property color hover: "#f0f0f0" // 悬停背景
    readonly property color pressed: "#e0e0e0" // 按下背景
    readonly property color focus: "#d0d0d0" // 焦点/键盘导航
    readonly property color disabledBg: "#f5f5f5" // 禁用组件背景

    // 语义反馈色（Semantic）
    readonly property color primary: "#1976d2" // 品牌主色（按钮、链接等）
    readonly property color secondary: "#9c27b0" // 辅助强调色
    readonly property color success: "#4caf50" // 成功/通过
    readonly property color warning: "#ff9800" // 警告/提示
    readonly property color error: "#e81123" // 错误/危险
    readonly property color info: "#2196f3" // 信息/提示

    // 特殊功能色（Special）
    readonly property color link: "#1976d2" // 超链接
    readonly property color shadow: "#1a000000" // 阴影（带透明度）
    readonly property color overlay: "#80000000" // 模态遮罩/浮层
    readonly property color accent: "#ff4081" // 强调点缀色（可选）
}
