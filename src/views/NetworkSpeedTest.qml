import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

Rectangle {
    id: _root
    color: SepKits.Color.background

    Component.onCompleted: SepKits.NetworkSpeedTest.fetchServers()

    // ── Gauge speed binding ──
    // ALL backend properties must be accessed BEFORE any conditional branch,
    // otherwise QML only tracks properties from the first-evaluated branch.
    QtObject {
        id: _private
        readonly property double gaugeSpeed: {
            var dSpeed = SepKits.NetworkSpeedTest.downloadSpeed
            var uSpeed = SepKits.NetworkSpeedTest.uploadSpeed
            var phase = SepKits.NetworkSpeedTest.currentPhase
            if (phase === "download") return dSpeed
            if (phase === "upload") return uSpeed
            return 0
        }
    }

    // ── Helper ──
    function _fmtValue(v, decimals) {
        if (v <= 0) return "0"
        if (decimals !== undefined) return v.toFixed(decimals)
        if (v < 1) return v.toFixed(2)
        if (v < 10) return v.toFixed(1)
        return Math.round(v).toString()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SepKits.Theme.spacingXl
        spacing: SepKits.Theme.spacingLg

        // ═══ Toolbar ═══
        RowLayout {
            spacing: SepKits.Theme.spacingMd

            SepKits.BackButton {}

            Text {
                text: qsTr("Network Speed Test")
                font.family: SepKits.Font.fontFamilyTitle
                font.pixelSize: SepKits.Font.sizeH3
                font.weight: SepKits.Font.weightH3
                color: SepKits.Color.foreground
            }

            Item { Layout.fillWidth: true }

            SepKits.PrimaryButton {
                id: _actionBtn
                text: SepKits.NetworkSpeedTest.isRunning ? qsTr("Cancel") : qsTr("Start")
                onClicked: {
                    if (SepKits.NetworkSpeedTest.isRunning)
                        SepKits.NetworkSpeedTest.cancelTest()
                    else
                        SepKits.NetworkSpeedTest.startTest()
                }
            }
        }

        // ═══ Content: left (gauge + ISP) | right (results) ═══
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: SepKits.Theme.spacingXl

            // ── Left panel (1/3) ──
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                spacing: SepKits.Theme.spacingMd

                SepKits.SpeedGauge {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    speed: _private.gaugeSpeed
                    maxSpeed: SepKits.NetworkSpeedTest.gaugeMaxSpeed
                    unit: SepKits.NetworkSpeedTest.speedUnit
                    phase: SepKits.NetworkSpeedTest.currentPhase
                    active: SepKits.NetworkSpeedTest.isRunning
                }

                // ISP / IP info
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 72
                    color: SepKits.Color.card
                    radius: SepKits.Theme.cardRadius
                    border.color: SepKits.Color.border
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: SepKits.Theme.cardPadding
                        spacing: SepKits.Theme.spacingMd

                        Column {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("ISP")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                color: SepKits.Color.mutedForeground
                            }
                            Text {
                                text: SepKits.NetworkSpeedTest.isp || "—"
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                font.weight: SepKits.Font.weightMedium
                                color: SepKits.Color.foreground
                                elide: Text.ElideRight
                                width: parent.width
                            }
                        }

                        Rectangle {
                            width: 1
                            Layout.preferredHeight: 32
                            color: SepKits.Color.border
                        }

                        Column {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("Internal IP")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                color: SepKits.Color.mutedForeground
                            }
                            Text {
                                text: SepKits.NetworkSpeedTest.internalIp || "—"
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                font.weight: SepKits.Font.weightMedium
                                color: SepKits.Color.foreground
                            }
                        }

                        Rectangle {
                            width: 1
                            Layout.preferredHeight: 32
                            color: SepKits.Color.border
                        }

                        Column {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: true
                            Text {
                                text: qsTr("External IP")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                color: SepKits.Color.mutedForeground
                            }
                            Text {
                                text: SepKits.NetworkSpeedTest.externalIp || "—"
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                font.weight: SepKits.Font.weightMedium
                                color: SepKits.Color.foreground
                            }
                        }
                    }
                }
            }

            // ── Right panel: results card (2/3) ──
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 2
                color: SepKits.Color.card
                radius: SepKits.Theme.cardRadius
                border.color: SepKits.Color.border
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: SepKits.Theme.cardPadding
                    spacing: SepKits.Theme.spacingMd

                    // Row 1: Download | Upload
                    RowLayout {
                        spacing: SepKits.Theme.spacingMd

                        // Download
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: SepKits.Color.alpha(SepKits.Color.cyan400, 0.08)
                            radius: SepKits.Theme.radius
                            border.color: SepKits.Color.alpha(SepKits.Color.cyan400, 0.2)
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: qsTr("Download")
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeSmall
                                    color: SepKits.Color.mutedForeground
                                }
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 4
                                    Text {
                                        text: {
                                            if (SepKits.NetworkSpeedTest.currentPhase !== "done") return "—"
                                            var v = SepKits.NetworkSpeedTest.downloadResult
                                            return v <= 0 ? "—" : _root._fmtValue(v)
                                        }
                                        font.family: SepKits.Font.fontFamilyTitle
                                        font.pixelSize: SepKits.Font.sizeH3
                                        font.weight: SepKits.Font.weightH3
                                        color: SepKits.Color.cyan400
                                    }
                                    Text {
                                        text: SepKits.NetworkSpeedTest.speedUnit
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.mutedForeground
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 2
                                    }
                                }
                            }
                        }

                        // Upload
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: SepKits.Color.alpha(SepKits.Color.purple500, 0.08)
                            radius: SepKits.Theme.radius
                            border.color: SepKits.Color.alpha(SepKits.Color.purple500, 0.2)
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: qsTr("Upload")
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeSmall
                                    color: SepKits.Color.mutedForeground
                                }
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 4
                                    Text {
                                        text: {
                                            if (SepKits.NetworkSpeedTest.currentPhase !== "done") return "—"
                                            var v = SepKits.NetworkSpeedTest.uploadResult
                                            return v <= 0 ? "—" : _root._fmtValue(v)
                                        }
                                        font.family: SepKits.Font.fontFamilyTitle
                                        font.pixelSize: SepKits.Font.sizeH3
                                        font.weight: SepKits.Font.weightH3
                                        color: SepKits.Color.purple500
                                    }
                                    Text {
                                        text: SepKits.NetworkSpeedTest.speedUnit
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.mutedForeground
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 2
                                    }
                                }
                            }
                        }
                    }

                    // Row 2: Ping | Jitter | Packet Loss
                    RowLayout {
                        spacing: SepKits.Theme.spacingMd

                        // Ping
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 72
                            color: SepKits.Color.alpha(SepKits.Color.foreground, 0.04)
                            radius: SepKits.Theme.radius
                            border.color: SepKits.Color.border
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: qsTr("Ping")
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeSmall
                                    color: SepKits.Color.mutedForeground
                                }
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 3
                                    Text {
                                        text: {
                                            var v = SepKits.NetworkSpeedTest.pingLatency
                                            return v <= 0 ? "—" : Math.round(v).toString()
                                        }
                                        font.family: SepKits.Font.fontFamilyTitle
                                        font.pixelSize: SepKits.Font.sizeH3
                                        font.weight: SepKits.Font.weightH3
                                        color: SepKits.Color.foreground
                                    }
                                    Text {
                                        text: "ms"
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.mutedForeground
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 2
                                    }
                                }
                            }
                        }

                        // Jitter
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 72
                            color: SepKits.Color.alpha(SepKits.Color.foreground, 0.04)
                            radius: SepKits.Theme.radius
                            border.color: SepKits.Color.border
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: qsTr("Jitter")
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeSmall
                                    color: SepKits.Color.mutedForeground
                                }
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 3
                                    Text {
                                        text: {
                                            var v = SepKits.NetworkSpeedTest.pingJitter
                                            return v <= 0 ? "—" : v.toFixed(1)
                                        }
                                        font.family: SepKits.Font.fontFamilyTitle
                                        font.pixelSize: SepKits.Font.sizeH3
                                        font.weight: SepKits.Font.weightH3
                                        color: SepKits.Color.foreground
                                    }
                                    Text {
                                        text: "ms"
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.mutedForeground
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 2
                                    }
                                }
                            }
                        }

                        // Packet Loss
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 72
                            color: SepKits.Color.alpha(SepKits.Color.foreground, 0.04)
                            radius: SepKits.Theme.radius
                            border.color: SepKits.Color.border
                            border.width: 1

                            Column {
                                anchors.centerIn: parent
                                spacing: 2

                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: qsTr("Packet Loss")
                                    font.family: SepKits.Font.fontFamilyBody
                                    font.pixelSize: SepKits.Font.sizeSmall
                                    color: SepKits.Color.mutedForeground
                                }
                                Row {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 3
                                    Text {
                                        text: {
                                            if (SepKits.NetworkSpeedTest.currentPhase !== "done") return "—"
                                            var v = SepKits.NetworkSpeedTest.packetLoss
                                            return v < 0 ? "—" : v.toFixed(1)
                                        }
                                        font.family: SepKits.Font.fontFamilyTitle
                                        font.pixelSize: SepKits.Font.sizeH3
                                        font.weight: SepKits.Font.weightH3
                                        color: SepKits.Color.foreground
                                    }
                                    Text {
                                        text: "%"
                                        font.family: SepKits.Font.fontFamilyBody
                                        font.pixelSize: SepKits.Font.sizeSmall
                                        color: SepKits.Color.mutedForeground
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 2
                                    }
                                }
                            }
                        }
                    }

                    // Row 3: Server selector | Unit selector
                    RowLayout {
                        spacing: SepKits.Theme.spacingMd

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            spacing: 4

                            Text {
                                text: qsTr("Change Server")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                font.weight: SepKits.Font.weightMedium
                                color: SepKits.Color.foreground
                            }

                            SepKits.ComboBox {
                                id: _serverCombo
                                label: ""
                                Layout.fillWidth: true
                                model: {
                                    var items = [qsTr("Auto (Best Server)")]
                                    var list = SepKits.NetworkSpeedTest.serverList
                                    for (var i = 0; i < list.length; i++)
                                        items.push(list[i].name + " - " + list[i].location)
                                    return items
                                }
                                currentIndex: 0
                                onActivated: index => {
                                    if (index === 0)
                                        SepKits.NetworkSpeedTest.selectedServerId = -1
                                    else {
                                        var list = SepKits.NetworkSpeedTest.serverList
                                        if (index - 1 < list.length)
                                            SepKits.NetworkSpeedTest.selectedServerId = list[index - 1].id
                                    }
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 1
                            spacing: 4

                            Text {
                                text: qsTr("Speed Unit")
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeSmall
                                font.weight: SepKits.Font.weightMedium
                                color: SepKits.Color.foreground
                            }

                            SepKits.ComboBox {
                                id: _unitCombo
                                label: ""
                                Layout.fillWidth: true
                                model: ["Mbps", "MB/s", "kbps", "Gbps", "kB/s", "GB/s"]
                                currentIndex: 0
                                onActivated: index => {
                                    SepKits.NetworkSpeedTest.speedUnit = _unitCombo.model[index]
                                }
                            }
                        }
                    }

                    // Log output from speedtest.exe
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: SepKits.Color.alpha(SepKits.Color.foreground, 0.03)
                        radius: SepKits.Theme.radius
                        border.color: SepKits.Color.border
                        border.width: 1
                        clip: true

                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 4
                            clip: true

                            TextArea {
                                id: _logArea
                                readOnly: true
                                text: SepKits.NetworkSpeedTest.rawLog
                                width: parent.width
                                color: SepKits.Color.mutedForeground
                                font.family: SepKits.Font.fontFamilyBody
                                font.pixelSize: SepKits.Font.sizeTiny
                                placeholderText: qsTr("Speedtest output will appear here...")
                                placeholderTextColor: SepKits.Color.mutedForeground
                                background: null
                                wrapMode: TextArea.Wrap
                                onTextChanged: {
                                    // Auto-scroll to bottom when new content arrives
                                    Qt.callLater(function() {
                                        _logArea.cursorPosition = _logArea.length
                                    })
                                }
                            }
                        }
                    }

                    // Progress bar (no text)
                    SepKits.SepProgressBar {
                        Layout.fillWidth: true
                        value: SepKits.NetworkSpeedTest.progress
                    }
                }
            }
        }
    }
}
