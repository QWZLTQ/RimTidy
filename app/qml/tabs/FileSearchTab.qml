import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

Rectangle {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    color: Theme.background

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 12; spacing: 8

        // Header
        Text { text: tr("File Search"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLarge; font.weight: Font.DemiBold }

        // Search bar
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Rectangle {
                Layout.fillWidth: true; height: 36; radius: 6; color: Theme.card; border.color: fileSearchInput.activeFocus ? Theme.accent : Theme.border; border.width: fileSearchInput.activeFocus ? 2 : 1
                Behavior on border.color { ColorAnimation { duration: 120 } }
                TextInput {
                    id: fileSearchInput; anchors.fill: parent; anchors.margins: 8; verticalAlignment: TextInput.AlignVCenter
                    font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; color: Theme.textPrimary; clip: true; selectByMouse: true
                    Text { anchors.fill: parent; verticalAlignment: Text.AlignVCenter; text: tr("Search for files across mods..."); color: Theme.textTertiary; font: parent.font; visible: !parent.text && !parent.activeFocus }
                }
            }
            ComboBox {
                model: [tr("All Files"), "*.xml", "*.cs", "*.png", "*.dds"]
                implicitWidth: 120; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
            }
            Button {
                text: tr("Search"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 36; leftPadding: 16; rightPadding: 16
                background: Rectangle { radius: 6; color: parent.hovered ? Theme.accentHover : Theme.accent; Behavior on color { ColorAnimation { duration: 80 } } }
                contentItem: Text { text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }

        // Results header
        Rectangle {
            Layout.fillWidth: true; height: 32; color: Theme.background; radius: 6
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                Text { Layout.preferredWidth: 200; text: tr("File Name"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 150; text: tr("Mod"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.fillWidth: true; text: tr("Path"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 80; text: tr("Size"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
            }
        }

        // Results
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: 0
            Text { anchors.centerIn: parent; visible: parent.count === 0; text: tr("Enter a search term to find files across all mod directories."); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; horizontalAlignment: Text.AlignHCenter }
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: 6; radius: 3; color: "#C0C0C0" } }
        }

        // Status
        Text { text: tr("0 results"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
    }
}
