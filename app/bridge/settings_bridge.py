"""
Bridge that exposes Settings model properties to QML.
Each setting becomes a Q_PROPERTY readable/writable from QML.
"""

from loguru import logger
from PySide6.QtCore import Property, QObject, Signal, Slot


class SettingsBridge(QObject):
    """Exposes settings as QML-bindable properties."""

    settingsChanged = Signal()
    dialogRequested = Signal()  # Emitted when settings dialog should open
    dialogClosed = Signal()  # Emitted when settings dialog closes

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._visible = False
        # Cache settings values
        self._game_location = ""
        self._config_folder = ""
        self._steam_mods_folder = ""
        self._local_mods_folder = ""
        self._instance_folder = ""
        self._theme_name = "Fluent"
        self._font_family = "Segoe UI"
        self._font_size = 13
        self._enable_themes = True
        self._steam_client_integration = False
        self._sort_method = "Topological"
        self._enable_mod_type_filter = True
        self._show_save_indicators = False
        # todds settings
        self._todds_preset = "optimized"
        self._todds_custom_command = ""
        self._todds_active_mods_target = True
        self._todds_dry_run = False
        self._todds_overwrite = False
        # Custom background settings
        self._custom_background = ""
        self._panel_opacity = 1.0

    # --- Dialog visibility ---
    visibleChanged = Signal()

    @Property(bool, notify=visibleChanged)
    def visible(self) -> bool:
        return self._visible

    @visible.setter  # type: ignore[no-redef]
    def visible(self, val: bool) -> None:
        if self._visible != val:
            self._visible = val
            self.visibleChanged.emit()

    @Slot()
    def open(self) -> None:
        self._visible = True
        self.visibleChanged.emit()
        self.dialogRequested.emit()

    @Slot()
    def close(self) -> None:
        self._visible = False
        self.visibleChanged.emit()
        self.dialogClosed.emit()

    # --- Location settings ---
    @Property(str, notify=settingsChanged)
    def gameLocation(self) -> str:
        return self._game_location

    @gameLocation.setter  # type: ignore[no-redef]
    def gameLocation(self, val: str) -> None:
        self._game_location = val
        self.settingsChanged.emit()

    @Property(str, notify=settingsChanged)
    def configFolder(self) -> str:
        return self._config_folder

    @configFolder.setter  # type: ignore[no-redef]
    def configFolder(self, val: str) -> None:
        self._config_folder = val
        self.settingsChanged.emit()

    @Property(str, notify=settingsChanged)
    def steamModsFolder(self) -> str:
        return self._steam_mods_folder

    @steamModsFolder.setter  # type: ignore[no-redef]
    def steamModsFolder(self, val: str) -> None:
        self._steam_mods_folder = val
        self.settingsChanged.emit()

    @Property(str, notify=settingsChanged)
    def localModsFolder(self) -> str:
        return self._local_mods_folder

    @localModsFolder.setter  # type: ignore[no-redef]
    def localModsFolder(self, val: str) -> None:
        self._local_mods_folder = val
        self.settingsChanged.emit()

    @Property(str, notify=settingsChanged)
    def instanceFolder(self) -> str:
        return self._instance_folder

    @instanceFolder.setter  # type: ignore[no-redef]
    def instanceFolder(self, val: str) -> None:
        self._instance_folder = val
        self.settingsChanged.emit()

    # --- Theme settings ---
    @Property(str, notify=settingsChanged)
    def themeName(self) -> str:
        return self._theme_name

    @themeName.setter  # type: ignore[no-redef]
    def themeName(self, val: str) -> None:
        self._theme_name = val
        self.settingsChanged.emit()

    @Property(str, notify=settingsChanged)
    def fontFamily(self) -> str:
        return self._font_family

    @fontFamily.setter  # type: ignore[no-redef]
    def fontFamily(self, val: str) -> None:
        self._font_family = val
        self.settingsChanged.emit()

    @Property(int, notify=settingsChanged)
    def fontSize(self) -> int:
        return self._font_size

    @fontSize.setter  # type: ignore[no-redef]
    def fontSize(self, val: int) -> None:
        self._font_size = val
        self.settingsChanged.emit()

    @Property(bool, notify=settingsChanged)
    def enableThemes(self) -> bool:
        return self._enable_themes

    @enableThemes.setter  # type: ignore[no-redef]
    def enableThemes(self, val: bool) -> None:
        self._enable_themes = val
        self.settingsChanged.emit()

    # --- General settings ---
    @Property(bool, notify=settingsChanged)
    def steamClientIntegration(self) -> bool:
        return self._steam_client_integration

    @steamClientIntegration.setter  # type: ignore[no-redef]
    def steamClientIntegration(self, val: bool) -> None:
        self._steam_client_integration = val
        self.settingsChanged.emit()

    @Property(str, notify=settingsChanged)
    def sortMethod(self) -> str:
        return self._sort_method

    @sortMethod.setter  # type: ignore[no-redef]
    def sortMethod(self, val: str) -> None:
        self._sort_method = val
        self.settingsChanged.emit()

    @Property(bool, notify=settingsChanged)
    def enableModTypeFilter(self) -> bool:
        return self._enable_mod_type_filter

    @enableModTypeFilter.setter  # type: ignore[no-redef]
    def enableModTypeFilter(self, val: bool) -> None:
        self._enable_mod_type_filter = val
        self.settingsChanged.emit()

    @Property(bool, notify=settingsChanged)
    def showSaveIndicators(self) -> bool:
        return self._show_save_indicators

    @showSaveIndicators.setter  # type: ignore[no-redef]
    def showSaveIndicators(self, val: bool) -> None:
        self._show_save_indicators = val
        self.settingsChanged.emit()

    # --- todds settings ---
    @Property(str, notify=settingsChanged)
    def toddsPreset(self) -> str:
        return self._todds_preset

    @toddsPreset.setter  # type: ignore[no-redef]
    def toddsPreset(self, val: str) -> None:
        self._todds_preset = val
        self.settingsChanged.emit()

    @Property(str, notify=settingsChanged)
    def toddsCustomCommand(self) -> str:
        return self._todds_custom_command

    @toddsCustomCommand.setter  # type: ignore[no-redef]
    def toddsCustomCommand(self, val: str) -> None:
        self._todds_custom_command = val
        self.settingsChanged.emit()

    @Property(bool, notify=settingsChanged)
    def toddsActiveModsTarget(self) -> bool:
        return self._todds_active_mods_target

    @toddsActiveModsTarget.setter  # type: ignore[no-redef]
    def toddsActiveModsTarget(self, val: bool) -> None:
        self._todds_active_mods_target = val
        self.settingsChanged.emit()

    @Property(bool, notify=settingsChanged)
    def toddsDryRun(self) -> bool:
        return self._todds_dry_run

    @toddsDryRun.setter  # type: ignore[no-redef]
    def toddsDryRun(self, val: bool) -> None:
        self._todds_dry_run = val
        self.settingsChanged.emit()

    @Property(bool, notify=settingsChanged)
    def toddsOverwrite(self) -> bool:
        return self._todds_overwrite

    @toddsOverwrite.setter  # type: ignore[no-redef]
    def toddsOverwrite(self, val: bool) -> None:
        self._todds_overwrite = val
        self.settingsChanged.emit()

    # --- Custom background settings ---
    @Property(str, notify=settingsChanged)
    def customBackground(self) -> str:
        return self._custom_background

    @customBackground.setter  # type: ignore[no-redef]
    def customBackground(self, val: str) -> None:
        self._custom_background = val
        self.settingsChanged.emit()

    @Property(float, notify=settingsChanged)
    def panelOpacity(self) -> float:
        return self._panel_opacity

    @panelOpacity.setter  # type: ignore[no-redef]
    def panelOpacity(self, val: float) -> None:
        self._panel_opacity = val
        self.settingsChanged.emit()

    @Slot(result=str)
    def pickBackgroundImage(self) -> str:
        """Open a native file dialog to pick a background image."""
        from PySide6.QtWidgets import QFileDialog

        path, _ = QFileDialog.getOpenFileName(
            None,
            "Select Background Image",
            "",
            "Images (*.png *.jpg *.jpeg *.bmp *.webp);;All Files (*)",
        )
        if path:
            self._custom_background = path.replace("\\", "/")
            self.settingsChanged.emit()
        return self._custom_background

    # --- Actions ---
    @Slot()
    def save(self) -> None:
        """Save ALL settings from QML bridge back to the real Settings model."""
        logger.debug("Settings: Save requested from QML")
        try:
            from app.models.settings import Settings

            s = Settings()
            s.load()
            inst_name = s.current_instance
            inst = s.instances.get(inst_name)
            if inst:
                if self._game_location:
                    inst.game_folder = self._game_location
                if self._config_folder:
                    inst.config_folder = self._config_folder
                if self._steam_mods_folder:
                    inst.workshop_folder = self._steam_mods_folder
                if self._local_mods_folder:
                    inst.local_folder = self._local_mods_folder
                inst.steam_client_integration = self._steam_client_integration
                s.instances[inst_name] = inst

            # General settings
            s.sorting_algorithm = self._sort_method
            s.mod_type_filter = self._enable_mod_type_filter
            s.show_save_comparison_indicators = self._show_save_indicators
            s.enable_themes = self._enable_themes
            s.font_size = self._font_size
            if self._font_family:
                s.font_family = self._font_family

            # Custom background settings
            s.custom_background = self._custom_background
            s.panel_opacity = self._panel_opacity

            # todds settings
            s.todds_preset = self._todds_preset
            s.todds_custom_command = self._todds_custom_command
            s.todds_active_mods_target = self._todds_active_mods_target
            s.todds_dry_run = self._todds_dry_run
            s.todds_overwrite = self._todds_overwrite

            s.save()
            logger.info("Settings saved successfully")
        except Exception as e:
            logger.error(f"Failed to save settings: {e}")
        self.close()

    @Slot()
    def cancel(self) -> None:
        logger.debug("Settings: Cancel requested from QML")
        self.close()

    @Slot()
    def resetDefaults(self) -> None:
        """Reset all settings to defaults using the same logic as original UI."""
        logger.debug("Settings: Reset to defaults requested from QML")
        try:
            from app.models.settings import Settings
            s = Settings()  # Fresh Settings object = all defaults
            s.save()
            # Update bridge properties to reflect defaults
            self._game_location = ""
            self._config_folder = ""
            self._steam_mods_folder = ""
            self._local_mods_folder = ""
            self._instance_folder = ""
            self._sort_method = "Topological"
            self._enable_mod_type_filter = True
            self._show_save_indicators = False
            self._enable_themes = True
            self._font_size = 13
            self._font_family = "Segoe UI"
            self._steam_client_integration = False
            self._custom_background = ""
            self._panel_opacity = 1.0
            self._todds_preset = "optimized"
            self._todds_custom_command = ""
            self._todds_active_mods_target = True
            self._todds_dry_run = False
            self._todds_overwrite = False
            self.settingsChanged.emit()
            logger.info("Settings reset to defaults")
        except Exception as e:
            logger.error(f"Reset defaults failed: {e}")

    @Slot()
    def autodetectLocations(self) -> None:
        """Autodetect RimWorld paths based on platform defaults."""
        import sys
        from pathlib import Path

        logger.info("Settings: Autodetect locations from QML")

        try:
            if sys.platform == "darwin":
                home = Path.home()
                game = home / "Library/Application Support/Steam/steamapps/common/Rimworld/RimworldMac.app"
                config = home / "Library/Application Support/Rimworld/Config"
                workshop = home / "Library/Application Support/Steam/steamapps/workshop/content/294100"
            elif sys.platform == "linux":
                home = Path.home()
                debian = home / ".steam/debian-installation"
                if not debian.exists():
                    debian = home / ".steam/steam"
                game = debian / "steamapps/common/RimWorld"
                config = home / ".config/unity3d/Ludeon Studios/RimWorld by Ludeon Studios/Config"
                workshop = debian / "steamapps/workshop/content/294100"
            elif sys.platform == "win32":
                home = Path.home()
                try:
                    from app.utils.win_find_steam import find_steam_folder

                    steam_folder, found = find_steam_folder()
                    if not found:
                        steam_folder = "C:/Program Files (x86)/Steam"
                except Exception:
                    steam_folder = "C:/Program Files (x86)/Steam"

                try:
                    from app.controllers.settings_controller import find_steam_rimworld, get_path_up_to_string

                    game_str = find_steam_rimworld(steam_folder)
                    if not game_str:
                        game_str = f"{steam_folder}/steamapps/common/RimWorld"
                    game = Path(game_str)

                    ws = get_path_up_to_string(game, "common", exclude=True)
                    if ws:
                        workshop = Path(ws) / "workshop/content/294100"
                    else:
                        workshop = Path(f"{steam_folder}/steamapps/workshop/content/294100")
                except Exception:
                    game = Path(f"{steam_folder}/steamapps/common/RimWorld")
                    workshop = Path(f"{steam_folder}/steamapps/workshop/content/294100")

                config = home / "AppData/LocalLow/Ludeon Studios/RimWorld by Ludeon Studios/Config"
            else:
                logger.error("Unknown platform for autodetect")
                return

            # Only set if path exists and field is empty
            if game.exists() and not self._game_location:
                self._game_location = str(game)
            if config.exists() and not self._config_folder:
                self._config_folder = str(config)
            if workshop.exists() and not self._steam_mods_folder:
                self._steam_mods_folder = str(workshop)
            local_mods = game / "Mods"
            if local_mods.exists() and not self._local_mods_folder:
                self._local_mods_folder = str(local_mods)

            self.settingsChanged.emit()
            logger.info(f"Autodetected: game={self._game_location}, config={self._config_folder}, workshop={self._steam_mods_folder}, local={self._local_mods_folder}")
        except Exception as e:
            logger.error(f"Autodetect failed: {e}")
