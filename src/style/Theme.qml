pragma Singleton

import QtQuick

QtObject {
    id: _root

    // ==================== Radii ====================
    readonly property int radius: 8        // button, input
    readonly property int cardRadius: 10   // card

    // ==================== Spacing (8px grid) ====================
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 16
    readonly property int spacingLg: 24
    readonly property int spacingXl: 32
    readonly property int spacing2xl: 48
    readonly property int spacing3xl: 64

    // ==================== Component Padding ====================
    readonly property int buttonPaddingV: 12
    readonly property int buttonPaddingH: 24
    readonly property int inputPaddingV: 10
    readonly property int inputPaddingH: 12
    readonly property int cardPadding: 20

    // ==================== Animation Durations ====================
    readonly property int animFast: 200
    readonly property int animNormal: 300
    readonly property int animTheme: 600
}
