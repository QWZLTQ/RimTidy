import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style
import "../delegates"

ColumnLayout {
    id: modsPanel
    spacing: 6

    // Models are set from Python via context properties: activeModsModel, inactiveModsModel

    // Search bar
    Rectangle {
        Layout.fillWidth: true
        height: 36
        radius: Theme.borderRadius
        color: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, Theme.panelOpacity)
        border.color: searchInput.activeFocus ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, Theme.panelOpacity)
        border.width: searchInput.activeFocus ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: 120 } }

        TextInput {
            id: searchInput
            anchors.fill: parent
            anchors.margins: 8
            verticalAlignment: TextInput.AlignVCenter
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            color: Theme.textPrimary
            clip: true
            selectByMouse: true

            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                text: "Search mods..."
                color: Theme.textTertiary
                font: parent.font
                visible: !parent.text && !parent.activeFocus
            }
        }
    }

    // Active mods list
    ModListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        title: "Active Mods (" + (typeof activeModsModel !== 'undefined' ? activeModsModel.rowCount() : 0) + ")"
        model: typeof activeModsModel !== 'undefined' ? activeModsModel : null
    }

    // Inactive mods list
    ModListView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        title: "Inactive Mods (" + (typeof inactiveModsModel !== 'undefined' ? inactiveModsModel.rowCount() : 0) + ")"
        model: typeof inactiveModsModel !== 'undefined' ? inactiveModsModel : null
    }

    // Bottom buttons
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Item { Layout.fillWidth: true }

        Repeater {
            model: ["Refresh", "Clear", "Restore", "Sort", "Save", "Run"]
            delegate: Button {
                text: modelData
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                implicitWidth: 90
                implicitHeight: 32

                background: Rectangle {
                    radius: 6
                    color: parent.pressed ? "#EBEBEB" : parent.hovered ? Theme.hover : Theme.card
                    border.color: parent.hovered ? "#C0C0C0" : Theme.border
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }
                }
                contentItem: Text {
                    text: parent.text
                    color: Theme.textPrimary
                    font: parent.font
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
