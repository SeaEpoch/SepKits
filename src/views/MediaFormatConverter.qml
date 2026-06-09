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
                                        visible: _row.file.type === "audio"
                                                 || _row.file.type === "video"
                                        width: 28
                                        height: 28
                                        enabled: !_root.isRunning
                                        topPadding: 0
                                        bottomPadding: 0
                                        leftPadding: 0
                                        rightPadding: 0
                                        contentItem: SepKits.SvgIcon {
                                            anchors.centerIn: parent
                                            width: 14
                                            height: 14
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
                                            color: _settingsBtn.hovered ? SepKits.Color.muted : SepKits.Color.transparent
                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: SepKits.Theme.animFast
                                                }
                                            }
                                        }
                                        onClicked: {
                                            _private.settingsFileIndex = _row.index
                                            _settingsPopup.reload()
                                            _settingsPopup.open()
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
                                    topPadding: 0
                                    bottomPadding: 0
                                    leftPadding: 0
                                    rightPadding: 0
                                    contentItem: SepKits.SvgIcon {
                                        anchors.centerIn: parent
                                        width: 14
                                        height: 14
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
                barColor: SepKits.Color.purple600
                barColorEnd: SepKits.Color.purple500
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

    Popup {
        id: _settingsPopup
        modal: false
        parent: Overlay.overlay
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        padding: 0
        implicitWidth: 480
        implicitHeight: _private.settingsIsVideo ? 520 : 340
        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0.0
                to: 1.0
                duration: SepKits.Theme.animNormal
            }
        }
        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1.0
                to: 0.0
                duration: SepKits.Theme.animNormal
            }
        }
        background: Rectangle {
            radius: SepKits.Theme.cardRadius
            color: SepKits.Color.card
            border.color: SepKits.Color.border
            border.width: 1
        }

        function aFields(ldr) {
            return ldr.item ? {
                                  "trimStart": ldr.item.trimStartField.text,
                                  "trimEnd": ldr.item.trimEndField.text,
                                  "volume": ldr.item.volSlider.value,
                                  "channels": ldr.item.chCombo.currentIndex,
                                  "sampleRate": ldr.item.srCombo.sampleRateValue()
                              } : null
        }
        function setAFields(ldr, ts, te, v, c, sr) {
            if (!ldr.item)
                return
            ldr.item.trimStartField.text = ts || ""
            ldr.item.trimEndField.text = te || ""
            ldr.item.volSlider.value = v !== undefined ? v : 0.0
            ldr.item.chCombo.currentIndex = c !== undefined ? c : 0
            ldr.item.srCombo.loadSampleRate(sr !== undefined ? sr : 0)
        }
        function setAudioToBackend(idx, ldr) {
            var f = aFields(ldr)
            if (!f)
                return
            SepKits.MediaFormatConverter.setAudioTrim(idx, f.trimStart, f.trimEnd)
            SepKits.MediaFormatConverter.setAudioVolume(idx, f.volume)
            SepKits.MediaFormatConverter.setAudioChannels(idx, f.channels)
            SepKits.MediaFormatConverter.setAudioSampleRate(idx, f.sampleRate)
        }
        function reload() {
            var f = _private.settingsFile
            if (!f)
                return
            var iv = _private.settingsIsVideo
            var as = (iv && f.videoSettings) ? f.videoSettings.audioSettings : f.audioSettings
            setAFields(_audioLoader, as.trimStart, as.trimEnd, as.volume, as.channels,
                       as.sampleRate)
            if (iv && f.videoSettings) {
                var vs = f.videoSettings
                _vTrimStart.text = vs.trimStart || ""
                _vTrimEnd.text = vs.trimEnd || ""
                _vCodecCombo._find(vs.videoCodec || "")
                setAFields(_vaAudioLoader, vs.audioSettings.trimStart, vs.audioSettings.trimEnd,
                           vs.audioSettings.volume, vs.audioSettings.channels,
                           vs.audioSettings.sampleRate)
            }
        }
        function saveAndClose() {
            var idx = _private.settingsFileIndex
            if (idx < 0) {
                close()
                return
            }
            if (_private.settingsIsVideo) {
                SepKits.MediaFormatConverter.setVideoTrim(idx, _vTrimStart.text, _vTrimEnd.text)
                SepKits.MediaFormatConverter.setVideoCodec(
                            idx,
                            _vCodecCombo.currentText === "Copy" ? "" : _vCodecCombo.currentText)
                setAudioToBackend(idx, _vaAudioLoader)
            } else {
                setAudioToBackend(idx, _audioLoader)
            }
            close()
        }
        function applyToAll() {
            var f = _private.settingsFile
            if (!f)
                return
            if (f.type === "audio") {
                var af = aFields(_audioLoader)
                if (af)
                    SepKits.MediaFormatConverter.applyAudioSettingsToAll(af)
            } else if (f.type === "video") {
                SepKits.MediaFormatConverter.applyVideoSettingsToAll({
                                                                         "trimStart": _vTrimStart.text,
                                                                         "trimEnd": _vTrimEnd.text,
                                                                         "videoCodec": _vCodecCombo.currentText === "Copy" ? "" : _vCodecCombo.currentText,
                                                                         "audioSettings": aFields(
                                                                                              _vaAudioLoader)
                                                                                          || {}
                                                                     })
            }
            close()
        }

        contentItem: Rectangle {
            color: SepKits.Color.transparent
            clip: true
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: SepKits.Theme.spacingLg
                spacing: SepKits.Theme.spacingMd
                Text {
                    Layout.fillWidth: true
                    text: _private.settingsFile ? qsTr("Settings: %1").arg(
                                                      _private.settingsFile.fileName) : qsTr(
                                                      "Settings")
                    font.family: SepKits.Font.fontFamilyTitle
                    font.pixelSize: SepKits.Font.sizeH3
                    font.weight: SepKits.Font.weightH3
                    color: SepKits.Color.foreground
                    elide: Text.ElideRight
                    Layout.bottomMargin: SepKits.Theme.spacingSm
                }
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
                                    id: _vTrimStart
                                    Layout.fillWidth: true
                                    placeholderText: "0:0:0"
                                    font.pixelSize: SepKits.Font.sizeSmall
                                    color: SepKits.Color.foreground
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
                                }
                                TextField {
                                    id: _vTrimEnd
                                    Layout.fillWidth: true
                                    placeholderText: "0:5:0"
                                    font.pixelSize: SepKits.Font.sizeSmall
                                    color: SepKits.Color.foreground
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
                                ComboBox {
                                    id: _vCodecCombo
                                    Layout.fillWidth: true
                                    model: ["Copy", "libx264", "libx265", "libvpx-vp9"]
                                    font.pixelSize: SepKits.Font.sizeSmall
                                    function _find(v) {
                                        for (var i = 0; i < model.length; i++)
                                            if (String(model[i]).toLowerCase() === String(
                                                        v).toLowerCase()) {
                                                currentIndex = i
                                                return
                                            }
                                        currentIndex = 0
                                    }
                                    background: Rectangle {
                                        radius: SepKits.Theme.radius
                                        color: SepKits.Color.background
                                        border.width: 1
                                        border.color: SepKits.Color.border
                                    }
                                    contentItem: Text {
                                        text: _vCodecCombo.displayText
                                        font: _vCodecCombo.font
                                        color: SepKits.Color.foreground
                                        verticalAlignment: Text.AlignVCenter
                                        leftPadding: 8
                                    }
                                }
                            }
                            Item {
                                Layout.fillHeight: true
                            }
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
                RowLayout {
                    Layout.fillWidth: true
                    spacing: SepKits.Theme.spacingMd
                    SepKits.SecondaryButton {
                        text: _private.settingsIsVideo ? qsTr("Apply to All Video") : qsTr(
                                                             "Apply to All Audio")
                        onClicked: _settingsPopup.applyToAll()
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                    SepKits.PrimaryButton {
                        text: qsTr("Done")
                        onClicked: _settingsPopup.saveAndClose()
                    }
                }
            }
        }
    }

    Component {
        id: _audioFieldsComp
        ColumnLayout {
            spacing: SepKits.Theme.spacingMd
            property alias trimStartField: _trimStart
            property alias trimEndField: _trimEnd
            property alias volSlider: _volSlider
            property alias chCombo: _chCombo
            property alias srCombo: _srCombo
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
                    id: _trimStart
                    Layout.fillWidth: true
                    placeholderText: "0:0:0"
                    font.pixelSize: SepKits.Font.sizeSmall
                    color: SepKits.Color.foreground
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
                    id: _trimEnd
                    Layout.fillWidth: true
                    placeholderText: "0:5:0"
                    font.pixelSize: SepKits.Font.sizeSmall
                    color: SepKits.Color.foreground
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
                Slider {
                    id: _volSlider
                    Layout.fillWidth: true
                    from: -20
                    to: 20
                    stepSize: 0.5
                    value: 0
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
                ComboBox {
                    id: _chCombo
                    Layout.fillWidth: true
                    model: [qsTr("Original"), qsTr("Mono"), qsTr("Stereo")]
                    font.pixelSize: SepKits.Font.sizeSmall
                    background: Rectangle {
                        radius: SepKits.Theme.radius
                        color: SepKits.Color.background
                        border.width: 1
                        border.color: SepKits.Color.border
                    }
                    contentItem: Text {
                        text: _chCombo.displayText
                        font: _chCombo.font
                        color: SepKits.Color.foreground
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
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
                ComboBox {
                    id: _srCombo
                    Layout.fillWidth: true
                    model: [qsTr("Original"), "22050 Hz", "44100 Hz", "48000 Hz", "96000 Hz"]
                    font.pixelSize: SepKits.Font.sizeSmall
                    property int _value: 0
                    function loadSampleRate(v) {
                        _value = v
                        _updateIndex()
                    }
                    function sampleRateValue() {
                        var r = [0, 22050, 44100, 48000, 96000]
                        return r[currentIndex]
                    }
                    function _updateIndex() {
                        var r = [0, 22050, 44100, 48000, 96000]
                        for (var i = 0; i < r.length; i++)
                            if (r[i] === _value) {
                                currentIndex = i
                                return
                            }
                        currentIndex = 0
                    }
                    Component.onCompleted: _updateIndex()
                    background: Rectangle {
                        radius: SepKits.Theme.radius
                        color: SepKits.Color.background
                        border.width: 1
                        border.color: SepKits.Color.border
                    }
                    contentItem: Text {
                        text: _srCombo.displayText
                        font: _srCombo.font
                        color: SepKits.Color.foreground
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 8
                    }
                }
            }
        }
    }
}
