import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

BaseDialog {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    dialogTitle: tr("Workshop Mod Updates")
    width: parent.width * 0.7; height: parent.height * 0.65

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 8

        Text { Layout.fillWidth: true; wrapMode: Text.Wrap; text: tr("The following Workshop mods have available updates."); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }

        Rectangle {
            Layout.fillWidth: true; height: 32; color: Theme.background; radius: 6
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                Text { Layout.preferredWidth: 200; text: tr("Mod Name"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 100; text: tr("Current"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 100; text: tr("Available"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.fillWidth: true; text: tr("Workshop ID"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
            }
        }

        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: 0
            Text { anchors.centerIn: parent; visible: parent.count === 0; text: tr("All mods are up to date"); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        }

        RowLayout { Layout.fillWidth: true; spacing: 8; Item { Layout.fillWidth: true }
            Button { text: tr("Update via SteamCMD"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1 }; contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
            Button { text: tr("Update via Steam"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.accentHover : Theme.accent; Behavior on color { ColorAnimation { duration: 80 } } }; contentItem: Text { text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
        }
    }
}
