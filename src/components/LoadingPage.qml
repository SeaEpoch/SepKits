import QtQuick
import QtQuick.Controls
import SepKits as SepKits

/**
 * LoadingPage.qml
 *
 * 通用异步加载容器：构建期显示加载动画，完成后以交叉淡变切换至真实内容。
 *
 * @property contentComponent  要异步构建的重量级组件，由调用方传入
 *
 * 使用示例：
 *   LoadingPage {
 *       anchors.fill: parent
 *       contentComponent: MyHeavyView {}
 *   }
 *
 * 加载进度策略（"智能伪进度"）：
 *   - 构建期：0 → 85%，OutQuart 缓动，视觉上呈现"快速起步、末段等待"
 *   - Ready 后：从当前位置补至 100%，衔接转场动画
 *   此方案与 Loader.asynchronous 的无进度回调特性匹配，
 *   若业务层日后能提供真实进度，只需在外部直接驱动 _progressFill.width。
 */
Item {
    id: _root

    property Component contentComponent: null

    // ── 真实内容层（z:0，初始透明，由转场动画揭出）─────────────────────────
    Loader {
        id: _loader
        anchors.fill: parent
        asynchronous: true          // 将组件树实例化分散至主线程空闲帧，避免 UI 冻结
        sourceComponent: _root.contentComponent
        opacity: 0

        onStatusChanged: {
            if (status === Loader.Loading) {
                _progressFill.width = 0
                _progressPhase1.start()
            } else if (status === Loader.Ready) {
                // phase1 可能尚未跑满；stop() 后 phase2 从当前宽度接续，不跳变
                _progressPhase1.stop()
                _progressPhase2.start()
            }
        }
    }

    // ── 加载动画层（z:1，覆盖于内容层上方）────────────────────────────────
    Rectangle {
        id: _placeholder
        anchors.fill: parent
        z: 1
        color: SepKits.Color.background

        // ── 动画主体（整体垂直居中，固定宽 280）──────────────────────────
        Item {
            id: _animContainer
            width: 280
            anchors.centerIn: parent
            height: _arcGroup.height + 28
                  + _loadingText.height + 10
                  + _dotsRow.height    + 22
                  + _progressTrack.height

            // ── 双层弧形圆环 + Logo ──────────────────────────────────────
            Item {
                id: _arcGroup
                width: 116; height: 116
                anchors.horizontalCenter: parent.horizontalCenter

                // 外环：layer.enabled 将 Canvas 内容缓存为 GPU 纹理，
                // RotationAnimator 在渲染线程执行变换，不触发 CPU 重绘。
                Canvas {
                    id: _outerRing
                    anchors.fill: parent
                    layer.enabled: true
                    layer.smooth: true
                    Component.onCompleted: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)

                        var cx = width / 2, cy = height / 2
                        var outerR = 58, innerR = 55.5
                        var sweepAngle = 255

                        // 线性插值两端颜色，模拟沿弧方向的渐变效果。
                        // ShapePath 不支持沿路径渐变，故退而使用 Canvas 逐段绘制。
                        function lerpColor(c1, c2, t) {
                            c1 = String(c1); c2 = String(c2)
                            var r1=parseInt(c1.substr(1,2),16), g1=parseInt(c1.substr(3,2),16), b1=parseInt(c1.substr(5,2),16)
                            var r2=parseInt(c2.substr(1,2),16), g2=parseInt(c2.substr(3,2),16), b2=parseInt(c2.substr(5,2),16)
                            return "rgb("+Math.round(r1+(r2-r1)*t)+","+Math.round(g1+(g2-g1)*t)+","+Math.round(b1+(b2-b1)*t)+")"
                        }

                        ctx.lineWidth = outerR - innerR
                        ctx.lineCap = "butt"
                        for (var i = 0; i < sweepAngle; i++) {
                            var rad = (-90 + i) * Math.PI / 180
                            ctx.strokeStyle = lerpColor(SepKits.Color.accent, SepKits.Color.cyan400, i / sweepAngle)
                            ctx.beginPath()
                            ctx.moveTo(cx + innerR * Math.cos(rad), cy + innerR * Math.sin(rad))
                            ctx.lineTo(cx + outerR * Math.cos(rad), cy + outerR * Math.sin(rad))
                            ctx.stroke()
                        }
                    }

                    RotationAnimator on rotation {
                        running: _placeholder.visible
                        from: 0; to: 360; duration: 3000
                        loops: Animation.Infinite
                    }
                }

                // 内环：单色短弧，与外环反向旋转形成视觉层次
                Canvas {
                    id: _innerRing
                    width: 86; height: 86
                    anchors.centerIn: parent
                    layer.enabled: true
                    layer.smooth: true
                    Component.onCompleted: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        var cx = width / 2, cy = height / 2
                        var outerR = 43, innerR = 41
                        ctx.lineWidth = outerR - innerR
                        ctx.lineCap = "butt"
                        ctx.strokeStyle = String(SepKits.Color.cyan400)
                        for (var i = 0; i < 110; i++) {
                            var rad = i * Math.PI / 180
                            ctx.beginPath()
                            ctx.moveTo(cx + innerR * Math.cos(rad), cy + innerR * Math.sin(rad))
                            ctx.lineTo(cx + outerR * Math.cos(rad), cy + outerR * Math.sin(rad))
                            ctx.stroke()
                        }
                    }

                    RotationAnimator on rotation {
                        running: _placeholder.visible
                        from: 360; to: 0; duration: 2200
                        loops: Animation.Infinite
                    }
                }

                Rectangle {
                    width: 52; height: 52; radius: 13
                    anchors.centerIn: parent
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: SepKits.Color.cyan400 }
                        GradientStop { position: 1.0; color: SepKits.Color.accent  }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "S"
                        font.family: "Georgia"; font.pixelSize: 22; font.bold: true
                        color: SepKits.Color.white
                    }
                }
            }

            // ── 标题文字 ────────────────────────────────────────────────
            Text {
                id: _loadingText
                anchors { top: _arcGroup.bottom; topMargin: 28; horizontalCenter: parent.horizontalCenter }
                text: "Loading"
                font.family: "Georgia"; font.pixelSize: 20; font.bold: true
                font.letterSpacing: 0.3
                color: SepKits.Color.foreground
            }

            // ── 等待指示点（三点依次亮起）──────────────────────────────
            Row {
                id: _dotsRow
                anchors { top: _loadingText.bottom; topMargin: 10; horizontalCenter: parent.horizontalCenter }
                spacing: 5

                Repeater {
                    model: 3
                    delegate: Rectangle {
                        required property int index
                        width: 5; height: 5; radius: 2.5
                        color: SepKits.Color.mutedForeground
                        opacity: 0.2

                        SequentialAnimation on opacity {
                            running: _placeholder.visible
                            loops: Animation.Infinite
                            // 首次 Pause 错开三点的初始相位；
                            // 总周期 1350ms（index 0/1 精确对齐），
                            // index 2 周期 1710ms 存在微小漂移，视觉不可察。
                            PauseAnimation  { duration: index * 450 }
                            NumberAnimation { to: 1.0; duration: 405 }
                            NumberAnimation { to: 0.2; duration: 405 }
                            PauseAnimation  { duration: Math.max(0, 540 - index * 450) }
                        }
                    }
                }
            }

            // ── 加载进度条 ───────────────────────────────────────────────
            Rectangle {
                id: _progressTrack
                anchors { top: _dotsRow.bottom; topMargin: 22; horizontalCenter: parent.horizontalCenter }
                width: 260; height: 6; radius: 3
                color: SepKits.Color.border

                Rectangle {
                    id: _progressFill
                    height: parent.height; radius: 3; width: 0
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: SepKits.Color.accent  }
                        GradientStop { position: 1.0; color: SepKits.Color.cyan400 }
                    }
                }
            }
        }
    }

    // ── 进度条动画（两段式，定义在根级以避免跨层 id 访问的歧义）─────────────

    // 阶段一：构建期 0 → 85%，OutQuart 使末段速度趋近于零，视觉呈"正在等待"
    NumberAnimation {
        id: _progressPhase1
        target: _progressFill; property: "width"
        from: 0; to: _progressTrack.width * 0.85
        duration: 1000; easing.type: Easing.OutQuart
    }

    // 阶段二：Ready 后从当前位置补至 100%，完成后启动页面转场
    NumberAnimation {
        id: _progressPhase2
        target: _progressFill; property: "width"
        to: _progressTrack.width
        duration: 220; easing.type: Easing.OutCubic
        onStopped: _crossFade.start()
    }

    // ── 页面转场：交叉淡变（cross-fade）──────────────────────────────────
    // 占位层淡出与内容层淡入同步执行，总时长 400ms，
    // InOutQuad 使过渡中段速度最快，视觉上最自然。
    ParallelAnimation {
        id: _crossFade
        NumberAnimation {
            target: _placeholder; property: "opacity"
            to: 0; duration: 400; easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: _loader; property: "opacity"
            to: 1; duration: 400; easing.type: Easing.InOutQuad
        }
        onStopped: _placeholder.visible = false  // 转场结束后移出渲染树，释放资源
    }
}