import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

BaseDialog {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    dialogTitle: tr("Missing Mod Properties")

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 8

        Text { Layout.fillWidth: true; wrapMode: Text.Wrap; text: tr("The following mods are missing a Package ID or Steam Workshop ID."); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }

        Rectangle {
            Layout.fillWidth: true; height: 32; color: Theme.background; radius: 6
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                Text { Layout.preferredWidth: 200; text: tr("Mod Name"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 120; text: tr("Missing Property"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.fillWidth: true; text: tr("Path"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
            }
        }

        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: 0
            Text { anchors.centerIn: parent; visible: parent.count === 0; text: tr("No issues found"); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        }

        RowLayout { Layout.fillWidth: true; spacing: 8; Item { Layout.fillWidth: true }
            Button { text: tr("Add to Ignore List"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1 }; contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
            Button { text: tr("Close"); onClicked: close(); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1 }; contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
        }
    }
}
