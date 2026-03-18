import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

Popup {
    id: baseDialog
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.65
    height: parent.height * 0.7
    padding: 0
    closePolicy: Popup.CloseOnEscape

    property string dialogTitle: "Dialog"

    // Content area — override via default property
    default property alias content: contentArea.data

    background: Rectangle { color: Theme.surface; radius: Theme.borderRadiusLarge; border.color: Theme.border; border.width: 1 }
    enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 } }

    ColumnLayout {
        anchors.fill: parent; spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true; height: 44; color: "transparent"
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 12
                Text { text: baseDialog.dialogTitle; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 16; font.weight: Font.DemiBold }
                Item { Layout.fillWidth: true }
                Button {
                    text: "✕"; flat: true; implicitWidth: 30; implicitHeight: 30
                    onClicked: baseDialog.close()
                    background: Rectangle { radius: 6; color: parent.hovered ? "#E0E0E0" : "transparent" }
                    contentItem: Text { text: parent.text; color: Theme.textSecondary; font.pixelSize: 14; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.borderSubtle }
        }

        // Content
        Item {
            id: contentArea
            Layout.fillWidth: true; Layout.fillHeight: true
        }
    }
}
