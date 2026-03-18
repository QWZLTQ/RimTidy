import QtQuick
import QtQuick.Layouts
import RimSort.Style

Rectangle {
    id: statusBar
    height: 28
    color: Theme.surface

    Rectangle {
        anchors.top: parent.top
        width: parent.width
        height: 1
        color: Theme.borderSubtle
    }

    property string message: ""

    Text {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 12
        text: statusBar.message
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
    }
}
