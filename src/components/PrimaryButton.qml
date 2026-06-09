import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import SepKits as SepKits

// Primary action button — solid Electric Blue background, white text.
// Customize with `bgColor` / `fgColor` for accent variants (e.g. theme switch).

Button {
    id: _root

    property color bgColor: SepKits.Color.primary
    property color fgColor: SepKits.Color.primaryForeground

    topPadding: SepKits.Theme.buttonPaddingV
    bottomPadding: SepKits.Theme.buttonPaddingV
    leftPadding: SepKits.Theme.buttonPaddingH
    rightPadding: SepKits.Theme.buttonPaddingH

    contentItem: Text {
        text: _root.text
        color: _root.enabled ? _root.fgColor : SepKits.Color.disabled(SepKits.Color.mutedForeground)
        font.family: SepKits.Font.fontFamilyBody
        font.pixelSize: SepKits.Font.sizeBody
        font.weight: SepKits.Font.weightMedium
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        radius: SepKits.Theme.radius
        color: _root.enabled
            ? (_root.pressed ? SepKits.Color.alpha(_root.bgColor, 0.8)
                : _root.hovered ? SepKits.Color.alpha(_root.bgColor, 0.9)
                : _root.bgColor)
            : SepKits.Color.muted
        Behavior on color { ColorAnimation { duration: SepKits.Theme.animFast } }
    }
}
