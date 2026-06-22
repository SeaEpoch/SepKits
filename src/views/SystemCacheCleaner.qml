import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

Rectangle {
    id: _root
    color: SepKits.Color.background

    QtObject {
        id: _private
        property string logContent: ""
        readonly property var model: SepKits.SystemCacheCleaner.model
    }

    function appendLog(message) {
        _private.logContent += message + "\n"
        _logArea.cursorPosition = _logArea.length
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SepKits.Theme.spacingXl
        spacing: SepKits.Theme.spacingMd

        // ═══ 1. Toolbar ═══
        RowLayout {
            spacing: SepKits.Theme.spacingMd

            SepKits.BackButton {}

            Text {
                text: qsTr("Cache Cleaner")
                font.family: SepKits.Font.fontFamilyTitle
                font.pixelSize: SepKits.Font.sizeH3
                font.weight: SepKits.Font.weightH3
                color: SepKits.Color.foreground
                Layout.leftMargin: SepKits.Theme.spacingSm
            }

            Item { Layout.fillWidth: true }

            // Select All
            Item {
                implicitWidth: _selAllRow.implicitWidth
                implicitHeight: _selAllRow.implicitHeight
                visible: _private.model && _private.model.allScanned

                RowLayout {
                    id: _selAllRow
                    spacing: 4

                    Rectangle {
                        implicitWidth: 16; implicitHeight: 16; radius: 3
                        border.width: 2
                        border.color: _private.model && _private.model.anyChecked ? SepKits.Color.primary : SepKits.Color.border
                        color: _private.model && _private.model.anyChecked ? SepKits.Color.primary : SepKits.Color.transparent

                        Text {
                            anchors.centerIn: parent
                            text: _private.model && _private.model.anyChecked ? "✓" : ""
                            color: SepKits.Color.primaryForeground
                            font.pixelSize: 11; font.weight: Font.Bold
                        }
                    }
                    Text {
                        text: qsTr("Select All")
                        color: SepKits.Color.foreground
                        font.family: SepKits.Font.fontFamilyBody
                        font.pixelSize: SepKits.Font.sizeSmall
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (_private.model) _private.model.setAllChecked(!_private.model.anyChecked) }
                }
            }

            // Scan
            SepKits.PrimaryButton {
                id: _scanBtn
                text: qsTr("Scan All")
                enabled: !SepKits.SystemCacheCleaner.scanning && !SepKits.SystemCacheCleaner.running
                onClicked: {
                    _private.logContent = ""
                    SepKits.SystemCacheCleaner.startScan()
                }
            }

            // Clean
            SepKits.PrimaryButton {
                id: _cleanBtn
                text: qsTr("Clean Selected")
                enabled: _private.model && _private.model.allScanned && _private.model.anyChecked
                    && !SepKits.SystemCacheCleaner.running && !SepKits.SystemCacheCleaner.scanning
                onClicked: {
                    SepKits.DialogManager.confirm(
                        qsTr("Confirm Cleanup"),
                        qsTr("%1 categories selected. Clean them now?\n\nPlease save any unsaved work before proceeding.").arg(_private.model ? _private.model.checkedCount : 0),
                        qsTr("Start Cleaning"),
                        qsTr("Cancel"),
                        function() {
                            _private.logContent = ""
                            if (_private.model) SepKits.SystemCacheCleaner.startCleanup(_private.model.checkedKeys())
                        },
                        null
                    )
                }
            }

            // Cancel
            SepKits.SecondaryButton {
                id: _cancelBtn
                text: qsTr("Cancel")
                visible: SepKits.SystemCacheCleaner.scanning || SepKits.SystemCacheCleaner.running
                onClicked: SepKits.SystemCacheCleaner.cancel()
            }
        }

        // ═══ 2. Split area — list + log ═══
        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Vertical

            // Category list
            Rectangle {
                id: _listRect
                SplitView.preferredHeight: parent.height * 0.65
                SplitView.minimumHeight: 150

                color: SepKits.Color.card
                radius: SepKits.Theme.cardRadius
                border.color: SepKits.Color.border
                border.width: 1

                ListView {
                    id: _listView
                    anchors.fill: parent
                    anchors.margins: 4
                    clip: true
                    model: _private.model

                    delegate: Item {
                        width: _listView.width
                        height: 44

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: SepKits.Theme.spacingSm
                            anchors.rightMargin: SepKits.Theme.spacingSm
                            spacing: SepKits.Theme.spacingMd

                            // Checkbox
                            Rectangle {
                                implicitWidth: 18; implicitHeight: 18; radius: 4
                                border.width: 2
                                opacity: model.scanned ? 1.0 : 0.4
                                border.color: {
                                    if (!model.scanned) return SepKits.Color.border
                                    return model.checked ? SepKits.Color.primary : SepKits.Color.border
                                }
                                color: (model.scanned && model.checked) ? SepKits.Color.primary : SepKits.Color.transparent
                                Behavior on color { ColorAnimation { duration: SepKits.Theme.animFast } }

                                Text {
                                    anchors.centerIn: parent
                                    text: (model.scanned && model.checked) ? "✓" : ""
                                    color: SepKits.Color.primaryForeground
                                    font.pixelSize: 12; font.weight: Font.Bold
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: model.scanned
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: model.checked = !model.checked
                                }
                            }

                            // Label
                            Text {
                                text: model.label
                                color: SepKits.Color.foreground
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeBody
                                font.weight: SepKits.Font.weightMedium
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            // File count
                            Text {
                                text: model.scanned ? model.fileCount + " " + qsTr("files") : ""
                                color: SepKits.Color.mutedForeground
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                visible: model.scanned
                                Layout.alignment: Qt.AlignRight
                            }

                            // Size
                            Text {
                                text: model.sizeText
                                color: model.scanned ? SepKits.Color.foreground : SepKits.Color.mutedForeground
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                font.weight: Font.Medium
                                Layout.alignment: Qt.AlignRight
                                Layout.preferredWidth: 80
                                horizontalAlignment: Text.AlignRight
                            }
                        }

                        // Divider
                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            height: index < 9 ? 1 : 0
                            color: SepKits.Color.border
                        }
                    }
                }
            }

            // Log output
            Rectangle {
                SplitView.preferredHeight: parent.height * 0.35
                SplitView.minimumHeight: 100

                color: SepKits.Color.card
                radius: SepKits.Theme.cardRadius
                border.color: SepKits.Color.border
                border.width: 1

                ScrollView {
                    id: _scrollView
                    anchors.fill: parent
                    anchors.margins: SepKits.Theme.spacingMd
                    clip: true

                    TextArea {
                        id: _logArea
                        readOnly: true
                        text: _private.logContent
                        width: Math.max(_scrollView.availableWidth, implicitWidth)
                        color: SepKits.Color.foreground
                        font.family: SepKits.Font.fontFamilyBody
                        font.pixelSize: SepKits.Font.sizeSmall
                        placeholderText: qsTr("Click \"Scan All\" to analyze cache sizes, then select items to clean.")
                        placeholderTextColor: SepKits.Color.mutedForeground
                        background: null
                        selectByMouse: true
                        wrapMode: TextArea.NoWrap
                    }
                }
            }

            handle: Rectangle {
                implicitHeight: SepKits.Theme.spacingSm
                implicitWidth: parent ? parent.width : 0
                color: SepKits.Color.transparent
            }
        }

        // ═══ 4. Progress bar ═══
        RowLayout {
            spacing: SepKits.Theme.spacingMd
            visible: SepKits.SystemCacheCleaner.scanning || SepKits.SystemCacheCleaner.running

            Text {
                id: _progressLabel
                text: SepKits.SystemCacheCleaner.scanning ? qsTr("Scanning...") : qsTr("Cleaning...")
                color: SepKits.Color.mutedForeground
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
            }

            SepKits.SepProgressBar {
                id: _progressBar
                Layout.fillWidth: true
                value: SepKits.SystemCacheCleaner.progressValue
            }

            Text {
                text: (SepKits.SystemCacheCleaner.progressValue * 100).toFixed(0) + "%"
                color: SepKits.Color.mutedForeground
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeSmall
                Layout.preferredWidth: 40
                horizontalAlignment: Text.AlignRight
            }
        }
    }

    // ═══ Connections ═══

    Connections {
        target: SepKits.SystemCacheCleaner

        function onProgressUpdated(message) {
            appendLog(message)
        }

        function onProgressLabelChanged(label) {
            _progressLabel.text = label
        }

        function onScanAllCompleted() {
            // 不需要翻译
            appendLog("=== Scan completed. Select categories to clean. ===")
        }

        function onCleanupFinished(cleanedCount, freedBytes) {
            // 不需要翻译
            appendLog("=== Process Completed ===")
        }
    }

    Component.onCompleted: {
        appendLog(qsTr("Click \"Scan All\" to analyze cache sizes."))
        if (!SepKits.SystemCacheCleaner.isRunningAsAdmin())
            SepKits.DialogManager.confirm(
                qsTr("Administrator Privileges Required"),
                qsTr("Some categories require administrator privileges. Relaunch as administrator?"),
                qsTr("Relaunch as Admin"),
                qsTr("Continue Without"),
                function() { SepKits.SystemCacheCleaner.requestAdminRelaunch() },
                null
            )
    }
}
