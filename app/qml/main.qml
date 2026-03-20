import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import QtCore
import RimSort.Style
import "components"

ApplicationWindow {
    id: root
    visible: true
    width: Screen.width * 0.75
    height: Screen.height * 0.8
    x: (Screen.width - width) / 2
    y: (Screen.height - height) / 2
    title: root.tr("RimTidy")
    color: Theme.background

    // Force palette to follow app theme (prevents system dark mode bleeding in)
    palette.window: Theme.surface
    palette.windowText: Theme.textPrimary
    palette.base: Theme.card
    palette.alternateBase: Theme.background
    palette.text: Theme.textPrimary
    palette.button: Theme.card
    palette.buttonText: Theme.textPrimary
    palette.highlight: Theme.accent
    palette.highlightedText: "#FFFFFF"
    palette.mid: Theme.border
    palette.light: Theme.hover
    palette.dark: Theme.border

    flags: Qt.Window | Qt.FramelessWindowHint

    property bool _showTranslationStatus: false
    // Expose i18n.t as a root function so inline components/popups can access it
    function tr(key) { return i18n ? i18n.t(key) : key }
    property int resizeMargin: 6

    // Sync custom background from settings on changes
    Connections {
        target: settings
        function onSettingsChanged() {
            if (settings.customBackground)
                Theme.customBackground = "file:///" + settings.customBackground
            else
                Theme.customBackground = ""
            Theme.panelOpacity = settings.panelOpacity
        }
    }

    // Resize edges
    MouseArea { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: resizeMargin; cursorShape: Qt.SizeVerCursor; onPressed: root.startSystemResize(Qt.TopEdge) }
    MouseArea { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: resizeMargin; cursorShape: Qt.SizeVerCursor; onPressed: root.startSystemResize(Qt.BottomEdge) }
    MouseArea { anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: resizeMargin; cursorShape: Qt.SizeHorCursor; onPressed: root.startSystemResize(Qt.LeftEdge) }
    MouseArea { anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: parent.bottom; width: resizeMargin; cursorShape: Qt.SizeHorCursor; onPressed: root.startSystemResize(Qt.RightEdge) }
    MouseArea { anchors.bottom: parent.bottom; anchors.right: parent.right; width: resizeMargin*2; height: resizeMargin*2; cursorShape: Qt.SizeFDiagCursor; onPressed: root.startSystemResize(Qt.BottomEdge | Qt.RightEdge) }
    MouseArea { anchors.bottom: parent.bottom; anchors.left: parent.left; width: resizeMargin*2; height: resizeMargin*2; cursorShape: Qt.SizeBDiagCursor; onPressed: root.startSystemResize(Qt.BottomEdge | Qt.LeftEdge) }

    // Custom background image
    Image {
        id: bgImage
        anchors.fill: parent
        source: Theme.customBackground
        fillMode: Image.PreserveAspectCrop
        visible: Theme.customBackground !== ""
        z: -1
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Title bar
        CustomTitleBar {
            Layout.fillWidth: true
            title: "RimTidy"
            targetWindow: root
        }

        // Menu bar
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: menuBarRow.implicitHeight + 4
            color: Theme.surface
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.borderSubtle }

            MenuBar {
                id: menuBarRow
                anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter

                background: Rectangle { color: "transparent" }

                delegate: MenuBarItem {
                    id: menuBarItem
                    contentItem: Text {
                        text: menuBarItem.text; color: Theme.textPrimary
                        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                        horizontalAlignment: Text.AlignLeft; verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: Theme.borderRadiusSmall
                        color: menuBarItem.highlighted ? Theme.hover : "transparent"
                    }
                }

                Menu {
                    title: root.tr("File")
                    HoverMenuItem { text: root.tr("Open Mod List..."); shortcut: "Ctrl+O"; tip: root.tr("从 XML/RWS 文件导入 Mod 列表"); onTriggered: menuActions.openModList() }
                    MenuSeparator {}
                    HoverMenuItem { text: root.tr("Save Mod List As..."); shortcut: "Ctrl+Shift+S"; tip: root.tr("将当前激活 Mod 列表导出为 XML 文件"); onTriggered: menuActions.saveModListAs() }
                    MenuSeparator {}
                    Menu {
                        title: root.tr("Import")
                        HoverMenuItem { text: root.tr("From Rentry.co"); tip: root.tr("从 Rentry.co 链接导入 Mod 列表"); onTriggered: menuActions.importFromRentry() }
                        HoverMenuItem { text: root.tr("From Workshop Collection"); tip: root.tr("从 Steam 创意工坊合集 URL 导入"); onTriggered: menuActions.importFromWorkshopCollection() }
                        HoverMenuItem { text: root.tr("From Save File..."); tip: root.tr("从 RimWorld 存档文件提取 Mod 列表"); onTriggered: menuActions.importFromSaveFile() }
                    }
                    Menu {
                        title: root.tr("Export")
                        HoverMenuItem { text: root.tr("To Clipboard..."); tip: root.tr("复制 Mod 列表报告到剪贴板（含名称和链接）"); onTriggered: menuActions.exportToClipboard() }
                        HoverMenuItem { text: root.tr("To Rentry.co..."); tip: root.tr("上传 Mod 列表到 Rentry.co 分享"); onTriggered: menuActions.exportToRentry() }
                    }
                    MenuSeparator {}
                    Menu {
                        title: root.tr("Open...")
                        Menu {
                            title: "RimTidy"
                            HoverMenuItem { text: root.tr("Root Directory"); tip: root.tr("打开 RimTidy 程序所在目录"); onTriggered: menuActions.openAppDirectory() }
                            HoverMenuItem { text: root.tr("Config Directory"); tip: root.tr("打开 RimTidy 配置存储目录"); onTriggered: menuActions.openSettingsDirectory() }
                            HoverMenuItem { text: root.tr("Logs Directory"); tip: root.tr("打开 RimTidy 日志目录"); onTriggered: menuActions.openRimSortLogsDirectory() }
                        }
                        Menu {
                            title: "RimWorld"
                            HoverMenuItem { text: root.tr("Root Directory"); tip: root.tr("打开 RimWorld 游戏安装目录"); onTriggered: menuActions.openRimWorldDirectory() }
                            HoverMenuItem { text: root.tr("Config Directory"); tip: root.tr("打开 RimWorld 配置目录"); onTriggered: menuActions.openRimWorldConfigDirectory() }
                            HoverMenuItem { text: root.tr("Logs Directory"); tip: root.tr("打开 RimWorld 日志目录"); onTriggered: menuActions.openRimWorldLogsDirectory() }
                            HoverMenuItem { text: root.tr("Local Mods Directory"); tip: root.tr("打开本地 Mod 安装目录"); onTriggered: menuActions.openLocalModsDirectory() }
                            HoverMenuItem { text: root.tr("Steam Mods Directory"); tip: root.tr("打开 Steam 创意工坊 Mod 目录"); onTriggered: menuActions.openSteamModsDirectory() }
                        }
                    }
                    MenuSeparator {}
                    HoverMenuItem { text: root.tr("Settings..."); shortcut: "Ctrl+,"; tip: root.tr("打开应用设置"); onTriggered: settingsLoader.active = true }
                    MenuSeparator {}
                    HoverMenuItem { text: root.tr("Exit"); shortcut: "Ctrl+Q"; tip: root.tr("退出 RimTidy"); onTriggered: menuActions.quit() }
                }

                Menu {
                    title: root.tr("Edit")
                    HoverMenuItem { text: root.tr("Cut"); shortcut: "Ctrl+X"; tip: root.tr("使用拖拽或双击移动 Mod"); onTriggered: menuActions.cut() }
                    HoverMenuItem { text: root.tr("Copy"); shortcut: "Ctrl+C"; tip: root.tr("右键 Mod → 剪贴板 → 复制包 ID"); onTriggered: menuActions.copy() }
                    HoverMenuItem { text: root.tr("Paste"); shortcut: "Ctrl+V"; tip: root.tr("使用拖拽或双击添加 Mod"); onTriggered: menuActions.paste() }
                    MenuSeparator {}
                    HoverMenuItem { text: root.tr("Rule Editor..."); tip: root.tr("编辑 Mod 排序规则（加载顺序）"); onTriggered: menuActions.openRuleEditor() }
                    HoverMenuItem { text: root.tr("Ignore JSON Editor..."); tip: root.tr("管理已忽略警告的 Mod 列表"); onTriggered: menuActions.openIgnoreJsonEditor() }
                    HoverMenuItem { text: root.tr("Reset Warning Toggles"); tip: root.tr("重置所有 Mod 的警告屏蔽状态"); onTriggered: menuActions.resetAllWarnings() }
                    HoverMenuItem { text: root.tr("Reset Mod Colors"); tip: root.tr("清除所有 Mod 的自定义颜色"); onTriggered: menuActions.resetAllModColors() }
                }

                Menu {
                    title: root.tr("View")
                    Action {
                        id: translationStatusAction
                        text: root.tr("Show Translation Status"); checkable: true
                        onToggled: {
                            root._showTranslationStatus = checked
                        }
                    }
                    MenuSeparator {}
                    Action {
                        text: Theme.mode === "light" ? root.tr("Dark Mode") : root.tr("Light Mode")
                        shortcut: "Ctrl+Shift+D"
                        onTriggered: Theme.toggleMode()
                    }
                }

                Menu {
                    title: root.tr("Download")
                    HoverMenuItem { text: root.tr("Add Git Mod"); tip: root.tr("从 Git 仓库克隆 Mod 到本地目录"); onTriggered: menuActions.addGitMod() }
                    HoverMenuItem { text: root.tr("Add Zip Mod"); tip: root.tr("从 Zip 压缩包安装 Mod"); onTriggered: menuActions.addZipMod() }
                    MenuSeparator {}
                    HoverMenuItem { text: root.tr("Browse Workshop"); tip: root.tr("在浏览器中打开 Steam 创意工坊"); onTriggered: menuActions.browseWorkshop() }
                    HoverMenuItem { text: root.tr("Update Workshop Mods"); tip: root.tr("通过 Steam 验证并更新创意工坊 Mod"); onTriggered: menuActions.updateWorkshopMods() }
                    MenuSeparator {}
                    HoverMenuItem { text: root.tr("Verify Game Files"); tip: root.tr("通过 Steam 验证 RimWorld 游戏文件完整性"); onTriggered: menuActions.verifyGameFiles() }
                }

                Menu {
                    title: root.tr("Instances")
                    HoverMenuItem { text: root.tr("Backup Instance..."); tip: root.tr("将当前实例配置备份为 Zip 文件"); onTriggered: menuActions.backupInstance() }
                    HoverMenuItem { text: root.tr("Restore Instance..."); tip: root.tr("从备份文件恢复实例"); onTriggered: menuActions.restoreInstance() }
                    MenuSeparator {}
                    HoverMenuItem { text: root.tr("Clone Instance..."); tip: root.tr("复制当前实例为新实例"); onTriggered: menuActions.cloneInstance() }
                    HoverMenuItem { text: root.tr("Create Instance..."); tip: root.tr("创建一个全新的空实例"); onTriggered: menuActions.createInstance() }
                    HoverMenuItem { text: root.tr("Delete Instance..."); tip: root.tr("删除当前实例（不可恢复）"); onTriggered: menuActions.deleteInstance() }
                }

                Menu {
                    title: root.tr("Textures")
                    HoverMenuItem { text: root.tr("Optimize Active Mods Textures"); tip: root.tr("仅优化已激活 Mod 的纹理"); onTriggered: menuActions.optimizeActiveModsTextures() }
                    HoverMenuItem { text: root.tr("Optimize Inactive Mods Textures"); tip: root.tr("仅优化未激活 Mod 的纹理"); onTriggered: menuActions.optimizeInactiveModsTextures() }
                    HoverMenuItem { text: root.tr("Optimize All Mods Textures"); tip: root.tr("优化所有 Mod 的纹理"); onTriggered: menuActions.optimizeAllModsTextures() }
                    MenuSeparator {}
                    HoverMenuItem { text: root.tr("Delete .dds Textures"); tip: root.tr("使用 todds 删除所有 .dds 纹理文件"); onTriggered: menuActions.deleteDdsTextures() }
                    HoverMenuItem { text: root.tr("Delete Generated .dds Only"); tip: root.tr("仅删除优化生成的 .dds 文件（保留 Mod 原始 DDS）"); onTriggered: menuActions.deleteGeneratedDdsOnly() }
                }

                Menu {
                    title: root.tr("Update")
                    HoverMenuItem { text: root.tr("Check for Updates..."); tip: root.tr("检查 RimTidy 是否有新版本"); onTriggered: menuActions.checkForUpdates() }
                }

                Menu {
                    title: root.tr("Help")
                    HoverMenuItem { text: root.tr("RimTidy Wiki..."); tip: root.tr("打开 RimTidy 使用文档"); onTriggered: menuActions.openWiki() }
                    HoverMenuItem { text: root.tr("RimTidy GitHub..."); tip: root.tr("打开 RimTidy 源代码仓库"); onTriggered: menuActions.openGitHub() }
                }
            }
        }

        // Tab bar + content
        TabBar {
            id: tabBar
            Layout.fillWidth: true
            background: Rectangle { color: Theme.surface }

            Repeater {
                model: [root.tr("Main Content"), root.tr("ACF Log Reader"), root.tr("Player Log"), root.tr("File Search"), root.tr("Troubleshooting")]
                delegate: TabButton {
                    text: modelData
                    width: implicitWidth
                    font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                    contentItem: Text {
                        text: parent.text; color: tabBar.currentIndex === index ? Theme.accent : Theme.textSecondary
                        font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                        Behavior on color { ColorAnimation { duration: 120 } }
                    }
                    background: Rectangle {
                        color: "transparent"
                        Rectangle {
                            anchors.bottom: parent.bottom; width: parent.width; height: 2
                            color: tabBar.currentIndex === index ? Theme.accent : "transparent"
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }
                    }
                }
            }
        }
        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle }

        // Stacked content
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: tabBar.currentIndex

            // Tab 0: Main Content
            Item {

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 6

                // Left: Mod Info Panel
                Rectangle {
                    id: modInfoPanel
                    Layout.fillHeight: true
                    Layout.preferredWidth: parent.width * 0.35
                    radius: Theme.borderRadius
                    color: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, Theme.panelOpacity)
                    border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, Theme.panelOpacity); border.width: 1
                    clip: true

                    // Safe property accessors (modInfo may be null initially)
                    // Root-level properties accessible by all children via modInfoPanel.xxx
                    property string miCurrentUuid: ""   // UUID of currently displayed mod
                    property string miPreview: ""
                    property string miName: ""
                    property string miPackageId: ""
                    property string miAuthors: ""
                    property string miModVersion: ""
                    property string miSupportedVersions: ""
                    property string miFolderSize: ""
                    property string miModPath: ""
                    property string miLastTouched: ""
                    property string miFilesystemTime: ""
                    property string miExternalTimes: ""
                    property string miDescription: ""
                    property bool miIsScenario: false
                    property string miScenarioSummary: ""

                    Connections {
                        target: modInfo
                        function onInfoChanged() {
                            // Save note for previous mod before switching
                            if (modInfoPanel.miCurrentUuid && modInfoPanel.miPackageId) {
                                root._setModNote(modInfoPanel.miPackageId, notesArea.text)
                            }
                            modInfoPanel.miCurrentUuid = modInfo.uuid
                            modInfoPanel.miPreview = modInfo.previewImage
                            modInfoPanel.miName = modInfo.name
                            modInfoPanel.miPackageId = modInfo.packageId
                            modInfoPanel.miAuthors = modInfo.authors
                            modInfoPanel.miModVersion = modInfo.modVersion
                            modInfoPanel.miSupportedVersions = modInfo.supportedVersions
                            modInfoPanel.miFolderSize = modInfo.folderSize
                            modInfoPanel.miModPath = modInfo.modPath
                            modInfoPanel.miLastTouched = modInfo.lastTouched
                            modInfoPanel.miFilesystemTime = modInfo.filesystemTime
                            modInfoPanel.miExternalTimes = modInfo.externalTimes
                            modInfoPanel.miDescription = modInfo.description
                            modInfoPanel.miIsScenario = modInfo.isScenario
                            modInfoPanel.miScenarioSummary = modInfo.scenarioSummary
                            // Load note for newly selected mod
                            notesArea.text = root._getModNote(modInfo.packageId)
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 8

                        // Preview image
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: parent.height * 0.30
                            color: "transparent"; radius: Theme.borderRadiusSmall
                            Image {
                                anchors.fill: parent
                                source: modInfoPanel.miPreview
                                fillMode: Image.PreserveAspectFit
                                asynchronous: true
                                visible: modInfoPanel.miPreview !== ""
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: modInfoPanel.miPreview === "" && modInfoPanel.miName === ""
                                text: "RimTidy"
                                color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: 24; font.weight: Font.Bold
                                opacity: 0.3
                            }
                            Text {
                                anchors.centerIn: parent
                                visible: modInfoPanel.miPreview === "" && modInfoPanel.miName !== ""
                                text: root.tr("No Preview")
                                color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                            }
                        }

                        // Separator
                        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle }

                        // Metadata grid
                        Flickable {
                            Layout.fillWidth: true; Layout.preferredHeight: parent.height * 0.25
                            contentHeight: metaCol.implicitHeight; clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: 4; radius: 2; color: "#C0C0C0" } }

                            Column {
                                id: metaCol; width: parent.width; spacing: 4

                                ModInfoRow { label: root.tr("Name"); value: modInfoPanel.miName; visible: modInfoPanel.miName !== "" }
                                ModInfoRow { label: root.tr("PackageID"); value: modInfoPanel.miPackageId; visible: modInfoPanel.miPackageId !== "" && !modInfoPanel.miIsScenario }
                                ModInfoRow { label: root.tr("Authors"); value: modInfoPanel.miAuthors; visible: modInfoPanel.miAuthors !== "" && !modInfoPanel.miIsScenario }
                                ModInfoRow { label: root.tr("Version"); value: modInfoPanel.miModVersion; visible: modInfoPanel.miModVersion !== "" && !modInfoPanel.miIsScenario }
                                ModInfoRow { label: root.tr("Supported"); value: modInfoPanel.miSupportedVersions; visible: modInfoPanel.miSupportedVersions !== "" && !modInfoPanel.miIsScenario }
                                ModInfoRow { label: root.tr("Size"); value: modInfoPanel.miFolderSize; visible: modInfoPanel.miFolderSize !== "" && !modInfoPanel.miIsScenario }

                                // Path (clickable)
                                Row {
                                    width: parent.width; spacing: 4
                                    visible: modInfoPanel.miModPath !== ""
                                    Text { width: parent.width * 0.25; text: root.tr("Path"); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                                    Text {
                                        width: parent.width * 0.74; text: modInfoPanel.miModPath; color: Theme.accent
                                        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.underline: true
                                        elide: Text.ElideMiddle; wrapMode: Text.NoWrap
                                        MouseArea {
                                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                            onClicked: { if (modInfo) modInfo.openFolder(modInfoPanel.miModPath) }
                                        }
                                    }
                                }

                                ModInfoRow { label: root.tr("Last Touched"); value: modInfoPanel.miLastTouched; visible: modInfoPanel.miLastTouched !== "" && !modInfoPanel.miIsScenario }
                                ModInfoRow { label: root.tr("Modified"); value: modInfoPanel.miFilesystemTime; visible: modInfoPanel.miFilesystemTime !== "" && !modInfoPanel.miIsScenario }
                                ModInfoRow { label: root.tr("Workshop"); value: modInfoPanel.miExternalTimes; visible: modInfoPanel.miExternalTimes !== "" && !modInfoPanel.miIsScenario }

                                ModInfoRow { label: root.tr("Summary"); value: modInfoPanel.miScenarioSummary; visible: modInfoPanel.miIsScenario && modInfoPanel.miScenarioSummary !== "" }
                            }
                        }

                        // Separator
                        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle; visible: modInfoPanel.miName !== "" }

                        // User notes
                        Rectangle {
                            Layout.fillWidth: true; Layout.preferredHeight: parent.height * 0.12
                            visible: modInfoPanel.miName !== ""
                            radius: Theme.borderRadiusSmall; color: Theme.surface; border.color: notesArea.activeFocus ? Theme.accent : Theme.border; border.width: 1
                            Behavior on border.color { ColorAnimation { duration: 120 } }
                            TextArea {
                                id: notesArea
                                anchors.fill: parent; anchors.margins: 4
                                placeholderText: root.tr("Personal notes...")
                                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textPrimary; wrapMode: TextEdit.Wrap
                                background: null
                            }
                        }

                        // Separator
                        Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle }

                        // Description
                        Flickable {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            contentHeight: descText.implicitHeight; clip: true
                            boundsBehavior: Flickable.StopAtBounds
                            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: 4; radius: 2; color: "#C0C0C0" } }

                            TextArea {
                                id: descText; width: parent.width
                                readOnly: true; textFormat: TextEdit.RichText; wrapMode: TextEdit.Wrap
                                text: modInfoPanel.miDescription || "<center><br><br>Welcome to RimTidy!</center>"
                                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall
                                color: Theme.textPrimary
                                background: null
                            }
                        }
                    }
                }

                // Inline component: metadata label-value row
                component ModInfoRow: Row {
                    property string label: ""
                    property string value: ""
                    width: parent.width; spacing: 4
                    Text { width: parent.width * 0.25; text: label; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.Medium }
                    Text { width: parent.width * 0.74; text: value; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; wrapMode: Text.Wrap }
                }

                // Right: Mod lists (side by side: inactive left, active right)
                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    spacing: 6

                    // Two lists side by side
                    RowLayout {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        spacing: 6

                        // Left: Inactive mods
                        ColumnLayout {
                            Layout.fillHeight: true; Layout.fillWidth: true; Layout.preferredWidth: 1; spacing: 4
                            RowLayout {
                                Layout.fillWidth: true; spacing: 4
                                Rectangle {
                                    Layout.fillWidth: true; height: 36; radius: Theme.borderRadius; color: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, Theme.panelOpacity)
                                    border.color: searchInactive.activeFocus ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, Theme.panelOpacity)
                                    border.width: searchInactive.activeFocus ? 2 : 1
                                    Behavior on border.color { ColorAnimation { duration: 120 } }
                                    TextInput {
                                        id: searchInactive; anchors.fill: parent; anchors.margins: 8
                                        verticalAlignment: TextInput.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                                        color: Theme.textPrimary; clip: true; selectByMouse: true
                                        Text { anchors.fill: parent; verticalAlignment: Text.AlignVCenter; text: root.tr("Search inactive..."); color: Theme.textTertiary; font: parent.font; visible: !parent.text && !parent.activeFocus }
                                    }
                                }
                                // Data source filter
                                StyledComboBox {
                                    id: inactiveSourceFilter
                                    implicitWidth: 80; implicitHeight: 36
                                    model: ["All", "Local", "Steam", "DLC"]
                                }
                            }
                            // Sort combobox + warnings filter + new folder button
                            RowLayout {
                                Layout.fillWidth: true; spacing: 4
                                StyledComboBox {
                                    id: inactiveSortCombo
                                    implicitWidth: 100; implicitHeight: 30
                                    model: ["Name (A-Z)", "Name (Z-A)", "Author", "Package ID"]
                                    onCurrentIndexChanged: {
                                        if (!inactiveModsModel) return
                                        var uuids = inactiveModsModel.getUuids()
                                        if (typeof appBridge !== 'undefined' && appBridge.isInitialized()) {
                                            var sorted = appBridge.sortInactiveMods(uuids, currentIndex)
                                            if (sorted.length > 0) inactiveModsModel.populate(sorted)
                                        }
                                    }
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: root.tr("Only Show Warnings/Errors")
                                    color: warningsOnlyBtn.active ? "#E6A817" : Theme.textSecondary
                                    font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall
                                    verticalAlignment: Text.AlignVCenter
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: warningsOnlyBtn.active = !warningsOnlyBtn.active }
                                }
                                Button {
                                    id: warningsOnlyBtn
                                    property bool active: false
                                    implicitWidth: 30; implicitHeight: 30
                                    background: Rectangle {
                                        radius: 6
                                        color: warningsOnlyBtn.active ? (Theme.mode === "dark" ? "#5C3D08" : "#FFF3CD") : warningsOnlyBtn.pressed ? "#EBEBEB" : warningsOnlyBtn.hovered ? Theme.hover : Theme.card
                                        border.color: warningsOnlyBtn.active ? "#E6A817" : warningsOnlyBtn.hovered ? "#C0C0C0" : Theme.border; border.width: 1
                                        Behavior on color { ColorAnimation { duration: 80 } }
                                    }
                                    contentItem: Text {
                                        text: "⚠"; color: warningsOnlyBtn.active ? "#E6A817" : Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 14
                                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: active = !active
                                }
                                Button {
                                    id: newFolderBtn
                                    implicitWidth: 36; implicitHeight: 30
                                    font.family: Theme.fontFamily; font.pixelSize: 16; font.weight: Font.Bold
                                    ToolTip.visible: hovered; ToolTip.text: root.tr("New Folder"); ToolTip.delay: 400
                                    background: Rectangle {
                                        radius: 6
                                        color: newFolderBtn.pressed ? "#EBEBEB" : newFolderBtn.hovered ? Theme.hover : Theme.card
                                        border.color: newFolderBtn.hovered ? "#C0C0C0" : Theme.border; border.width: 1
                                        Behavior on color { ColorAnimation { duration: 80 } }
                                    }
                                    contentItem: Text {
                                        text: "+"; color: Theme.textPrimary; font: parent.font
                                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: root._createFolder()
                                }
                            }

                            // ---- Folder-aware inactive mod list ----
                            Rectangle {
                                id: inactiveCard
                                Layout.fillWidth: true; Layout.fillHeight: true
                                radius: Theme.borderRadius; color: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, Theme.panelOpacity)
                                border.color: _dragging && _dragSourceList !== "inactive" && inactiveCardMa.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, Theme.panelOpacity)
                                border.width: _dragging && _dragSourceList !== "inactive" && inactiveCardMa.containsMouse ? 2 : 1
                                Behavior on border.color { ColorAnimation { duration: 100 } }

                                property string listKey: "inactive"
                                property var listModel: inactiveModsModel   // for _finishDrag compat
                                property var otherModel: activeModsModel

                                MouseArea { id: inactiveCardMa; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }

                                ColumnLayout {
                                    anchors.fill: parent; anchors.margins: 1; spacing: 0

                                    // Header
                                    Rectangle {
                                        Layout.fillWidth: true; height: 28; color: "transparent"
                                        Text {
                                            anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                            text: {
                                                var _dep = _inactiveProxyModel.count  // binding dependency: re-eval on proxy change
                                                var total = inactiveModsModel ? inactiveModsModel.rowCount() : 0
                                                if (searchInactive.text) {
                                                    var shown = 0
                                                    for (var i = 0; i < inactiveLv.count; i++) {
                                                        var item = inactiveLv.itemAtIndex(i)
                                                        if (item && item.visible) shown++
                                                    }
                                                    return root.tr("Inactive Mods") + " [" + shown + "/" + total + "]"
                                                }
                                                return root.tr("Inactive Mods") + " (" + total + ")"
                                            }
                                            color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.DemiBold
                                        }
                                    }
                                    Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle }

                                    ListView {
                                        id: inactiveLv
                                        Layout.fillWidth: true; Layout.fillHeight: true
                                        clip: true; model: _inactiveProxyModel
                                        boundsBehavior: Flickable.StopAtBounds
                                        footer: Item { width: 1; height: 60 }  // Drop zone to move mods out of folders
                                        flickDeceleration: 3000; maximumFlickVelocity: 0
                                        interactive: !_dragging
                                        focus: true; keyNavigationEnabled: true
                                        MouseArea {
                                            anchors.fill: parent; enabled: _dragging; z: 100
                                            hoverEnabled: true
                                            acceptedButtons: Qt.LeftButton
                                            onPositionChanged: function(mouse) {
                                                if (_dragging) {
                                                    var gp = mapToGlobal(mouse.x, mouse.y)
                                                    _dragPos = root.contentItem.mapFromGlobal(gp.x, gp.y)
                                                }
                                            }
                                            onReleased: function(mouse) {
                                                if (_dragging) {
                                                    var gp = mapToGlobal(mouse.x, mouse.y)
                                                    if (_dragFolderId !== "") {
                                                        root._finishFolderDrag(gp)
                                                    } else {
                                                        root._finishDrag(gp, inactiveCard)
                                                    }
                                                }
                                            }
                                            onWheel: function(wheel) {
                                                var step = wheel.angleDelta.y > 0 ? -90 : 90
                                                inactiveLv.contentY = Math.max(0, Math.min(inactiveLv.contentY + step, inactiveLv.contentHeight - inactiveLv.height))
                                            }
                                        }

                                        Keys.onReturnPressed: {
                                            if (currentIndex >= 0) {
                                                var it = _inactiveProxyModel.get(currentIndex)
                                                if (it && it.itemType === "mod") transferMod(currentIndex, it.uuid)
                                                else if (it && it.itemType === "folder") root._toggleFolderExpanded(it.folderId)
                                            }
                                        }
                                        Keys.onSpacePressed: {
                                            if (currentIndex >= 0) {
                                                var it2 = _inactiveProxyModel.get(currentIndex)
                                                if (it2 && it2.itemType === "mod") transferMod(currentIndex, it2.uuid)
                                                else if (it2 && it2.itemType === "folder") root._toggleFolderExpanded(it2.folderId)
                                            }
                                        }

                                        function transferMod(idx, modUuid) {
                                            if (!modUuid) return
                                            inactiveModsModel.removeByUuids([modUuid])
                                            activeModsModel.insertUuids([modUuid], -1)
                                            root.refreshErrorsWarnings()
                                        }

                                        // Drop indicator line
                                        Rectangle {
                                            id: inactiveDropLine; visible: {
                                                if (!_dragging || _dragSourceList !== "inactive" || _dragFolderId !== "") return false
                                                // Hide when cursor leaves the inactive list area
                                                var gp = root.contentItem.mapToGlobal(_dragPos.x, _dragPos.y)
                                                var lp = inactiveCard.mapFromGlobal(gp.x, gp.y)
                                                return lp.x >= 0 && lp.x <= inactiveCard.width && lp.y >= 0 && lp.y <= inactiveCard.height
                                            }
                                            width: parent.width - 16; height: 2; radius: 1; color: Theme.accent; x: 8; z: 10
                                            y: {
                                                if (!visible) return 0
                                                var globalPos = root.contentItem.mapToGlobal(_dragPos.x, _dragPos.y)
                                                var lvLocal = inactiveLv.mapFromGlobal(globalPos.x, globalPos.y)
                                                var idx = Math.round((lvLocal.y + inactiveLv.contentY) / 30)
                                                if (idx < 0) idx = 0
                                                // Clamp to visible item count (use proxy model data, not itemAtIndex which returns null outside viewport)
                                                var visItems = 0
                                                var filterText = searchInactive.text ? searchInactive.text.toLowerCase() : ""
                                                for (var ci = 0; ci < _inactiveProxyModel.count; ci++) {
                                                    var cItem = _inactiveProxyModel.get(ci)
                                                    if (cItem.itemType === "folder") { visItems++; continue }
                                                    if (filterText && cItem.name.toLowerCase().indexOf(filterText) < 0) continue
                                                    visItems++
                                                }
                                                if (idx > visItems) idx = visItems
                                                return idx * 30 - inactiveLv.contentY
                                            }
                                        }

                                        delegate: Item {
                                            id: proxyDelegate
                                            required property int index
                                            required property string itemType
                                            required property string uuid
                                            required property string name
                                            required property string folderId
                                            required property string folderName
                                            required property bool folderExpanded
                                            required property int folderModCount
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
                                            required property string modColor
                                            required property bool isNew
                                            required property bool inSave

                                            property bool isMod: itemType === "mod"
                                            property bool isFolder: itemType === "folder"
                                            property bool matchesFilter: {
                                                if (isFolder) return true
                                                if (searchInactive.text && !name.toLowerCase().includes(searchInactive.text.toLowerCase())) return false
                                                if (inactiveSourceFilter.currentText === "Local" && dataSource !== "local") return false
                                                if (inactiveSourceFilter.currentText === "Steam" && dataSource !== "workshop") return false
                                                if (inactiveSourceFilter.currentText === "DLC" && dataSource !== "expansion") return false
                                                // Warnings/errors only filter
                                                if (warningsOnlyBtn.active && errors === "" && warnings === "" && !invalid) return false
                                                return true
                                            }

                                            width: inactiveLv.width; height: matchesFilter ? 30 : 0
                                            visible: matchesFilter; clip: true

                                            // ==== Folder header ====
                                            Rectangle {
                                                visible: proxyDelegate.isFolder
                                                anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4
                                                radius: 5
                                                color: {
                                                    if (inactiveLv.currentIndex === proxyDelegate.index) return Theme.selectionActive
                                                    if (folderHdrMa.containsMouse) return Theme.hover
                                                    return Theme.withPanelAlpha(Theme.mode === "dark" ? "#2A2D32" : "#ECEDF0")
                                                }
                                                Behavior on color { ColorAnimation { duration: 80 } }

                                                MouseArea {
                                                    id: folderHdrMa; anchors.fill: parent; hoverEnabled: true
                                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                    property point pressPos: Qt.point(0, 0)
                                                    property bool didDrag: false
                                                    onPressed: function(mouse) {
                                                        if (mouse.button === Qt.RightButton) { folderCtxMenu.popup(); return }
                                                        pressPos = Qt.point(mouse.x, mouse.y); didDrag = false
                                                    }
                                                    onPositionChanged: function(mouse) {
                                                        if (!pressed || root._renamingFolderId === proxyDelegate.folderId) return
                                                        var dx = mouse.x - pressPos.x; var dy = mouse.y - pressPos.y
                                                        if (!_dragging && (dx*dx + dy*dy > 100)) {
                                                            _dragging = true; _dragFolderId = proxyDelegate.folderId
                                                            _dragName = "\uD83D\uDCC1 " + proxyDelegate.folderName; _dragSourceList = "inactive"
                                                            _dragUuid = ""
                                                        }
                                                        if (_dragging) {
                                                            var gp = folderHdrMa.mapToGlobal(mouse.x, mouse.y)
                                                            _dragPos = root.contentItem.mapFromGlobal(gp.x, gp.y)
                                                            didDrag = true
                                                        }
                                                    }
                                                    onReleased: function(mouse) {
                                                        if (mouse.button === Qt.RightButton) return
                                                        if (_dragging && _dragFolderId !== "") {
                                                            var gp = folderHdrMa.mapToGlobal(mouse.x, mouse.y)
                                                            root._finishFolderDrag(gp)
                                                        } else if (!didDrag) {
                                                            inactiveLv.currentIndex = proxyDelegate.index
                                                        }
                                                    }
                                                    onDoubleClicked: root._toggleFolderExpanded(proxyDelegate.folderId)
                                                }

                                                RowLayout {
                                                    anchors.fill: parent; anchors.leftMargin: 6; anchors.rightMargin: 8; spacing: 4

                                                    // Expand/collapse arrow
                                                    Text {
                                                        text: proxyDelegate.folderExpanded ? "\u25BC" : "\u25B6"
                                                        color: Theme.textSecondary; font.pixelSize: 9
                                                        Layout.alignment: Qt.AlignVCenter
                                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root._toggleFolderExpanded(proxyDelegate.folderId) }
                                                    }

                                                    // Folder icon
                                                    Text { text: "\uD83D\uDCC1"; font.pixelSize: 13; Layout.alignment: Qt.AlignVCenter }

                                                    // Folder name (display or edit)
                                                    Text {
                                                        id: folderNameLabel
                                                        visible: root._renamingFolderId !== proxyDelegate.folderId
                                                        Layout.fillWidth: true
                                                        text: proxyDelegate.folderName; color: Theme.textPrimary
                                                        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Medium
                                                        elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                                                    }
                                                    Rectangle {
                                                        visible: root._renamingFolderId === proxyDelegate.folderId
                                                        Layout.fillWidth: true; Layout.preferredHeight: 22
                                                        Layout.alignment: Qt.AlignVCenter
                                                        radius: 3; color: Theme.mode === "dark" ? "#3A3D42" : "#FFFFFF"
                                                        border.color: Theme.accent; border.width: 1
                                                        TextInput {
                                                            id: folderRenameInput
                                                            anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4
                                                            verticalAlignment: TextInput.AlignVCenter
                                                            text: proxyDelegate.folderName; color: Theme.textPrimary
                                                            font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                                                            selectByMouse: true; clip: true
                                                            onAccepted: root._renameFolder(proxyDelegate.folderId, text)
                                                            Keys.onEscapePressed: { root._renamingFolderId = "" }
                                                            onActiveFocusChanged: {
                                                                if (!activeFocus && visible && root._renamingFolderId === proxyDelegate.folderId)
                                                                    root._renameFolder(proxyDelegate.folderId, text)
                                                            }
                                                            onVisibleChanged: {
                                                                if (visible) { text = proxyDelegate.folderName; forceActiveFocus(); selectAll() }
                                                            }
                                                        }
                                                    }

                                                    // Mod count
                                                    Text {
                                                        text: "(" + proxyDelegate.folderModCount + ")"
                                                        color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall
                                                        Layout.alignment: Qt.AlignVCenter
                                                    }
                                                }

                                                // Folder right-click menu
                                                Menu {
                                                    id: folderCtxMenu
                                                    MenuItem { text: root.tr("Rename"); onTriggered: { root._renamingFolderId = proxyDelegate.folderId } }
                                                    MenuSeparator {}
                                                    MenuItem { text: root.tr("Delete folder"); onTriggered: root._deleteFolder(proxyDelegate.folderId) }
                                                }
                                            }

                                            // ==== Mod item ====
                                            Rectangle {
                                                visible: proxyDelegate.isMod
                                                anchors.fill: parent
                                                anchors.leftMargin: proxyDelegate.folderId !== "" ? 20 : 4
                                                anchors.rightMargin: 4
                                                radius: 5
                                                color: {
                                                    if (_dragging && _dragUuid === proxyDelegate.uuid) return Theme.selection
                                                    if (inactiveLv.currentIndex === proxyDelegate.index) return Theme.selectionActive
                                                    if (inactiveModMa.containsMouse) return Theme.hover
                                                    if (proxyDelegate.errors !== "") return Theme.withPanelAlpha(Theme.mode === "dark" ? "#3D1518" : "#FDE8E8")
                                                    if (proxyDelegate.warnings !== "") return Theme.withPanelAlpha(Theme.mode === "dark" ? "#3D2E08" : "#FFF8E1")
                                                    if (proxyDelegate.invalid) return Theme.withPanelAlpha(Theme.mode === "dark" ? "#3D1518" : "#FDE8E8")
                                                    return Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, Theme.panelOpacity)
                                                }
                                                Behavior on color { ColorAnimation { duration: 100 } }

                                                MouseArea {
                                                    id: inactiveModMa; anchors.fill: parent; hoverEnabled: true
                                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                                    property point pressPos: Qt.point(0, 0)
                                                    property bool didDrag: false

                                                    onPressed: function(mouse) {
                                                        if (mouse.button === Qt.RightButton) {
                                                            inactiveLv.currentIndex = proxyDelegate.index
                                                            var info = contextMenu.getModMenuInfo(proxyDelegate.uuid)
                                                            inactiveModCtxMenu.targetUuid = proxyDelegate.uuid
                                                            inactiveModCtxMenu.modName = info.name || ""
                                                            inactiveModCtxMenu.modPath = info.path || ""
                                                            inactiveModCtxMenu.hasUrl = info.hasUrl || false
                                                            inactiveModCtxMenu.hasSteamUri = info.hasSteamUri || false
                                                            inactiveModCtxMenu.packageId = info.packageid || ""
                                                            inactiveModCtxMenu.popup()
                                                            return
                                                        }
                                                        pressPos = Qt.point(mouse.x, mouse.y); didDrag = false
                                                    }
                                                    onPositionChanged: function(mouse) {
                                                        if (!pressed || mouse.button === Qt.RightButton) return
                                                        var dx = mouse.x - pressPos.x; var dy = mouse.y - pressPos.y
                                                        if (!_dragging && (dx*dx + dy*dy > 100)) {
                                                            _dragging = true; _dragUuid = proxyDelegate.uuid
                                                            _dragName = proxyDelegate.name; _dragSourceList = "inactive"
                                                        }
                                                        if (_dragging) {
                                                            var gp = inactiveModMa.mapToGlobal(mouse.x, mouse.y)
                                                            _dragPos = root.contentItem.mapFromGlobal(gp.x, gp.y)
                                                            didDrag = true
                                                        }
                                                    }
                                                    onReleased: function(mouse) {
                                                        if (mouse.button === Qt.RightButton) return
                                                        if (_dragging) {
                                                            var gp = inactiveModMa.mapToGlobal(mouse.x, mouse.y)
                                                            _finishDrag(gp, inactiveCard)
                                                        } else if (!didDrag) {
                                                            inactiveLv.currentIndex = proxyDelegate.index
                                                            if (typeof modInfo !== "undefined" && modInfo) modInfo.displayModInfo(proxyDelegate.uuid)
                                                        }
                                                    }
                                                    onDoubleClicked: { if (!_dragging) inactiveLv.transferMod(proxyDelegate.index, proxyDelegate.uuid) }

                                                    // Mod context menu
                                                    Menu {
                                                        id: inactiveModCtxMenu
                                                        property string targetUuid: ""
                                                        property string modName: ""
                                                        property string modPath: ""
                                                        property bool hasUrl: false
                                                        property bool hasSteamUri: false
                                                        property string packageId: ""

                                                        MenuItem { text: root.tr("Open folder"); onTriggered: contextMenu.openModFolder(inactiveModCtxMenu.targetUuid) }
                                                        MenuItem { text: root.tr("Open folder in text editor"); onTriggered: contextMenu.openModFolderInEditor(inactiveModCtxMenu.targetUuid) }
                                                        MenuSeparator {}
                                                        MenuItem { text: root.tr("Change mod color"); onTriggered: contextMenu.changeModColor(inactiveModCtxMenu.targetUuid) }
                                                        MenuItem { text: root.tr("Reset mod color"); onTriggered: contextMenu.resetModColor(inactiveModCtxMenu.targetUuid) }
                                                        MenuSeparator {}
                                                        MenuItem { text: root.tr("Open URL in browser"); visible: inactiveModCtxMenu.hasUrl; height: visible ? implicitHeight : 0; onTriggered: contextMenu.openModUrl(inactiveModCtxMenu.targetUuid) }
                                                        MenuItem { text: root.tr("Open mod in Steam"); visible: inactiveModCtxMenu.hasSteamUri; height: visible ? implicitHeight : 0; onTriggered: contextMenu.openModInSteam(inactiveModCtxMenu.targetUuid) }
                                                        MenuSeparator {}
                                                        MenuItem { text: root.tr("Toggle warning suppression"); onTriggered: contextMenu.toggleWarning(inactiveModCtxMenu.targetUuid) }
                                                        MenuSeparator {}
                                                        Menu {
                                                            title: root.tr("Move to folder")
                                                            MenuItem { text: root.tr("(No folder)"); onTriggered: root._removeModFromFolder(inactiveModCtxMenu.targetUuid) }
                                                            Repeater {
                                                                model: root._folders.length
                                                                MenuItem {
                                                                    required property int index
                                                                    text: root._folders[index] ? root._folders[index].name : ""
                                                                    onTriggered: root._addModToFolder(inactiveModCtxMenu.targetUuid, root._folders[index].id)
                                                                }
                                                            }
                                                        }
                                                        MenuSeparator {}
                                                        Menu {
                                                            title: root.tr("Clipboard")
                                                            MenuItem { text: root.tr("Copy Package ID"); onTriggered: contextMenu.copyPackageIdToClipboard(inactiveModCtxMenu.targetUuid) }
                                                            MenuItem { text: root.tr("Copy URL"); visible: inactiveModCtxMenu.hasUrl; height: visible ? implicitHeight : 0; onTriggered: contextMenu.copyUrlToClipboard(inactiveModCtxMenu.targetUuid) }
                                                        }
                                                        Menu {
                                                            title: root.tr("Miscellaneous")
                                                            MenuItem { text: root.tr("Edit mod rules"); onTriggered: contextMenu.editModRules(inactiveModCtxMenu.targetUuid) }
                                                        }
                                                        Menu {
                                                            title: root.tr("Workshop options")
                                                            MenuItem { text: root.tr("Re-download with git"); onTriggered: contextMenu.redownloadGitMod(inactiveModCtxMenu.targetUuid) }
                                                            MenuItem { text: root.tr("Re-download with SteamCMD"); onTriggered: contextMenu.redownloadSteamcmdMod(inactiveModCtxMenu.targetUuid) }
                                                            MenuItem { text: root.tr("Re-subscribe with Steam"); visible: proxyDelegate.dataSource === "workshop"; height: visible ? implicitHeight : 0; onTriggered: contextMenu.resubscribeSteamMod(inactiveModCtxMenu.targetUuid) }
                                                            MenuItem { text: root.tr("Unsubscribe with Steam"); visible: proxyDelegate.dataSource === "workshop"; height: visible ? implicitHeight : 0; onTriggered: contextMenu.unsubscribeSteamMod(inactiveModCtxMenu.targetUuid) }
                                                        }
                                                        MenuSeparator {}
                                                        MenuItem { text: root.tr("Activate mod"); onTriggered: inactiveLv.transferMod(proxyDelegate.index, proxyDelegate.uuid) }
                                                        MenuSeparator {}
                                                        MenuItem {
                                                            text: root.tr("Delete mod")
                                                            onTriggered: { contextMenu.deleteModFolder(inactiveModCtxMenu.targetUuid); inactiveModsModel.removeByUuids([inactiveModCtxMenu.targetUuid]) }
                                                        }
                                                    }
                                                }

                                                RowLayout {
                                                    anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 3
                                                    Rectangle { width: 4; height: 16; radius: 2; Layout.alignment: Qt.AlignVCenter; color: proxyDelegate.dataSource === "expansion" ? "#107C10" : proxyDelegate.dataSource === "workshop" ? "#0078D4" : "#8A8A8A" }
                                                    Rectangle { visible: proxyDelegate.hasCSharp; width: 6; height: 6; radius: 3; color: "#9B59B6"; Layout.alignment: Qt.AlignVCenter }
                                                    Text { Layout.fillWidth: true; text: proxyDelegate.name; color: proxyDelegate.invalid || proxyDelegate.errorsWarnings !== "" ? Theme.danger : proxyDelegate.filtered ? Theme.textTertiary : Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter }
                                                    Text {
                                                        visible: proxyDelegate.warnings !== ""; text: "\u26A0"; color: Theme.warning; font.pixelSize: 14; Layout.alignment: Qt.AlignVCenter
                                                        MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; ToolTip.visible: containsMouse; ToolTip.text: proxyDelegate.warnings; ToolTip.delay: 300 }
                                                    }
                                                    Text {
                                                        visible: proxyDelegate.errors !== ""; text: "\u2715"; color: Theme.danger; font.pixelSize: 14; font.weight: Font.Bold; Layout.alignment: Qt.AlignVCenter
                                                        MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; ToolTip.visible: containsMouse; ToolTip.text: proxyDelegate.errors; ToolTip.delay: 300 }
                                                    }
                                                }
                                            }
                                        }

                                        Text { anchors.centerIn: parent; visible: inactiveLv.count === 0; text: root.tr("No mods"); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: 6; radius: 3; color: "#C0C0C0"; opacity: parent.active ? 1 : 0.4; Behavior on opacity { NumberAnimation { duration: 200 } } } }
                                    }
                                }
                            }
                        }

                        // Right: Active mods
                        ColumnLayout {
                            Layout.fillHeight: true; Layout.fillWidth: true; Layout.preferredWidth: 1; spacing: 4
                            RowLayout {
                                Layout.fillWidth: true; spacing: 4
                                Rectangle {
                                    Layout.fillWidth: true; height: 36; radius: Theme.borderRadius; color: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, Theme.panelOpacity)
                                    border.color: searchActive.activeFocus ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, Theme.panelOpacity)
                                    border.width: searchActive.activeFocus ? 2 : 1
                                    Behavior on border.color { ColorAnimation { duration: 120 } }
                                    TextInput {
                                        id: searchActive; anchors.fill: parent; anchors.margins: 8
                                        verticalAlignment: TextInput.AlignVCenter; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                                        color: Theme.textPrimary; clip: true; selectByMouse: true
                                        Text { anchors.fill: parent; verticalAlignment: Text.AlignVCenter; text: root.tr("Search active..."); color: Theme.textTertiary; font: parent.font; visible: !parent.text && !parent.activeFocus }
                                    }
                                }
                                StyledComboBox {
                                    id: activeSourceFilter
                                    implicitWidth: 80; implicitHeight: 36
                                    model: ["All", "Local", "Steam", "DLC"]
                                }
                            }
                            // Warnings/errors filter for active mods
                            RowLayout {
                                Layout.fillWidth: true; spacing: 4; implicitHeight: 30
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: root.tr("Only Show Warnings/Errors")
                                    color: activeWarningsOnlyBtn.active ? "#E6A817" : Theme.textSecondary
                                    font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall
                                    verticalAlignment: Text.AlignVCenter
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: activeWarningsOnlyBtn.active = !activeWarningsOnlyBtn.active }
                                }
                                Button {
                                    id: activeWarningsOnlyBtn
                                    property bool active: false
                                    implicitWidth: 30; implicitHeight: 30
                                    background: Rectangle {
                                        radius: 6
                                        color: activeWarningsOnlyBtn.active ? (Theme.mode === "dark" ? "#5C3D08" : "#FFF3CD") : activeWarningsOnlyBtn.pressed ? "#EBEBEB" : activeWarningsOnlyBtn.hovered ? Theme.hover : Theme.card
                                        border.color: activeWarningsOnlyBtn.active ? "#E6A817" : activeWarningsOnlyBtn.hovered ? "#C0C0C0" : Theme.border; border.width: 1
                                        Behavior on color { ColorAnimation { duration: 80 } }
                                    }
                                    contentItem: Text {
                                        text: "⚠"; color: activeWarningsOnlyBtn.active ? "#E6A817" : Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: 14
                                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                                    }
                                    onClicked: active = !active
                                }
                            }
                            ModListCard {
                                Layout.fillWidth: true; Layout.fillHeight: true
                                listTitle: root.tr("Active Mods")
                                listModel: activeModsModel
                                otherModel: inactiveModsModel
                                listKey: "active"
                                filterText: searchActive.text
                                sourceFilter: activeSourceFilter.currentText
                                warningsOnly: activeWarningsOnlyBtn.active
                            }
                        }
                    }

                    // Error/Warning summary bar
                    Rectangle {
                        id: errorSummaryBar
                        Layout.fillWidth: true; height: visible ? 28 : 0; visible: false
                        radius: Theme.borderRadiusSmall; color: Theme.card; border.color: Theme.border; border.width: 1

                        property int errorCount: 0
                        property int warningCount: 0

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12; spacing: 16
                            Text { text: "⚠ " + errorSummaryBar.warningCount + " " + root.tr("warning(s)"); color: Theme.warning; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; visible: errorSummaryBar.warningCount > 0 }
                            Text { text: "✕ " + errorSummaryBar.errorCount + " " + root.tr("error(s)"); color: Theme.danger; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; visible: errorSummaryBar.errorCount > 0 }
                            Item { Layout.fillWidth: true }
                        }
                    }

                    // Game version + Buttons
                    RowLayout {
                        Layout.fillWidth: true; spacing: 8
                        Text {
                            id: gameVersionLabel
                            text: appBridge && appBridge.isInitialized() ? appBridge.getGameVersion() : ""
                            color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall
                            visible: text !== ""
                        }
                        Item { Layout.fillWidth: true }
                        ActionBtn { text: root.tr("Refresh"); onClicked: {
                            appBridge.refreshModLists()
                            var active = appBridge.getActiveModUuids()
                            var inactive = appBridge.getInactiveModUuids()
                            activeModsModel.populate(active)
                            inactiveModsModel.populate(inactive)
                            root.refreshErrorsWarnings()
                        }}
                        ActionBtn { text: root.tr("Clear"); onClicked: {
                            var lists = appBridge.getClearedLists()
                            activeModsModel.populate(lists.active)
                            inactiveModsModel.populate(lists.inactive)
                            root.refreshErrorsWarnings()
                        }}
                        ActionBtn { text: root.tr("Restore"); onClicked: {
                            var lists = appBridge.getRestoreLists()
                            if (lists.active.length > 0) {
                                activeModsModel.populate(lists.active)
                                inactiveModsModel.populate(lists.inactive)
                                root.refreshErrorsWarnings()
                            }
                        }}
                        ActionBtn { text: root.tr("Sort"); onClicked: {
                            var sorted = appBridge.sortModList(activeModsModel.getUuids())
                            if (sorted.length > 0) {
                                activeModsModel.populate(sorted)
                                var inactive = appBridge.getInactiveModUuids()
                                inactiveModsModel.populate(inactive)
                            }
                        }}
                        ActionBtn { text: root.tr("Save"); onClicked: appBridge.saveModList(activeModsModel.getUuids()) }
                        ActionBtn { text: root.tr("Save As"); onClicked: savePresetDialog.open() }
                        ActionBtn { text: root.tr("Load"); onClicked: { loadPresetDialog.refreshList(); loadPresetDialog.open() } }
                        ActionBtn { text: root.tr("Run"); accent: true; onClicked: appBridge.runGame() }
                    }
                }
            }
            } // end Tab 0 Item

            // Tab 1: ACF Log Reader
            Loader { source: "tabs/AcfLogReaderTab.qml" }

            // Tab 2: Player Log
            Loader { source: "tabs/PlayerLogTab.qml" }

            // Tab 3: File Search
            Loader { source: "tabs/FileSearchTab.qml" }

            // Tab 4: Troubleshooting
            Loader { source: "tabs/TroubleshootingTab.qml" }
        }

        // Status bar
        StatusBar { Layout.fillWidth: true; message: statusBar.message }
    }

    // Inline component: A mod list card with header and ListView
    component ActionBtn: Button {
        property bool accent: false
        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
        implicitWidth: 90; implicitHeight: 32
        background: Rectangle {
            radius: 6
            color: parent.accent ? (parent.pressed ? Theme.accentPressed : parent.hovered ? Theme.accentHover : Theme.accent) : (parent.pressed ? "#EBEBEB" : parent.hovered ? Theme.hover : Theme.card)
            border.color: parent.accent ? "transparent" : (parent.hovered ? "#C0C0C0" : Theme.border); border.width: parent.accent ? 0 : 1
            Behavior on color { ColorAnimation { duration: 80 } }
        }
        contentItem: Text { text: parent.text; color: parent.accent ? "white" : Theme.textPrimary; font: parent.font; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
    }

    // ---- Global drag state (shared between lists) ----
    property bool _dragging: false
    property string _dragUuid: ""
    property string _dragName: ""
    property string _dragSourceList: ""
    property point _dragPos: Qt.point(0, 0)
    property string _dragFolderId: ""  // non-empty when dragging a folder

    // Floating ghost label that follows cursor during drag
    Rectangle {
        id: dragGhost; visible: _dragging; z: 1000
        x: _dragPos.x + 12; y: _dragPos.y + 4
        width: ghostText.implicitWidth + 20; height: 26; radius: 5
        color: _dragFolderId !== "" ? Theme.mode === "dark" ? "#2A2D32" : "#ECEDF0" : Theme.accent; opacity: 0.85
        Text { id: ghostText; anchors.centerIn: parent; text: _dragName; color: _dragFolderId !== "" ? Theme.textPrimary : "white"; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall }
    }

    // ---- Folder state for inactive mod categorization (QML-only, does not affect Python/mod files) ----
    property var _folders: []              // [{id: string, name: string, expanded: bool, modUuids: [string]}]
    property var _modFolderMemory: ({})    // uuid → folderId (remembers folder when mod goes to active)
    property int _folderIdCounter: 0
    property string _renamingFolderId: ""  // folder currently being renamed ("" = none)
    ListModel { id: _inactiveProxyModel }

    // Persistence via QSettings (Windows: registry, Linux/macOS: config file)
    Settings {
        id: folderSettings
        category: "InactiveModFolders"
        property string foldersJson: "[]"
        property string memoryJson: "{}"
        property int idCounter: 0
    }

    // Convert UUID ↔ packageId for persistence (UUIDs are regenerated each session)
    function _uuidToPackageId(uuid) {
        if (!inactiveModsModel) return ""
        var allUuids = inactiveModsModel.getUuids()
        var idx = allUuids.indexOf(uuid)
        if (idx < 0) return ""
        return inactiveModsModel.data(inactiveModsModel.index(idx, 0), _R_PackageId) || ""
    }

    function _buildPackageIdToUuidMap() {
        var map = {}
        // Include both inactive and active mods so memory survives restart
        // when a mod is currently in the active list
        var models = [inactiveModsModel, activeModsModel]
        for (var m = 0; m < models.length; m++) {
            if (!models[m]) continue
            var allUuids = models[m].getUuids()
            for (var i = 0; i < allUuids.length; i++) {
                var pid = models[m].data(models[m].index(i, 0), _R_PackageId) || ""
                if (pid !== "" && !map[pid]) map[pid] = allUuids[i]
            }
        }
        return map
    }

    function _saveFolderState() {
        // Save with packageIds instead of UUIDs
        var persistFolders = []
        for (var i = 0; i < _folders.length; i++) {
            var f = _folders[i]
            var pids = []
            for (var j = 0; j < f.modUuids.length; j++) {
                var pid = _uuidToPackageId(f.modUuids[j])
                if (pid !== "") pids.push(pid)
            }
            persistFolders.push({ id: f.id, name: f.name, expanded: f.expanded, modPackageIds: pids })
        }
        // Save memory as packageId → folderId
        var persistMemory = {}
        for (var uuid in _modFolderMemory) {
            var memPid = _uuidToPackageId(uuid)
            if (memPid !== "") persistMemory[memPid] = _modFolderMemory[uuid]
        }
        folderSettings.foldersJson = JSON.stringify(persistFolders)
        folderSettings.memoryJson = JSON.stringify(persistMemory)
        folderSettings.idCounter = _folderIdCounter
    }

    function _loadFolderState() {
        _folderIdCounter = folderSettings.idCounter || 0
        // Folders and memory are loaded as packageId-based; conversion to UUID
        // happens in _resolveLoadedFolders() after inactiveModsModel is populated.
        try {
            var raw = JSON.parse(folderSettings.foldersJson)
            if (Array.isArray(raw)) root._pendingFolderData = raw
        } catch(e) { root._pendingFolderData = [] }
        try {
            var rawMem = JSON.parse(folderSettings.memoryJson)
            if (rawMem && typeof rawMem === "object") root._pendingMemoryData = rawMem
        } catch(e) { root._pendingMemoryData = {} }
    }

    // Called after inactiveModsModel is populated to resolve packageIds → UUIDs
    function _resolveLoadedFolders() {
        var pending = root._pendingFolderData
        if (!pending || pending.length === 0) return
        var pidMap = _buildPackageIdToUuidMap()
        var folders = []
        for (var i = 0; i < pending.length; i++) {
            var pf = pending[i]
            var uuids = []
            var pids = pf.modPackageIds || pf.modUuids || []  // backwards compat: try modUuids too
            for (var j = 0; j < pids.length; j++) {
                var resolved = pidMap[pids[j]]
                if (resolved) uuids.push(resolved)
            }
            folders.push({ id: pf.id, name: pf.name, expanded: pf.expanded, modUuids: uuids })
        }
        _folders = folders

        // Resolve memory
        var rawMem = root._pendingMemoryData || {}
        var mem = {}
        for (var pid in rawMem) {
            var resolvedUuid = pidMap[pid]
            if (resolvedUuid) mem[resolvedUuid] = rawMem[pid]
        }
        _modFolderMemory = mem

        root._pendingFolderData = []
        root._pendingMemoryData = {}
        _rebuildInactiveProxy()
    }

    property var _pendingFolderData: []
    property var _pendingMemoryData: ({})

    // ---- Theme persistence ----
    Settings {
        id: themeSettings
        category: "Theme"
        property string mode: "light"
        property string scheme: "default"
    }
    Component.onDestruction: {
        themeSettings.mode = Theme.mode
        themeSettings.scheme = Theme.scheme
    }

    // ---- Per-mod user notes (keyed by packageId for persistence) ----
    property var _modNotes: ({})   // packageId → note text

    Settings {
        id: notesSettings
        category: "ModNotes"
        property string notesJson: "{}"
    }

    function _saveModNotes() {
        notesSettings.notesJson = JSON.stringify(_modNotes)
    }

    function _loadModNotes() {
        try {
            var n = JSON.parse(notesSettings.notesJson)
            if (n && typeof n === "object") _modNotes = n
        } catch(e) { _modNotes = {} }
    }

    function _getModNote(packageId) {
        return _modNotes[packageId] || ""
    }

    function _setModNote(packageId, text) {
        if (!packageId) return
        var n = Object.assign({}, _modNotes)
        if (text && text.trim() !== "") {
            n[packageId] = text
        } else {
            delete n[packageId]
        }
        _modNotes = n
        _saveModNotes()
    }

    // Role ID constants (must match ModListRoles in mod_list_model.py)
    readonly property int _R_Name: 258
    readonly property int _R_PackageId: 259
    readonly property int _R_DataSource: 260
    readonly property int _R_HasCSharp: 261
    readonly property int _R_HasGit: 263
    readonly property int _R_HasSteamcmd: 264
    readonly property int _R_Errors: 265
    readonly property int _R_Warnings: 266
    readonly property int _R_ErrorsWarnings: 267
    readonly property int _R_Filtered: 268
    readonly property int _R_Invalid: 269
    readonly property int _R_ModColor: 272
    readonly property int _R_IsNew: 273
    readonly property int _R_InSave: 274

    component ModListCard: Rectangle {
        id: cardRoot
        radius: Theme.borderRadius
        color: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, Theme.panelOpacity)
        border.color: _dragging && _dragSourceList !== listKey && cardMa.containsMouse ? Theme.accent : Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, Theme.panelOpacity)
        border.width: _dragging && _dragSourceList !== listKey && cardMa.containsMouse ? 2 : 1
        Behavior on border.color { ColorAnimation { duration: 100 } }

        property string listTitle: "Mods"
        property var listModel: null
        property var otherModel: null
        property string listKey: ""
        property string filterText: ""
        property string sourceFilter: "All"
        property bool warningsOnly: false

        // Calculate model insertion index from global mouse position,
        // accounting for filtered (hidden) items.
        function getDropModelIndex(globalY) {
            var localPos = lv.mapFromGlobal(0, globalY)
            var rawY = localPos.y + lv.contentY
            var visibleIdx = Math.round(rawY / 30)
            if (visibleIdx < 0) visibleIdx = 0
            // No filter active — visible index == model index
            var hasFilter = cardRoot.filterText || cardRoot.sourceFilter !== "All" || cardRoot.warningsOnly
            if (!hasFilter) {
                if (visibleIdx > lv.count) visibleIdx = lv.count
                return visibleIdx
            }
            // Map visible index to model index using model data (not itemAtIndex,
            // which returns null for delegates outside the viewport).
            var ft = cardRoot.filterText ? cardRoot.filterText.toLowerCase() : ""
            var count = 0
            for (var i = 0; i < lv.count; i++) {
                var idx = listModel.index(i, 0)
                var name = listModel.data(idx, 258) || ""       // NameRole = UserRole+2
                var ds = listModel.data(idx, 260) || ""         // DataSourceRole = UserRole+4
                var errs = listModel.data(idx, 265) || ""       // ErrorsRole = UserRole+9
                var warns = listModel.data(idx, 266) || ""      // WarningsRole = UserRole+10
                var inv = listModel.data(idx, 269) || false     // InvalidRole = UserRole+13
                // Replicate matchesFilter logic
                var vis = true
                if (ft && name.toLowerCase().indexOf(ft) < 0) vis = false
                if (vis && cardRoot.sourceFilter === "Local" && ds !== "local") vis = false
                if (vis && cardRoot.sourceFilter === "Steam" && ds !== "workshop") vis = false
                if (vis && cardRoot.sourceFilter === "DLC" && ds !== "expansion") vis = false
                if (vis && cardRoot.warningsOnly && errs === "" && warns === "" && !inv) vis = false
                if (vis) {
                    if (count === visibleIdx) return i
                    count++
                }
            }
            return lv.count  // append
        }

        // Invisible MouseArea to detect drops on this card
        MouseArea {
            id: cardMa; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton
        }

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 1; spacing: 0

            Rectangle {
                Layout.fillWidth: true; height: 28; color: "transparent"
                Text {
                    anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                    text: {
                        var total = listModel ? listModel.rowCount() : 0
                        var visible = lv.count
                        // Count visible items when filtering
                        if (cardRoot.filterText) {
                            var shown = 0
                            for (var i = 0; i < lv.count; i++) {
                                var item = lv.itemAtIndex(i)
                                if (item && item.visible) shown++
                            }
                            return listTitle + " [" + shown + "/" + total + "]"
                        }
                        return listTitle + " (" + total + ")"
                    }
                    color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall; font.weight: Font.DemiBold
                }
            }
            Rectangle { Layout.fillWidth: true; height: 1; color: Theme.borderSubtle }


            ListView {
                id: lv
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true; model: listModel
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 3000; maximumFlickVelocity: 2500
                interactive: !_dragging  // disable flickable during drag
                focus: true
                MouseArea {
                    anchors.fill: parent; enabled: _dragging; z: 100
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onPositionChanged: function(mouse) {
                        if (_dragging) {
                            var gp = mapToGlobal(mouse.x, mouse.y)
                            _dragPos = root.contentItem.mapFromGlobal(gp.x, gp.y)
                        }
                    }
                    onReleased: function(mouse) {
                        if (_dragging) {
                            var gp = mapToGlobal(mouse.x, mouse.y)
                            root._finishDrag(gp, cardRoot)
                        }
                    }
                    onWheel: function(wheel) {
                        var step = wheel.angleDelta.y > 0 ? -90 : 90
                        lv.contentY = Math.max(0, Math.min(lv.contentY + step, lv.contentHeight - lv.height))
                    }
                }
                keyNavigationEnabled: true

                Keys.onReturnPressed: { if (currentIndex >= 0) transferMod(currentIndex, listModel.getUuidAt(currentIndex)) }
                Keys.onSpacePressed: { if (currentIndex >= 0) transferMod(currentIndex, listModel.getUuidAt(currentIndex)) }
                Keys.onDeletePressed: { if (currentIndex >= 0) { var uuid = listModel.getUuidAt(currentIndex); contextMenu.deleteModFolder(uuid); listModel.removeByUuids([uuid]) } }

                function transferMod(idx, modUuid) {
                    if (!listModel || !otherModel) return
                    listModel.removeByUuids([modUuid])
                    otherModel.insertUuids([modUuid], -1)
                    root.refreshErrorsWarnings()
                }

                // Calculate drop index from global mouse position
                function getDropIndex(globalY) {
                    var localPos = lv.mapFromGlobal(0, globalY)
                    var idx = Math.floor((localPos.y + lv.contentY) / 30)
                    if (idx < 0) idx = 0
                    if (idx > lv.count) idx = lv.count
                    return idx
                }

                // Drop indicator line
                Rectangle {
                    id: dropLine; visible: {
                        if (!_dragging || _dragFolderId !== "") return false
                        if (_dragSourceList === cardRoot.listKey) return true
                        // Cross-list: check if cursor is over this card using _dragPos
                        var gp = root.contentItem.mapToGlobal(_dragPos.x, _dragPos.y)
                        var lp = cardRoot.mapFromGlobal(gp.x, gp.y)
                        return lp.x >= 0 && lp.x <= cardRoot.width && lp.y >= 0 && lp.y <= cardRoot.height
                    }
                    width: parent.width - 16; height: 2; radius: 1; color: Theme.accent; x: 8; z: 10
                    y: {
                        if (!visible) return 0
                        // _dragPos is relative to root.contentItem, convert to global then to lv-local
                        var globalPos = root.contentItem.mapToGlobal(_dragPos.x, _dragPos.y)
                        var lvLocal = lv.mapFromGlobal(globalPos.x, globalPos.y)
                        var rawY = lvLocal.y + lv.contentY
                        var visibleIdx = Math.round(rawY / 30)
                        if (visibleIdx < 0) visibleIdx = 0
                        // Count visible items to clamp (use model data, not itemAtIndex)
                        var hasFilter = cardRoot.filterText || cardRoot.sourceFilter !== "All" || cardRoot.warningsOnly
                        if (hasFilter) {
                            var visCount = 0
                            var _ft = cardRoot.filterText ? cardRoot.filterText.toLowerCase() : ""
                            for (var vi = 0; vi < lv.count; vi++) {
                                var _idx = listModel.index(vi, 0)
                                var _nm = (listModel.data(_idx, 258) || "").toLowerCase()
                                var _ds = listModel.data(_idx, 260) || ""
                                var _er = listModel.data(_idx, 265) || ""
                                var _wn = listModel.data(_idx, 266) || ""
                                var _iv = listModel.data(_idx, 269) || false
                                var _v = true
                                if (_ft && _nm.indexOf(_ft) < 0) _v = false
                                if (_v && cardRoot.sourceFilter === "Local" && _ds !== "local") _v = false
                                if (_v && cardRoot.sourceFilter === "Steam" && _ds !== "workshop") _v = false
                                if (_v && cardRoot.sourceFilter === "DLC" && _ds !== "expansion") _v = false
                                if (_v && cardRoot.warningsOnly && _er === "" && _wn === "" && !_iv) _v = false
                                if (_v) visCount++
                            }
                            if (visibleIdx > visCount) visibleIdx = visCount
                        } else {
                            if (visibleIdx > lv.count) visibleIdx = lv.count
                        }
                        return visibleIdx * 30 - lv.contentY
                    }
                }

                delegate: Item {
                    id: delegateItem
                    property bool matchesFilter: {
                        // Text filter
                        if (cardRoot.filterText && !name.toLowerCase().includes(cardRoot.filterText.toLowerCase())) return false
                        // Data source filter
                        if (cardRoot.sourceFilter === "Local" && dataSource !== "local") return false
                        if (cardRoot.sourceFilter === "Steam" && dataSource !== "workshop") return false
                        if (cardRoot.sourceFilter === "DLC" && dataSource !== "expansion") return false
                        // Warnings/errors only filter
                        if (cardRoot.warningsOnly && errors === "" && warnings === "" && !invalid) return false
                        return true
                    }
                    width: lv.width; height: matchesFilter ? 30 : 0
                    visible: matchesFilter; clip: true
                    required property int index
                    required property string name
                    required property string uuid
                    required property string dataSource
                    required property bool hasCSharp
                    required property string errors
                    required property string warnings
                    required property string errorsWarnings
                    required property bool filtered
                    required property bool invalid
                    required property string modColor

                    Rectangle {
                        id: delegateBg
                        anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4
                        radius: 5
                        color: {
                            if (_dragging && _dragUuid === delegateItem.uuid) return Theme.selection
                            if (lv.currentIndex === delegateItem.index) return Theme.selectionActive
                            if (dragMa.containsMouse) return Theme.hover
                            // Error/warning background tinting
                            if (delegateItem.errors !== "") return Theme.withPanelAlpha(Theme.mode === "dark" ? "#3D1518" : "#FDE8E8")
                            if (delegateItem.warnings !== "") return Theme.withPanelAlpha(Theme.mode === "dark" ? "#3D2E08" : "#FFF8E1")
                            if (delegateItem.invalid) return Theme.withPanelAlpha(Theme.mode === "dark" ? "#3D1518" : "#FDE8E8")
                            return Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, Theme.panelOpacity)
                        }
                        Behavior on color { ColorAnimation { duration: 100 } }

                        MouseArea {
                            id: dragMa; anchors.fill: parent; hoverEnabled: true
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            property point pressPos: Qt.point(0, 0)
                            property bool didDrag: false

                            onPressed: function(mouse) {
                                if (mouse.button === Qt.RightButton) {
                                    lv.currentIndex = delegateItem.index
                                    // Build context menu dynamically
                                    var info = contextMenu.getModMenuInfo(delegateItem.uuid)
                                    modContextMenu.targetUuid = delegateItem.uuid
                                    modContextMenu.modName = info.name || ""
                                    modContextMenu.modPath = info.path || ""
                                    modContextMenu.hasUrl = info.hasUrl || false
                                    modContextMenu.hasSteamUri = info.hasSteamUri || false
                                    modContextMenu.packageId = info.packageid || ""
                                    modContextMenu.popup()
                                    return
                                }
                                pressPos = Qt.point(mouse.x, mouse.y)
                                didDrag = false
                            }
                            onPositionChanged: function(mouse) {
                                if (!pressed || mouse.button === Qt.RightButton) return
                                var dx = mouse.x - pressPos.x; var dy = mouse.y - pressPos.y
                                if (!_dragging && (dx*dx + dy*dy > 100)) {
                                    _dragging = true
                                    _dragUuid = delegateItem.uuid
                                    _dragName = delegateItem.name
                                    _dragSourceList = cardRoot.listKey
                                }
                                if (_dragging) {
                                    var gp = dragMa.mapToGlobal(mouse.x, mouse.y)
                                    _dragPos = root.contentItem.mapFromGlobal(gp.x, gp.y)
                                    didDrag = true
                                }
                            }
                            onReleased: function(mouse) {
                                if (mouse.button === Qt.RightButton) return
                                if (_dragging) {
                                    var gp = dragMa.mapToGlobal(mouse.x, mouse.y)
                                    _finishDrag(gp, cardRoot)
                                } else if (!didDrag) {
                                    lv.currentIndex = delegateItem.index
                                    if (modInfo) modInfo.displayModInfo(delegateItem.uuid)
                                }
                            }
                            onDoubleClicked: {
                                if (!_dragging) lv.transferMod(delegateItem.index, delegateItem.uuid)
                            }

                            // Context menu
                            Menu {
                                id: modContextMenu
                                property string targetUuid: ""
                                property string modName: ""
                                property string modPath: ""
                                property bool hasUrl: false
                                property bool hasSteamUri: false
                                property string packageId: ""

                                MenuItem { text: root.tr("Open folder"); onTriggered: contextMenu.openModFolder(modContextMenu.targetUuid) }
                                MenuItem { text: root.tr("Open folder in text editor"); onTriggered: contextMenu.openModFolderInEditor(modContextMenu.targetUuid) }
                                MenuSeparator {}
                                MenuItem { text: root.tr("Change mod color"); onTriggered: contextMenu.changeModColor(modContextMenu.targetUuid) }
                                MenuItem { text: root.tr("Reset mod color"); onTriggered: contextMenu.resetModColor(modContextMenu.targetUuid) }
                                MenuSeparator {}
                                MenuItem { text: root.tr("Open URL in browser"); visible: modContextMenu.hasUrl; height: visible ? implicitHeight : 0; onTriggered: contextMenu.openModUrl(modContextMenu.targetUuid) }
                                MenuItem { text: root.tr("Open mod in Steam"); visible: modContextMenu.hasSteamUri; height: visible ? implicitHeight : 0; onTriggered: contextMenu.openModInSteam(modContextMenu.targetUuid) }
                                MenuSeparator {}
                                MenuItem { text: root.tr("Toggle warning suppression"); onTriggered: contextMenu.toggleWarning(modContextMenu.targetUuid) }
                                MenuSeparator {}
                                Menu {
                                    title: root.tr("Clipboard")
                                    MenuItem { text: root.tr("Copy Package ID"); onTriggered: contextMenu.copyPackageIdToClipboard(modContextMenu.targetUuid) }
                                    MenuItem { text: root.tr("Copy URL"); visible: modContextMenu.hasUrl; height: visible ? implicitHeight : 0; onTriggered: contextMenu.copyUrlToClipboard(modContextMenu.targetUuid) }
                                }
                                Menu {
                                    title: root.tr("Miscellaneous")
                                    MenuItem { text: root.tr("Edit mod rules"); onTriggered: contextMenu.editModRules(modContextMenu.targetUuid) }
                                }
                                Menu {
                                    title: root.tr("Workshop options")
                                    MenuItem { text: root.tr("Re-download with git"); onTriggered: contextMenu.redownloadGitMod(modContextMenu.targetUuid) }
                                    MenuItem { text: root.tr("Re-download with SteamCMD"); onTriggered: contextMenu.redownloadSteamcmdMod(modContextMenu.targetUuid) }
                                    MenuItem { text: root.tr("Re-subscribe with Steam"); visible: delegateItem.dataSource === "workshop"; height: visible ? implicitHeight : 0; onTriggered: contextMenu.resubscribeSteamMod(modContextMenu.targetUuid) }
                                    MenuItem { text: root.tr("Unsubscribe with Steam"); visible: delegateItem.dataSource === "workshop"; height: visible ? implicitHeight : 0; onTriggered: contextMenu.unsubscribeSteamMod(modContextMenu.targetUuid) }
                                }
                                MenuSeparator {}
                                MenuItem {
                                    text: cardRoot.listKey === "active" ? root.tr("Deactivate mod") : root.tr("Activate mod")
                                    onTriggered: lv.transferMod(delegateItem.index, delegateItem.uuid)
                                }
                                MenuSeparator {}
                                MenuItem {
                                    text: root.tr("Delete mod")
                                    onTriggered: {
                                        contextMenu.deleteModFolder(modContextMenu.targetUuid)
                                        listModel.removeByUuids([modContextMenu.targetUuid])
                                    }
                                }
                            }
                        }

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 8; anchors.rightMargin: 8; spacing: 3
                            Rectangle { width: 4; height: 16; radius: 2; Layout.alignment: Qt.AlignVCenter; color: delegateItem.dataSource === "expansion" ? "#107C10" : delegateItem.dataSource === "workshop" ? "#0078D4" : "#8A8A8A" }
                            Rectangle { visible: delegateItem.hasCSharp; width: 6; height: 6; radius: 3; color: "#9B59B6"; Layout.alignment: Qt.AlignVCenter }
                            Text { Layout.fillWidth: true; text: delegateItem.name; color: delegateItem.invalid || delegateItem.errorsWarnings !== "" ? Theme.danger : delegateItem.filtered ? Theme.textTertiary : Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter }
                            Text {
                                visible: delegateItem.warnings !== ""; text: "⚠"; color: Theme.warning; font.pixelSize: 14; Layout.alignment: Qt.AlignVCenter
                                MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; ToolTip.visible: containsMouse; ToolTip.text: delegateItem.warnings; ToolTip.delay: 300 }
                            }
                            Text {
                                visible: delegateItem.errors !== ""; text: "✕"; color: Theme.danger; font.pixelSize: 14; font.weight: Font.Bold; Layout.alignment: Qt.AlignVCenter
                                MouseArea { anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton; ToolTip.visible: containsMouse; ToolTip.text: delegateItem.errors; ToolTip.delay: 300 }
                            }
                        }
                    }
                }

                Text { anchors.centerIn: parent; visible: lv.count === 0; text: root.tr("No mods"); color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded; contentItem: Rectangle { implicitWidth: 6; radius: 3; color: "#C0C0C0"; opacity: parent.active ? 1 : 0.4; Behavior on opacity { NumberAnimation { duration: 200 } } } }
            }
        }
    }

    // Settings dialog (loaded from separate file)
    Loader {
        id: settingsLoader
        anchors.fill: parent
        active: false
        source: "dialogs/SettingsDialog.qml"
        onLoaded: item.open()
        Connections {
            target: settingsLoader.item
            function onClosed() {
                settingsLoader.active = false
                // After settings dialog closes, re-initialize or refresh mod lists
                if (typeof appBridge !== "undefined" && appBridge) {
                    if (!appBridge.isInitialized()) {
                        appBridge.initialize()
                        if (appBridge.isInitialized()) {
                            var active = appBridge.getActiveModUuids()
                            var inactive = appBridge.getInactiveModUuids()
                            inactive = appBridge.sortInactiveMods(inactive, inactiveSortCombo.currentIndex)
                            activeModsModel.populate(active)
                            inactiveModsModel.populate(inactive)
                            root.refreshErrorsWarnings()
                        }
                    } else {
                        appBridge.refreshModLists()
                        var a2 = appBridge.getActiveModUuids()
                        var i2 = appBridge.getInactiveModUuids()
                        i2 = appBridge.sortInactiveMods(i2, inactiveSortCombo.currentIndex)
                        activeModsModel.populate(a2)
                        inactiveModsModel.populate(i2)
                        root.refreshErrorsWarnings()
                    }
                }
            }
        }
    }

    // Handle drag drop completion — find which list the cursor is over (folder-aware)
    function _finishDrag(globalPos, sourceCard) {
        var uuid = _dragUuid
        var srcKey = _dragSourceList
        _dragging = false; _dragUuid = ""; _dragName = ""; _dragSourceList = ""; _dragFolderId = ""

        if (!uuid) return

        function findCards(item) {
            var cards = []
            for (var i = 0; i < item.children.length; i++) {
                var child = item.children[i]
                if (child.listKey !== undefined && child.listModel) cards.push(child)
                cards = cards.concat(findCards(child))
            }
            return cards
        }
        var allCards = findCards(root.contentItem)

        for (var i = 0; i < allCards.length; i++) {
            var card = allCards[i]
            var localPos = card.mapFromGlobal(globalPos.x, globalPos.y)
            if (localPos.x < 0 || localPos.x > card.width || localPos.y < 0 || localPos.y > card.height) continue

            if (card.listKey !== srcKey) {
                // Cross-list transfer
                // Inactive → Active: insert at mouse position
                // Active → Inactive: append (folder memory restores position)
                var crossDropIdx = -1
                if (srcKey === "inactive" && card.listKey === "active") {
                    crossDropIdx = card.getDropModelIndex(globalPos.y)
                }
                sourceCard.listModel.removeByUuids([uuid])
                card.listModel.insertUuids([uuid], crossDropIdx)
                // Active → Inactive: restore remembered folder (only if not already present)
                if (srcKey === "active" && card.listKey === "inactive") {
                    var mem = _modFolderMemory[uuid]
                    if (mem) {
                        for (var fi = 0; fi < _folders.length; fi++) {
                            if (_folders[fi].id === mem) {
                                // UUID is still in modUuids at its original position — skip re-add
                                if (_folders[fi].modUuids.indexOf(uuid) < 0) {
                                    _addModToFolder(uuid, mem)
                                }
                                break
                            }
                        }
                    }
                }
            } else if (card.listKey === "inactive") {
                // Same list: inactive — folder management via proxy index
                // Use Math.round to match the drop indicator line (insert BETWEEN rows)
                var lvLocal = inactiveLv.mapFromGlobal(globalPos.x, globalPos.y)
                var rawY = lvLocal.y + inactiveLv.contentY
                var visibleLine = Math.round(rawY / 30)  // visible row index
                if (visibleLine < 0) visibleLine = 0
                // Convert visible row index to proxy model index (skip filtered items)
                var insertLine = _inactiveProxyModel.count  // default: end
                var visCount = 0
                for (var vl = 0; vl < _inactiveProxyModel.count; vl++) {
                    var vlItem = _inactiveProxyModel.get(vl)
                    var vlVisible = true
                    if (vlItem.itemType === "mod") {
                        if (searchInactive.text && vlItem.name.toLowerCase().indexOf(searchInactive.text.toLowerCase()) < 0)
                            vlVisible = false
                    }
                    if (vlVisible) {
                        if (visCount === visibleLine) { insertLine = vl; break }
                        visCount++
                    }
                }
                if (insertLine > _inactiveProxyModel.count) insertLine = _inactiveProxyModel.count

                // Determine which folder the insert line falls into
                // insertLine N means "between row N-1 and row N"
                // Scan above and below, skipping the dragged item itself
                var targetFolderId = ""

                // If dropped below all items (in the footer zone), always remove from folder.
                // Use raw pixel position: only count as "below all" if the cursor is
                // more than half a row (15px) past the last non-dragged item's bottom edge.
                // This lets users drop INTO a trailing empty/collapsed folder while still
                // being able to drop into the blank zone further below to leave all folders.
                var effectiveCount = 0
                for (var ec = 0; ec < _inactiveProxyModel.count; ec++) {
                    var ecItem = _inactiveProxyModel.get(ec)
                    // Only count visible items (not filtered out)
                    var ecVisible = true
                    if (ecItem.itemType === "mod" && searchInactive.text && ecItem.name.toLowerCase().indexOf(searchInactive.text.toLowerCase()) < 0)
                        ecVisible = false
                    if (ecVisible && ecItem.uuid !== uuid) effectiveCount++
                }
                var contentBottom = effectiveCount * 30  // pixel Y of last visible item's bottom
                var droppedBelowAll = rawY > contentBottom + 15

                // Scan upward from insert line to find folder context
                for (var sa = insertLine - 1; !droppedBelowAll && sa >= 0; sa--) {
                    var aboveItem = _inactiveProxyModel.get(sa)
                    if (aboveItem.itemType === "mod" && aboveItem.uuid === uuid) continue  // skip self
                    if (aboveItem.itemType === "mod" && aboveItem.folderId !== "") {
                        targetFolderId = aboveItem.folderId; break
                    }
                    if (aboveItem.itemType === "folder") {
                        targetFolderId = aboveItem.folderId; break  // right below folder header
                    }
                    break  // uncategorized mod above = not in a folder
                }
                // If above is uncategorized or empty, check below
                if (targetFolderId === "" && !droppedBelowAll) {
                    for (var sb = insertLine; sb < _inactiveProxyModel.count; sb++) {
                        var belowItem = _inactiveProxyModel.get(sb)
                        if (belowItem.itemType === "mod" && belowItem.uuid === uuid) continue  // skip self
                        if (belowItem.itemType === "mod" && belowItem.folderId !== "") {
                            targetFolderId = belowItem.folderId; break
                        }
                        break  // folder header or uncategorized = not in a folder
                    }
                }

                // Find current folder of the dragged mod
                var currentFolderId = ""
                for (var cf = 0; cf < _inactiveProxyModel.count; cf++) {
                    var cfItem = _inactiveProxyModel.get(cf)
                    if (cfItem.itemType === "mod" && cfItem.uuid === uuid) { currentFolderId = cfItem.folderId; break }
                }

                if (targetFolderId !== "") {
                    // Count how many mods of this folder are above the insert line (excluding dragged)
                    var posInFolder = 0
                    for (var pi = 0; pi < insertLine; pi++) {
                        var pItem = _inactiveProxyModel.get(pi)
                        if (pItem.itemType === "mod" && pItem.folderId === targetFolderId && pItem.uuid !== uuid)
                            posInFolder++
                    }
                    _addModToFolder(uuid, targetFolderId, posInFolder)
                } else if (currentFolderId !== "") {
                    // Moving out of a folder to uncategorized
                    _removeModFromFolder(uuid)
                } else {
                    // Uncategorized mod reorder — move in the Python model directly
                    var allUuids = inactiveModsModel.getUuids()
                    var fromModelIdx = allUuids.indexOf(uuid)
                    // Count uncategorized mods above insert line (excluding dragged) to find target model index
                    var uncatAbove = 0
                    for (var ui = 0; ui < insertLine; ui++) {
                        var uItem = _inactiveProxyModel.get(ui)
                        if (uItem.itemType === "mod" && uItem.folderId === "" && uItem.uuid !== uuid)
                            uncatAbove++
                    }
                    // Find the model index of the uncatAbove-th uncategorized mod
                    var uuidToFolder2 = {}
                    for (var ff = 0; ff < _folders.length; ff++) {
                        for (var mm = 0; mm < _folders[ff].modUuids.length; mm++)
                            uuidToFolder2[_folders[ff].modUuids[mm]] = true
                    }
                    var toModelIdx = 0
                    var uncatCount = 0
                    for (var mi = 0; mi < allUuids.length; mi++) {
                        if (uuidToFolder2[allUuids[mi]]) continue
                        if (allUuids[mi] === uuid) continue
                        if (uncatCount === uncatAbove) { toModelIdx = mi; break }
                        uncatCount++
                        toModelIdx = mi + 1
                    }
                    // Adjust for downward drag: removal shifts items up by 1
                    if (fromModelIdx >= 0 && fromModelIdx < toModelIdx) toModelIdx--
                    if (fromModelIdx >= 0 && fromModelIdx !== toModelIdx) {
                        inactiveModsModel.moveItem(fromModelIdx, toModelIdx)
                        // Lightweight proxy update: move within proxy instead of full rebuild
                        var proxyFrom = -1, proxyTo = -1
                        for (var pf = 0; pf < _inactiveProxyModel.count; pf++) {
                            var pfItem = _inactiveProxyModel.get(pf)
                            if (pfItem.itemType === "mod" && pfItem.uuid === uuid) { proxyFrom = pf; break }
                        }
                        if (proxyFrom >= 0) {
                            // Find proxy target: count uncategorized visible mods
                            var pUncatSeen = 0
                            proxyTo = _inactiveProxyModel.count
                            for (var pt = 0; pt < _inactiveProxyModel.count; pt++) {
                                var ptItem = _inactiveProxyModel.get(pt)
                                if (ptItem.itemType === "mod" && ptItem.folderId === "" && ptItem.uuid !== uuid) {
                                    if (pUncatSeen === uncatAbove) { proxyTo = pt; break }
                                    pUncatSeen++
                                }
                            }
                            _inactiveProxyModel.move(proxyFrom, proxyTo, 1)
                        }
                    }
                }
            } else {
                // Same list: active — reorder (filter-aware)
                var targetIdx = card.getDropModelIndex(globalPos.y)
                var uuids = card.listModel.getUuids()
                var fromIdx = -1
                for (var k = 0; k < uuids.length; k++) { if (uuids[k] === uuid) { fromIdx = k; break } }
                if (targetIdx > uuids.length) targetIdx = uuids.length
                // When dragging down, the source removal shifts items up by 1
                if (fromIdx >= 0 && targetIdx > fromIdx) targetIdx--
                if (fromIdx >= 0 && fromIdx !== targetIdx) {
                    card.listModel.moveItem(fromIdx, targetIdx)
                }
            }
            root.refreshErrorsWarnings()
            return
        }
    }

    // Handle folder drag-drop reordering
    function _finishFolderDrag(globalPos) {
        var folderId = _dragFolderId
        _dragging = false; _dragFolderId = ""; _dragName = ""; _dragSourceList = ""; _dragUuid = ""
        if (!folderId || _folders.length < 2) return

        // Find current folder index
        var fromIdx = -1
        for (var i = 0; i < _folders.length; i++) {
            if (_folders[i].id === folderId) { fromIdx = i; break }
        }
        if (fromIdx < 0) return

        // Calculate insert line from drop position
        var lvLocal = inactiveLv.mapFromGlobal(globalPos.x, globalPos.y)
        var rawY = lvLocal.y + inactiveLv.contentY
        var insertLine = Math.round(rawY / 30)
        if (insertLine < 0) insertLine = 0
        if (insertLine > _inactiveProxyModel.count) insertLine = _inactiveProxyModel.count

        // Find all folder header positions in proxy (excluding dragged folder)
        var folderPositions = []
        for (var p = 0; p < _inactiveProxyModel.count; p++) {
            var item = _inactiveProxyModel.get(p)
            if (item.itemType === "folder" && item.folderId !== folderId) {
                folderPositions.push({folderId: item.folderId, proxyRow: p})
            }
        }

        // Determine target index: find which other folder the insert line is before
        var toIdx = _folders.length  // default: after all folders
        for (var fp = 0; fp < folderPositions.length; fp++) {
            if (folderPositions[fp].proxyRow >= insertLine) {
                for (var fi = 0; fi < _folders.length; fi++) {
                    if (_folders[fi].id === folderPositions[fp].folderId) { toIdx = fi; break }
                }
                break
            }
        }

        // Adjust for removal shift
        if (fromIdx < toIdx) toIdx--
        if (fromIdx === toIdx) return

        // Reorder _folders array
        var newFolders = _folders.slice()
        var moved = newFolders.splice(fromIdx, 1)[0]
        newFolders.splice(toIdx, 0, moved)
        _folders = newFolders

        _saveFolderState()
        _rebuildInactiveProxy()
    }

    // Debounced refresh: delay errors/warnings recomputation so rapid
    // drag-and-drop operations feel smooth. The actual heavy work runs
    // after the user stops moving mods for 300ms.
    Timer {
        id: refreshEwTimer
        interval: 300; repeat: false
        onTriggered: _doRefreshErrorsWarnings()
    }
    function refreshErrorsWarnings() {
        refreshEwTimer.restart()
    }

    // Spread the recompute across two frames to avoid a single long freeze.
    // Frame 1: active list.  Frame 2 (via Timer): inactive list + summary.
    Timer {
        id: refreshEwPhase2
        interval: 0; repeat: false  // next event-loop iteration
        onTriggered: {
            var inactiveEw = appBridge.getModErrorsWarnings(inactiveModsModel.getUuids(), "Inactive")
            if (inactiveEw) {
                var inactiveBatch = {}
                var inactiveUuids = inactiveModsModel.getUuids()
                for (var j = 0; j < inactiveUuids.length; j++)
                    inactiveBatch[inactiveUuids[j]] = {"errors": "", "warnings": "", "errors_warnings": ""}
                for (var uuid2 in inactiveEw) {
                    if (uuid2 !== "__summary__") inactiveBatch[uuid2] = inactiveEw[uuid2]
                }
                inactiveModsModel.setBatchItemMeta(inactiveBatch)
            }
            updateErrorSummary()
        }
    }
    function _doRefreshErrorsWarnings() {
        if (!appBridge || !appBridge.isInitialized()) return
        // Phase 1: active list
        var activeEw = appBridge.getModErrorsWarnings(activeModsModel.getUuids(), "Active")
        if (activeEw) {
            var activeBatch = {}
            var activeUuids = activeModsModel.getUuids()
            for (var i = 0; i < activeUuids.length; i++)
                activeBatch[activeUuids[i]] = {"errors": "", "warnings": "", "errors_warnings": ""}
            for (var uuid in activeEw) {
                if (uuid !== "__summary__") activeBatch[uuid] = activeEw[uuid]
            }
            activeModsModel.setBatchItemMeta(activeBatch)
        }
        // Phase 2: inactive list on next frame
        refreshEwPhase2.start()
    }

    // Update error summary when active model changes
    function updateErrorSummary() {
        if (!activeModsModel) return
        var errCount = 0, warnCount = 0
        for (var i = 0; i < activeModsModel.rowCount(); i++) {
            var idx = activeModsModel.index(i, 0)
            var err = activeModsModel.data(idx, 265)  // ErrorsRole = UserRole+9 = 256+9
            var warn = activeModsModel.data(idx, 266) // WarningsRole = UserRole+10 = 256+10
            if (err && err !== "") errCount++
            if (warn && warn !== "") warnCount++
        }
        errorSummaryBar.errorCount = errCount
        errorSummaryBar.warningCount = warnCount
        errorSummaryBar.visible = (errCount > 0 || warnCount > 0)
    }

    Connections {
        target: activeModsModel
        function onDataChanged() { updateErrorSummary() }
        function onModelReset() { updateErrorSummary() }
    }

    // ---- Proxy model sync: rebuild when inactive model structure changes, sync on metadata changes ----
    Connections {
        target: inactiveModsModel
        function onListUpdated() {
            // On first populate after load, resolve packageId → UUID
            if (root._pendingFolderData && root._pendingFolderData.length > 0) {
                root._resolveLoadedFolders()
            } else {
                root._rebuildInactiveProxy()
            }
        }
        function onDataChanged() { root._syncProxyMeta() }
    }

    // ---- Folder management functions ----
    function _generateFolderId() {
        _folderIdCounter++
        return "folder_" + _folderIdCounter
    }

    function _createFolder() {
        var fid = _generateFolderId()
        var f = _folders.slice()
        f.push({ id: fid, name: "New Folder", expanded: true, modUuids: [] })
        _folders = f
        _renamingFolderId = fid
        _saveFolderState()
        _rebuildInactiveProxy()
    }

    function _deleteFolder(folderId) {
        var f = _folders.slice()
        for (var i = 0; i < f.length; i++) {
            if (f[i].id === folderId) {
                var mem = Object.assign({}, _modFolderMemory)
                for (var m = 0; m < f[i].modUuids.length; m++) delete mem[f[i].modUuids[m]]
                _modFolderMemory = mem
                f.splice(i, 1)
                break
            }
        }
        _folders = f
        _saveFolderState()
        _rebuildInactiveProxy()
    }

    function _renameFolder(folderId, newName) {
        if (!newName || newName.trim() === "") newName = "New Folder"
        var f = _folders.slice()
        for (var i = 0; i < f.length; i++) {
            if (f[i].id === folderId) {
                f[i] = { id: f[i].id, name: newName.trim(), expanded: f[i].expanded, modUuids: f[i].modUuids }
                break
            }
        }
        _folders = f
        _renamingFolderId = ""
        _saveFolderState()
        _rebuildInactiveProxy()
    }

    function _toggleFolderExpanded(folderId) {
        var f = _folders.slice()
        for (var i = 0; i < f.length; i++) {
            if (f[i].id === folderId) {
                f[i] = { id: f[i].id, name: f[i].name, expanded: !f[i].expanded, modUuids: f[i].modUuids }
                break
            }
        }
        _folders = f
        _saveFolderState()
        _rebuildInactiveProxy()
    }

    function _addModToFolder(uuid, folderId, insertAt) {
        _removeModFromFolderSilent(uuid)
        var f = _folders.slice()
        for (var i = 0; i < f.length; i++) {
            if (f[i].id === folderId) {
                var mods = f[i].modUuids.slice()
                var existing = mods.indexOf(uuid)
                if (existing >= 0) mods.splice(existing, 1)
                if (insertAt !== undefined && insertAt >= 0 && insertAt <= mods.length)
                    mods.splice(insertAt, 0, uuid)
                else
                    mods.push(uuid)
                f[i] = { id: f[i].id, name: f[i].name, expanded: f[i].expanded, modUuids: mods }
                break
            }
        }
        _folders = f
        var mem = Object.assign({}, _modFolderMemory)
        mem[uuid] = folderId
        _modFolderMemory = mem
        _saveFolderState()
        _rebuildInactiveProxy()
    }

    function _removeModFromFolder(uuid) {
        _removeModFromFolderSilent(uuid)
        var mem = Object.assign({}, _modFolderMemory)
        delete mem[uuid]
        _modFolderMemory = mem
        _saveFolderState()
        _rebuildInactiveProxy()
    }

    function _removeModFromFolderSilent(uuid) {
        var f = _folders.slice()
        for (var i = 0; i < f.length; i++) {
            var idx = f[i].modUuids.indexOf(uuid)
            if (idx >= 0) {
                var mods = f[i].modUuids.slice()
                mods.splice(idx, 1)
                f[i] = { id: f[i].id, name: f[i].name, expanded: f[i].expanded, modUuids: mods }
                _folders = f
                return
            }
        }
    }

    // ---- Proxy model rebuild/sync ----
    function _rebuildInactiveProxy() {
        if (!inactiveModsModel) return

        // Save scroll position, detach model to prevent ListView from reacting during rebuild
        var savedY = inactiveLv.contentY
        inactiveLv.model = null

        _inactiveProxyModel.clear()
        var allUuids = inactiveModsModel.getUuids()

        // Build uuid→row map
        var rowMap = {}
        for (var r = 0; r < allUuids.length; r++) rowMap[allUuids[r]] = r

        // Build uuid→folderId map
        var uuidToFolder = {}
        for (var fi = 0; fi < _folders.length; fi++) {
            var folder = _folders[fi]
            for (var mi = 0; mi < folder.modUuids.length; mi++) uuidToFolder[folder.modUuids[mi]] = folder.id
        }

        // Folders first, then uncategorized
        for (var fi2 = 0; fi2 < _folders.length; fi2++) {
            var f = _folders[fi2]
            var validMods = []
            for (var vm = 0; vm < f.modUuids.length; vm++) {
                if (rowMap[f.modUuids[vm]] !== undefined) validMods.push(f.modUuids[vm])
            }
            _inactiveProxyModel.append({
                itemType: "folder", folderId: f.id, folderName: f.name,
                folderExpanded: f.expanded, folderModCount: validMods.length,
                uuid: "", name: "", packageId: "", dataSource: "",
                hasCSharp: false, hasGit: false, hasSteamcmd: false,
                errors: "", warnings: "", errorsWarnings: "",
                filtered: false, invalid: false, modColor: "",
                isNew: false, inSave: false
            })
            if (f.expanded) {
                for (var em = 0; em < validMods.length; em++) {
                    _inactiveProxyModel.append(_buildModEntry(validMods[em], f.id, rowMap))
                }
            }
        }

        // Uncategorized mods (preserving source model order)
        for (var u = 0; u < allUuids.length; u++) {
            if (!uuidToFolder[allUuids[u]])
                _inactiveProxyModel.append(_buildModEntry(allUuids[u], "", rowMap))
        }

        // Re-attach model and restore scroll position
        inactiveLv.model = _inactiveProxyModel
        var maxY = Math.max(0, _inactiveProxyModel.count * 30 - inactiveLv.height)
        inactiveLv.contentY = Math.min(savedY, maxY)
    }

    function _buildModEntry(uuid, folderId, rowMap) {
        var row = rowMap[uuid]
        if (row === undefined) return {
            itemType: "mod", folderId: folderId, uuid: uuid,
            name: "Unknown", packageId: "", dataSource: "local",
            hasCSharp: false, hasGit: false, hasSteamcmd: false,
            errors: "", warnings: "", errorsWarnings: "",
            filtered: false, invalid: false, modColor: "",
            isNew: false, inSave: false,
            folderName: "", folderExpanded: false, folderModCount: 0
        }
        var m = inactiveModsModel
        var idx = m.index(row, 0)
        return {
            itemType: "mod", folderId: folderId,
            uuid: uuid,
            name: m.data(idx, _R_Name) || "Unknown",
            packageId: m.data(idx, _R_PackageId) || "",
            dataSource: m.data(idx, _R_DataSource) || "local",
            hasCSharp: m.data(idx, _R_HasCSharp) || false,
            hasGit: m.data(idx, _R_HasGit) || false,
            hasSteamcmd: m.data(idx, _R_HasSteamcmd) || false,
            errors: m.data(idx, _R_Errors) || "",
            warnings: m.data(idx, _R_Warnings) || "",
            errorsWarnings: m.data(idx, _R_ErrorsWarnings) || "",
            filtered: m.data(idx, _R_Filtered) || false,
            invalid: m.data(idx, _R_Invalid) || false,
            modColor: m.data(idx, _R_ModColor) || "",
            isNew: m.data(idx, _R_IsNew) || false,
            inSave: m.data(idx, _R_InSave) || false,
            folderName: "", folderExpanded: false, folderModCount: 0
        }
    }

    function _syncProxyMeta() {
        if (!inactiveModsModel) return
        var allUuids = inactiveModsModel.getUuids()
        var rowMap = {}
        for (var r = 0; r < allUuids.length; r++) rowMap[allUuids[r]] = r
        var m = inactiveModsModel
        for (var i = 0; i < _inactiveProxyModel.count; i++) {
            var item = _inactiveProxyModel.get(i)
            if (item.itemType !== "mod") continue
            var row = rowMap[item.uuid]
            if (row === undefined) continue
            var idx = m.index(row, 0)
            _inactiveProxyModel.setProperty(i, "errors", m.data(idx, _R_Errors) || "")
            _inactiveProxyModel.setProperty(i, "warnings", m.data(idx, _R_Warnings) || "")
            _inactiveProxyModel.setProperty(i, "errorsWarnings", m.data(idx, _R_ErrorsWarnings) || "")
            _inactiveProxyModel.setProperty(i, "invalid", m.data(idx, _R_Invalid) || false)
            _inactiveProxyModel.setProperty(i, "modColor", m.data(idx, _R_ModColor) || "")
        }
    }

    // ---- HoverMenuItem: MenuItem with tooltip on hover ----
    component HoverMenuItem: MenuItem {
        property string tip: ""
        property string shortcut: ""
        ToolTip.visible: tip !== "" && hovered
        ToolTip.text: tip
        ToolTip.delay: 500
    }

    // ---- Styled ComboBox for theme-aware dropdowns ----
    component StyledComboBox: ComboBox {
        id: scb
        font.family: Theme.fontFamily; font.pixelSize: Theme.fontSizeSmall
        background: Rectangle {
            radius: 6; color: scb.pressed ? Theme.hover : Theme.card
            border.color: scb.activeFocus ? Theme.accent : Theme.border; border.width: 1
            Behavior on border.color { ColorAnimation { duration: 100 } }
        }
        contentItem: Text {
            leftPadding: 8; rightPadding: scb.indicator.width + 8
            text: scb.displayText; color: Theme.textPrimary; font: scb.font
            verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
        }
        indicator: Canvas {
            x: scb.width - width - 8; y: (scb.height - height) / 2
            width: 10; height: 6
            onPaint: { var ctx = getContext("2d"); ctx.fillStyle = Theme.textSecondary; ctx.beginPath(); ctx.moveTo(0, 0); ctx.lineTo(width, 0); ctx.lineTo(width/2, height); ctx.closePath(); ctx.fill() }
            Connections { target: Theme; function onModeChanged() { parent.requestPaint() } }
        }
        popup: Popup {
            y: scb.height; width: scb.width; implicitHeight: contentItem.implicitHeight + 8
            padding: 4
            background: Rectangle { color: Theme.card; radius: 8; border.color: Theme.border; border.width: 1 }
            contentItem: ListView {
                clip: true; implicitHeight: contentHeight; model: scb.popup.visible ? scb.delegateModel : null
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            }
        }
        delegate: ItemDelegate {
            width: scb.width; height: 30
            contentItem: Text { text: modelData; color: Theme.textPrimary; font: scb.font; verticalAlignment: Text.AlignVCenter; leftPadding: 8 }
            background: Rectangle { radius: 4; color: highlighted ? Theme.hover : "transparent" }
            highlighted: scb.highlightedIndex === index
        }
    }

    // ---- Save Preset Dialog ----
    Dialog {
        id: savePresetDialog
        title: root.tr("Save Mod List Preset")
        anchors.centerIn: parent
        width: 360; modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            var name = presetNameInput.text.trim()
            if (name) {
                appBridge.saveModListPreset(name, activeModsModel.getUuids())
                presetNameInput.text = ""
            }
        }
        onOpened: { presetNameInput.text = ""; presetNameInput.forceActiveFocus() }

        contentItem: ColumnLayout {
            spacing: 12
            Text {
                text: root.tr("Enter a name for this mod list:")
                color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
            }
            TextField {
                id: presetNameInput
                Layout.fillWidth: true
                placeholderText: root.tr("e.g. Combat Build")
                font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                Keys.onReturnPressed: savePresetDialog.accept()
            }
        }
    }

    // ---- Load Preset Dialog ----
    Dialog {
        id: loadPresetDialog
        title: root.tr("Load Mod List Preset")
        anchors.centerIn: parent
        width: 420; height: 400; modal: true
        standardButtons: Dialog.Close

        function refreshList() {
            presetListModel.clear()
            var presets = appBridge.listModListPresets()
            for (var i = 0; i < presets.length; i++) {
                presetListModel.append(presets[i])
            }
        }

        contentItem: ColumnLayout {
            spacing: 8

            Text {
                text: root.tr("Saved mod lists:")
                color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                visible: presetListModel.count > 0
            }
            Text {
                text: root.tr("No saved presets yet. Use 'Save As' to create one.")
                color: Theme.textTertiary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize
                visible: presetListModel.count === 0
            }

            ListView {
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true; model: presetListModel
                spacing: 4

                delegate: Rectangle {
                    width: ListView.view.width; height: 56; radius: 6
                    color: presetMa.containsMouse ? Theme.hover : Theme.card
                    border.color: Theme.border; border.width: 1
                    Behavior on color { ColorAnimation { duration: 80 } }

                    required property int index
                    required property string name
                    required property string created
                    required property string count

                    MouseArea {
                        id: presetMa; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            var uuids = appBridge.loadModListPreset(name)
                            if (uuids.length > 0) {
                                // Compute inactive = all mods minus the loaded active set
                                var activeSet = {}
                                for (var ai = 0; ai < uuids.length; ai++) activeSet[uuids[ai]] = true
                                var allMods = activeModsModel.getUuids().concat(inactiveModsModel.getUuids())
                                var inactive = []
                                var seen = {}
                                for (var ii = 0; ii < allMods.length; ii++) {
                                    if (!activeSet[allMods[ii]] && !seen[allMods[ii]]) {
                                        inactive.push(allMods[ii])
                                        seen[allMods[ii]] = true
                                    }
                                }
                                activeModsModel.populate(uuids)
                                inactiveModsModel.populate(inactive)
                                _rebuildInactiveProxy()
                                root.refreshErrorsWarnings()
                                loadPresetDialog.close()
                            }
                        }
                    }

                    RowLayout {
                        anchors.fill: parent; anchors.margins: 10; spacing: 8
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 2
                            Text {
                                text: name
                                color: Theme.textPrimary; font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize; font.weight: Font.DemiBold
                            }
                            Text {
                                text: count + " mods  |  " + created
                                color: Theme.textTertiary; font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                        // Delete button
                        Rectangle {
                            width: 28; height: 28; radius: 4
                            color: delMa.containsMouse ? Theme.danger : "transparent"
                            Text {
                                anchors.centerIn: parent; text: "\u2715"
                                color: delMa.containsMouse ? "white" : Theme.textTertiary
                                font.pixelSize: 14
                            }
                            MouseArea {
                                id: delMa; anchors.fill: parent; hoverEnabled: true
                                onClicked: {
                                    appBridge.deleteModListPreset(name)
                                    loadPresetDialog.refreshList()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    ListModel { id: presetListModel }

    Component.onCompleted: {
        if (typeof dwmHelper !== 'undefined') dwmHelper.applyRoundedCorners(root)
        // Restore theme
        Theme.mode = themeSettings.mode || "light"
        Theme.scheme = themeSettings.scheme || "default"
        // Restore custom background
        if (settings && settings.customBackground) {
            Theme.customBackground = "file:///" + settings.customBackground
            Theme.panelOpacity = settings.panelOpacity
        }
        _loadFolderState()
        _loadModNotes()
        _rebuildInactiveProxy()
    }
}
