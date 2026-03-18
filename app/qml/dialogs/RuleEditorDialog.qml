import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

BaseDialog {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    dialogTitle: tr("Rule Editor")
    width: parent.width * 0.75; height: parent.height * 0.8

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 16; spacing: 8

        // Filter row
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            TextField {
                Layout.fillWidth: true; placeholderText: tr("Filter rules...")
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                background: Rectangle { radius: 6; color: Theme.card; border.color: parent.activeFocus ? Theme.accent : Theme.border; border.width: 1 }
            }
            ComboBox {
                model: [tr("All Rules"), tr("User Rules"), tr("Community Rules")]
                implicitWidth: 160
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
            }
        }

        // Rules table header
        Rectangle {
            Layout.fillWidth: true; height: 32; color: Theme.background; radius: 6
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 4
                Text { Layout.preferredWidth: 200; text: tr("Mod Name"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 100; text: tr("Category"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.preferredWidth: 100; text: tr("Rule Type"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                Text { Layout.fillWidth: true; text: tr("Comment"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
            }
        }

        // Rules list
        ListView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
            model: 20
            delegate: Rectangle {
                width: ListView.view.width; height: 36; color: index % 2 === 0 ? Theme.card : Theme.background
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 4
                    Text { Layout.preferredWidth: 200; text: tr("Mod Rule ") + (index + 1); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; elide: Text.ElideRight }
                    Text { Layout.preferredWidth: 100; text: tr("loadAfter"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                    Text { Layout.preferredWidth: 100; text: index % 3 === 0 ? "User" : "Community"; color: index % 3 === 0 ? Theme.accent : Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                    Text { Layout.fillWidth: true; text: ""; color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.italic: true }
                }
            }
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: 6; radius: 3; color: "#C0C0C0" } }
        }

        // Bottom buttons
        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Item { Layout.fillWidth: true }
            DialogButton { text: tr("Add Rule") }
            DialogButton { text: tr("Delete Selected") }
            DialogButton { text: tr("Save"); accent: true }
        }
    }

    component DialogButton: Button {
        property bool accent: false
        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; implicitHeight: 32; leftPadding: 14; rightPadding: 14
        background: Rectangle { radius: 6; color: parent.accent ? (parent.pressed ? Theme.accentPressed : parent.hovered ? Theme.accentHover : Theme.accent) : (parent.pressed ? "#EBEBEB" : parent.hovered ? Theme.hover : Theme.card); border.color: parent.accent ? "transparent" : Theme.border; border.width: parent.accent ? 0 : 1; Behavior on color { ColorAnimation { duration: 80 } } }
        contentItem: Text { text: parent.text; color: parent.accent ? "white" : Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
    }
}
