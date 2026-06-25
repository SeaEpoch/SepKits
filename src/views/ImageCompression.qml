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
        property int applyAllQuality: 5
    }

    readonly property bool running: SepKits.ImageCompressor.isRunning
    readonly property var fileList: SepKits.ImageCompressor.files

    function pendingCount() {
        var c = 0; var fl = fileList
        for (var i = 0; i < fl.length; i++) { if (fl[i].status === "pending") c++ }
        return c
    }

    Component.onCompleted: {
        var saved = SepKits.SettingsStore.value("imageCompOutputDir", "")
        if (saved) SepKits.ImageCompressor.outputDir = saved
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SepKits.Theme.spacingXl
        spacing: SepKits.Theme.spacingLg

        // ═══ Toolbar ═══
        RowLayout {
            spacing: SepKits.Theme.spacingMd
            SepKits.BackButton { enabled: !_root.running }
            Text {
                text: qsTr("Image Compression")
                font.family: SepKits.Font.fontFamilyTitle
                font.pixelSize: SepKits.Font.sizeH3
                font.weight: SepKits.Font.weightH3
                color: SepKits.Color.foreground
                Layout.leftMargin: SepKits.Theme.spacingSm
            }
            Item { Layout.fillWidth: true }
            SepKits.SecondaryButton {
                text: qsTr("Add Files"); enabled: !_root.running
                onClicked: _addFilesDialog.open()
            }
            SepKits.PrimaryButton {
                text: _root.running ? qsTr("Cancel") : qsTr("Start Compression")
                enabled: _root.pendingCount() > 0 || _root.running
                onClicked: {
                    if (_root.running) SepKits.ImageCompressor.cancelCompression()
                    else SepKits.ImageCompressor.startCompression()
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
                text: SepKits.ImageCompressor.outputDir
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

        // ═══ Apply-to-all quality row ═══
        RowLayout {
            visible: _fileListView.count > 0
            spacing: SepKits.Theme.spacingMd
            Text {
                text: qsTr("Apply quality to all:")
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                color: SepKits.Color.mutedForeground
            }
            SepKits.SepSlider {
                Layout.fillWidth: true
                from: 0; to: 10; value: _private.applyAllQuality; stepSize: 1
                onValueChanged: _private.applyAllQuality = value
            }
            Text {
                text: _private.applyAllQuality
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                color: SepKits.Color.foreground
                Layout.preferredWidth: 20
            }
            SepKits.SecondaryButton {
                text: qsTr("Apply"); enabled: !_root.running && _fileListView.count > 0
                onClicked: SepKits.ImageCompressor.applyQualityToAll(_private.applyAllQuality)
            }
        }

        // ═══ File List Card ═══
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true
            color: SepKits.Color.card; radius: SepKits.Theme.cardRadius
            border.color: SepKits.Color.border; border.width: 1; clip: true

            ColumnLayout {
                anchors.fill: parent; spacing: 0

                // Header
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 40
                    color: SepKits.Color.alpha(SepKits.Color.muted, 0.4)
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: SepKits.Theme.spacingMd
                        anchors.rightMargin: SepKits.Theme.spacingMd
                        spacing: SepKits.Theme.spacingSm
                        Item { Layout.preferredWidth: 24 }
                        Text {
                            text: qsTr("File Name"); Layout.fillWidth: true
                            font.family: SepKits.Font.fontFamilyBody
                            font.pixelSize: SepKits.Font.sizeTiny
                            font.weight: SepKits.Font.weightMedium
                            color: SepKits.Color.mutedForeground
                        }
                        Text {
                            text: qsTr("Quality"); Layout.preferredWidth: 140
                            horizontalAlignment: Text.AlignHCenter
                            font.family: SepKits.Font.fontFamilyBody
                            font.pixelSize: SepKits.Font.sizeTiny
                            font.weight: SepKits.Font.weightMedium
                            color: SepKits.Color.mutedForeground
                        }
                        Text {
                            text: qsTr("Size"); Layout.preferredWidth: 64
                            font.family: SepKits.Font.fontFamilyBody
                            font.pixelSize: SepKits.Font.sizeTiny
                            font.weight: SepKits.Font.weightMedium
                            color: SepKits.Color.mutedForeground
                        }
                        Text {
                            text: qsTr("Status"); Layout.preferredWidth: 64
                            font.family: SepKits.Font.fontFamilyBody
                            font.pixelSize: SepKits.Font.sizeTiny
                            font.weight: SepKits.Font.weightMedium
                            color: SepKits.Color.mutedForeground
                        }
                        Item { Layout.preferredWidth: 36 }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 1
                    color: SepKits.Color.border
                }

                ListView {
                    id: _fileListView
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    model: _root.fileList

                    delegate: Rectangle {
                        id: _row
                        width: ListView.view.width; height: 48
                        color: index % 2 === 0 ? "transparent"
                            : SepKits.Color.alpha(SepKits.Color.muted, 0.2)
                        property var file: modelData; property int idx: index

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: SepKits.Theme.spacingMd
                            anchors.rightMargin: SepKits.Theme.spacingMd
                            spacing: SepKits.Theme.spacingSm

                            SepKits.SvgIcon {
                                Layout.preferredWidth: 24; Layout.preferredHeight: 20
                                iconSource: SepKits.FontAwesome.image
                                color: SepKits.Color.green500
                            }

                            Text {
                                id: _fileNameText
                                text: _row.file.fileName || ""
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                color: SepKits.Color.foreground
                                elide: Text.ElideRight; Layout.fillWidth: true
                                maximumLineCount: 1

                                MouseArea {
                                    id: _hoverArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.NoButton
                                }
                                ToolTip {
                                    visible: _hoverArea.containsMouse
                                    text: _row.file.path || ""
                                    delay: 500
                                }
                            }

                            RowLayout {
                                Layout.preferredWidth: 140
                                spacing: SepKits.Theme.spacingSm
                                SepKits.SepSlider {
                                    id: _qualitySlider
                                    Layout.preferredWidth: 110
                                    from: 0; to: 10
                                    value: _row.file.compressionQuality !== undefined ? _row.file.compressionQuality : 5
                                    stepSize: 1
                                    enabled: !_root.running
                                    onValueChanged: SepKits.ImageCompressor.setCompressionQuality(_row.idx, value)
                                }
                                Text {
                                    text: _qualitySlider.value
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeTiny
                                    color: SepKits.Color.mutedForeground
                                    Layout.preferredWidth: 16
                                }
                            }

                            Text {
                                text: _row.file.fileSizeText || ""
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                color: SepKits.Color.mutedForeground
                                Layout.preferredWidth: 64
                            }

                            Text {
                                text: {
                                    switch (_row.file.status) {
                                        case "converting": return qsTr("Compressing")
                                        case "done": return qsTr("Done")
                                        case "failed": return qsTr("Failed")
                                        default: return qsTr("Ready")
                                    }
                                }
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                color: {
                                    switch (_row.file.status) {
                                        case "converting": return SepKits.Color.purple500
                                        case "done": return SepKits.Color.green500
                                        case "failed": return SepKits.Color.distructive
                                        default: return SepKits.Color.blue500
                                    }
                                }
                                Layout.preferredWidth: 64
                            }

                            Item {
                                Layout.preferredWidth: 36; Layout.fillHeight: true
                                Button {
                                    id: _delBtn
                                    anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                                    width: 28; height: 28
                                    enabled: !_root.running
                                    topPadding: 7; bottomPadding: 7; leftPadding: 7; rightPadding: 7
                                    contentItem: SepKits.SvgIcon {
                                        anchors.centerIn: parent
                                        iconSource: SepKits.FontAwesome.xmark
                                        color: _delBtn.hovered ? SepKits.Color.distructive : SepKits.Color.mutedForeground
                                        Behavior on color { ColorAnimation { duration: SepKits.Theme.animFast } }
                                    }
                                    background: Rectangle {
                                        radius: SepKits.Theme.radius
                                        color: _delBtn.hovered ? SepKits.Color.alpha(SepKits.Color.distructive, 0.12) : SepKits.Color.transparent
                                        Behavior on color { ColorAnimation { duration: SepKits.Theme.animFast } }
                                    }
                                    onClicked: SepKits.ImageCompressor.removeFile(_row.idx)
                                }
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: qsTr("Drag and drop image files here.")
                        font.family: SepKits.Font.fontFamilyBody
                        font.pixelSize: SepKits.Font.sizeSmall
                        color: SepKits.Color.mutedForeground
                        visible: _fileListView.count === 0
                    }
                }
            }
        }

        // ═══ Progress (matches MediaFormatConverter) ═══
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            Text {
                text: {
                    var total = _root.pendingCount()
                    var fl = _root.fileList
                    if (_root.running) {
                        if (total > 0)
                            return qsTr("Compressing %n file(s)...", "", fl.length)
                        return qsTr("Compressing...")
                    }
                    if (_root.fileList.length === 0)
                        return qsTr("Add files to begin")
                    if (fl.length > 0 && total === 0)
                        return qsTr("All files compressed")
                    return qsTr("%n file(s) ready", "", total)
                }
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                color: SepKits.Color.mutedForeground
            }
            SepKits.SepProgressBar {
                Layout.fillWidth: true
                value: SepKits.ImageCompressor.progress
            }
        }
    }

    // ═══ Dialogs ═══

    FileDialog {
        id: _addFilesDialog
        title: qsTr("Add Image Files")
        fileMode: FileDialog.OpenFiles
        nameFilters: [
            qsTr("Images (%1)").arg("*.jpg *.jpeg *.png *.bmp *.webp *.gif *.tiff *.tif *.apng *.avif *.jp2 *.exr *.hdr *.tga *.pcx"),
            qsTr("All Files (*.*)")
        ]
        onAccepted: {
            var paths = []; var selectedFiles = currentFiles
            for (var i = 0; i < selectedFiles.length; i++) {
                paths.push(String(selectedFiles[i]).replace(/^(file:\/{3})/, ""))
            }
            SepKits.ImageCompressor.addFiles(paths)
        }
    }

    FolderDialog {
        id: _outputFolderDialog
        title: qsTr("Select Output Folder")
        currentFolder: "file:///" + SepKits.ImageCompressor.outputDir
        onAccepted: {
            var path = String(currentFolder).replace(/^(file:\/{3})/, "")
            SepKits.ImageCompressor.outputDir = path
            SepKits.SettingsStore.setValue("imageCompOutputDir", path)
        }
    }

    DropArea {
        anchors.fill: parent; z: 1; enabled: !_root.running
        onEntered: drag => { drag.accept(Qt.LinkAction) }
        onDropped: drop => {
            var paths = []
            for (var i = 0; i < drop.urls.length; i++) {
                paths.push(String(drop.urls[i]).replace(/^(file:\/{3})/, ""))
            }
            SepKits.ImageCompressor.addFiles(paths)
        }
    }
}
