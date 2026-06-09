import QtQuick
import QtQuick.Controls
import SepKits as SepKits

Button {
    id: _root
    text: qsTr("← Back")
    topPadding: SepKits.Theme.spacingSm
    bottomPadding: SepKits.Theme.spacingSm
    leftPadding: SepKits.Theme.spacingMd
    rightPadding: SepKits.Theme.spacingMd

    contentItem: Text {
        text: _root.text
        color: _root.hovered ? SepKits.Color.foreground : SepKits.Color.mutedForeground
        font.family: SepKits.Font.fontFamilyBody
        font.pixelSize: SepKits.Font.sizeSmall
        font.weight: SepKits.Font.weightMedium
    }
    background: Rectangle {
        radius: SepKits.Theme.radius
        color: _root.hovered ? SepKits.Color.muted : SepKits.Color.transparent
    }
    onClicked: Window.window.navigateBack()
}
