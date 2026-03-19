import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import RimSort.Style

Popup {
    function tr(key) { return typeof i18n !== "undefined" && i18n ? i18n.t(key) : key }
    id: settingsPopup
    modal: true
    anchors.centerIn: parent
    width: parent.width * 0.7
    height: parent.height * 0.8
    padding: 0
    closePolicy: Popup.CloseOnEscape

    background: Rectangle {
        color: Theme.surface
        radius: Theme.borderRadiusLarge
        border.color: Theme.border; border.width: 1
    }

    enter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 } }
    exit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 100 } }

    ColumnLayout {
        anchors.fill: parent; spacing: 0

        // Header
        Rectangle {
            Layout.fillWidth: true; height: 48; color: "transparent"
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 12
                Text { text: tr("Settings"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 18; font.weight: Font.DemiBold }
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.borderSubtle }
        }

        // Body
        RowLayout {
            Layout.fillWidth: true; Layout.fillHeight: true; spacing: 0

            // Sidebar
            Rectangle {
                Layout.fillHeight: true; Layout.preferredWidth: 160; color: Theme.background
                ListView {
                    id: tabList; anchors.fill: parent; anchors.topMargin: 8
                    model: [tr("Locations"), tr("Game Launch"), tr("Databases"), tr("Sorting"), tr("DB Builder"), tr("SteamCMD"), tr("todds"), tr("External Tools"), tr("Theme"), tr("Launch State"), tr("Authentication"), tr("Advanced")]
                    currentIndex: 0
                    delegate: ItemDelegate {
                        id: sidebarDelegate
                        width: tabList.width; height: 36
                        highlighted: tabList.currentIndex === index
                        onClicked: tabList.currentIndex = index
                        contentItem: Text {
                            text: modelData; color: sidebarDelegate.highlighted ? Theme.accent : Theme.textPrimary
                            font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                            verticalAlignment: Text.AlignVCenter; leftPadding: 16
                            font.weight: sidebarDelegate.highlighted ? Font.DemiBold : Font.Normal
                        }
                        background: Rectangle {
                            color: sidebarDelegate.highlighted ? Theme.accentLight : (sidebarDelegate.hovered ? Theme.hover : Theme.background)
                            radius: 6; anchors.margins: 4
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                    }
                }
            }

            Rectangle { Layout.fillHeight: true; width: 1; color: Theme.borderSubtle }

            // Content pages
            StackLayout {
                Layout.fillWidth: true; Layout.fillHeight: true
                currentIndex: tabList.currentIndex

                // === Tab 0: Locations ===
                Flickable {
                    contentHeight: locCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: locCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 16

                        SGroupTitle { text: tr("Game Location") }
                        SPathField { placeholderText: tr("C:\\Program Files (x86)\\Steam\\steamapps\\common\\RimWorld"); text: settings.gameLocation; onTextEdited: settings.gameLocation = text }

                        SGroupTitle { text: tr("Config Folder") }
                        SPathField { placeholderText: tr("...\\Ludeon Studios\\RimWorld by Ludeon Studios\\Config"); text: settings.configFolder; onTextEdited: settings.configFolder = text }

                        SGroupTitle { text: tr("Steam Mods Folder") }
                        SCheck { text: tr("Enable Steam client integration"); checked: settings.steamClientIntegration; onToggled: settings.steamClientIntegration = checked }
                        SPathField { placeholderText: tr("...\\Steam\\steamapps\\workshop\\content\\294100"); text: settings.steamModsFolder; onTextEdited: settings.steamModsFolder = text }

                        SGroupTitle { text: tr("Local Mods Folder") }
                        SPathField { placeholderText: tr("...\\Steam\\steamapps\\common\\RimWorld\\Mods"); text: settings.localModsFolder; onTextEdited: settings.localModsFolder = text }

                        SGroupTitle { text: tr("Instance Folder (optional)") }
                        SPathField { placeholderText: tr("Leave empty to use default location"); text: settings.instanceFolder; onTextEdited: settings.instanceFolder = text }

                        RowLayout { Layout.fillWidth: true; spacing: 8; Item { Layout.fillWidth: true }
                            SBtn { text: tr("Clear All"); onClicked: { settings.gameLocation = ""; settings.configFolder = ""; settings.steamModsFolder = ""; settings.localModsFolder = ""; settings.instanceFolder = "" } }
                            SBtn { text: tr("Autodetect"); accent: true; onClicked: settings.autodetectLocations() }
                        }
                    }
                }

                // === Tab 1: Game Launch ===
                Flickable {
                    contentHeight: glCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: glCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("Launch Method") }
                        SCheck { text: tr("Use Steam protocol for launching") }
                        SCheck { text: tr("Use Steamworks integration for launching") }

                        SGroupTitle { text: tr("Custom Game Arguments") }
                        SPathField { placeholderText: tr("Additional launch arguments...") }

                        SGroupTitle { text: tr("Game Executable") }
                        SDesc { text: tr("Override the default game executable path if needed.") }
                        SPathField { placeholderText: tr("Leave empty to use default") }
                    }
                }

                // === Tab 2: Databases ===
                Flickable {
                    contentHeight: dbCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: dbCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("Community Rules Database") }
                        SDesc { text: tr("URL or local path to the community rules database used for sorting.") }
                        SPathField { placeholderText: tr("Community rules database path or URL...") }

                        SGroupTitle { text: tr("Steam Workshop Database") }
                        SDesc { text: tr("URL or local path to the Steam Workshop database.") }
                        SPathField { placeholderText: tr("Steam Workshop database path or URL...") }

                        SGroupTitle { text: tr("No Version Warning Database") }
                        SPathField { placeholderText: tr("Path or URL...") }

                        SGroupTitle { text: tr("Use This Instead Database") }
                        SPathField { placeholderText: tr("Path or URL...") }
                    }
                }

                // === Tab 3: Sorting ===
                Flickable {
                    contentHeight: sortCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: sortCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("Sort Algorithm") }
                        SRadio { text: tr("Topological Sort (recommended)"); checked: settings.sortMethod === "Topological"; onToggled: if (checked) settings.sortMethod = "Topological" }
                        SRadio { text: tr("Alphabetical Sort"); checked: settings.sortMethod === "Alphabetical"; onToggled: if (checked) settings.sortMethod = "Alphabetical" }

                        SGroupTitle { text: tr("Sorting Behavior") }
                        SCheck { text: tr("Treat About.xml dependencies as load order rules") }
                        SCheck { text: tr("Use alternative package IDs as satisfying dependencies") }

                        SGroupTitle { text: tr("Display Options") }
                        SCheck { text: tr("Show mod type filter (C# / XML)"); checked: settings.enableModTypeFilter; onToggled: settings.enableModTypeFilter = checked }
                        SCheck { text: tr("Show save comparison indicators"); checked: settings.showSaveIndicators; onToggled: settings.showSaveIndicators = checked }
                        SCheck { text: tr("Enable inactive mods list sorting") }
                    }
                }

                // === Tab 4: DB Builder ===
                Flickable {
                    contentHeight: dbbCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: dbbCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("Database Builder") }
                        SDesc { text: tr("Configure how the mod database is built from Steam Workshop data.") }
                        SCheck { text: tr("Enable database building on refresh") }
                        SCheck { text: tr("Include mod dependencies in database") }

                        SGroupTitle { text: tr("Build Options") }
                        SDesc { text: tr("Number of concurrent API queries for database building.") }
                        RowLayout { spacing: 8
                            Text { text: tr("Concurrent queries:"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                            SpinBox { from: 1; to: 20; value: 5 }
                        }
                    }
                }

                // === Tab 5: SteamCMD ===
                Flickable {
                    contentHeight: scmdCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: scmdCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("SteamCMD Installation") }
                        SDesc { text: tr("Path to your SteamCMD installation. Required for downloading mods without Steam client.") }
                        SPathField { placeholderText: tr("SteamCMD installation path...") }
                        SBtn { text: tr("Install SteamCMD") }

                        SGroupTitle { text: tr("Download Settings") }
                        SCheck { text: tr("Validate downloads after completion") }
                        SCheck { text: tr("Force re-download existing mods") }
                    }
                }

                // === Tab 6: todds ===
                Flickable {
                    contentHeight: toddsCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: toddsCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("Quality Preset") }
                        RadioButton {
                            text: tr("Optimized - Recommended for RimWorld")
                            checked: settings.toddsPreset === "optimized"
                            onToggled: if (checked) settings.toddsPreset = "optimized"
                        }
                        RadioButton {
                            text: tr("Custom todds command")
                            checked: settings.toddsPreset === "custom"
                            onToggled: if (checked) settings.toddsPreset = "custom"
                        }
                        SDesc { text: tr("If -p (path) is not specified, the path from the current active/all mods selection will be used.") }
                        SPathField {
                            placeholderText: tr("e.g.: -f BC1 -af BC7 -on -vf -fs -r Textures -t -p \"D:\\\\Mods\"")
                            text: settings.toddsCustomCommand
                            onTextEdited: settings.toddsCustomCommand = text
                            enabled: settings.toddsPreset === "custom"
                        }

                        SGroupTitle { text: tr("When Optimizing Textures") }
                        RadioButton {
                            text: tr("Optimize active mods only")
                            checked: settings.toddsActiveModsTarget
                            onToggled: if (checked) settings.toddsActiveModsTarget = true
                        }
                        RadioButton {
                            text: tr("Optimize all mods")
                            checked: !settings.toddsActiveModsTarget
                            onToggled: if (checked) settings.toddsActiveModsTarget = false
                        }

                        SGroupTitle { text: tr("Options") }
                        SCheck { text: tr("Enable dry-run mode"); checked: settings.toddsDryRun; onToggled: settings.toddsDryRun = checked }
                        SCheck { text: tr("Overwrite existing optimized textures"); checked: settings.toddsOverwrite; onToggled: settings.toddsOverwrite = checked }
                    }
                }

                // === Tab 7: External Tools ===
                Flickable {
                    contentHeight: etCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: etCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("Text Editor") }
                        SDesc { text: tr("Path to your preferred text editor for opening log files.") }
                        SPathField { placeholderText: tr("Text editor executable path...") }

                        SGroupTitle { text: tr("Git") }
                        SDesc { text: tr("Path to git executable (for git-based mod management).") }
                        SPathField { placeholderText: tr("git executable path...") }
                    }
                }

                // === Tab 8: Theme ===
                Flickable {
                    contentHeight: thCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: thCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("Appearance") }
                        SCheck { text: tr("Enable themes"); checked: settings.enableThemes; onToggled: settings.enableThemes = checked }

                        SGroupTitle { text: tr("Color Mode") }
                        SRadio { text: tr("Light"); checked: Theme.mode === "light"; onToggled: if (checked) Theme.mode = "light" }
                        SRadio { text: tr("Dark"); checked: Theme.mode === "dark"; onToggled: if (checked) Theme.mode = "dark" }

                        SGroupTitle { text: tr("Color Scheme") }
                        Flow {
                            Layout.fillWidth: true; spacing: 8
                            Repeater {
                                model: Theme.schemeNames.length
                                delegate: Rectangle {
                                    required property int index
                                    property var _sch: Theme._schemes[Theme.schemeNames[index]]
                                    property bool _active: Theme.scheme === Theme.schemeNames[index]
                                    width: 80; height: 52; radius: 6
                                    border.color: _active ? Theme.accent : Theme.border
                                    border.width: _active ? 2 : 1
                                    color: _active ? Theme.accentLight : Theme.card
                                    Column {
                                        anchors.centerIn: parent; spacing: 3
                                        Row {
                                            anchors.horizontalCenter: parent.horizontalCenter; spacing: 3
                                            Rectangle { width: 14; height: 14; radius: 7; color: _sch ? _sch.bgL : "transparent" ; border.color: "#C0C0C0"; border.width: 0.5 }
                                            Rectangle { width: 14; height: 14; radius: 7; color: _sch ? _sch.accentL : "transparent" }
                                        }
                                        Row {
                                            anchors.horizontalCenter: parent.horizontalCenter; spacing: 3
                                            Rectangle { width: 14; height: 14; radius: 7; color: _sch ? _sch.bgD : "transparent"; border.color: "#555"; border.width: 0.5 }
                                            Rectangle { width: 14; height: 14; radius: 7; color: _sch ? _sch.accentD : "transparent" }
                                        }
                                        Text {
                                            text: Theme.schemeLabels[index]; anchors.horizontalCenter: parent.horizontalCenter
                                            color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 10
                                        }
                                    }
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Theme.scheme = Theme.schemeNames[index] }
                                }
                            }
                        }

                        SGroupTitle { text: tr("Font") }
                        RowLayout { spacing: 8
                            Text { text: tr("Font size:"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                            SpinBox { from: 8; to: 24; value: settings.fontSize; onValueModified: settings.fontSize = value }
                        }

                        SGroupTitle { text: tr("Custom Background") }
                        SDesc { text: tr("Set a custom background image for the main window. Panels will become semi-transparent.") }
                        RowLayout { spacing: 8; Layout.fillWidth: true
                            SPathField {
                                id: bgPathField
                                placeholderText: tr("No image selected...")
                                text: settings.customBackground
                                Layout.fillWidth: true
                                readOnly: true
                            }
                            SBtn { text: tr("Browse..."); onClicked: { var p = settings.pickBackgroundImage(); if (p) { bgPathField.text = p; Theme.customBackground = "file:///" + p } } }
                            SBtn { text: tr("Clear"); onClicked: { settings.customBackground = ""; bgPathField.text = ""; Theme.customBackground = ""; Theme.panelOpacity = 1.0; opacitySlider.value = 100 } }
                            Text { text: tr("Recommended: 1920×1080 or larger"); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                        }

                        SGroupTitle { text: tr("Panel Transparency") }
                        SDesc { text: tr("Adjust the opacity of panels when a custom background is set.") }
                        RowLayout { spacing: 12; Layout.fillWidth: true
                            Text { text: tr("Transparent"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                            Slider {
                                id: opacitySlider
                                Layout.fillWidth: true
                                from: 0; to: 100; stepSize: 1
                                value: settings.panelOpacity * 100
                                enabled: settings.customBackground !== ""
                                onMoved: { var v = value / 100.0; settings.panelOpacity = v; Theme.panelOpacity = v }
                                background: Rectangle {
                                    x: opacitySlider.leftPadding; y: opacitySlider.topPadding + opacitySlider.availableHeight / 2 - height / 2
                                    width: opacitySlider.availableWidth; height: 4; radius: 2; color: Theme.border
                                    Rectangle { width: opacitySlider.visualPosition * parent.width; height: parent.height; radius: 2; color: opacitySlider.enabled ? Theme.accent : Theme.textTertiary }
                                }
                                handle: Rectangle {
                                    x: opacitySlider.leftPadding + opacitySlider.visualPosition * (opacitySlider.availableWidth - width)
                                    y: opacitySlider.topPadding + opacitySlider.availableHeight / 2 - height / 2
                                    width: 18; height: 18; radius: 9
                                    color: opacitySlider.pressed ? Theme.accentPressed : opacitySlider.hovered ? Theme.accentHover : Theme.accent
                                    border.color: Theme.surface; border.width: 2
                                }
                            }
                            Text { text: tr("Opaque"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
                            Text { text: Math.round(opacitySlider.value) + "%"; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; Layout.preferredWidth: 40 }
                        }

                        SGroupTitle { text: tr("Mod List Colors") }
                        SCheck { text: tr("Color mod background instead of text") }
                    }
                }

                // === Tab 9: Launch State ===
                Flickable {
                    contentHeight: lsCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: lsCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("Main Window") }
                        SRadio { text: tr("Normal (centered)") }
                        SRadio { text: tr("Maximized"); checked: true }
                        SRadio { text: tr("Custom size") }
                        RowLayout { spacing: 8
                            Text { text: tr("Width:"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                            SpinBox { from: 400; to: 3840; value: 900; stepSize: 50 }
                            Text { text: tr("Height:"); color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                            SpinBox { from: 300; to: 2160; value: 600; stepSize: 50 }
                        }

                        SGroupTitle { text: tr("Browser Window") }
                        SRadio { text: tr("Normal") }
                        SRadio { text: tr("Maximized"); checked: true }
                    }
                }

                // === Tab 10: Authentication ===
                Flickable {
                    contentHeight: authCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: authCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("GitHub Authentication") }
                        SDesc { text: tr("A GitHub personal access token increases API rate limits for database operations.") }
                        SPathField { placeholderText: tr("GitHub personal access token..."); echoMode: TextInput.Password }

                        SGroupTitle { text: tr("Steam Web API") }
                        SDesc { text: tr("Steam Web API key for accessing Workshop data. Get one at steamcommunity.com/dev/apikey") }
                        SPathField { placeholderText: tr("Steam Web API key..."); echoMode: TextInput.Password }
                    }
                }

                // === Tab 11: Advanced ===
                Flickable {
                    contentHeight: advCol.implicitHeight + 32; clip: true; boundsBehavior: Flickable.StopAtBounds
                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                    ColumnLayout {
                        id: advCol; anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                        anchors.margins: 20; spacing: 12

                        SGroupTitle { text: tr("Debug") }
                        SCheck { text: tr("Enable debug logging") }
                        SCheck { text: tr("Show warnings for version mismatches") }

                        SGroupTitle { text: tr("Mod List Behavior") }
                        SCheck { text: tr("Constrain dialogues to main window monitor") }
                        SCheck { text: tr("Auto-update community databases on refresh") }

                        SGroupTitle { text: tr("File Watcher") }
                        SCheck { text: tr("Enable file system watcher for mod changes") }
                        SDesc { text: tr("Automatically refreshes mod lists when files are added or removed.") }

                        SGroupTitle { text: tr("Danger Zone") }
                        RowLayout { spacing: 8
                            SBtn { text: tr("Reset All Settings"); Layout.alignment: Qt.AlignLeft
                                onClicked: settings.resetDefaults()
                                background: Rectangle { radius: 6; color: parent.hovered ? "#B52E31" : Theme.danger; Behavior on color { ColorAnimation { duration: 80 } } }
                                contentItem: Text { text: parent.text; color: "white"; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                            }
                        }
                    }
                }
            }
        }

        // Footer
        Rectangle {
            Layout.fillWidth: true; height: 56; color: "transparent"
            Rectangle { anchors.top: parent.top; width: parent.width; height: 1; color: Theme.borderSubtle }
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 20; anchors.rightMargin: 20
                SBtn { text: tr("Reset to Defaults"); onClicked: settings.resetDefaults() }
                Item { Layout.fillWidth: true }
                SBtn { text: tr("Cancel"); onClicked: settingsPopup.close() }
                SBtn { text: "OK"; accent: true; onClicked: { settings.save(); settingsPopup.close() } }
            }
        }
    }

    // ---- Reusable inline components ----

    component SGroupTitle: ColumnLayout {
        property alias text: titleText.text
        Layout.fillWidth: true; spacing: 4
        Text { id: titleText; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.DemiBold }
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle }
    }

    component SDesc: Text {
        Layout.fillWidth: true; wrapMode: Text.Wrap
        color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall
    }

    component SPathField: TextField {
        Layout.fillWidth: true; implicitHeight: 36
        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall
        color: Theme.textPrimary; selectByMouse: true
        background: Rectangle { radius: 6; color: Theme.card; border.color: parent.activeFocus ? Theme.accent : Theme.border; border.width: parent.activeFocus ? 2 : 1; Behavior on border.color { ColorAnimation { duration: 120 } } }
    }

    component SCheck: CheckBox {
        Layout.fillWidth: true
        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
        indicator: Rectangle {
            implicitWidth: 18; implicitHeight: 18; x: 0; y: (parent.height - height) / 2
            radius: 4; border.color: parent.checked ? Theme.accent : "#C0C0C0"; color: parent.checked ? Theme.accent : Theme.card
            Behavior on color { ColorAnimation { duration: 80 } }
            Text { anchors.centerIn: parent; text: "✓"; color: "white"; font.pixelSize: 12; visible: parent.parent.checked }
        }
        contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; verticalAlignment: Text.AlignVCenter; leftPadding: parent.indicator.width + 8 }
    }

    component SRadio: RadioButton {
        Layout.fillWidth: true
        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
        indicator: Rectangle {
            implicitWidth: 18; implicitHeight: 18; x: 0; y: (parent.height - height) / 2
            radius: 9; border.color: parent.checked ? Theme.accent : "#C0C0C0"; border.width: 2; color: Theme.card
            Rectangle { anchors.centerIn: parent; width: 8; height: 8; radius: 4; color: Theme.accent; visible: parent.parent.checked }
        }
        contentItem: Text { text: parent.text; color: Theme.textPrimary; font: parent.font; verticalAlignment: Text.AlignVCenter; leftPadding: parent.indicator.width + 8 }
    }

    component SBtn: Button {
        property bool accent: false
        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
        implicitHeight: 34; leftPadding: 16; rightPadding: 16
        background: Rectangle {
            radius: 6
            color: parent.accent ? (parent.pressed ? Theme.accentPressed : parent.hovered ? Theme.accentHover : Theme.accent) : (parent.pressed ? "#EBEBEB" : parent.hovered ? Theme.hover : Theme.card)
            border.color: parent.accent ? "transparent" : (parent.hovered ? "#C0C0C0" : Theme.border); border.width: parent.accent ? 0 : 1
            Behavior on color { ColorAnimation { duration: 80 } }
        }
        contentItem: Text { text: parent.text; color: parent.accent ? "white" : Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
    }
}
