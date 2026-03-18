import QtQuick
import QtQuick.Layouts
import RimSort.Style

Item {
    id: delegateRoot
    width: ListView.view ? ListView.view.width : 200
    height: 30

    required property int index
    required property string uuid
    required property string name
    required property string packageId
    required property string dataSource
    required property bool hasCSharp
    required property bool hasGit
    required property bool hasSteamcmd
    required property string errors
    required property string warnings
    required property string errorsWarnings
    required property bool filtered
    required property bool invalid
    required property bool mismatch
    required property string modColor
    required property bool isNew
    required property bool inSave

    property bool isSelected: false

    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        radius: 5
        color: {
            if (delegateRoot.isSelected) return Theme.selectionActive
            if (mouseArea.containsMouse) return Theme.hover
            if (delegateRoot.modColor !== "") return delegateRoot.modColor
            return "transparent"
        }

        Behavior on color { ColorAnimation { duration: 80 } }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    // TODO: context menu
                } else {
                    delegateRoot.ListView.view.currentIndex = delegateRoot.index
                }
            }
            onDoubleClicked: {
                // Signal to move mod to other list — handled by parent ListView
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            spacing: 4

            // Source icon indicator
            Rectangle {
                width: 4
                height: 16
                radius: 2
                color: {
                    if (delegateRoot.dataSource === "expansion") return "#107C10"  // green
                    if (delegateRoot.dataSource === "workshop") return "#0078D4"   // blue
                    if (delegateRoot.hasGit) return "#F05032"                       // git orange
                    if (delegateRoot.hasSteamcmd) return "#1B2838"                 // steam dark
                    return "#8A8A8A"                                                // local gray
                }
                Layout.alignment: Qt.AlignVCenter
            }

            // C# indicator dot
            Rectangle {
                visible: delegateRoot.hasCSharp
                width: 6
                height: 6
                radius: 3
                color: "#9B59B6"
                Layout.alignment: Qt.AlignVCenter

                ToolTip.visible: csharpMa.containsMouse
                ToolTip.text: "C#"
                MouseArea {
                    id: csharpMa
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            // Mod name
            Text {
                Layout.fillWidth: true
                text: delegateRoot.name
                color: {
                    if (delegateRoot.filtered) return Theme.textTertiary
                    if (delegateRoot.invalid || delegateRoot.errorsWarnings !== "") return Theme.danger
                    return Theme.textPrimary
                }
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }

            // In-save indicator
            Rectangle {
                visible: delegateRoot.inSave
                width: 8
                height: 8
                radius: 4
                color: Theme.success
                Layout.alignment: Qt.AlignVCenter
                ToolTip.visible: inSaveMa.containsMouse
                ToolTip.text: "In latest save"
                MouseArea {
                    id: inSaveMa
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            // New indicator
            Rectangle {
                visible: delegateRoot.isNew
                width: 8
                height: 8
                radius: 4
                color: Theme.accent
                Layout.alignment: Qt.AlignVCenter
                ToolTip.visible: newMa.containsMouse
                ToolTip.text: "Not in latest save"
                MouseArea {
                    id: newMa
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            // Warning icon
            Text {
                visible: delegateRoot.warnings !== ""
                text: "⚠"
                color: Theme.warning
                font.pixelSize: 14
                Layout.alignment: Qt.AlignVCenter
                ToolTip.visible: warnMa.containsMouse
                ToolTip.text: delegateRoot.warnings
                MouseArea {
                    id: warnMa
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            // Error icon
            Text {
                visible: delegateRoot.errors !== ""
                text: "✕"
                color: Theme.danger
                font.pixelSize: 14
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignVCenter
                ToolTip.visible: errMa.containsMouse
                ToolTip.text: delegateRoot.errors
                MouseArea {
                    id: errMa
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }
        }
    }
}
