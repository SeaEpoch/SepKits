import QtQuick
import SepKits as SepKits

Canvas {
    id: _gauge

    // ── Public properties ──
    property double speed: 0
    property double maxSpeed: 100
    property string unit: "Mbps"
    property string phase: "idle"
    property bool active: false
    property color downloadColor: SepKits.Color.cyan400
    property color uploadColor: SepKits.Color.purple500

    // ── Internal ──
    QtObject {
        id: _private

        // Per-unit scale: each unit gets its own non-linear label set derived from
        // the same proportional breakdown (0, 1/200, 1/100, 1/20, 1/10, 1/4, 1/2, 3/4, 1) × max.
        // This keeps the pointer in a visible range regardless of unit.
        readonly property var unitScale: ({
            "Mbps": { labels: [0, 5, 10, 50, 100, 250, 500, 750, 1000], max: 1000 },
            "kbps": { labels: [0, 5000, 10000, 50000, 100000, 250000, 500000, 750000, 1000000], max: 1000000 },
            "Gbps": { labels: [0, 0.005, 0.01, 0.05, 0.1, 0.25, 0.5, 0.75, 1], max: 1 },
            "B/s":  { labels: [0, 625000, 1250000, 6250000, 12500000, 31250000, 62500000, 93750000, 125000000], max: 125000000 },
            "kB/s": { labels: [0, 625, 1250, 6250, 12500, 31250, 62500, 93750, 125000], max: 125000 },
            "MB/s": { labels: [0, 0.625, 1.25, 6.25, 12.5, 31.25, 62.5, 93.75, 125], max: 125 },
            "GB/s": { labels: [0, 0.000625, 0.00125, 0.00625, 0.0125, 0.03125, 0.0625, 0.09375, 0.125], max: 0.125 }
        })[unit] || ({ labels: [0, 5, 10, 50, 100, 250, 500, 750, 1000], max: 1000 })

        readonly property real startAngle: 135   // degrees — bottom-left
        readonly property real sweepAngle: 270   // degrees — total sweep
        readonly property real arcWidth: 24

        // Smooth animated speed (manually animated, used in onPaint)
        property double targetSpeed: 0
        property double animatedSpeed: 0
    }

    Timer {
        id: _animTimer
        interval: 33  // ~30fps
        repeat: true
        property double _startVal: 0
        property double _endVal: 0
        property int _elapsed: 0
        readonly property int _duration: 120

        function startAnim(from, to) {
            _startVal = from
            _endVal = to
            _elapsed = 0
            running = true
        }

        onTriggered: {
            _elapsed += interval
            if (_elapsed >= _duration) {
                _private.animatedSpeed = _endVal
                running = false
            } else {
                var t = _elapsed / _duration
                // Ease OutCubic: 1 - (1-t)^3
                var eased = 1 - Math.pow(1 - t, 3)
                _private.animatedSpeed = _startVal + (_endVal - _startVal) * eased
            }
            _gauge.requestPaint()
        }
    }

    antialiasing: true
    renderStrategy: Canvas.Cooperative

    onSpeedChanged: {
        _animTimer.startAnim(_private.animatedSpeed, speed)
        requestPaint()
    }
    onMaxSpeedChanged: requestPaint()
    onUnitChanged: requestPaint()
    onPhaseChanged: {
        if (phase === "upload" || phase === "done") {
            _animTimer.running = false
            _private.animatedSpeed = 0
            _private.targetSpeed = 0
        }
        requestPaint()
    }
    onDownloadColorChanged: requestPaint()
    onUploadColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    // ── Map speed → angular fraction using non-linear scale ──
    function _speedToFrac(s) {
        var labels = _private.unitScale.labels
        var max = _private.unitScale.max
        if (s <= 0) return 0
        if (s >= max) return 1
        for (var i = 0; i < labels.length - 1; i++) {
            var lo = labels[i]
            var hi = labels[i + 1]
            if (s <= hi) {
                var segFrac = (s - lo) / (hi - lo)
                return (i + segFrac) / (labels.length - 1)
            }
        }
        return 1
    }

    function _activeColor() {
        if (phase === "download") return downloadColor
        if (phase === "upload") return uploadColor
        if (phase === "done") return SepKits.Color.green500
        return downloadColor
    }

    function _formatSpeed(v) {
        if (v <= 0) return "0"
        if (v < 1) return v.toFixed(2)
        if (v < 10) return v.toFixed(1)
        return Math.round(v).toString()
    }

    function _formatLabel(v) {
        if (v === 0) return "0"
        if (v >= 1000000) return (v / 1000000).toFixed(0) + "M"
        if (v >= 1000) return (v / 1000).toFixed(0) + "k"
        if (v < 0.001) return v.toPrecision(1)
        if (v < 0.01) return v.toPrecision(2)
        if (v < 1) return v.toPrecision(3)
        if (Number.isInteger(v)) return v.toString()
        return v.toFixed(1)
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)

        var cx = width / 2
        var cy = height / 2
        var r = Math.min(cx, cy) * 0.72
        var baseColor = _activeColor()
        var frac = _speedToFrac(Math.min(Math.max(_private.animatedSpeed, 0), _private.unitScale.max))
        var startRad = _private.startAngle * Math.PI / 180
        var sweepRadTotal = _private.sweepAngle * Math.PI / 180

        // ── 1. Background arc ──
        ctx.beginPath()
        ctx.arc(cx, cy, r, startRad, startRad + sweepRadTotal)
        ctx.lineWidth = _private.arcWidth
        ctx.strokeStyle = SepKits.Color.muted
        ctx.lineCap = "round"
        ctx.stroke()

        // ── 2. Active arc with alpha gradient ──
        var showActive = (phase === "download" || phase === "upload" || phase === "done") && frac > 0
        if (showActive) {
            var activeSweep = frac * sweepRadTotal
            var segs = 72
            ctx.lineWidth = _private.arcWidth
            ctx.lineCap = "round"

            for (var i = 0; i < segs; i++) {
                var t1 = i / segs
                var t2 = (i + 1) / segs
                var alpha = 0.1 + t2 * 0.9
                var a1 = startRad + t1 * activeSweep
                var a2 = startRad + t2 * activeSweep

                ctx.beginPath()
                ctx.arc(cx, cy, r, a1, a2)
                ctx.strokeStyle = Qt.rgba(baseColor.r, baseColor.g, baseColor.b, alpha)
                ctx.stroke()
            }
        }

        // ── 3. Scale labels — equal visual spacing, no tick marks ──
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        ctx.font = "bold 13px sans-serif"
        ctx.fillStyle = SepKits.Color.mutedForeground

        var labels = _private.unitScale.labels
        var labelR = r - _private.arcWidth - 8

        for (var j = 0; j < labels.length; j++) {
            var labelFrac = j / (labels.length - 1)  // equal visual spacing
            var angleDeg = _private.startAngle + labelFrac * _private.sweepAngle
            var angleRad = angleDeg * Math.PI / 180
            var lx = cx + labelR * Math.cos(angleRad)
            var ly = cy + labelR * Math.sin(angleRad)

            ctx.fillText(_formatLabel(labels[j]), lx, ly)
        }

        // ── 4. Text block in gap area ──
        // Chord connecting labels 0 (135°) and 1000 (45°) is horizontal at y = cy + sin(45°)*labelR
        // All text vertically centered on this chord line
        var chordY = cy + 0.707 * labelR
        ctx.textAlign = "center"

        // Speed value — middle baseline on chord line (36px font ~18px above/below baseline)
        ctx.textBaseline = "middle"
        ctx.font = "bold 36px sans-serif"
        ctx.fillStyle = SepKits.Color.foreground
        ctx.fillText(_formatSpeed(_private.animatedSpeed), cx, chordY)

        // Unit — above speed value, bottom-aligned with gap
        ctx.textBaseline = "bottom"
        ctx.font = "14px sans-serif"
        ctx.fillStyle = SepKits.Color.mutedForeground
        ctx.fillText(unit, cx, chordY - 22)

        // Phase label — below speed value, top-aligned with gap
        var phaseText = ""
        if (phase === "download") phaseText = qsTr("Downloading...")
        else if (phase === "upload") phaseText = qsTr("Uploading...")
        else if (phase === "ping") phaseText = qsTr("Testing ping...")
        else if (phase === "done") phaseText = qsTr("Complete")

        if (phaseText) {
            ctx.textBaseline = "top"
            ctx.font = "12px sans-serif"
            ctx.fillStyle = baseColor
            ctx.fillText(phaseText, cx, chordY + 22)
        }

        // ── 7. Trapezoidal pointer ──
        // Pointer points RIGHT (0°) in local coords; rotate maps 0→start, max→end
        var needleRad = startRad + frac * sweepRadTotal

        ctx.save()
        ctx.translate(cx, cy)
        ctx.rotate(needleRad)

        var tipHalfW = 4.5
        var baseHalfW = 10
        var pointerLen = r - _private.arcWidth / 2 - 4

        // Pointer body with alpha gradient (tip=opaque, base=transparent)
        var ptrGrad = ctx.createLinearGradient(pointerLen, 0, -4, 0)
        ptrGrad.addColorStop(0, Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 1.0))
        ptrGrad.addColorStop(1, Qt.rgba(baseColor.r, baseColor.g, baseColor.b, 0.0))

        ctx.beginPath()
        ctx.moveTo(pointerLen, -tipHalfW)
        ctx.lineTo(pointerLen, tipHalfW)
        ctx.lineTo(-4, baseHalfW)
        ctx.lineTo(-4, -baseHalfW)
        ctx.closePath()
        ctx.fillStyle = ptrGrad
        ctx.fill()

        ctx.restore()
    }
}
