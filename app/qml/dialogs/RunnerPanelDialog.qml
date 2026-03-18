import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

BaseDialog {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    dialogTitle: tr("Runner")
    width: parent.width * 0.6; height: parent.height * 0.65

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 8

        // Progress bar
        ProgressBar {
            Layout.fillWidth: true; value: 0; indeterminate: true
            background: Rectangle { implicitHeight: 4; color: Theme.border; radius: 2 }
            contentItem: Item { implicitHeight: 4; Rectangle { width: parent.width * parent.parent.position; height: parent.height; color: Theme.accent; radius: 2 } }
        }

        // Output log
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 8; color: "#1E1E1E"; border.color: Theme.border; border.width: 1

            Flickable {
                anchors.fill: parent; anchors.margins: 8; contentHeight: outputText.implicitHeight; clip: true
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                TextArea {
                    id: outputText; width: parent.width; readOnly: true; wrapMode: TextEdit.Wrap
                    text: tr("Waiting for process output...")
                    color: "#D4D4D4"; font.family: "Consolas, monospace"; font.pixelSize: 12
                    background: null
                }
            }
        }

        // Bottom buttons
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Item { Layout.fillWidth: true }
            Button {
                text: tr("Stop"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14
                background: Rectangle { radius: 6; color: parent.pressed ? "#B52E31" : parent.hovered ? Theme.danger : "#E8484C"; Behavior on color { ColorAnimation { duration: 80 } } }
                contentItem: Text { text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            Button {
                text: tr("Close"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14
                onClicked: close()
                background: Rectangle { radius: 6; color: parent.pressed ? "#EBEBEB" : parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1; Behavior on color { ColorAnimation { duration: 80 } } }
                contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }
    }
}
