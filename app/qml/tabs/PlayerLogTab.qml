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
            Text { text: tr("Player Log"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLarge; font.weight: Font.DemiBold }
            Item { Layout.fillWidth: true }
            Button {
                text: tr("Reload"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14
                background: Rectangle { radius: 6; color: parent.hovered ? Theme.hover : Theme.card; border.color: Theme.border; border.width: 1; Behavior on color { ColorAnimation { duration: 80 } } }
                contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
            Button {
                text: tr("Upload Log"); font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14
                background: Rectangle { radius: 6; color: parent.hovered ? Theme.accentHover : Theme.accent; Behavior on color { ColorAnimation { duration: 80 } } }
                contentItem: Text { text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }

        // Search
        Rectangle {
            Layout.fillWidth: true; height: 36; radius: 6; color: Theme.card; border.color: logSearch.activeFocus ? Theme.accent : Theme.border; border.width: logSearch.activeFocus ? 2 : 1
            Behavior on border.color { ColorAnimation { duration: 120 } }
            TextInput {
                id: logSearch; anchors.fill: parent; anchors.margins: 8; verticalAlignment: TextInput.AlignVCenter
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; color: Theme.textPrimary; clip: true; selectByMouse: true
                Text { anchors.fill: parent; verticalAlignment: Text.AlignVCenter; text: tr("Search log..."); color: Theme.textTertiary; font: parent.font; visible: !parent.text && !parent.activeFocus }
            }
        }

        // Log viewer
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 8; color: "#1E1E1E"; border.color: Theme.border; border.width: 1

            Flickable {
                anchors.fill: parent; anchors.margins: 8; contentHeight: logText.implicitHeight; clip: true
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: 6; radius: 3; color: "#555555" } }
                TextArea {
                    id: logText; width: parent.width; readOnly: true; wrapMode: TextEdit.Wrap
                    text: tr("Player log will appear here.\nConfigure game paths in Settings to load the log file.")
                    color: "#D4D4D4"; font.family: "Consolas, monospace"; font.pixelSize: 12
                    background: null
                }
            }
        }

        // Stats bar
        RowLayout {
            Layout.fillWidth: true; spacing: 16
            Text { text: tr("Errors: 0"); color: Theme.danger; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            Text { text: tr("Warnings: 0"); color: Theme.warning; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            Text { text: tr("Lines: 0"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
            Item { Layout.fillWidth: true }
        }
    }
}
