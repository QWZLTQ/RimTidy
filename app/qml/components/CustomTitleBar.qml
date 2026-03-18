import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import RimSort.Style

Rectangle {
    id: titleBar
    height: Theme.titleBarHeight
    color: Theme.titleBar
    border.width: 0

    // Bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: Theme.titleBarBorder
    }

    property string title: "RimTidy"
    property var targetWindow: null

    // Repaint icons when theme changes
    Connections {
        target: Theme
        function onModeChanged() { titleBar.repaintIcons() }
    }
    function repaintIcons() {
        for (var i = 0; i < layout.children.length; i++) {
            var child = layout.children[i]
            if (child.contentItem && child.contentItem instanceof Canvas) {
                child.contentItem.requestPaint()
            }
        }
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.leftMargin: 14
        spacing: 0

        // App title
        Text {
            text: titleBar.title
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Font.DemiBold
        }

        Item { Layout.fillWidth: true }

        // Minimize
        TitleBarButton {
            objectName: "btnMinimize"
            onClicked: {
                if (titleBar.targetWindow) titleBar.targetWindow.showMinimized()
            }
            contentItem: Canvas {
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = Theme.textSecondary
                    ctx.lineWidth = 1
                    var cx = width / 2, cy = height / 2
                    ctx.beginPath()
                    ctx.moveTo(cx - 5, cy)
                    ctx.lineTo(cx + 5, cy)
                    ctx.stroke()
                }
            }
        }

        // Maximize / Restore
        TitleBarButton {
            id: btnMaximize
            objectName: "btnMaximize"
            property bool isMaximized: titleBar.targetWindow ? (titleBar.targetWindow.visibility === Window.Maximized) : false
            onClicked: {
                if (!titleBar.targetWindow) return
                if (isMaximized) {
                    titleBar.targetWindow.showNormal()
                } else {
                    titleBar.targetWindow.showMaximized()
                }
            }
            contentItem: Canvas {
                property bool isMax: btnMaximize.isMaximized
                onIsMaxChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = Theme.textSecondary
                    ctx.lineWidth = 1
                    var cx = width / 2, cy = height / 2
                    if (isMax) {
                        ctx.strokeRect(cx - 3, cy - 1, 7, 7)
                        ctx.strokeRect(cx - 5, cy - 4, 7, 7)
                    } else {
                        ctx.strokeRect(cx - 5, cy - 4, 10, 8)
                    }
                }
            }
        }

        // Close
        TitleBarButton {
            objectName: "btnClose"
            isClose: true
            onClicked: {
                if (titleBar.targetWindow) titleBar.targetWindow.close()
            }
            contentItem: Canvas {
                id: closeCanvas
                property bool btnHov: parent.btnHovered
                onBtnHovChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    ctx.strokeStyle = btnHov ? "#FFFFFF" : "#5C5C5C"
                    ctx.lineWidth = 1
                    var cx = width / 2, cy = height / 2
                    ctx.beginPath()
                    ctx.moveTo(cx - 4, cy - 4); ctx.lineTo(cx + 4, cy + 4)
                    ctx.moveTo(cx + 4, cy - 4); ctx.lineTo(cx - 4, cy + 4)
                    ctx.stroke()
                }
            }
        }
    }

    // Drag to move window
    DragHandler {
        target: null
        onActiveChanged: {
            if (active && titleBar.targetWindow) {
                titleBar.targetWindow.startSystemMove()
            }
        }
    }

    // Double-click to maximize/restore
    TapHandler {
        onDoubleTapped: {
            if (!titleBar.targetWindow) return
            if (titleBar.targetWindow.visibility === Window.Maximized) {
                titleBar.targetWindow.showNormal()
            } else {
                titleBar.targetWindow.showMaximized()
            }
        }
    }
}
