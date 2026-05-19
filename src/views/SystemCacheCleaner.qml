import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

Rectangle {
    id: _root
    color: SepKits.Color.background

    property string _logContent: ""

    function appendLog(message) {
        _logContent += message + "\n"
        _logArea.cursorPosition = _logArea.length
    }

    readonly property var _model: SepKits.SystemCacheCleaner.model

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SepKits.Theme.spacingXl
        spacing: SepKits.Theme.spacingMd

        // ═══ 1. Toolbar ═══
        RowLayout {
            spacing: SepKits.Theme.spacingMd

            Button {
                text: qsTr("← Back")
                topPadding: SepKits.Theme.spacingSm
                bottomPadding: SepKits.Theme.spacingSm
                leftPadding: SepKits.Theme.spacingMd
                rightPadding: SepKits.Theme.spacingMd
                contentItem: Text {
                    text: parent.text
                    color: SepKits.Color.foreground
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeSmall
                    font.weight: SepKits.Font.weightMedium
                }
                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: parent.hovered ? SepKits.Color.muted : SepKits.Color.transparent
                }
                onClicked: Window.window.navigateBack()
            }

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
                visible: _model && _model.allScanned

                RowLayout {
                    id: _selAllRow
                    spacing: 4

                    Rectangle {
                        implicitWidth: 16; implicitHeight: 16; radius: 3
                        border.width: 2
                        border.color: _model && _model.anyChecked ? SepKits.Color.primary : SepKits.Color.border
                        color: _model && _model.anyChecked ? SepKits.Color.primary : SepKits.Color.transparent

                        Text {
                            anchors.centerIn: parent
                            text: _model && _model.anyChecked ? "✓" : ""
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
                    onClicked: { if (_model) _model.setAllChecked(!_model.anyChecked) }
                }
            }

            // Scan
            Button {
                id: _scanBtn
                text: qsTr("Scan All")
                enabled: !SepKits.SystemCacheCleaner.scanning && !SepKits.SystemCacheCleaner.running
                topPadding: SepKits.Theme.buttonPaddingV
                bottomPadding: SepKits.Theme.buttonPaddingV
                leftPadding: SepKits.Theme.buttonPaddingH
                rightPadding: SepKits.Theme.buttonPaddingH
                contentItem: Text {
                    text: _scanBtn.text
                    color: _scanBtn.enabled ? SepKits.Color.primaryForeground : SepKits.Color.disabled(SepKits.Color.primaryForeground)
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeBody
                    font.weight: SepKits.Font.weightMedium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: _scanBtn.enabled
                        ? (_scanBtn.pressed ? SepKits.Color.alpha(SepKits.Color.primary, 0.8)
                            : _scanBtn.hovered ? SepKits.Color.alpha(SepKits.Color.primary, 0.9)
                            : SepKits.Color.primary)
                        : SepKits.Color.muted
                }
                onClicked: {
                    _logContent = ""
                    SepKits.SystemCacheCleaner.startScan()
                }
            }

            // Clean
            Button {
                id: _cleanBtn
                text: qsTr("Clean Selected")
                enabled: _model && _model.allScanned && _model.anyChecked
                    && !SepKits.SystemCacheCleaner.running && !SepKits.SystemCacheCleaner.scanning
                topPadding: SepKits.Theme.buttonPaddingV
                bottomPadding: SepKits.Theme.buttonPaddingV
                leftPadding: SepKits.Theme.buttonPaddingH
                rightPadding: SepKits.Theme.buttonPaddingH
                contentItem: Text {
                    text: _cleanBtn.text
                    color: _cleanBtn.enabled ? SepKits.Color.primaryForeground : SepKits.Color.disabled(SepKits.Color.primaryForeground)
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeBody
                    font.weight: SepKits.Font.weightMedium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: _cleanBtn.enabled
                        ? (_cleanBtn.pressed ? SepKits.Color.alpha(SepKits.Color.primary, 0.8)
                            : _cleanBtn.hovered ? SepKits.Color.alpha(SepKits.Color.primary, 0.9)
                            : SepKits.Color.primary)
                        : SepKits.Color.muted
                }
                onClicked: _confirmDialog.open()
            }

            // Export
            Button {
                id: _exportBtn
                text: qsTr("Export Log")
                visible: _logContent.length > 0
                topPadding: SepKits.Theme.buttonPaddingV
                bottomPadding: SepKits.Theme.buttonPaddingV
                leftPadding: SepKits.Theme.buttonPaddingH
                rightPadding: SepKits.Theme.buttonPaddingH
                contentItem: Text {
                    text: _exportBtn.text
                    color: _exportBtn.hovered ? SepKits.Color.foreground : SepKits.Color.mutedForeground
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeBody
                    font.weight: SepKits.Font.weightMedium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: _exportBtn.hovered ? SepKits.Color.muted : SepKits.Color.transparent
                    border.color: SepKits.Color.border
                    border.width: 1
                }
                onClicked: {
                    var path = SepKits.SystemCacheCleaner.exportLog(_root._logContent)
                    if (path) _root.appendLog(qsTr("Log exported to: %1").arg(path))
                    else _root.appendLog(qsTr("Export failed"))
                }
            }

            // Cancel
            Button {
                id: _cancelBtn
                text: qsTr("Cancel")
                visible: SepKits.SystemCacheCleaner.scanning || SepKits.SystemCacheCleaner.running
                topPadding: SepKits.Theme.buttonPaddingV
                bottomPadding: SepKits.Theme.buttonPaddingV
                leftPadding: SepKits.Theme.buttonPaddingH
                rightPadding: SepKits.Theme.buttonPaddingH
                contentItem: Text {
                    text: _cancelBtn.text
                    color: _cancelBtn.hovered ? SepKits.Color.foreground : SepKits.Color.mutedForeground
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeBody
                    font.weight: SepKits.Font.weightMedium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: _cancelBtn.hovered ? SepKits.Color.muted : SepKits.Color.transparent
                    border.color: SepKits.Color.border
                    border.width: 1
                }
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
                    model: _model

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
                        text: _logContent
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

            ProgressBar {
                id: _progressBar
                Layout.fillWidth: true
                from: 0.0
                to: 1.0
                value: SepKits.SystemCacheCleaner.progressValue

                background: Rectangle {
                    implicitHeight: 6
                    radius: 3
                    color: SepKits.Color.muted
                }
                contentItem: Item {
                    implicitHeight: 6
                    Rectangle {
                        width: _progressBar.visualPosition * parent.width
                        height: parent.height
                        radius: 3
                        color: SepKits.Color.primary
                        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                    }
                }
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

    // ═══ Dialogs ═══

    SepKits.Dialog {
        id: _confirmDialog
        anchors.centerIn: parent
        dialogTitle: qsTr("Confirm Cleanup")
        dialogMessage: qsTr("%1 categories selected. Clean them now?\n\nPlease save any unsaved work before proceeding.").arg(_model ? _model.checkedCount : 0)
        acceptText: qsTr("Start Cleaning")
        rejectText: qsTr("Cancel")
        onAccepted: {
            _logContent = ""
            if (_model) SepKits.SystemCacheCleaner.startCleanup(_model.checkedKeys())
        }
    }

    SepKits.Dialog {
        id: _elevationDialog
        anchors.centerIn: parent
        dialogTitle: qsTr("Administrator Privileges Required")
        dialogMessage: qsTr("Some categories require administrator privileges. Relaunch as administrator?")
        acceptText: qsTr("Relaunch as Admin")
        rejectText: qsTr("Continue Without")
        onAccepted: SepKits.SystemCacheCleaner.requestAdminRelaunch()
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
            appendLog(qsTr("=== Scan completed. Select categories to clean. ==="))
        }

        function onCleanupFinished(cleanedCount, freedBytes) {
            appendLog(qsTr("=== Process Completed ==="))
        }
    }

    Component.onCompleted: {
        appendLog(qsTr("Click \"Scan All\" to analyze cache sizes."))
        if (!SepKits.SystemCacheCleaner.isRunningAsAdmin())
            _elevationDialog.open()
    }
}
