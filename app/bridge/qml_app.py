"""
QML Application launcher.
Initializes QQmlApplicationEngine, registers bridge objects, and loads the QML UI.
Uses QApplication (not QGuiApplication) because MetadataManager/SettingsController need Widgets.
"""

import os
import sys
from pathlib import Path

from loguru import logger
from PySide6.QtCore import QObject, QTimer, QUrl, Slot
from PySide6.QtWidgets import QApplication
from PySide6.QtQml import QQmlApplicationEngine


class DwmHelper(QObject):
    """Helper to apply Windows 11 DWM effects from QML."""

    @Slot(QObject)
    def applyRoundedCorners(self, window: QObject) -> None:
        if sys.platform != "win32":
            return
        try:
            import ctypes

            hwnd = int(window.winId())
            DWMWA_WINDOW_CORNER_PREFERENCE = 33
            DWMWCP_ROUND = 2
            preference = ctypes.c_int(DWMWCP_ROUND)
            ctypes.windll.dwmapi.DwmSetWindowAttribute(
                hwnd, DWMWA_WINDOW_CORNER_PREFERENCE,
                ctypes.byref(preference), ctypes.sizeof(preference),
            )

            class MARGINS(ctypes.Structure):
                _fields_ = [
                    ("cxLeftWidth", ctypes.c_int), ("cxRightWidth", ctypes.c_int),
                    ("cyTopHeight", ctypes.c_int), ("cyBottomHeight", ctypes.c_int),
                ]

            margins = MARGINS(1, 1, 1, 1)
            ctypes.windll.dwmapi.DwmExtendFrameIntoClientArea(hwnd, ctypes.byref(margins))
            logger.debug("Applied DWM rounded corners from QML")
        except Exception as e:
            logger.debug(f"DWM not available: {e}")


