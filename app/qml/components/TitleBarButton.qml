import QtQuick
import QtQuick.Controls
import RimSort.Style

AbstractButton {
    id: btn
    implicitWidth: 46
    implicitHeight: Theme.titleBarHeight

    property bool isClose: false
    property bool btnHovered: hoverHandler.hovered

    HoverHandler {
        id: hoverHandler
    }

    background: Rectangle {
        color: {
            if (btn.pressed) {
                return btn.isClose ? "#C50F1F" : "#D0D0D0"
            }
            if (btn.btnHovered) {
                return btn.isClose ? Theme.closeHover : "#E0E0E0"
            }
            return "transparent"
        }
        Behavior on color { ColorAnimation { duration: 100 } }
    }
}
