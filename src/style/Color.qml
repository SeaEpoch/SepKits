pragma Singleton

import QtQuick
import SepKits as SepKits

QtObject {
    id: _color

    // 主题枚举名
    enum ThemeName {
        Default = 0
    }

    // 主题列表（可用主题）
    property QtObject _defaultTheme: SepKits.DefaultTheme {}
    readonly property var themeLists: [_defaultTheme]

    // 主题类型
    property int currTheme: Color.ThemeName.Default

    // 主题切换函数
    function switchTheme(themeType) {
        if (themeLists[themeType] !== undefined) {
            currTheme = themeType
        } else {
            console.warn("[Color.qml]Unknown theme enum value: ", themeType)
        }
    }

    /////
    // 参数1: color (string 或 color 类型，如 "#1976d2" 或 Colors.primary)
    // 参数2: alpha (0.0 ~ 1.0 为归一化透明度；0~255 为整数透明度)
    // 返回: "#AARRGGBB" 格式字符串（前两位为透明度，后六位为原颜色Hex）
    function alpha(baseColor, alphaValue) {
        // 统一转为字符串并移除可能存在的 "#"
        let hex = String(baseColor).replace("#", "").toUpperCase()

        // 如果输入是 8 位颜色（如 #AARRGGBB），取后 6 位颜色部分
        if (hex.length === 8) {
            hex = hex.substring(2)
        } else if (hex.length === 6) {
            // 正常 6 位颜色，保持不变
        } else {
            console.warn("Colors.alpha: 不支持的颜色格式", baseColor)
            return baseColor
        }

        // 处理透明度：支持 0~1 或 0~255
        let a = 0
        if (alphaValue >= 0 && alphaValue <= 1) {
            a = Math.round(alphaValue * 255)
        } else if (alphaValue >= 0 && alphaValue <= 255) {
            a = Math.round(alphaValue)
        } else {
            console.warn("Colors.alpha: 透明度值超出范围", alphaValue)
            a = 255
        }

        // 转为两位十六进制（补零）
        let alphaHex = a.toString(16).toUpperCase().padStart(2, "0")

        return "#" + alphaHex + hex
    }

    // ==================== 功能颜色 ==================== \\
    // 基础中性色（Neutral）
    readonly property color background: themeLists[currTheme].background // 主窗口/页面背景
    readonly property color surface: themeLists[currTheme].surface // 卡片、面板等表面背景
    readonly property color border: themeLists[currTheme].border // 边框颜色
    readonly property color divider: themeLists[currTheme].divider // 分割线

    // 文字颜色（Text）
    readonly property color textPrimary: themeLists[currTheme].textPrimary // 主要正文文字
    readonly property color textSecondary: themeLists[currTheme].textSecondary // 次要/说明文字
    readonly property color textDisabled: themeLists[currTheme].textDisabled // 禁用状态文字
    readonly property color textPlaceholder: themeLists[currTheme].textPlaceholder // 输入框占位文字
    readonly property color textInverse: themeLists[currTheme].textInverse // 深色背景上的反色文字

    // 交互状态色（States）
    readonly property color hover: themeLists[currTheme].hover // 悬停背景
    readonly property color pressed: themeLists[currTheme].pressed // 按下背景
    readonly property color focus: themeLists[currTheme].focus // 焦点/键盘导航
    readonly property color disabledBg: themeLists[currTheme].disabledBg // 禁用组件背景

    // 语义反馈色（Semantic）
    readonly property color primary: themeLists[currTheme].primary // 品牌主色（按钮、链接等）
    readonly property color secondary: themeLists[currTheme].secondary // 辅助强调色
    readonly property color success: themeLists[currTheme].success // 成功/通过
    readonly property color warning: themeLists[currTheme].warning // 警告/提示
    readonly property color error: themeLists[currTheme].error // 错误/危险
    readonly property color info: themeLists[currTheme].info // 信息/提示

    // 特殊功能色（Special）
    readonly property color link: themeLists[currTheme].link // 超链接
    readonly property color shadow: themeLists[currTheme].shadow // 阴影（带透明度）
    readonly property color overlay: themeLists[currTheme].overlay // 模态遮罩/浮层
    readonly property color accent: themeLists[currTheme].accent // 强调点缀色（可选）

    // ==================== 基本颜色 ==================== \\
    readonly property color transparent: "transparent"

    readonly property color aliceBlue: "#f0f8ff"
    readonly property color antiqueWhite: "#faebd7"
    readonly property color aqua: "#00ffff"
    readonly property color aquamarine: "#7fffd4"
    readonly property color azure: "#f0ffff"
    readonly property color beige: "#f5f5dc"
    readonly property color bisque: "#ffe4c4"
    readonly property color black: "#000000"
    readonly property color blanchedAlmond: "#ffebcd"
    readonly property color blue: "#0000ff"
    readonly property color blueViolet: "#8a2be2"
    readonly property color brown: "#a52a2a"
    readonly property color burlyWood: "#deb887"
    readonly property color cadetBlue: "#5f9ea0"
    readonly property color chartreuse: "#7fff00"
    readonly property color chocolate: "#d2691e"
    readonly property color coral: "#ff7f50"
    readonly property color cornflowerBlue: "#6495ed"
    readonly property color cornsilk: "#fff8dc"
    readonly property color crimson: "#dc143c"
    readonly property color cyan: "#00ffff"
    readonly property color darkBlue: "#00008b"
    readonly property color darkCyan: "#008b8b"
    readonly property color darkGoldenRod: "#b8860b"
    readonly property color darkGray: "#a9a9a9"
    readonly property color darkGreen: "#006400"
    readonly property color darkGrey: "#a9a9a9"
    readonly property color darkKhaki: "#bdb76b"
    readonly property color darkMagenta: "#8b008b"
    readonly property color darkOliveGreen: "#556b2f"
    readonly property color darkOrange: "#ff8c00"
    readonly property color darkOrchid: "#9932cc"
    readonly property color darkRed: "#8b0000"
    readonly property color darkSalmon: "#e9967a"
    readonly property color darkSeaGreen: "#8fbc8f"
    readonly property color darkSlateBlue: "#483d8b"
    readonly property color darkSlateGray: "#2f4f4f"
    readonly property color darkSlateGrey: "#2f4f4f"
    readonly property color darkTurquoise: "#00ced1"
    readonly property color darkViolet: "#9400d3"
    readonly property color deepPink: "#ff1493"
    readonly property color deepSkyBlue: "#00bfff"
    readonly property color dimGray: "#696969"
    readonly property color dimGrey: "#696969"
    readonly property color dodgerBlue: "#1e90ff"
    readonly property color fireBrick: "#b22222"
    readonly property color floralWhite: "#fffaf0"
    readonly property color forestGreen: "#228b22"
    readonly property color fuchsia: "#ff00ff"
    readonly property color gainsboro: "#dcdcdc"
    readonly property color ghostWhite: "#f8f8ff"
    readonly property color gold: "#ffd700"
    readonly property color goldenRod: "#daa520"
    readonly property color gray: "#808080"
    readonly property color grey: "#808080"
    readonly property color green: "#008000"
    readonly property color greenYellow: "#adff2f"
    readonly property color honeyDew: "#f0fff0"
    readonly property color hotPink: "#ff69b4"
    readonly property color indianRed: "#cd5c5c"
    readonly property color indigo: "#4b0082"
    readonly property color ivory: "#fffff0"
    readonly property color khaki: "#f0e68c"
    readonly property color lavender: "#e6e6fa"
    readonly property color lavenderBlush: "#fff0f5"
    readonly property color lawnGreen: "#7cfc00"
    readonly property color lemonChiffon: "#fffacd"
    readonly property color lightBlue: "#add8e6"
    readonly property color lightCoral: "#f08080"
    readonly property color lightCyan: "#e0ffff"
    readonly property color lightGoldenRodYellow: "#fafad2"
    readonly property color lightGray: "#d3d3d3"
    readonly property color lightGreen: "#90ee90"
    readonly property color lightGrey: "#d3d3d3"
    readonly property color lightPink: "#ffb6c1"
    readonly property color lightSalmon: "#ffa07a"
    readonly property color lightSeaGreen: "#20b2aa"
    readonly property color lightSkyBlue: "#87cefa"
    readonly property color lightSlateGray: "#778899"
    readonly property color lightSlateGrey: "#778899"
    readonly property color lightSteelBlue: "#b0c4de"
    readonly property color lightYellow: "#ffffe0"
    readonly property color lime: "#00ff00"
    readonly property color limeGreen: "#32cd32"
    readonly property color linen: "#faf0e6"
    readonly property color magenta: "#ff00ff"
    readonly property color maroon: "#800000"
    readonly property color mediumAquaMarine: "#66cdaa"
    readonly property color mediumBlue: "#0000cd"
    readonly property color mediumOrchid: "#ba55d3"
    readonly property color mediumPurple: "#9370db"
    readonly property color mediumSeaGreen: "#3cb371"
    readonly property color mediumSlateBlue: "#7b68ee"
    readonly property color mediumSpringGreen: "#00fa9a"
    readonly property color mediumTurquoise: "#48d1cc"
    readonly property color mediumVioletRed: "#c71585"
    readonly property color midnightBlue: "#191970"
    readonly property color mintCream: "#f5fffa"
    readonly property color mistyRose: "#ffe4e1"
    readonly property color moccasin: "#ffe4b5"
    readonly property color navajoWhite: "#ffdead"
    readonly property color navy: "#000080"
    readonly property color oldLace: "#fdf5e6"
    readonly property color olive: "#808000"
    readonly property color oliveDrab: "#6b8e23"
    readonly property color orange: "#ffa500"
    readonly property color orangeRed: "#ff4500"
    readonly property color orchid: "#da70d6"
    readonly property color paleGoldenRod: "#eee8aa"
    readonly property color paleGreen: "#98fb98"
    readonly property color paleTurquoise: "#afeeee"
    readonly property color paleVioletRed: "#db7093"
    readonly property color papayaWhip: "#ffefd5"
    readonly property color peachPuff: "#ffdab9"
    readonly property color peru: "#cd853f"
    readonly property color pink: "#ffc0cb"
    readonly property color plum: "#dda0dd"
    readonly property color powderBlue: "#b0e0e6"
    readonly property color purple: "#800080"
    readonly property color red: "#ff0000"
    readonly property color rosyBrown: "#bc8f8f"
    readonly property color royalBlue: "#4169e1"
    readonly property color saddleBrown: "#8b4513"
    readonly property color salmon: "#fa8072"
    readonly property color sandyBrown: "#f4a460"
    readonly property color seaGreen: "#2e8b57"
    readonly property color seaShell: "#fff5ee"
    readonly property color sienna: "#a0522d"
    readonly property color silver: "#c0c0c0"
    readonly property color skyBlue: "#87ceeb"
    readonly property color slateBlue: "#6a5acd"
    readonly property color slateGray: "#708090"
    readonly property color slateGrey: "#708090"
    readonly property color snow: "#fffafa"
    readonly property color springGreen: "#00ff7f"
    readonly property color steelBlue: "#4682b4"
    readonly property color tan: "#d2b48c"
    readonly property color teal: "#008080"
    readonly property color thistle: "#d8bfd8"
    readonly property color tomato: "#ff6347"
    readonly property color turquoise: "#40e0d0"
    readonly property color violet: "#ee82ee"
    readonly property color wheat: "#f5deb3"
    readonly property color white: "#ffffff"
    readonly property color whiteSmoke: "#f5f5f5"
    readonly property color yellow: "#ffff00"
    readonly property color yellowGreen: "#9acd32"
}
