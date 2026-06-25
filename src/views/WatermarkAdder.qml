import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import SepKits as SepKits

Rectangle {
    id: _root
    color: SepKits.Color.background

    QtObject {
        id: _private

        property int mode: 0          // 0=single, 1=batch
        property int wmType: 0        // 0=text, 1=image

        property string wmText: "Watermark"
        property string wmFontFamily: "Arial"
        property int wmFontSize: 48
        property color wmTextColor: "#FFFFFF"
        // Mode-specific defaults (single: 50%, batch: 50%)
        property double wmSingleTextOpacity: 0.2
        property double wmBatchTextOpacity: 0.2

        property string wmImagePath: ""
        property double wmOpacity: 0.2
        property double wmImageScale: 0.3

        // Mode-specific rotation (single: 0°, batch: -32°)
        property double wmSingleRotation: 0.0
        property double wmBatchRotation: -32.0

        property double wmPosX: 0.5
        property double wmPosY: 0.5

        // Batch spacing (0-100%)
        property int wmHSpacing: 16
        property int wmVSpacing: 84

        property string previewOriginal: ""
        property string previewLayer: ""

        function buildSettingsMap() {
            return {
                "type": mode === 1 ? "text" : (wmType === 0 ? "text" : "image"),
                "text": wmText, "fontFamily": wmFontFamily, "fontSize": wmFontSize,
                "textColor": wmTextColor,
                "textOpacity": mode === 0 ? wmSingleTextOpacity : wmBatchTextOpacity,
                "imagePath": wmImagePath, "opacity": wmOpacity, "imageScale": wmImageScale,
                "rotation": mode === 0 ? wmSingleRotation : wmBatchRotation,
                "posX": wmPosX, "posY": wmPosY,
                "batchMode": mode === 1,
                "hSpacing": wmHSpacing / 100.0, "vSpacing": wmVSpacing / 100.0
            }
        }

        function refreshPreview() {
            var f = _root.inputFileData
            if (!f || !f.path) {
                previewOriginal = ""; previewLayer = ""; return
            }
            // (1) Clear layer FIRST to prevent old watermark showing on new image
            previewLayer = ""
            previewOriginal = f.type === "video" && f.thumbnailPath
                ? "file:///" + f.thumbnailPath : "file:///" + f.path
            if (f.width) {} // keep media dimensions for reference
            // Generate new layer synchronously
            var lp = SepKits.WatermarkProcessor.generatePreview(f.path, buildSettingsMap())
            previewLayer = lp ? "file:///" + lp : ""
        }

        // (2) Helper functions for painted area (uses Qt Image.paintedWidth/Height)
        function paintedX(img) { return (img.width  - (img.paintedWidth  || 0)) / 2 }
        function paintedY(img) { return (img.height - (img.paintedHeight || 0)) / 2 }
        function paintedW(img) { return img.paintedWidth  || 1 }
        function paintedH(img) { return img.paintedHeight || 1 }

        property Timer _previewTimer: Timer {
            interval: 150; running: false; repeat: false
            onTriggered: _private.refreshPreview()
        }
        function schedulePreviewRefresh() { _previewTimer.restart() }
        function immediatePreviewRefresh() { _previewTimer.stop(); _private.refreshPreview() }
    }

    readonly property bool running: SepKits.WatermarkProcessor.isRunning
    readonly property var inputFileData: SepKits.WatermarkProcessor.inputFile
    property bool hasFile: inputFileData && inputFileData.path ? true : false

    Component.onCompleted: {
        var saved = SepKits.SettingsStore.value("watermarkOutputDir", "")
        if (saved) SepKits.WatermarkProcessor.outputDir = saved
    }

    Connections {
        target: SepKits.WatermarkProcessor
        function onInputFileChanged() {
            if (_root.hasFile) _private.immediatePreviewRefresh()
            else { _private.previewOriginal = ""; _private.previewLayer = "" }
        }
        function onThumbnailReady(thumbPath) { _private.immediatePreviewRefresh() }
    }

    // ─── Layout ────────────────────────────────────────────────────────────

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SepKits.Theme.spacingXl
        spacing: SepKits.Theme.spacingLg

        // ═══ Toolbar ═══
        RowLayout {
            spacing: SepKits.Theme.spacingMd
            SepKits.BackButton { enabled: !_root.running }
            Text {
                text: qsTr("Watermark Adder")
                font.family: SepKits.Font.fontFamilyTitle
                font.pixelSize: SepKits.Font.sizeH3
                font.weight: SepKits.Font.weightH3
                color: SepKits.Color.foreground
                Layout.leftMargin: SepKits.Theme.spacingSm
            }
            Item { Layout.fillWidth: true }
            SepKits.SecondaryButton {
                text: qsTr("Add File")
                enabled: !_root.running
                onClicked: _addFileDialog.open()
            }
            SepKits.PrimaryButton {
                text: _root.running ? qsTr("Cancel") : qsTr("Start")
                enabled: _root.hasFile || _root.running
                onClicked: {
                    if (_root.running) SepKits.WatermarkProcessor.cancelProcessing()
                    else {
                        SepKits.WatermarkProcessor.setWatermarkSettings(_private.buildSettingsMap())
                        SepKits.WatermarkProcessor.startProcessing()
                    }
                }
            }
        }

        // ═══ Output Directory ═══
        RowLayout {
            spacing: SepKits.Theme.spacingSm
            Text {
                text: qsTr("Output to")
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                color: SepKits.Color.mutedForeground
            }
            TextField {
                id: _outputDirField
                Layout.fillWidth: true; implicitHeight: 40; readOnly: true
                text: SepKits.WatermarkProcessor.outputDir
                color: SepKits.Color.foreground
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                topPadding: SepKits.Theme.inputPaddingV
                bottomPadding: SepKits.Theme.inputPaddingV
                leftPadding: SepKits.Theme.inputPaddingH
                rightPadding: SepKits.Theme.inputPaddingH
                background: Rectangle {
                    radius: SepKits.Theme.radius; color: SepKits.Color.background
                    border.width: 1; border.color: SepKits.Color.border
                }
            }
            SepKits.SecondaryButton {
                text: qsTr("Browse"); enabled: !_root.running
                onClicked: _outputFolderDialog.open()
            }
        }

        // ═══ Main Content: Preview (left) + Settings (right) ─── (5) 50/50 split
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: SepKits.Color.card; radius: SepKits.Theme.cardRadius
            border.color: SepKits.Color.border; border.width: 1; clip: true

            RowLayout {
                anchors.fill: parent
                anchors.margins: SepKits.Theme.spacingMd
                spacing: SepKits.Theme.spacingLg

                // LEFT: Preview (50%)
                Rectangle {
                    Layout.preferredWidth: Math.round(parent.width * 0.50)
                    Layout.fillHeight: true
                    color: SepKits.Color.background; radius: SepKits.Theme.radius
                    border.color: SepKits.Color.border; border.width: 1; clip: true

                    // (2) Both preview layers stacked, using paintedWidth/Height
                    Item {
                        anchors.fill: parent; anchors.margins: 2

                        Image {
                            id: _previewOriginal
                            anchors.fill: parent
                            source: _private.previewOriginal
                            fillMode: Image.PreserveAspectFit
                            visible: _private.previewOriginal !== ""
                        }

                        Image {
                            id: _previewLayerImg
                            anchors.fill: parent
                            source: _private.previewLayer
                            fillMode: Image.PreserveAspectFit
                            visible: _private.previewLayer !== ""
                        }

                        // Watermark position indicator (single mode)
                        Rectangle {
                            id: _wmIndicator
                            width: 24; height: 24; radius: 12
                            x: _private.paintedX(_previewOriginal)
                               + _private.wmPosX * _private.paintedW(_previewOriginal) - width / 2
                            y: _private.paintedY(_previewOriginal)
                               + _private.wmPosY * _private.paintedH(_previewOriginal) - height / 2
                            color: SepKits.Color.alpha(SepKits.Color.primary, 0.35)
                            border.color: SepKits.Color.primary; border.width: 2
                            visible: _root.hasFile && _private.mode === 0
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: _root.hasFile && _private.mode === 0 && !_root.running
                            cursorShape: enabled ? Qt.CrossCursor : Qt.ArrowCursor
                            onPositionChanged: function(mouse) {
                                var pw = _private.paintedW(_previewOriginal)
                                var ph = _private.paintedH(_previewOriginal)
                                if (pw <= 0 || ph <= 0) return
                                _private.wmPosX = Math.max(0, Math.min(1,
                                    (mouse.x - _private.paintedX(_previewOriginal)) / pw))
                                _private.wmPosY = Math.max(0, Math.min(1,
                                    (mouse.y - _private.paintedY(_previewOriginal)) / ph))
                                _private.schedulePreviewRefresh()
                            }
                            onClicked: function(mouse) {
                                var pw = _private.paintedW(_previewOriginal)
                                var ph = _private.paintedH(_previewOriginal)
                                if (pw <= 0 || ph <= 0) return
                                _private.wmPosX = Math.max(0, Math.min(1,
                                    (mouse.x - _private.paintedX(_previewOriginal)) / pw))
                                _private.wmPosY = Math.max(0, Math.min(1,
                                    (mouse.y - _private.paintedY(_previewOriginal)) / ph))
                                _private.schedulePreviewRefresh()
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Add a file to preview")
                        font.family: SepKits.Font.fontFamilyBody
                        font.pixelSize: SepKits.Font.sizeSmall
                        color: SepKits.Color.mutedForeground
                        visible: !_root.hasFile
                    }
                }

                // RIGHT: Settings (50%)
                ColumnLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    spacing: 0

                        // ── TabBar (underline style) ──
                        TabBar {
                            id: _modeTabBar
                            Layout.fillWidth: true
                            currentIndex: _private.mode
                            onCurrentIndexChanged: {
                                _private.mode = currentIndex
                                _private.schedulePreviewRefresh()
                            }
                            background: Rectangle { color: SepKits.Color.transparent }
                            TabButton {
                                text: qsTr("Single Watermark")
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
                                        width: parent.width; height: 2
                                        color: parent.parent.checked ? SepKits.Color.primary : SepKits.Color.transparent
                                    }
                                }
                            }
                            TabButton {
                                text: qsTr("Batch Watermark")
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
                                        width: parent.width; height: 2
                                        color: parent.parent.checked ? SepKits.Color.primary : SepKits.Color.transparent
                                    }
                                }
                            }
                        }
                        Rectangle { Layout.fillWidth: true; height: 1; color: SepKits.Color.border }

                        StackLayout {
                            Layout.fillWidth: true
                            Layout.topMargin: SepKits.Theme.spacingMd
                            currentIndex: _modeTabBar.currentIndex

                            // ── Panel 0: Single ──
                            ColumnLayout {
                                spacing: SepKits.Theme.spacingSm

                                SepKits.SepComboBox {
                                    label: qsTr("Type")
                                    Layout.preferredWidth: 180
                                    comboHeight: 36; comboRadius: SepKits.Theme.radius
                                    model: [qsTr("Text"), qsTr("Image")]
                                    currentIndex: _private.wmType
                                    onActivated: index => {
                                        _private.wmType = index
                                        _private.schedulePreviewRefresh()
                                    }
                                }

                                // ── Text settings ──
                                ColumnLayout {
                                    visible: _private.wmType === 0
                                    spacing: SepKits.Theme.spacingSm
                                    Layout.fillWidth: true

                                    RowLayout {
                                        spacing: SepKits.Theme.spacingSm
                                        TextField {
                                            id: _textInput
                                            Layout.fillWidth: true; implicitHeight: 36
                                            topPadding: 8; bottomPadding: 8
                                            leftPadding: 10; rightPadding: 10
                                            text: _private.wmText
                                            color: SepKits.Color.foreground
                                            font.family: SepKits.Font.fontFamilyBody
                                            font.pixelSize: SepKits.Font.sizeSmall
                                            placeholderText: qsTr("Watermark text")
                                            placeholderTextColor: SepKits.Color.mutedForeground
                                            onTextChanged: { _private.wmText = text; _private.schedulePreviewRefresh() }
                                            background: Rectangle {
                                                radius: SepKits.Theme.radius; color: SepKits.Color.background
                                                border.width: 1
                                                border.color: _textInput.activeFocus ? SepKits.Color.primary : SepKits.Color.border
                                            }
                                        }
                                        Button {
                                            text: qsTr("Font"); implicitHeight: 36
                                            onClicked: _fontDialog.open()
                                            contentItem: Text {
                                                text: parent.text
                                                font.family: SepKits.Font.fontFamilyBody
                                                font.pixelSize: SepKits.Font.sizeSmall
                                                color: SepKits.Color.foreground
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            background: Rectangle {
                                                radius: SepKits.Theme.radius
                                                color: parent.hovered ? SepKits.Color.muted : "transparent"
                                                border.width: 1; border.color: SepKits.Color.border
                                            }
                                        }
                                    }

                                    // (3) Color section with proper spacing
                                    Item { Layout.preferredHeight: 4 }
                                    Text {
                                        text: qsTr("Color")
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeTiny
                                        color: SepKits.Color.mutedForeground
                                    }
                                    SepKits.SepColorPicker {
                                        Layout.fillWidth: true
                                        selectedColor: _private.wmTextColor
                                        onColorSelected: c => { _private.wmTextColor = c; _private.schedulePreviewRefresh() }
                                    }
                                    Item { Layout.preferredHeight: 4 }

                                    // Text Opacity slider (single mode)
                                    RowLayout {
                                        spacing: SepKits.Theme.spacingMd
                                        Text {
                                            text: qsTr("Opacity: %1%").arg(Math.round(_private.wmSingleTextOpacity * 100))
                                            font.family: SepKits.Font.fontFamilyBody
                                            font.pixelSize: SepKits.Font.sizeSmall
                                            color: SepKits.Color.foreground
                                            Layout.preferredWidth: 110
                                        }
                                        SepKits.SepSlider {
                                            Layout.fillWidth: true
                                            from: 0.01; to: 1.0; value: _private.wmSingleTextOpacity; stepSize: 0.01
                                            onValueChanged: { _private.wmSingleTextOpacity = value; _private.schedulePreviewRefresh() }
                                        }
                                    }
                                    // Text Size slider
                                    RowLayout {
                                        spacing: SepKits.Theme.spacingMd
                                        Text {
                                            text: qsTr("Size: %1").arg(_private.wmFontSize)
                                            font.family: SepKits.Font.fontFamilyBody
                                            font.pixelSize: SepKits.Font.sizeSmall
                                            color: SepKits.Color.foreground
                                            Layout.preferredWidth: 110
                                        }
                                        SepKits.SepSlider {
                                            Layout.fillWidth: true
                                            from: 8; to: 200; value: _private.wmFontSize; stepSize: 1
                                            onValueChanged: { _private.wmFontSize = value; _private.schedulePreviewRefresh() }
                                        }
                                    }
                                }

                                // ── Image settings ──
                                ColumnLayout {
                                    visible: _private.wmType === 1
                                    spacing: SepKits.Theme.spacingSm
                                    Layout.fillWidth: true

                                    RowLayout {
                                        spacing: SepKits.Theme.spacingSm
                                        TextField {
                                            id: _imagePathField
                                            Layout.fillWidth: true; implicitHeight: 36
                                            topPadding: 8; bottomPadding: 8
                                            leftPadding: 10; rightPadding: 10; readOnly: true
                                            text: _private.wmImagePath ? decodeURIComponent(_private.wmImagePath.replace(/^.*[\\/]/, "")) : ""
                                            color: SepKits.Color.foreground
                                            font.family: SepKits.Font.fontFamilyBody
                                            font.pixelSize: SepKits.Font.sizeSmall
                                            placeholderText: qsTr("Select watermark image...")
                                            placeholderTextColor: SepKits.Color.mutedForeground
                                            background: Rectangle {
                                                radius: SepKits.Theme.radius; color: SepKits.Color.background
                                                border.width: 1; border.color: SepKits.Color.border
                                            }
                                        }
                                        Button {
                                            text: qsTr("Browse"); implicitHeight: 36
                                            onClicked: _wmImageDialog.open()
                                            contentItem: Text {
                                                text: parent.text
                                                font.family: SepKits.Font.fontFamilyBody
                                                font.pixelSize: SepKits.Font.sizeSmall
                                                color: SepKits.Color.foreground
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            background: Rectangle {
                                                radius: SepKits.Theme.radius
                                                color: parent.hovered ? SepKits.Color.muted : "transparent"
                                                border.width: 1; border.color: SepKits.Color.border
                                            }
                                        }
                                    }

                                    // Image Opacity slider
                                    RowLayout {
                                        spacing: SepKits.Theme.spacingMd
                                        Text {
                                            text: qsTr("Opacity: %1%").arg(Math.round(_private.wmOpacity * 100))
                                            font.family: SepKits.Font.fontFamilyBody
                                            font.pixelSize: SepKits.Font.sizeSmall
                                            color: SepKits.Color.foreground
                                            Layout.preferredWidth: 110
                                        }
                                        SepKits.SepSlider {
                                            Layout.fillWidth: true
                                            from: 0.01; to: 1.0; value: _private.wmOpacity; stepSize: 0.01
                                            onValueChanged: { _private.wmOpacity = value; _private.schedulePreviewRefresh() }
                                        }
                                    }
                                    // Image Size slider
                                    RowLayout {
                                        spacing: SepKits.Theme.spacingMd
                                        Text {
                                            text: qsTr("Size: %1%").arg(Math.round(_private.wmImageScale * 100))
                                            font.family: SepKits.Font.fontFamilyBody
                                            font.pixelSize: SepKits.Font.sizeSmall
                                            color: SepKits.Color.foreground
                                            Layout.preferredWidth: 110
                                        }
                                        SepKits.SepSlider {
                                            Layout.fillWidth: true
                                            from: 0.05; to: 2.0; value: _private.wmImageScale; stepSize: 0.05
                                            onValueChanged: { _private.wmImageScale = value; _private.schedulePreviewRefresh() }
                                        }
                                    }
                                }

                                // ── Shared: Rotation (single mode) ──
                                RowLayout {
                                    spacing: SepKits.Theme.spacingMd
                                    Text {
                                        text: qsTr("Rotation: %1°").arg(_private.wmSingleRotation)
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.foreground
                                        Layout.preferredWidth: 110
                                    }
                                    SepKits.SepSlider {
                                        Layout.fillWidth: true
                                        from: -180; to: 180; value: _private.wmSingleRotation; stepSize: 1
                                        onValueChanged: { _private.wmSingleRotation = value; _private.schedulePreviewRefresh() }
                                    }
                                }

                                Text {
                                    visible: _root.hasFile
                                    text: _root.hasFile ? qsTr("File: %1 (%2×%3)").arg(inputFileData.fileName).arg(inputFileData.width).arg(inputFileData.height) : ""
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeTiny
                                    color: SepKits.Color.mutedForeground
                                    elide: Text.ElideMiddle; Layout.fillWidth: true
                                }
                                Item { Layout.fillHeight: true }
                            }

                            // ── Panel 1: Batch ──
                            ColumnLayout {
                                spacing: SepKits.Theme.spacingSm

                                RowLayout {
                                    spacing: SepKits.Theme.spacingSm
                                    TextField {
                                        id: _batchTextInput
                                        Layout.fillWidth: true; implicitHeight: 36
                                        topPadding: 8; bottomPadding: 8
                                        leftPadding: 10; rightPadding: 10
                                        text: _private.wmText
                                        color: SepKits.Color.foreground
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        placeholderText: qsTr("Watermark text")
                                        placeholderTextColor: SepKits.Color.mutedForeground
                                        onTextChanged: { _private.wmText = text; _private.schedulePreviewRefresh() }
                                        background: Rectangle {
                                            radius: SepKits.Theme.radius; color: SepKits.Color.background
                                            border.width: 1
                                            border.color: _batchTextInput.activeFocus ? SepKits.Color.primary : SepKits.Color.border
                                        }
                                    }
                                    Button {
                                        text: qsTr("Font"); implicitHeight: 36
                                        onClicked: _fontDialog.open()
                                        contentItem: Text {
                                            text: parent.text
                                            font.family: SepKits.Font.fontFamilyBody
                                            font.pixelSize: SepKits.Font.sizeSmall
                                            color: SepKits.Color.foreground
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        background: Rectangle {
                                            radius: SepKits.Theme.radius
                                            color: parent.hovered ? SepKits.Color.muted : "transparent"
                                            border.width: 1; border.color: SepKits.Color.border
                                        }
                                    }
                                }

                                Item { Layout.preferredHeight: 4 }
                                Text {
                                    text: qsTr("Color")
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeTiny
                                    color: SepKits.Color.mutedForeground
                                }
                                SepKits.SepColorPicker {
                                    Layout.fillWidth: true
                                    selectedColor: _private.wmTextColor
                                    onColorSelected: c => { _private.wmTextColor = c; _private.schedulePreviewRefresh() }
                                }
                                Item { Layout.preferredHeight: 4 }

                                // Batch Opacity (batch mode)
                                RowLayout {
                                    spacing: SepKits.Theme.spacingMd
                                    Text {
                                        text: qsTr("Opacity: %1%").arg(Math.round(_private.wmBatchTextOpacity * 100))
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.foreground
                                        Layout.preferredWidth: 110
                                    }
                                    SepKits.SepSlider {
                                        Layout.fillWidth: true
                                        from: 0.01; to: 1.0; value: _private.wmBatchTextOpacity; stepSize: 0.01
                                        onValueChanged: { _private.wmBatchTextOpacity = value; _private.schedulePreviewRefresh() }
                                    }
                                }
                                // Batch Size
                                RowLayout {
                                    spacing: SepKits.Theme.spacingMd
                                    Text {
                                        text: qsTr("Size: %1").arg(_private.wmFontSize)
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.foreground
                                        Layout.preferredWidth: 110
                                    }
                                    SepKits.SepSlider {
                                        Layout.fillWidth: true
                                        from: 8; to: 200; value: _private.wmFontSize; stepSize: 1
                                        onValueChanged: { _private.wmFontSize = value; _private.schedulePreviewRefresh() }
                                    }
                                }
                                // Batch Rotation (batch mode)
                                RowLayout {
                                    spacing: SepKits.Theme.spacingMd
                                    Text {
                                        text: qsTr("Rotation: %1°").arg(_private.wmBatchRotation)
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.foreground
                                        Layout.preferredWidth: 110
                                    }
                                    SepKits.SepSlider {
                                        Layout.fillWidth: true
                                        from: -180; to: 180; value: _private.wmBatchRotation; stepSize: 1
                                        onValueChanged: { _private.wmBatchRotation = value; _private.schedulePreviewRefresh() }
                                    }
                                }
                                // Batch H Spacing
                                RowLayout {
                                    spacing: SepKits.Theme.spacingMd
                                    Text {
                                        text: qsTr("H Spacing: %1%").arg(_private.wmHSpacing)
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.foreground
                                        Layout.preferredWidth: 110
                                    }
                                    SepKits.SepSlider {
                                        Layout.fillWidth: true
                                        from: 0; to: 100; value: _private.wmHSpacing; stepSize: 1
                                        onValueChanged: { _private.wmHSpacing = value; _private.schedulePreviewRefresh() }
                                    }
                                }
                                // Batch V Spacing
                                RowLayout {
                                    spacing: SepKits.Theme.spacingMd
                                    Text {
                                        text: qsTr("V Spacing: %1%").arg(_private.wmVSpacing)
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.foreground
                                        Layout.preferredWidth: 110
                                    }
                                    SepKits.SepSlider {
                                        Layout.fillWidth: true
                                        from: 0; to: 100; value: _private.wmVSpacing; stepSize: 1
                                        onValueChanged: { _private.wmVSpacing = value; _private.schedulePreviewRefresh() }
                                    }
                                }

                                Text {
                                    text: qsTr("Watermark text will repeat in a grid pattern across the entire media.")
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeTiny
                                    color: SepKits.Color.mutedForeground
                                    wrapMode: Text.WordWrap; Layout.fillWidth: true
                                }
                                Text {
                                    visible: _root.hasFile
                                    text: _root.hasFile ? qsTr("File: %1 (%2×%3)").arg(inputFileData.fileName).arg(inputFileData.width).arg(inputFileData.height) : ""
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeTiny
                                    color: SepKits.Color.mutedForeground
                                    elide: Text.ElideMiddle; Layout.fillWidth: true
                                }
                                Item { Layout.fillHeight: true }
                            }
                        }
                }
            }
        }

        // ═══ Progress (always visible) ═══
        ColumnLayout {
            spacing: SepKits.Theme.spacingSm
            Text {
                text: {
                    if (_root.running) return qsTr("Processing...")
                    if (SepKits.WatermarkProcessor.progress >= 1.0) return qsTr("Complete")
                    return qsTr("Ready")
                }
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                color: {
                    if (_root.running) return SepKits.Color.purple500
                    if (SepKits.WatermarkProcessor.progress >= 1.0) return SepKits.Color.green500
                    return SepKits.Color.mutedForeground
                }
            }
            SepKits.SepProgressBar {
                Layout.fillWidth: true
                value: SepKits.WatermarkProcessor.progress
            }
        }
    }

    // ─── (4) Slider row: fixed label width prevents jitter ──────────────────

    // Reusable helper: creates a slider row with fixed-width label.
    // We inline each row below using the pattern:
    //   RowLayout { Text { Layout.preferredWidth:110; text: qsTr(...).arg(val) } SepSlider { ... } }

    // ═══ Dialogs ═══

    FileDialog {
        id: _addFileDialog
        title: qsTr("Select Media File")
        fileMode: FileDialog.OpenFile
        nameFilters: [
            qsTr("All Media (%1)").arg("*.mp4 *.avi *.mkv *.mov *.webm *.wmv *.flv *.m4v *.mpeg *.mpg *.ts *.mts *.3gp *.ogv *.divx *.hevc *.mjpeg *.av1 *.swf *.avchd *.vob *.xvid *.mxf *.rm *.f4v *.asf *.rmvb *.wtv *.3g2 *.jpg *.jpeg *.png *.bmp *.webp *.gif *.tiff *.tif *.apng *.avif *.jp2 *.exr *.hdr *.tga *.pcx"),
            qsTr("Videos (%1)").arg("*.mp4 *.avi *.mkv *.mov *.webm *.wmv *.flv *.m4v *.mpeg *.mpg *.ts *.mts *.3gp *.ogv *.divx *.hevc *.mjpeg *.av1 *.swf"),
            qsTr("Images (%1)").arg("*.jpg *.jpeg *.png *.bmp *.webp *.gif *.tiff *.tif *.apng *.avif *.jp2 *.exr *.hdr *.tga *.pcx"),
            qsTr("All Files (*.*)")
        ]
        onAccepted: {
            var path = String(currentFile).replace(/^(file:\/{3})/, "")
            SepKits.WatermarkProcessor.setInputFile(path)
        }
    }

    FolderDialog {
        id: _outputFolderDialog
        title: qsTr("Select Output Folder")
        currentFolder: "file:///" + SepKits.WatermarkProcessor.outputDir
        onAccepted: {
            var path = String(currentFolder).replace(/^(file:\/{3})/, "")
            SepKits.WatermarkProcessor.outputDir = path
            SepKits.SettingsStore.setValue("watermarkOutputDir", path)
        }
    }

    FileDialog {
        id: _wmImageDialog
        title: qsTr("Select Watermark Image")
        fileMode: FileDialog.OpenFile
        nameFilters: [
            qsTr("Images (%1)").arg("*.png *.jpg *.jpeg *.bmp"),
            qsTr("All Files (*.*)")
        ]
        onAccepted: {
            var path = String(currentFile).replace(/^(file:\/{3})/, "")
            _private.wmImagePath = path
            _private.schedulePreviewRefresh()
        }
    }

    FontDialog {
        id: _fontDialog
        title: qsTr("Select Font")
        onAccepted: {
            _private.wmFontFamily = currentFont.family
            _private.schedulePreviewRefresh()
        }
    }

    // Drag-and-drop
    DropArea {
        anchors.fill: parent; z: 1; enabled: !_root.running
        onEntered: drag => { drag.accept(Qt.LinkAction) }
        onDropped: drop => {
            if (drop.urls.length > 0) {
                var path = String(drop.urls[0]).replace(/^(file:\/{3})/, "")
                SepKits.WatermarkProcessor.setInputFile(path)
            }
        }
    }
}
