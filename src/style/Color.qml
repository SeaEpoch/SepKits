pragma Singleton

import QtQuick
import SepKits as SepKits

QtObject {
    id: _root

    // 主题枚举名
    enum ThemeName {
        Light = 0,
        Dark = 1
    }

    // 主题列表（可用主题）
    property QtObject _private: QtObject {
        property QtObject lightTheme: SepKits.LightTheme {}
        property QtObject darkTheme: SepKits.DarkTheme {}
    }
    readonly property var themeLists: [_private.lightTheme, _private.darkTheme]

    // 主题类型
    property int currTheme: SepKits.SettingsStore.value("currTheme", Color.ThemeName.Light)

    // 主题切换函数
    function switchTheme(themeType) {
        if (themeLists[themeType] !== undefined) {
            currTheme = themeType
        } else {
            console.warn("[Color.qml]Unknown theme enum value: ", themeType)
        }
    }

    onCurrThemeChanged: {
        SepKits.SettingsStore.setValue("currTheme", _root.currTheme)
    }

    function alpha(baseColor, alphaValue) {
        // 强制转为 color 对象，确保可以直接读取 r/g/b/a 分量（0~1）
        var c = Qt.rgba(0, 0, 0, 0)
        c = baseColor

        // 保留：检测命名颜色或特殊值（仅在传入字符串时生效）
        if (typeof baseColor === 'string') {
            var inputStr = baseColor.trim().toLowerCase()
            if (inputStr !== "" && !inputStr.startsWith("#")) {
                console.warn("Colors.alpha: 检测到命名颜色或特殊值 '" + baseColor +
                             "'，已自动转换，但推荐统一使用 #RRGGBB 格式以获得最佳兼容性与性能。")
            }
        }

        // 直接读取颜色分量（0~1 浮点数）
        var r = c.r
        var g = c.g
        var b = c.b
        var existingAlpha = c.a  // 0~1

        // 处理新透明度（支持 0~1 或 0~255）
        var newAlphaNorm = 1.0
        if (alphaValue >= 0 && alphaValue <= 1) {
            newAlphaNorm = alphaValue
        } else if (alphaValue >= 0 && alphaValue <= 255) {
            newAlphaNorm = alphaValue / 255
        } else {
            console.warn("Colors.alpha: 透明度值超出范围", alphaValue)
            newAlphaNorm = 1.0
        }

        // 透明度叠加（乘法合成）
        var finalAlpha = existingAlpha * newAlphaNorm

        // 返回颜色对象，完全避免字符串构造
        return Qt.rgba(r, g, b, finalAlpha)
    }

    // 返回对应的禁用状态下的颜色
    function disabled(color) {
        return _root.alpha(color, 0.64)
    }

    // ==================== 主题颜色 ==================== \\
    readonly property color primary: themeLists[currTheme].primary
    readonly property color primaryForeground: themeLists[currTheme].primaryForeground
    readonly property color accentSecondary: themeLists[currTheme].accentSecondary
    readonly property color background: themeLists[currTheme].background
    readonly property color foreground: themeLists[currTheme].foreground
    readonly property color card: themeLists[currTheme].card
    readonly property color cardForeground: themeLists[currTheme].cardForeground
    readonly property color popover: themeLists[currTheme].popover
    readonly property color popoverForeground: themeLists[currTheme].popoverForeground
    readonly property color secondary: themeLists[currTheme].secondary
    readonly property color secondaryForeground: themeLists[currTheme].secondaryForeground
    readonly property color muted: themeLists[currTheme].muted
    readonly property color mutedForeground: themeLists[currTheme].mutedForeground
    readonly property color accent: themeLists[currTheme].accent
    readonly property color accentForeground: themeLists[currTheme].accentForeground
    readonly property color distructive: themeLists[currTheme].distructive
    readonly property color distructiveForeground: themeLists[currTheme].distructiveForeground
    readonly property color border: themeLists[currTheme].border
    readonly property color input: themeLists[currTheme].input
    readonly property color ring: themeLists[currTheme].ring
    readonly property color chart1: themeLists[currTheme].chart1
    readonly property color chart2: themeLists[currTheme].chart2
    readonly property color chart3: themeLists[currTheme].chart3
    readonly property color chart4: themeLists[currTheme].chart4
    readonly property color chart5: themeLists[currTheme].chart5

    readonly property color red100: themeLists[currTheme].red100
    readonly property color red500: themeLists[currTheme].red500
    readonly property color orange50: themeLists[currTheme].orange50
    readonly property color orange500: themeLists[currTheme].orange500
    readonly property color orange600: themeLists[currTheme].orange600
    readonly property color green50: themeLists[currTheme].green50
    readonly property color green500: themeLists[currTheme].green500
    readonly property color green600: themeLists[currTheme].green600
    readonly property color cyan400: themeLists[currTheme].cyan400
    readonly property color blue50: themeLists[currTheme].blue50
    readonly property color blue500: themeLists[currTheme].blue500
    readonly property color blue600: themeLists[currTheme].blue600
    readonly property color blue700: themeLists[currTheme].blue700
    readonly property color purple50: themeLists[currTheme].purple50
    readonly property color purple500: themeLists[currTheme].purple500
    readonly property color purple600: themeLists[currTheme].purple600
    readonly property color slate50: themeLists[currTheme].slate50
    readonly property color slate100: themeLists[currTheme].slate100
    readonly property color slate600: themeLists[currTheme].slate600
    readonly property color slate700: themeLists[currTheme].slate700
    readonly property color slate900: themeLists[currTheme].slate900

    // ==================== 基本颜色 ==================== \\
    readonly property color transparent: "#00000000"

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
