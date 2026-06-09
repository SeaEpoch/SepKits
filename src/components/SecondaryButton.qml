import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

// Secondary / outline button — transparent background with border, muted text.

Button {
    id: _root

    topPadding: SepKits.Theme.buttonPaddingV
    bottomPadding: SepKits.Theme.buttonPaddingV
    leftPadding: SepKits.Theme.buttonPaddingH
    rightPadding: SepKits.Theme.buttonPaddingH

    contentItem: Text {
        text: _root.text
        color: _root.enabled
            ? (_root.hovered ? SepKits.Color.foreground : SepKits.Color.mutedForeground)
            : SepKits.Color.disabled(SepKits.Color.mutedForeground)
        font.family: SepKits.Font.fontFamilyBody
        font.pixelSize: SepKits.Font.sizeBody
        font.weight: SepKits.Font.weightMedium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: SepKits.Theme.radius
        color: _root.hovered && _root.enabled ? SepKits.Color.muted : SepKits.Color.alpha(SepKits.Color.muted, 0)
        border.color: SepKits.Color.border
        border.width: 1
        Behavior on color { ColorAnimation { duration: SepKits.Theme.animFast } }
    }
}
