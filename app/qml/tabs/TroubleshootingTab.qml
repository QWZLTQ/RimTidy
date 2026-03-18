import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

Rectangle {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    color: Theme.background

    Flickable {
        anchors.fill: parent; anchors.margins: 12; contentHeight: mainCol.implicitHeight; clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: 6; radius: 3; color: "#C0C0C0" } }

        ColumnLayout {
            id: mainCol; width: parent.width; spacing: 16

            Text { text: tr("Troubleshooting"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeLarge; font.weight: Font.DemiBold }

            TroubleSection {
                title: tr("Quick Actions")
                description: tr("Common fixes for mod-related issues.")
                ColumnLayout {
                    spacing: 6
                    TroubleButton { text: tr("Clear Mod Cache"); desc: tr("Remove cached mod metadata and rescan") }
                    TroubleButton { text: tr("Reset Load Order"); desc: tr("Reset to default RimWorld load order") }
                    TroubleButton { text: tr("Verify All Mod Files"); desc: tr("Check all mod files for corruption") }
                }
            }

            TroubleSection {
                title: tr("Diagnostics")
                description: tr("Identify potential issues with your mod setup.")
                ColumnLayout {
                    spacing: 6
                    TroubleButton { text: tr("Check for Circular Dependencies"); desc: tr("Find dependency loops that prevent sorting") }
                    TroubleButton { text: tr("Find Incompatible Mods"); desc: tr("Detect mods marked as incompatible") }
                    TroubleButton { text: tr("Check for Missing Textures"); desc: tr("Find mods with broken texture references") }
                }
            }

            TroubleSection {
                title: tr("Cleanup")
                description: tr("Remove unnecessary files and data.")
                ColumnLayout {
                    spacing: 6
                    TroubleButton { text: tr("Clear RimTidy Logs"); desc: tr("Delete old RimTidy log files"); danger: true }
                    TroubleButton { text: tr("Clear Steam Download Cache"); desc: tr("Remove cached Steam downloads"); danger: true }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    component TroubleSection: Rectangle {
        property string title: ""
        property string description: ""
        default property alias content: sectionContent.data
        Layout.fillWidth: true; radius: Theme.borderRadius; color: Theme.card; border.color: Theme.border; border.width: 1
        implicitHeight: sectionCol.implicitHeight + 24

        ColumnLayout {
            id: sectionCol; anchors.fill: parent; anchors.margins: 12; spacing: 6
            Text { text: parent.parent.title; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.DemiBold }
            Text { text: parent.parent.description; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; visible: text !== "" }
            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle }
            ColumnLayout { id: sectionContent; Layout.fillWidth: true; spacing: 4 }
        }
    }

    component TroubleButton: Rectangle {
        property string text: ""
        property string desc: ""
        property bool danger: false
        Layout.fillWidth: true; height: 48; radius: 6; color: tbMa.containsMouse ? Theme.hover : "transparent"
        MouseArea { id: tbMa; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor }
        ColumnLayout {
            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 0
            Item { Layout.fillHeight: true }
            Text { text: parent.parent.text; color: parent.parent.danger ? Theme.danger : Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
            Text { text: parent.parent.desc; color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; visible: text !== "" }
            Item { Layout.fillHeight: true }
        }
    }
}
