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
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Text { text: tr("ACF Log Reader"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLarge; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            Button {
                text: tr("Refresh"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14
                background: Rectangle { radius: 6; color: parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1; Behavior on color { ColorAnimation { duration: 80 } } }
                contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }

        // Filter
        Rectangle {
            Layout.fillWidth: true; height: 36; radius: 6; color: Theme.card; border.color: acfSearch.activeFocus ? Theme.accent : Theme.border; border.width: acfSearch.activeFocus ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: 120 } }
            TextInput {
                id: acfSearch; anchors.fill: parent; anchors.margins: 8; verticalAlignment: TextInput.AlignVCenter
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; color: Theme.textPrimary; clip: true; selectByMouse: true
                Text { anchors.fill: parent; verticalAlignment: Text.AlignVCenter; text: tr("Filter ACF entries..."); color: Theme.textTertiary; font: parent.font; visible: !parent.text && !parent.activeFocus }
            }
        }

        // Table header
        Rectangle {
            Layout.fillWidth: true; height: 32; color: Theme.background; radius: 6
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                Text { Layout.preferredWidth: 200; text: tr("Mod Name"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 120; text: tr("Workshop ID"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 100; text: tr("State"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.fillWidth: true; text: tr("Last Updated"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
            }
        }

        // Log entries
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; model: 0
            Text { anchors.centerIn: parent; visible: parent.count === 0; text: tr("No ACF data loaded.\nConfigure paths in Settings to load ACF metadata."); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; horizontalAlignment: Text.AlignHCenter }
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: 6; radius: 3; color: "#C0C0C0" } }
        }
    }
}
