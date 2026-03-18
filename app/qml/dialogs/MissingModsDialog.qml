import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

BaseDialog {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    dialogTitle: tr("Missing Mods")

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 8

        Text {
            Layout.fillWidth: true; wrapMode: Text.Wrap
            text: tr("The following mods are missing from your active mod list. Select variants to download.")
            color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
        }

        // Table header
        Rectangle {
            Layout.fillWidth: true; height: 32; color: Theme.background; radius: 6
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                Text { Layout.preferredWidth: 200; text: tr("Package ID"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.fillWidth: true; text: tr("Available Variants"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 100; text: tr("Version"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
            }
        }

        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
            model: 0
            delegate: Rectangle { width: ListView.view.width; height: 36; color: "transparent" }
            Text { anchors.centerIn: parent; visible: parent.count === 0; text: tr("No missing mods"); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Item { Layout.fillWidth: true }
            Button { text: tr("Download via SteamCMD"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1 }; contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
            Button { text: tr("Subscribe via Steam"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14; background: Rectangle { radius: 6; color: parent.hovered ? Theme.accentHover : Theme.accent; Behavior on color { ColorAnimation { duration: 80 } } }; contentItem: Text { text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter } }
        }
    }
}
