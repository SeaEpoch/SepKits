import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

Dialog {
    id: _root

    property alias dialogTitle: _titleText.text
    property alias dialogMessage: _messageText.text
    property alias acceptText: _acceptBtn.text
    property alias rejectText: _rejectBtn.text

    modal: false
    padding: 0
    implicitWidth: Math.max(360, Math.min(_footerRow.implicitWidth + SepKits.Theme.spacingLg * 2, 580))
    closePolicy: Popup.CloseOnEscape

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: SepKits.Theme.animNormal; easing.type: Easing.InOutQuad }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: SepKits.Theme.animNormal; easing.type: Easing.InOutQuad }
    }

    background: Rectangle {
        color: SepKits.Color.card
        radius: SepKits.Theme.cardRadius
        border.color: SepKits.Color.border
        border.width: 1
    }

    header: Item {
        implicitHeight: SepKits.Theme.spacing3xl
        Text {
            id: _titleText
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: SepKits.Theme.spacingLg
            anchors.rightMargin: SepKits.Theme.spacingLg
            anchors.bottomMargin: SepKits.Theme.spacingSm
            color: SepKits.Color.foreground
            font.family: SepKits.Font.fontFamilyTitle
            font.pixelSize: SepKits.Font.sizeH3
            font.weight: SepKits.Font.weightH3
        }
    }

    contentItem: Text {
        id: _messageText
        color: SepKits.Color.mutedForeground
        font.family: SepKits.Font.fontFamilyBody
        font.pixelSize: SepKits.Font.sizeBody
        font.weight: SepKits.Font.weightBody
        wrapMode: Text.WordWrap
        leftPadding: SepKits.Theme.spacingLg
        rightPadding: SepKits.Theme.spacingLg
    }

    footer: Item {
        implicitHeight: SepKits.Theme.spacing3xl + SepKits.Theme.spacingMd

        RowLayout {
            id: _footerRow
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: SepKits.Theme.spacingLg
            spacing: SepKits.Theme.spacingMd

            Button {
                id: _rejectBtn
                topPadding: SepKits.Theme.buttonPaddingV
                bottomPadding: SepKits.Theme.buttonPaddingV
                leftPadding: SepKits.Theme.buttonPaddingH
                rightPadding: SepKits.Theme.buttonPaddingH

                contentItem: Text {
                    text: _rejectBtn.text
                    color: _rejectBtn.hovered ? SepKits.Color.foreground : SepKits.Color.mutedForeground
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeBody
                    font.weight: SepKits.Font.weightMedium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: _rejectBtn.hovered ? SepKits.Color.muted : SepKits.Color.transparent
                    border.color: SepKits.Color.border
                    border.width: 1
                }

                onClicked: _root.reject()
            }

            Button {
                id: _acceptBtn
                topPadding: SepKits.Theme.buttonPaddingV
                bottomPadding: SepKits.Theme.buttonPaddingV
                leftPadding: SepKits.Theme.buttonPaddingH
                rightPadding: SepKits.Theme.buttonPaddingH

                contentItem: Text {
                    text: _acceptBtn.text
                    color: SepKits.Color.primaryForeground
                    font.family: SepKits.Font.fontFamilyBody
                    font.pixelSize: SepKits.Font.sizeBody
                    font.weight: SepKits.Font.weightMedium
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: SepKits.Theme.radius
                    color: _acceptBtn.pressed ? SepKits.Color.alpha(SepKits.Color.primary, 0.8)
                        : _acceptBtn.hovered ? SepKits.Color.alpha(SepKits.Color.primary, 0.9)
                        : SepKits.Color.primary
                }

                onClicked: _root.accept()
            }
        }
    }
}
