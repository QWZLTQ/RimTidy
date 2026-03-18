import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style
import "../delegates"

Rectangle {
    id: listContainer
    radius: Theme.borderRadius
    color: Theme.card
    border.color: Theme.border
    border.width: 1

    property string title: "Mods"
    property alias model: listView.model

    // Signal for double-click to transfer mod
    signal modDoubleClicked(int index, string uuid)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 1
        spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 28
            color: "transparent"

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                text: listContainer.title
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.DemiBold
            }
        }

        // Separator
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.borderSubtle
        }

        // List
        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: 120

            // Smooth scrolling
            flickDeceleration: 3000
            maximumFlickVelocity: 2500

            delegate: ModListItemDelegate {
                isSelected: listView.currentIndex === index
            }

            // Empty state
            Text {
                anchors.centerIn: parent
                visible: listView.count === 0
                text: "No mods"
                color: Theme.textTertiary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
            }

            // Thin macOS-style scrollbar
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                contentItem: Rectangle {
                    implicitWidth: 6
                    radius: 3
                    color: "#C0C0C0"
                    opacity: parent.active ? 1.0 : 0.4
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }
            }

            // Keyboard navigation
            Keys.onUpPressed: {
                if (currentIndex > 0) currentIndex--
            }
            Keys.onDownPressed: {
                if (currentIndex < count - 1) currentIndex++
            }

            // Forward double-click signal
            function modDoubleClicked(index, uuid) {
                listContainer.modDoubleClicked(index, uuid)
            }
        }
    }
}
