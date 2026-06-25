pragma Singleton

import QtQuick

QtObject {

    function title(pageUrl) {
        switch (pageUrl) {
            case "views/WindowsAutoUpdateDisabler.qml": return qsTr("Disable Auto Update")
            case "views/SystemCacheCleaner.qml": return qsTr("Cache Cleaner")
            case "views/LoremIpsumGenerator.qml": return qsTr("Lorem Ipsum Generator")
            case "views/WatermarkAdder.qml": return qsTr("Watermark Adder")
            case "views/VideoWatermarkAdder.qml": return qsTr("Video Watermark")
            case "views/ImageCompression.qml": return qsTr("Image Compression")
            case "views/MediaFormatConverter.qml": return qsTr("Media Format Converter")
            case "views/ColorThemePicker.qml": return qsTr("Color Theme Picker")
            case "views/NetworkSpeedTest.qml": return qsTr("Network Speed Test")
            case "views/ThemeGenerator.qml": return qsTr("Theme Generator")
            default: return ""
        }
    }

    function description(pageUrl) {
        switch (pageUrl) {
            case "views/WindowsAutoUpdateDisabler.qml": return qsTr("Prevents Windows updates automatically.")
            case "views/SystemCacheCleaner.qml": return qsTr("Cleans system cache & temp files.")
            case "views/LoremIpsumGenerator.qml": return qsTr("Generate placeholder text quickly.")
            case "views/WatermarkAdder.qml": return qsTr("Add watermarks to media files.")
            case "views/VideoWatermarkAdder.qml": return qsTr("Add watermarks to video files.")
            case "views/ImageCompression.qml": return qsTr("Compress images without quality loss.")
            case "views/MediaFormatConverter.qml": return qsTr("Convert media formats easily.")
            case "views/ColorThemePicker.qml": return qsTr("Generate & save color schemes.")
            case "views/NetworkSpeedTest.qml": return qsTr("Measure download/upload speeds.")
            case "views/ThemeGenerator.qml": return qsTr("Create custom color themes.")
            default: return ""
        }
    }

    function tagText(pageUrl) {
        switch (pageUrl) {
            case "views/WindowsAutoUpdateDisabler.qml": return qsTr("SYSTEM")
            case "views/SystemCacheCleaner.qml": return qsTr("SYSTEM")
            case "views/LoremIpsumGenerator.qml": return qsTr("DEV")
            case "views/WatermarkAdder.qml": return qsTr("MEDIA")
            case "views/VideoWatermarkAdder.qml": return qsTr("MEDIA")
            case "views/ImageCompression.qml": return qsTr("MEDIA")
            case "views/MediaFormatConverter.qml": return qsTr("MEDIA")
            case "views/ColorThemePicker.qml": return qsTr("OTHER")
            case "views/NetworkSpeedTest.qml": return qsTr("OTHER")
            case "views/ThemeGenerator.qml": return qsTr("OTHER")
            default: return ""
        }
    }

    function iconKey(pageUrl) {
        switch (pageUrl) {
            case "views/WindowsAutoUpdateDisabler.qml": return "updateDisabled"
            case "views/SystemCacheCleaner.qml": return "restoreFromTrash"
            case "views/LoremIpsumGenerator.qml": return "edit"
            case "views/WatermarkAdder.qml": return "brandingWatermark"
            case "views/VideoWatermarkAdder.qml": return "brandingWatermark"
            case "views/ImageCompression.qml": return "compress"
            case "views/MediaFormatConverter.qml": return "driveFileMove"
            case "views/ColorThemePicker.qml": return "changeCircle"
            case "views/NetworkSpeedTest.qml": return "networkCheck"
            case "views/ThemeGenerator.qml": return "changeCircle"
            default: return ""
        }
    }
}
