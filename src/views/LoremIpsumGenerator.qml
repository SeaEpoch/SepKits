import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

Rectangle {
    id: _root
    color: SepKits.Color.background

    property string _outputText: ""
    property int _unitIndex: 0     // 0=Words, 1=Sentences, 2=Paragraphs
    property int _langIndex: 0     // 0=English, 1=中文

    function generate() {
        let count = parseInt(_countInput.text)
        if (isNaN(count) || count < 1) {
            _outputText = ""
            return
        }
        if (count > 999) count = 999
        _outputText = SepKits.LoremIpsumGenerator.generate(count, _unitIndex, _langIndex)
    }

    // ─── Layout ────────────────────────────────────────────────────────────

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SepKits.Theme.spacingXl
        spacing: SepKits.Theme.spacingMd

        // ═══ 1. Toolbar ═══
        RowLayout {
            spacing: SepKits.Theme.spacingMd

            // Back
            Button {
                id: _backBtn
                text: qsTr("← Back")
                topPadding: SepKits.Theme.spacingSm
                bottomPadding: SepKits.Theme.spacingSm
                leftPadding: SepKits.Theme.spacingMd
                rightPadding: SepKits.Theme.spacingMd
                contentItem: Text {
                    text: _backBtn.text
                    color: SepKits.Color.foreground
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeSmall
                    font.weight: SepKits.Font.weightMedium
                }
                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: _backBtn.hovered ? SepKits.Color.muted : SepKits.Color.transparent
                }
                onClicked: Window.window.navigateBack()
            }

            Text {
                text: qsTr("Lorem Ipsum Generator")
                font.family: SepKits.Font.fontFamilyTitle
                font.pixelSize: SepKits.Font.sizeH3
                font.weight: SepKits.Font.weightH3
                color: SepKits.Color.foreground
                Layout.leftMargin: SepKits.Theme.spacingSm
            }

            Item { Layout.fillWidth: true }

            // Count input
            TextField {
                id: _countInput
                implicitWidth: 80
                implicitHeight: 48
                topPadding: SepKits.Theme.inputPaddingV
                bottomPadding: SepKits.Theme.inputPaddingV
                leftPadding: SepKits.Theme.inputPaddingH
                rightPadding: SepKits.Theme.inputPaddingH
                horizontalAlignment: TextInput.AlignHCenter
                verticalAlignment: TextInput.AlignVCenter
                color: SepKits.Color.foreground
                font.family: SepKits.Font.fontFamilyBody
                font.pixelSize: SepKits.Font.sizeBody
                placeholderText: qsTr("Count")
                placeholderTextColor: SepKits.Color.mutedForeground
                text: "5"
                validator: IntValidator { bottom: 1; top: 999 }

                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: SepKits.Color.background
                    border.width: 1
                    border.color: _countInput.activeFocus
                        ? SepKits.Color.primary : SepKits.Color.border
                }
            }

            // Unit combo
            SepKits.ComboBox {
                label: ""
                Layout.preferredWidth: 150
                model: [qsTr("Words"), qsTr("Sentences"), qsTr("Paragraphs")]
                currentIndex: 0
                onActivated: index => _root._unitIndex = index
            }

            // Language combo
            SepKits.ComboBox {
                label: ""
                Layout.preferredWidth: 130
                model: [qsTr("English"), qsTr("中文")]
                currentIndex: 0
                onActivated: index => _root._langIndex = index
            }

            // Generate
            Button {
                id: _generateBtn
                text: qsTr("Generate")
                topPadding: SepKits.Theme.buttonPaddingV
                bottomPadding: SepKits.Theme.buttonPaddingV
                leftPadding: SepKits.Theme.buttonPaddingH
                rightPadding: SepKits.Theme.buttonPaddingH
                contentItem: Text {
                    text: _generateBtn.text
                    color: SepKits.Color.primaryForeground
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeBody
                    font.weight: SepKits.Font.weightMedium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: _generateBtn.pressed ? SepKits.Color.alpha(SepKits.Color.primary, 0.8)
                        : _generateBtn.hovered ? SepKits.Color.alpha(SepKits.Color.primary, 0.9)
                        : SepKits.Color.primary
                }
                onClicked: _root.generate()
            }

            // Copy
            Button {
                id: _copyBtn
                text: qsTr("Copy")
                enabled: _outputText.length > 0
                topPadding: SepKits.Theme.buttonPaddingV
                bottomPadding: SepKits.Theme.buttonPaddingV
                leftPadding: SepKits.Theme.buttonPaddingH
                rightPadding: SepKits.Theme.buttonPaddingH
                contentItem: Text {
                    text: _copyBtn.text
                    color: _copyBtn.enabled
                        ? (_copyBtn.hovered ? SepKits.Color.foreground : SepKits.Color.mutedForeground)
                        : SepKits.Color.disabled(SepKits.Color.mutedForeground)
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeBody
                    font.weight: SepKits.Font.weightMedium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: _copyBtn.hovered && _copyBtn.enabled
                        ? SepKits.Color.muted : SepKits.Color.transparent
                    border.color: SepKits.Color.border
                    border.width: 1
                }
                onClicked: SepKits.SettingsStore.copyToClipboard(_outputText)
            }
        }

        // ═══ 2. Output text area ═══
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
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
                    id: _outputArea
                    readOnly: true
                    text: _outputText
                    color: SepKits.Color.foreground
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeBody
                    placeholderText: qsTr("Generated text will appear here.\nSet the count, select unit and language, then click \"Generate\".")
                    placeholderTextColor: SepKits.Color.mutedForeground
                    background: null
                    wrapMode: TextArea.Wrap
                    selectByMouse: true
                    persistentSelection: true
                }
            }
        }
    }
}
