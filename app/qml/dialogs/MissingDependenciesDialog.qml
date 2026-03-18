import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

BaseDialog {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    dialogTitle: tr("Missing Dependencies")

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 8

        Text {
            Layout.fillWidth: true; wrapMode: Text.Wrap
            text: tr("Some mods have missing dependencies. Select which to add to your active mod list.")
            color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
        }

        // Scrollable checkbox list
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 8; color: Theme.card; border.color: Theme.border; border.width: 1

            ListView {
                anchors.fill: parent; anchors.margins: 8; clip: true; spacing: 4
                model: 0
                delegate: CheckBox {
                    text: tr("Dependency mod ") + (index + 1)
                    font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; checked: true
                }
                Text { anchors.centerIn: parent; visible: parent.count === 0; text: tr("No missing dependencies"); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Button { text: tr("Select All"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1 }; contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
            Item { Layout.fillWidth: true }
            Button { text: tr("Sort Without Adding"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1 }; contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
            Button { text: tr("Add Selected"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.accentHover : Theme.accent; Behavior on color { ColorAnimation { duration: 80 } } }; contentItem: Text { text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
        }
    }
}
