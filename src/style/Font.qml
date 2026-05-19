pragma Singleton

import QtQuick

QtObject {
    id: _root

    // ==================== Font Families ====================
    readonly property string fontFamilyTitle: "Calistoga"
    readonly property string fontFamilyBody: "Inter"

    // ==================== Typography Scale ====================
    // design doc: H1:48, H2:32, H3:24, Body:16, Small:14, Tiny:12
    readonly property int sizeH1: 48
    readonly property int sizeH2: 32
    readonly property int sizeH3: 24
    readonly property int sizeBody: 16
    readonly property int sizeSmall: 14
    readonly property int sizeTiny: 12

    // ==================== Font Weights ====================
    readonly property int weightH1: Font.Bold       // 700
    readonly property int weightH2: Font.Bold       // 700
    readonly property int weightH3: Font.DemiBold   // 600
    readonly property int weightBody: Font.Normal   // 400
    readonly property int weightSmall: Font.Normal  // 400
    readonly property int weightTiny: Font.Normal   // 400
    readonly property int weightMedium: Font.Medium // 500 (for button text)
}
