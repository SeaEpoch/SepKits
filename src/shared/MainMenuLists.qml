pragma Singleton

import QtQuick 2.15
import SepKits as SepKits

QtObject {
    // ListModel/ListElement 不支持变量值，故而使用数组
    readonly property var systemToolsMenuList: [{
            "name": qsTr("系统缓存清理"),
            "icon": SepKits.MaterialSymbols.restoreFromTrash,
            "desc": qsTr("对系统的“缓存”文件进行清理，但操作前请妥善保存工程文件内容！"),
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("关闭 Windows 自动更新"),
            "icon": SepKits.MaterialSymbols.updateDisabled,
            "desc": qsTr("关闭烦人的 Windows 自动更新，我们只需要一台稳定运行的系统！"),
            "page": "",
            "keepAlive": false
        }]

    readonly property var programmingToolsMenuList: [{
            "name": qsTr("代码格式化/压缩"),
            "icon": SepKits.MaterialSymbols.formatIndentDecrease,
            "desc": qsTr("支持常见编程语言的代码格式化或代码压缩。"),
            "page": "",
            "keepAlive": false
        }]

    readonly property var mediaToolsMenuList: [{
            "name": qsTr("格式转换"),
            "icon": SepKits.MaterialSymbols.changeCircle,
            "desc": qsTr("支持常见媒体的格式转换，轻松获取自己想要的文件格式。"),
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("添加水印"),
            "icon": SepKits.MaterialSymbols.brandingWatermark,
            "desc": qsTr("为您的作品添加自定义水印。"),
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("文件体积压缩"),
            "icon": SepKits.MaterialSymbols.compress,
            "desc": qsTr("压缩常见的媒体文件体积，同时兼顾原件的质量。"),
            "page": "",
            "keepAlive": false
        }]

    readonly property var otherToolsMenuList: [{
            "name": qsTr("屏幕截图"),
            "icon": "",
            "desc": "",
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("颜色拾取器"),
            "icon": "",
            "desc": "",
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("文件批量重命名"),
            "icon": "",
            "desc": "",
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("二维码生成器"),
            "icon": "",
            "desc": "",
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("文本转语音"),
            "icon": "",
            "desc": "",
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("图片批量处理"),
            "icon": "",
            "desc": "",
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("系统信息查看"),
            "icon": "",
            "desc": "",
            "page": "",
            "keepAlive": false
        }, {
            "name": qsTr("快捷笔记"),
            "icon": "",
            "desc": "",
            "page": "",
            "keepAlive": false
        }]
}