def launch_qml_app() -> int:
    """Launch the QML-based UI. Returns exit code."""
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

    # Use QApplication (not QGuiApplication) because backend code needs QWidgets for SettingsDialog etc.
    app = QApplication(sys.argv)
    app.setOrganizationName("RimTidy")
    app.setApplicationName("RimTidy")
    engine = QQmlApplicationEngine()

    # --- Register bridge objects ---
    dwm_helper = DwmHelper()
    engine.rootContext().setContextProperty("dwmHelper", dwm_helper)

    from app.bridge.app_bridge import AppBridge
    from app.bridge.mod_info_bridge import ModInfoBridge
    from app.bridge.menu_actions_bridge import MenuActionsBridge
    from app.bridge.status_bridge import StatusBridge
    from app.bridge.settings_bridge import SettingsBridge
    from app.bridge.mod_list_model import ModListModel
    from app.bridge.context_menu_bridge import ContextMenuBridge
    from app.bridge.i18n_bridge import I18nBridge
    # from app.bridge.folder_manager import FolderManager  # removed

    app_bridge = AppBridge()
    mod_info_bridge = ModInfoBridge()
    menu_actions = MenuActionsBridge()
    status_bridge = StatusBridge()
    settings_bridge = SettingsBridge()
    context_menu_bridge = ContextMenuBridge()
    i18n = I18nBridge()
    engine.rootContext().setContextProperty("contextMenu", context_menu_bridge)
    engine.rootContext().setContextProperty("i18n", i18n)
    context_menu_bridge.statusMessage.connect(status_bridge.setMessage)
    menu_actions.set_i18n(i18n)
    app_bridge.set_i18n(i18n)
    menu_actions.statusMessage.connect(status_bridge.setMessage)

    def on_menu_mod_lists_changed() -> None:
        active = menu_actions.getLastImportActive()
        inactive = menu_actions.getLastImportInactive()
        if active or inactive:
            active_mods_model.populate(active)
            inactive_mods_model.populate(inactive)

    menu_actions.modListsChanged.connect(on_menu_mod_lists_changed)

    active_mods_model = ModListModel()
    inactive_mods_model = ModListModel()

    engine.rootContext().setContextProperty("appBridge", app_bridge)
    engine.rootContext().setContextProperty("modInfo", mod_info_bridge)
    engine.rootContext().setContextProperty("menuActions", menu_actions)
    engine.rootContext().setContextProperty("statusBar", status_bridge)
    engine.rootContext().setContextProperty("settings", settings_bridge)
    engine.rootContext().setContextProperty("activeModsModel", active_mods_model)
    engine.rootContext().setContextProperty("inactiveModsModel", inactive_mods_model)

    # Connect AppBridge status messages to StatusBridge
    app_bridge.statusMessage.connect(status_bridge.setMessage)

    # When mod lists are ready, populate models
    def load_mod_lists() -> None:
        active = app_bridge.getActiveModUuids()
        inactive = app_bridge.getInactiveModUuids()
        inactive = app_bridge.sortInactiveMods(inactive, 0)
        active_mods_model.populate(active)
        inactive_mods_model.populate(inactive)

        # Compute errors/warnings
        for model, mod_uuids, lt in [
            (active_mods_model, active, "Active"),
            (inactive_mods_model, inactive, "Inactive"),
        ]:
            ew = app_bridge.getModErrorsWarnings(mod_uuids, lt)
            if ew:
                batch: dict = {}
                for uuid, data in ew.items():
                    if uuid == "__summary__":
                        continue
                    batch[uuid] = data
                if batch:
                    model.setBatchItemMeta(batch)

        version = app_bridge.getGameVersion()
        if version:
            status_bridge.setMessage(f"Ready — RimWorld {version} — {len(active)} active, {len(inactive)} inactive mods")
        else:
            status_bridge.setMessage(f"Ready — {len(active)} active, {len(inactive)} inactive mods")

    app_bridge.modListsReady.connect(load_mod_lists)

    # --- Add QML import paths ---
    qml_dir = Path(__file__).parent.parent / "qml"
    engine.addImportPath(str(qml_dir))
    for subdir in qml_dir.iterdir():
        if subdir.is_dir():
            engine.addImportPath(str(subdir))

    # --- Load QML ---
    main_qml = qml_dir / "main.qml"
    if not main_qml.exists():
        logger.error(f"QML file not found: {main_qml}")
        return 1

    def on_warnings(warnings: list) -> None:  # type: ignore[type-arg]
        for w in warnings:
            logger.warning(f"QML: {w.toString()}")

    engine.warnings.connect(on_warnings)
    engine.load(QUrl.fromLocalFile(str(main_qml)))

    if not engine.rootObjects():
        logger.error(f"Failed to load QML from: {main_qml}")
        return 1

    logger.info("QML UI loaded successfully")

    # Initialize backend after QML is loaded (deferred so window shows first)
    def deferred_init() -> None:
        app_bridge.initialize()
        if app_bridge.isInitialized():
            load_mod_lists()

            # Sync settings bridge with real settings
            if app_bridge._settings:
                s = app_bridge._settings
                inst = s.instances.get(s.current_instance)
                if inst:
                    settings_bridge.gameLocation = inst.game_folder or ""
                    settings_bridge.configFolder = inst.config_folder or ""
                    settings_bridge.steamModsFolder = inst.workshop_folder or ""
                    settings_bridge.localModsFolder = inst.local_folder or ""
                # Sync todds settings
                settings_bridge.toddsPreset = s.todds_preset
                settings_bridge.toddsCustomCommand = s.todds_custom_command
                settings_bridge.toddsActiveModsTarget = s.todds_active_mods_target
                settings_bridge.toddsDryRun = s.todds_dry_run
                settings_bridge.toddsOverwrite = s.todds_overwrite
                # Sync custom background settings
                settings_bridge.customBackground = getattr(s, "custom_background", "")
                settings_bridge.panelOpacity = getattr(s, "panel_opacity", 1.0)

    QTimer.singleShot(100, deferred_init)

    return app.exec()
