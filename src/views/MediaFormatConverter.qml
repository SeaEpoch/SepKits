import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import SepKits as SepKits

Rectangle {
    id: _root
    color: SepKits.Color.background

    QtObject {
        id: _private
        property int settingsFileIndex: -1
        readonly property var settingsFile: settingsFileIndex >= 0
                                            && settingsFileIndex < SepKits.MediaFormatConverter.files.length ? SepKits.MediaFormatConverter.files[settingsFileIndex] : null
        readonly property bool settingsIsVideo: settingsFile && settingsFile.type === "video"
        readonly property var audioFormats: ["MP3", "WAV", "FLAC", "AAC", "OGG", "WMA", "M4A", "OPUS"]
        readonly property var videoFormats: ["MP4", "AVI", "MKV", "MOV", "WebM", "WMV", "FLV"]
        readonly property var imageFormats: ["JPG", "PNG", "BMP", "WebP", "TIFF", "GIF", "ICO"]
        function formatsForType(type) {
            if (type === "audio")
                return audioFormats
            if (type === "video")
                return videoFormats
            if (type === "image")
                return imageFormats
            return []
        }

        // ─── Settings field values (bridged between content Component and backend) ───
        property string trimStart: ""
        property string trimEnd: ""
        property double volume: 0.0
        property int channels: 0
        property int sampleRate: 0
        property string vTrimStart: ""
        property string vTrimEnd: ""
        property string vCodec: ""
        property string vaTrimStart: ""
        property string vaTrimEnd: ""
        property double vaVolume: 0.0
        property int vaChannels: 0
        property int vaSampleRate: 0

        function loadSettingsToPrivate() {
            var f = settingsFile
            if (!f)
                return
            var iv = settingsIsVideo
            var as = (iv && f.videoSettings) ? f.videoSettings.audioSettings : f.audioSettings
            trimStart = as.trimStart || ""
            trimEnd = as.trimEnd || ""
            volume = as.volume !== undefined ? as.volume : 0.0
            channels = as.channels !== undefined ? as.channels : 0
            sampleRate = as.sampleRate !== undefined ? as.sampleRate : 0
            if (iv && f.videoSettings) {
                var vs = f.videoSettings
                vTrimStart = vs.trimStart || ""
                vTrimEnd = vs.trimEnd || ""
                vCodec = vs.videoCodec || ""
                vaTrimStart = vs.audioSettings.trimStart || ""
                vaTrimEnd = vs.audioSettings.trimEnd || ""
                vaVolume = vs.audioSettings.volume !== undefined ? vs.audioSettings.volume : 0.0
                vaChannels = vs.audioSettings.channels !== undefined ? vs.audioSettings.channels : 0
                vaSampleRate = vs.audioSettings.sampleRate !== undefined ? vs.audioSettings.sampleRate : 0
            }
        }

        function saveSettingsFromPrivate() {
            var idx = settingsFileIndex
            if (idx < 0)
                return
            if (settingsIsVideo) {
                SepKits.MediaFormatConverter.setVideoTrim(idx, vTrimStart, vTrimEnd)
                SepKits.MediaFormatConverter.setVideoCodec(idx, vCodec)
                SepKits.MediaFormatConverter.setAudioTrim(idx, vaTrimStart, vaTrimEnd)
                SepKits.MediaFormatConverter.setAudioVolume(idx, vaVolume)
                SepKits.MediaFormatConverter.setAudioChannels(idx, vaChannels)
                SepKits.MediaFormatConverter.setAudioSampleRate(idx, vaSampleRate)
            } else {
                SepKits.MediaFormatConverter.setAudioTrim(idx, trimStart, trimEnd)
                SepKits.MediaFormatConverter.setAudioVolume(idx, volume)
                SepKits.MediaFormatConverter.setAudioChannels(idx, channels)
                SepKits.MediaFormatConverter.setAudioSampleRate(idx, sampleRate)
            }
        }

        function applySettingsToAll() {
            var f = settingsFile
            if (!f)
                return
            if (f.type === "audio") {
                SepKits.MediaFormatConverter.applyAudioSettingsToAll({
                    "trimStart": trimStart,
                    "trimEnd": trimEnd,
                    "volume": volume,
                    "channels": channels,
                    "sampleRate": sampleRate
                })
            } else if (f.type === "video") {
                SepKits.MediaFormatConverter.applyVideoSettingsToAll({
                    "trimStart": vTrimStart,
                    "trimEnd": vTrimEnd,
                    "videoCodec": vCodec,
                    "audioSettings": {
                        "trimStart": vaTrimStart,
                        "trimEnd": vaTrimEnd,
                        "volume": vaVolume,
                        "channels": vaChannels,
                        "sampleRate": vaSampleRate
                    }
                })
            }
        }
    }

    readonly property bool isRunning: SepKits.MediaFormatConverter.isRunning
    readonly property double convProgress: SepKits.MediaFormatConverter.progress
    readonly property var fileList: SepKits.MediaFormatConverter.files
    property bool _hasConverted: false

    function convertibleCount() {
        var n = 0
        var fs = _root.fileList
        for (var i = 0; i < fs.length; i++) {
            if (fs[i].status !== "done")
                n++
        }
        return n
    }

    Component.onCompleted: {
        var saved = SepKits.SettingsStore.value("mediaConverterOutputDir", "")
        if (saved !== "")
            SepKits.MediaFormatConverter.outputDir = saved
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SepKits.Theme.spacingXl
        spacing: SepKits.Theme.spacingLg

        RowLayout {
            spacing: SepKits.Theme.spacingMd
            SepKits.BackButton {
                enabled: !_root.isRunning
            }
            Text {
                text: qsTr("Media Format Converter")
                font.family: SepKits.Font.fontFamilyTitle
                font.pixelSize: SepKits.Font.sizeH3
                font.weight: SepKits.Font.weightH3
                color: SepKits.Color.foreground
            }
            Item {
                Layout.fillWidth: true
            }
            SepKits.SecondaryButton {
                id: _logBtn
                visible: _root._hasConverted && !_root.isRunning
                text: qsTr("Log")
                onClicked: {
                    var p = SepKits.MediaFormatConverter.saveLog()
                    if (p)
                        Qt.openUrlExternally(p)
                }
            }
            SepKits.PrimaryButton {
                id: _actionBtn
                enabled: _root.convertibleCount() > 0 || _root.isRunning
                text: _root.isRunning ? qsTr("Cancel") : qsTr("Start Conversion")
                onClicked: {
                    if (_root.isRunning)
                        SepKits.MediaFormatConverter.cancelConversion()
                    else {
                        _root._hasConverted = true
                        SepKits.MediaFormatConverter.startConversion()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: SepKits.Theme.spacingSm
            Text {
                text: qsTr("Output Directory")
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                font.weight: SepKits.Font.weightMedium
                color: SepKits.Color.foreground
                Layout.alignment: Qt.AlignVCenter
            }
            TextField {
                id: _outputPathField
                Layout.fillWidth: true
                implicitHeight: 44
                readOnly: true
                color: SepKits.Color.foreground
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                placeholderText: qsTr("Select output folder...")
                placeholderTextColor: SepKits.Color.mutedForeground
                verticalAlignment: TextInput.AlignVCenter
                text: {
                    var s = SepKits.SettingsStore.value("mediaConverterOutputDir", "")
                    return s !== "" ? s : SepKits.MediaFormatConverter.outputDir
                }
                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: SepKits.Color.background
                    border.width: 1
                    border.color: SepKits.Color.border
                }
            }
            SepKits.PrimaryButton {
                text: qsTr("Browse")
                onClicked: _outputFolderDialog.open()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: SepKits.Color.card
            radius: SepKits.Theme.cardRadius
            border.color: SepKits.Color.border
            border.width: 1
            clip: true
            ColumnLayout {
                anchors.fill: parent
                spacing: 0
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    color: SepKits.Color.alpha(SepKits.Color.muted, 0.4)
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: SepKits.Theme.spacingMd
                        anchors.rightMargin: SepKits.Theme.spacingMd
                        spacing: SepKits.Theme.spacingSm
                        Item {
                            Layout.preferredWidth: 24
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("File Name")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                font.weight: SepKits.Font.weightMedium
                                color: SepKits.Color.mutedForeground
                            }
                        }
                        Item {
                            Layout.preferredWidth: 140
                            Layout.fillHeight: true
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Output Settings")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                font.weight: SepKits.Font.weightMedium
                                color: SepKits.Color.mutedForeground
                            }
                        }
                        Item {
                            Layout.preferredWidth: 72
                            Layout.fillHeight: true
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Size")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                font.weight: SepKits.Font.weightMedium
                                color: SepKits.Color.mutedForeground
                            }
                        }
                        Item {
                            Layout.preferredWidth: 64
                            Layout.fillHeight: true
                            Text {
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                text: qsTr("Status")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                font.weight: SepKits.Font.weightMedium
                                color: SepKits.Color.mutedForeground
                            }
                        }
                        Item {
                            Layout.preferredWidth: 36
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: SepKits.Color.border
                }
                ListView {
                    id: _fileList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: _root.fileList
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    delegate: Rectangle {
                        id: _row
                        width: _fileList.width
                        height: 48
                        color: index % 2 === 0 ? SepKits.Color.transparent : SepKits.Color.alpha(
                                                     SepKits.Color.muted, 0.2)
                        required property var modelData
                        required property int index
                        readonly property var file: modelData
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: SepKits.Theme.spacingMd
                            anchors.rightMargin: SepKits.Theme.spacingMd
                            spacing: SepKits.Theme.spacingSm
                            Item {
                                Layout.preferredWidth: 24
                                Layout.fillHeight: true
                                SepKits.SvgIcon {
                                    anchors {
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                    }
                                    width: 20
                                    height: 20
                                    iconSource: {
                                        switch (_row.file.type) {
                                        case "video":
                                            return SepKits.FontAwesome.film
                                        case "audio":
                                            return SepKits.FontAwesome.compactDisc
                                        case "image":
                                            return SepKits.FontAwesome.image
                                        default:
                                            return SepKits.FontAwesome.image
                                        }
                                    }
                                    color: {
                                        switch (_row.file.type) {
                                        case "video":
                                            return SepKits.Color.purple500
                                        case "audio":
                                            return SepKits.Color.blue500
                                        case "image":
                                            return SepKits.Color.green500
                                        default:
                                            return SepKits.Color.mutedForeground
                                        }
                                    }
                                }
                            }
                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: _row.file.fileName
                                    color: SepKits.Color.foreground
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeSmall
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    ToolTip.text: _row.file.path
                                    ToolTip.visible: _fileNameMA.containsMouse
                                    ToolTip.delay: 500
                                    MouseArea {
                                        id: _fileNameMA
                                        anchors.fill: parent
                                        acceptedButtons: Qt.NoButton
                                        hoverEnabled: true
                                    }
                                }
                            }
                            Item {
                                Layout.preferredWidth: 140
                                Layout.fillHeight: true
                                Row {
                                    anchors {
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                    }
                                    spacing: SepKits.Theme.spacingSm
                                    SepKits.ComboBox {
                                        id: _fmtCombo
                                        anchors.verticalCenter: parent.verticalCenter
                                        label: ""
                                        width: 78
                                        comboHeight: 32
                                        comboRadius: SepKits.Theme.radius
                                        enabled: !_root.isRunning
                                        model: _private.formatsForType(_row.file.type)
                                        currentIndex: {
                                            var fmts = _private.formatsForType(_row.file.type)
                                            var tgt = String(_row.file.targetFormat).toLowerCase()
                                            for (var i = 0; i < fmts.length; i++) {
                                                if (String(fmts[i]).toLowerCase() === tgt)
                                                    return i
                                            }
                                            return -1
                                        }
                                        onActivated: idx => {
                                                         SepKits.MediaFormatConverter.setTargetFormat(
                                                             _row.index, String(
                                                                 _fmtCombo.model[idx]).toLowerCase(
                                                                 ))
                                                     }
                                    }
                                    Button {
                                        id: _settingsBtn
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: _row.file.type === "audio"
                                                 || _row.file.type === "video"
                                        width: 28
                                        height: 28
                                        enabled: !_root.isRunning
                                        topPadding: 7
                                        bottomPadding: 7
                                        leftPadding: 7
                                        rightPadding: 7
                                        contentItem: SepKits.SvgIcon {
                                            anchors.centerIn: parent
                                            iconSource: SepKits.FontAwesome.gear
                                            color: _settingsBtn.hovered ? SepKits.Color.foreground : SepKits.Color.mutedForeground
                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: SepKits.Theme.animFast
                                                }
                                            }
                                        }
                                        background: Rectangle {
                                            radius: SepKits.Theme.radius
                                            color: SepKits.Color.transparent
                                        }
                                        onClicked: {
                                            _private.settingsFileIndex = _row.index
                                            _private.loadSettingsToPrivate()
                                            SepKits.DialogManager.custom(
                                                _private.settingsFile ? qsTr("Settings: %1").arg(
                                                                            _private.settingsFile.fileName) : qsTr(
                                                                            "Settings"),
                                                _settingsContentComp,
                                                qsTr("Done"),
                                                _private.settingsIsVideo ? qsTr(
                                                                              "Apply to All Video") : qsTr(
                                                                              "Apply to All Audio"),
                                                function () {
                                                    _private.saveSettingsFromPrivate()
                                                },
                                                function () {
                                                    _private.applySettingsToAll()
                                                }
                                            )
                                        }
                                    }
                                }
                            }
                            Item {
                                Layout.preferredWidth: 72
                                Layout.fillHeight: true
                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: _row.file.fileSizeText
                                    color: SepKits.Color.mutedForeground
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeTiny
                                }
                            }
                            Item {
                                Layout.preferredWidth: 64
                                Layout.fillHeight: true
                                Text {
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: {
                                        switch (_row.file.status) {
                                        case "converting":
                                            return qsTr("Converting")
                                        case "done":
                                            return qsTr("Done")
                                        case "failed":
                                            return qsTr("Failed")
                                        default:
                                            return qsTr("Ready")
                                        }
                                    }
                                    color: {
                                        switch (_row.file.status) {
                                        case "converting":
                                            return SepKits.Color.purple500
                                        case "done":
                                            return SepKits.Color.green500
                                        case "failed":
                                            return SepKits.Color.distructive
                                        default:
                                            return SepKits.Color.blue500
                                        }
                                    }
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeTiny
                                    font.weight: SepKits.Font.weightMedium
                                }
                            }
                            Item {
                                Layout.preferredWidth: 36
                                Layout.fillHeight: true
                                Button {
                                    id: _delBtn
                                    anchors {
                                        left: parent.left
                                        verticalCenter: parent.verticalCenter
                                    }
                                    width: 28
                                    height: 28
                                    enabled: !_root.isRunning
                                    topPadding: 7
                                    bottomPadding: 7
                                    leftPadding: 7
                                    rightPadding: 7
                                    contentItem: SepKits.SvgIcon {
                                        anchors.centerIn: parent
                                        iconSource: SepKits.FontAwesome.xmark
                                        color: _delBtn.hovered ? SepKits.Color.distructive : SepKits.Color.mutedForeground
                                        Behavior on color {
                                            ColorAnimation {
                                                duration: SepKits.Theme.animFast
                                            }
                                        }
                                    }
                                    background: Rectangle {
                                        radius: SepKits.Theme.radius
                                        color: _delBtn.hovered ? SepKits.Color.alpha(
                                                                     SepKits.Color.distructive,
                                                                     0.12) : SepKits.Color.transparent
                                        Behavior on color {
                                            ColorAnimation {
                                                duration: SepKits.Theme.animFast
                                            }
                                        }
                                    }
                                    onClicked: SepKits.MediaFormatConverter.removeFile(_row.index)
                                }
                            }
                        }
                    }
                    Rectangle {
                        anchors.fill: parent
                        visible: _fileList.count === 0
                        color: SepKits.Color.transparent
                        z: 1
                        Text {
                            anchors.centerIn: parent
                            text: _root.isRunning ? qsTr("Converting...") : qsTr(
                                                        "Drag & drop media files here")
                            font.family: SepKits.Font.fontFamilyBody
                            font.pixelSize: SepKits.Font.sizeBody
                            color: SepKits.Color.mutedForeground
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Text {
                text: {
                    var total = _root.convertibleCount()
                    if (_root.isRunning) {
                        if (total > 0)
                            return qsTr("Converting %n file(s)...", "", total)
                        return qsTr("Converting...")
                    }
                    if (total === 0) {
                        if (_root.fileList.length === 0)
                            return qsTr("Add files to begin")
                        return qsTr("All files converted")
                    }
                    return qsTr("%n file(s) ready", "", total)
                }
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                color: SepKits.Color.mutedForeground
            }
            SepKits.SepProgressBar {
                Layout.fillWidth: true
                value: _root.convProgress
                visible: _root.convertibleCount() > 0 || _root.isRunning
            }
        }
    }

    FolderDialog {
        id: _outputFolderDialog
        title: qsTr("Select Output Folder")
        onAccepted: {
            var p = selectedFolder.toString()
            if (p.startsWith("file:///"))
                p = p.substring(8)
            _outputPathField.text = p
            SepKits.MediaFormatConverter.outputDir = p
            SepKits.SettingsStore.setValue("mediaConverterOutputDir", p)
        }
    }

    DropArea {
        anchors.fill: parent
        enabled: !_root.isRunning
        onDropped: function (d) {
            if (d.hasUrls) {
                var p = []
                for (var i = 0; i < d.urls.length; i++) {
                    var u = d.urls[i].toString()
                    if (u.startsWith("file:///"))
                        u = u.substring(8)
                    else if (u.startsWith("file://"))
                        u = u.substring(7)
                    u = decodeURIComponent(u)
                    p.push(u)
                }
                SepKits.MediaFormatConverter.addFiles(p)
            }
        }
    }

    Component {
        id: _settingsContentComp
        Item {
            implicitWidth: _contentLayout.implicitWidth + SepKits.Theme.spacingLg * 2
            implicitHeight: _contentLayout.implicitHeight + SepKits.Theme.spacingMd * 2

            ColumnLayout {
                id: _contentLayout
                anchors.fill: parent
                anchors.leftMargin: SepKits.Theme.spacingLg
                anchors.rightMargin: SepKits.Theme.spacingLg
                anchors.topMargin: SepKits.Theme.spacingMd
                anchors.bottomMargin: SepKits.Theme.spacingMd
                spacing: SepKits.Theme.spacingMd

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: _private.settingsIsVideo
                    spacing: 0

                TabBar {
                    id: _tabBar
                    Layout.fillWidth: true
                    background: Rectangle {
                        color: SepKits.Color.transparent
                    }
                    TabButton {
                        text: qsTr("Video")
                        font.pixelSize: SepKits.Font.sizeSmall
                        contentItem: Text {
                            text: parent.text
                            font.family: SepKits.Font.fontFamilyBody
                            font.pixelSize: parent.font.pixelSize
                            color: parent.checked ? SepKits.Color.primary : SepKits.Color.mutedForeground
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            color: SepKits.Color.transparent
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 2
                                color: parent.parent.checked ? SepKits.Color.primary : SepKits.Color.transparent
                            }
                        }
                    }
                    TabButton {
                        text: qsTr("Audio")
                        font.pixelSize: SepKits.Font.sizeSmall
                        contentItem: Text {
                            text: parent.text
                            font.family: SepKits.Font.fontFamilyBody
                            font.pixelSize: parent.font.pixelSize
                            color: parent.checked ? SepKits.Color.primary : SepKits.Color.mutedForeground
                            horizontalAlignment: Text.AlignHCenter
                        }
                        background: Rectangle {
                            color: SepKits.Color.transparent
                            Rectangle {
                                anchors.bottom: parent.bottom
                                width: parent.width
                                height: 2
                                color: parent.parent.checked ? SepKits.Color.primary : SepKits.Color.transparent
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: SepKits.Color.border
                }
                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: SepKits.Theme.spacingMd
                    currentIndex: _tabBar.currentIndex

                    ColumnLayout {
                        spacing: SepKits.Theme.spacingMd
                        RowLayout {
                            spacing: SepKits.Theme.spacingSm
                            Text {
                                Layout.preferredWidth: 80
                                text: qsTr("Trim")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                color: SepKits.Color.foreground
                            }
                            TextField {
                                Layout.fillWidth: true
                                placeholderText: "0:0:0"
                                font.pixelSize: SepKits.Font.sizeSmall
                                color: SepKits.Color.foreground
                                text: _private.vTrimStart
                                onTextChanged: _private.vTrimStart = text
                                background: Rectangle {
                                    radius: SepKits.Theme.radius
                                    color: SepKits.Color.background
                                    border.width: 1
                                    border.color: SepKits.Color.border
                                }
                            }
                            Text {
                                text: "—"
                                color: SepKits.Color.mutedForeground
                                font.pixelSize: SepKits.Font.sizeSmall
                            }
                            TextField {
                                Layout.fillWidth: true
                                placeholderText: "0:5:0"
                                font.pixelSize: SepKits.Font.sizeSmall
                                color: SepKits.Color.foreground
                                text: _private.vTrimEnd
                                onTextChanged: _private.vTrimEnd = text
                                background: Rectangle {
                                    radius: SepKits.Theme.radius
                                    color: SepKits.Color.background
                                    border.width: 1
                                    border.color: SepKits.Color.border
                                }
                            }
                        }
                        RowLayout {
                            spacing: SepKits.Theme.spacingSm
                            Text {
                                Layout.preferredWidth: 80
                                text: qsTr("Codec")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                color: SepKits.Color.foreground
                            }
                            SepKits.ComboBox {
                                id: _vCodecCombo
                                Layout.fillWidth: true
                                label: ""
                                comboHeight: 32
                                comboRadius: SepKits.Theme.radius
                                model: ["Copy", "libx264", "libx265", "libvpx-vp9"]
                                currentIndex: {
                                    var codes = ["", "libx264", "libx265", "libvpx-vp9"]
                                    var v = _private.vCodec.toLowerCase()
                                    for (var i = 0; i < codes.length; i++)
                                        if (codes[i] === v)
                                            return i
                                    return 0
                                }
                                onActivated: index => {
                                    var codes = ["", "libx264", "libx265", "libvpx-vp9"]
                                    if (index >= 0 && index < codes.length)
                                        _private.vCodec = codes[index]
                                }
                            }
                        }
                        Item { Layout.fillHeight: true }
                    }

                    Loader {
                        id: _vaAudioLoader
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: _audioFieldsComp
                    }
                }
            }

            Loader {
                id: _audioLoader
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: !_private.settingsIsVideo
                sourceComponent: _audioFieldsComp
            }
        }
        }
    }

    Component {
        id: _audioFieldsComp
        ColumnLayout {
            spacing: SepKits.Theme.spacingMd
            readonly property bool _forVideo: _private.settingsIsVideo

            RowLayout {
                spacing: SepKits.Theme.spacingSm
                Text {
                    Layout.preferredWidth: 80
                    text: qsTr("Trim")
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeSmall
                    color: SepKits.Color.foreground
                }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "0:0:0"
                    font.pixelSize: SepKits.Font.sizeSmall
                    color: SepKits.Color.foreground
                    text: _forVideo ? _private.vaTrimStart : _private.trimStart
                    onTextChanged: _forVideo ? (_private.vaTrimStart = text) : (_private.trimStart = text)
                    background: Rectangle {
                        radius: SepKits.Theme.radius
                        color: SepKits.Color.background
                        border.width: 1
                        border.color: SepKits.Color.border
                    }
                }
                Text {
                    text: "—"
                    color: SepKits.Color.mutedForeground
                    font.pixelSize: SepKits.Font.sizeSmall
                }
                TextField {
                    Layout.fillWidth: true
                    placeholderText: "0:5:0"
                    font.pixelSize: SepKits.Font.sizeSmall
                    color: SepKits.Color.foreground
                    text: _forVideo ? _private.vaTrimEnd : _private.trimEnd
                    onTextChanged: _forVideo ? (_private.vaTrimEnd = text) : (_private.trimEnd = text)
                    background: Rectangle {
                        radius: SepKits.Theme.radius
                        color: SepKits.Color.background
                        border.width: 1
                        border.color: SepKits.Color.border
                    }
                }
            }
            RowLayout {
                spacing: SepKits.Theme.spacingSm
                Text {
                    Layout.preferredWidth: 80
                    text: qsTr("Volume")
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeSmall
                    color: SepKits.Color.foreground
                }
                SepKits.SepSlider {
                    id: _volSlider
                    Layout.fillWidth: true
                    from: -20
                    to: 20
                    stepSize: 0.5
                    value: _forVideo ? _private.vaVolume : _private.volume
                    onValueChanged: _forVideo ? (_private.vaVolume = value) : (_private.volume = value)
                }
                Text {
                    Layout.preferredWidth: 56
                    text: _volSlider.value.toFixed(1) + " dB"
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeTiny
                    color: SepKits.Color.mutedForeground
                    horizontalAlignment: Text.AlignRight
                }
            }
            RowLayout {
                spacing: SepKits.Theme.spacingSm
                Text {
                    Layout.preferredWidth: 80
                    text: qsTr("Channels")
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeSmall
                    color: SepKits.Color.foreground
                }
                SepKits.ComboBox {
                    Layout.fillWidth: true
                    label: ""
                    comboHeight: 32
                    comboRadius: SepKits.Theme.radius
                    model: [qsTr("Original"), qsTr("Mono"), qsTr("Stereo")]
                    currentIndex: _forVideo ? _private.vaChannels : _private.channels
                    onActivated: index => { if (_forVideo) _private.vaChannels = index; else _private.channels = index }
                }
            }
            RowLayout {
                spacing: SepKits.Theme.spacingSm
                Text {
                    Layout.preferredWidth: 80
                    text: qsTr("Sample Rate")
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeSmall
                    color: SepKits.Color.foreground
                }
                SepKits.ComboBox {
                    Layout.fillWidth: true
                    label: ""
                    comboHeight: 32
                    comboRadius: SepKits.Theme.radius
                    model: [qsTr("Original"), "22050 Hz", "44100 Hz", "48000 Hz", "96000 Hz"]
                    currentIndex: {
                        var rates = [0, 22050, 44100, 48000, 96000]
                        var v = _forVideo ? _private.vaSampleRate : _private.sampleRate
                        for (var i = 0; i < rates.length; i++)
                            if (rates[i] === v)
                                return i
                        return 0
                    }
                    onActivated: index => {
                        var rates = [0, 22050, 44100, 48000, 96000]
                        var val = rates[index] || 0
                        if (_forVideo)
                            _private.vaSampleRate = val
                        else
                            _private.sampleRate = val
                    }
                }
            }
        }
    }
}
