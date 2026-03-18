import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

BaseDialog {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    dialogTitle: tr("Ignore List Editor")
    width: parent.width * 0.5; height: parent.height * 0.6

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 8

        Text { Layout.fillWidth: true; wrapMode: Text.Wrap; text: tr("Mods in this list will have their warnings/errors suppressed."); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }

        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 8; color: Theme.card; border.color: Theme.border; border.width: 1

            ListView {
                anchors.fill: parent; anchors.margins: 8; clip: true; spacing: 2; model: 0
                delegate: Rectangle {
                    width: ListView.view.width; height: 32; radius: 4; color: mouseArea.containsMouse ? Theme.hover : "transparent"
                    MouseArea { id: mouseArea; anchors.fill: parent; hoverEnabled: true }
                    Text { anchors.left: parent.left; anchors.leftMargin: 8; anchors.verticalCenter: parent.verticalCenter; text: tr("Ignored Mod ") + (index + 1); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                }
                Text { anchors.centerIn: parent; visible: parent.count === 0; text: tr("Ignore list is empty"); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }
        }

        RowLayout { Layout.fillWidth: true; spacing: 8; Item { Layout.fillWidth: true }
            Button { text: tr("Remove Selected"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1 }; contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
            Button { text: tr("Save"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.accentHover : Theme.accent; Behavior on color { ColorAnimation { duration: 80 } } }; contentItem: Text { text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
        }
    }
}
