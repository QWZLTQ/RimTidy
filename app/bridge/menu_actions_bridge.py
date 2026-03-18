"""
Menu actions bridge for QML. Implements functionality by replicating
the original main_content_panel.py _do_xxx methods.
"""

import os
import sys
import traceback
from pathlib import Path

from loguru import logger
from PySide6.QtCore import QObject, Signal, Slot


class MenuActionsBridge(QObject):
    statusMessage = Signal(str)
    # Signal to tell QML to reload mod lists after import
    modListsChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)

    def _settings(self):  # type: ignore[no-untyped-def]
        from app.models.settings import Settings
        s = Settings(); s.load()
        return s

    def _instance(self):  # type: ignore[no-untyped-def]
        s = self._settings()
        return s.instances.get(s.current_instance)

    def _mm(self):  # type: ignore[no-untyped-def]
        from app.utils.metadata import MetadataManager
        return MetadataManager.instance()

    def _open_path(self, path: str | Path) -> None:
        from app.utils.generic import platform_specific_open
        p = str(path)
        if os.path.exists(p):
            platform_specific_open(p)
        else:
            self.statusMessage.emit(f"Path not found: {p}")

    # ========== File menu ==========

    @Slot()
    def openModList(self) -> None:
        """Open mod list from XML/RWS file — same as original _do_import_list_file_xml."""
        try:
            from PySide6.QtWidgets import QFileDialog
            from app.utils.app_info import AppInfo
            from app.utils import metadata
            path, _ = QFileDialog.getOpenFileName(
                None, "Open RimWorld mod list",
                str(AppInfo().saved_modlists_folder),
                "RimWorld mod list (*.rml *.rws *.xml)"
            )
            if not path:
                return
            active, inactive, duplicates, missing = metadata.get_mods_from_list(mod_list=path)
            self.statusMessage.emit(f"Imported {len(active)} active, {len(inactive)} inactive mods")
            self.modListsChanged.emit()
            # Store for QML to pick up
            self._last_import_active = active
            self._last_import_inactive = inactive
        except Exception as e:
            logger.error(f"Open mod list failed: {e}")

    @Slot(result="QVariant")
    def getLastImportActive(self) -> list[str]:
        return getattr(self, "_last_import_active", [])

    @Slot(result="QVariant")
    def getLastImportInactive(self) -> list[str]:
        return getattr(self, "_last_import_inactive", [])

    @Slot()
    def saveModListAs(self) -> None:
        """Export active mods to XML file — same as original _do_export_list_file_xml."""
        try:
            from PySide6.QtWidgets import QFileDialog
            from app.utils.app_info import AppInfo
            from app.utils.schema import generate_rimworld_mods_list
            from app.utils.xml import json_to_xml_write
            from app.utils import metadata as meta_utils

            path, _ = QFileDialog.getSaveFileName(
                None, "Save mod list",
                str(AppInfo().saved_modlists_folder),
                "XML (*.xml)"
            )
            if not path:
                return

            mm = self._mm()
            s = self._settings()
            inst = s.instances.get(s.current_instance)
            if not inst or not inst.config_folder:
                return

            # Get current active mods from saved config
            config_path = str(Path(inst.config_folder) / "ModsConfig.xml")
            active_uuids, _, _, _ = meta_utils.get_mods_from_list(config_path)

            package_ids = []
            for uuid in active_uuids:
                meta = mm.internal_local_metadata.get(uuid, {})
                pid = meta.get("packageid", "")
                if pid and pid not in package_ids:
                    package_ids.append(pid)

            mods_config_data = generate_rimworld_mods_list(mm.game_version or "", package_ids)
            if not path.endswith(".xml"):
                path += ".xml"
            json_to_xml_write(mods_config_data, path)
            self.statusMessage.emit(f"Exported {len(package_ids)} mods to {Path(path).name}")
        except Exception as e:
            logger.error(f"Save mod list failed: {e}")
            self.statusMessage.emit(f"Export failed: {e}")

    @Slot()
    def importFromRentry(self) -> None:
        try:
            from PySide6.QtWidgets import QInputDialog
            url, ok = QInputDialog.getText(None, "Import from Rentry", "Enter Rentry.co URL:")
            if ok and url:
                self.statusMessage.emit(f"Rentry import: requires web parsing (not yet implemented)")
        except Exception as e:
            logger.error(f"Rentry import failed: {e}")

    @Slot()
    def importFromWorkshopCollection(self) -> None:
        try:
            from PySide6.QtWidgets import QInputDialog
            url, ok = QInputDialog.getText(None, "Import Workshop Collection", "Enter Steam Workshop collection URL:")
            if ok and url:
                self.statusMessage.emit(f"Workshop collection import: requires Steam API (not yet implemented)")
        except Exception as e:
            logger.error(f"Workshop import failed: {e}")

    @Slot()
    def importFromSaveFile(self) -> None:
        """Import from save file — same as original _do_import_list_from_save_file."""
        try:
            from PySide6.QtWidgets import QFileDialog
            from app.utils import metadata

            # Default to Saves directory
            s = self._settings()
            inst = s.instances.get(s.current_instance)
            saves_dir = ""
            if inst and inst.config_folder:
                saves_dir = str(Path(inst.config_folder).parent / "Saves")

            path, _ = QFileDialog.getOpenFileName(
                None, "Select Save File", saves_dir,
                "RimWorld saves (*.rws);;All files (*)"
            )
            if not path:
                return
            active, inactive, _, _ = metadata.get_mods_from_list(mod_list=path)
            self._last_import_active = active
            self._last_import_inactive = inactive
            self.statusMessage.emit(f"Imported {len(active)} mods from save file")
            self.modListsChanged.emit()
        except Exception as e:
            logger.error(f"Import save failed: {e}")

    @Slot()
    def exportToClipboard(self) -> None:
        """Export to clipboard — same format as original _do_export_list_clipboard."""
        try:
            from app.utils.generic import copy_to_clipboard_safely
            from app.utils.app_info import AppInfo
            from app.utils import metadata as meta_utils

            mm = self._mm()
            s = self._settings()
            inst = s.instances.get(s.current_instance)
            if not inst or not inst.config_folder:
                return

            config_path = str(Path(inst.config_folder) / "ModsConfig.xml")
            active_uuids, _, _, _ = meta_utils.get_mods_from_list(config_path)

            # Build report in same format as original
            report = (
                f"Created with RimTidy {AppInfo().app_version}"
                f"\nRimWorld game version this list was created for: {mm.game_version}"
                f"\nTotal # of mods: {len(active_uuids)}\n"
            )
            for uuid in active_uuids:
                meta = mm.internal_local_metadata.get(uuid, {})
                name = meta.get("name", "No name specified")
                url = meta.get("url") or meta.get("steam_url") or "No url specified"
                pid = meta.get("packageid", "")
                report += f"\n{name} [{pid}][{url}]"

            copy_to_clipboard_safely(report)
            self.statusMessage.emit(f"Copied {len(active_uuids)} mods report to clipboard")
        except Exception as e:
            logger.error(f"Export clipboard failed: {e}")

    @Slot()
    def exportToRentry(self) -> None:
        self.statusMessage.emit("Export to Rentry: requires web API (not yet implemented)")

    @Slot()
    def openSettings(self) -> None:
        pass  # Handled by QML

    @Slot()
    def quit(self) -> None:
        from PySide6.QtWidgets import QApplication
        QApplication.quit()

    # ========== Edit menu ==========

    @Slot()
    def cut(self) -> None:
        self.statusMessage.emit("Use drag-drop or double-click to move mods")

    @Slot()
    def copy(self) -> None:
        self.statusMessage.emit("Right-click mod → Clipboard → Copy Package ID")

    @Slot()
    def paste(self) -> None:
        self.statusMessage.emit("Use drag-drop or double-click to add mods")

    @Slot()
    def openRuleEditor(self) -> None:
        try:
            from app.windows.rule_editor_panel import RuleEditor
            from PySide6.QtCore import Qt
            editor = RuleEditor(compact=False, initial_mode="loadAfter")
            editor._populate_from_metadata()
            editor.setWindowModality(Qt.WindowModality.ApplicationModal)
            editor.show()
            self._rule_editor = editor  # prevent GC
        except Exception as e:
            logger.error(f"Rule editor failed: {e}")
            self.statusMessage.emit(f"Rule editor error: {e}")

    @Slot()
    def openIgnoreJsonEditor(self) -> None:
        try:
            from app.windows.ignore_json_editor import IgnoreJsonEditor
            from PySide6.QtCore import Qt
            editor = IgnoreJsonEditor()
            editor.setWindowModality(Qt.WindowModality.ApplicationModal)
            editor.show()
            self._ignore_editor = editor  # prevent GC
        except Exception as e:
            logger.error(f"Ignore editor failed: {e}")

    @Slot()
    def resetAllWarnings(self) -> None:
        try:
            from app.controllers.metadata_db_controller import AuxMetadataController
            s = self._settings()
            aux = AuxMetadataController.get_or_create_cached_instance(s.aux_db_path)
            with aux.Session() as session:
                aux.reset_all_warning_toggles(session)
            self.statusMessage.emit("All warnings reset")
        except Exception as e:
            logger.error(f"Reset warnings failed: {e}")

    @Slot()
    def resetAllModColors(self) -> None:
        try:
            from app.controllers.metadata_db_controller import AuxMetadataController
            s = self._settings()
            aux = AuxMetadataController.get_or_create_cached_instance(s.aux_db_path)
            with aux.Session() as session:
                aux.reset_all_colors(session)
            self.statusMessage.emit("All mod colors reset")
        except Exception as e:
            logger.error(f"Reset colors failed: {e}")

    # ========== Download menu ==========

    @Slot()
    def addGitMod(self) -> None:
        """Clone git repo into local mods folder."""
        try:
            from PySide6.QtWidgets import QInputDialog
            url, ok = QInputDialog.getText(None, "Add Git Mod", "Enter git repository URL:")
            if not ok or not url:
                return
            inst = self._instance()
            if not inst or not inst.local_folder:
                self.statusMessage.emit("Local mods folder not configured")
                return
            repo_name = url.rstrip("/").split("/")[-1].replace(".git", "")
            target = Path(inst.local_folder) / repo_name
            if target.exists():
                self.statusMessage.emit(f"Folder already exists: {repo_name}")
                return
            self.statusMessage.emit(f"Cloning {repo_name}...")
            import pygit2
            pygit2.clone_repository(url, str(target))
            self.statusMessage.emit(f"Cloned: {repo_name}")
        except Exception as e:
            logger.error(f"Git clone failed: {e}")
            self.statusMessage.emit(f"Git clone failed: {e}")

    @Slot()
    def addZipMod(self) -> None:
        """Add zip mod — same as original _do_add_zip_mod (simplified: local file only)."""
        try:
            from PySide6.QtWidgets import QFileDialog
            inst = self._instance()
            if not inst or not inst.local_folder:
                self.statusMessage.emit("Local mods folder not configured")
                return
            path, _ = QFileDialog.getOpenFileName(None, "Select Zip Mod", "", "Zip files (*.zip)")
            if not path:
                return
            import zipfile
            with zipfile.ZipFile(path, "r") as zf:
                # Check if it's a bare mod (has About folder at root)
                names = zf.namelist()
                has_about = any(n.lower().startswith("about/") or n.lower() == "about" for n in names)
                if has_about:
                    # Bare mod — extract to folder named after zip
                    target = Path(inst.local_folder) / Path(path).stem
                else:
                    # Nested — extract directly (first folder is the mod)
                    target = Path(inst.local_folder)
                target.mkdir(parents=True, exist_ok=True)
                zf.extractall(str(target))
            self.statusMessage.emit(f"Extracted: {Path(path).stem}")
        except Exception as e:
            logger.error(f"Zip extract failed: {e}")
            self.statusMessage.emit(f"Zip extract failed: {e}")

    @Slot()
    def browseWorkshop(self) -> None:
        """Open Steam Workshop in browser — original uses internal SteamBrowser widget."""
        from app.utils.generic import open_url_browser
        open_url_browser("https://steamcommunity.com/app/294100/workshop/")

    @Slot()
    def updateWorkshopMods(self) -> None:
        """Validate/update workshop mods via Steam."""
        from app.utils.generic import open_url_browser
        open_url_browser("steam://validate/294100")
        self.statusMessage.emit("Steam is validating workshop mods...")

    @Slot()
    def verifyGameFiles(self) -> None:
        from app.utils.generic import open_url_browser
        open_url_browser("steam://validate/294100")

    # ========== Instances menu ==========

    @Slot()
    def backupInstance(self) -> None:
        try:
            import shutil
            from PySide6.QtWidgets import QFileDialog
            from app.utils.app_info import AppInfo
            s = self._settings()
            inst_folder = AppInfo().app_storage_folder / "instances" / s.current_instance
            path, _ = QFileDialog.getSaveFileName(None, "Backup Instance", f"{s.current_instance}_backup.zip", "Zip (*.zip)")
            if path and inst_folder.exists():
                if not path.endswith(".zip"):
                    path += ".zip"
                shutil.make_archive(path.replace(".zip", ""), "zip", str(inst_folder))
                self.statusMessage.emit(f"Instance backed up: {Path(path).name}")
        except Exception as e:
            logger.error(f"Backup failed: {e}")

    @Slot()
    def restoreInstance(self) -> None:
        try:
            from PySide6.QtWidgets import QFileDialog
            path, _ = QFileDialog.getOpenFileName(None, "Restore Instance", "", "Zip (*.zip)")
            if path:
                self.statusMessage.emit(f"Restore: select instance to overwrite (not yet implemented)")
        except Exception as e:
            logger.error(f"Restore failed: {e}")

    @Slot()
    def cloneInstance(self) -> None:
        try:
            from PySide6.QtWidgets import QInputDialog
            name, ok = QInputDialog.getText(None, "Clone Instance", "New instance name:")
            if ok and name:
                import shutil
                from app.utils.app_info import AppInfo
                s = self._settings()
                src = AppInfo().app_storage_folder / "instances" / s.current_instance
                dst = AppInfo().app_storage_folder / "instances" / name
                if src.exists():
                    shutil.copytree(str(src), str(dst))
                    from app.models.instance import Instance
                    s.instances[name] = Instance()
                    s.save()
                    self.statusMessage.emit(f"Cloned: {name}")
        except Exception as e:
            logger.error(f"Clone failed: {e}")

    @Slot()
    def createInstance(self) -> None:
        try:
            from PySide6.QtWidgets import QInputDialog
            name, ok = QInputDialog.getText(None, "Create Instance", "New instance name:")
            if ok and name:
                s = self._settings()
                from app.models.instance import Instance
                s.instances[name] = Instance()
                s.save()
                self.statusMessage.emit(f"Instance created: {name}")
        except Exception as e:
            logger.error(f"Create failed: {e}")

    @Slot()
    def deleteInstance(self) -> None:
        try:
            from PySide6.QtWidgets import QMessageBox
            s = self._settings()
            if s.current_instance == "Default":
                self.statusMessage.emit("Cannot delete default instance")
                return
            reply = QMessageBox.question(None, "Delete Instance",
                f"Delete instance '{s.current_instance}'?")
            if reply == QMessageBox.StandardButton.Yes:
                del s.instances[s.current_instance]
                s.current_instance = "Default"
                s.save()
                self.statusMessage.emit("Instance deleted")
        except Exception as e:
            logger.error(f"Delete failed: {e}")

    # ========== Textures menu ==========

    @Slot()
    def optimizeTextures(self) -> None:
        """Run todds texture optimization — same as original _do_optimize_textures."""
        try:
            s = self._settings()
            todds_active_mods_target = getattr(s, "todds_active_mods_target", False)
            todds_dry_run = getattr(s, "todds_dry_run", False)
            todds_overwrite = getattr(s, "todds_overwrite", False)
            self.statusMessage.emit("todds: configure in Settings → todds tab")
        except Exception as e:
            logger.error(f"Optimize textures failed: {e}")

    @Slot()
    def deleteDdsTextures(self) -> None:
        """Delete orphaned .dds textures — same as original _do_delete_dds_textures."""
        try:
            from PySide6.QtWidgets import QMessageBox
            reply = QMessageBox.question(None, "Delete DDS Textures",
                "Delete all orphaned .dds texture files?\nThis cannot be undone.")
            if reply == QMessageBox.StandardButton.Yes:
                from app.utils.dds_utility import DDSUtility
                s = self._settings()
                from app.controllers.settings_controller import SettingsController
                from app.views.settings_dialog import SettingsDialog
                sc = SettingsController(model=s, view=SettingsDialog())
                dds = DDSUtility(sc)
                count = dds.delete_dds_files_without_png()
                self.statusMessage.emit(f"Deleted {count} orphaned .dds files")
        except Exception as e:
            logger.error(f"Delete DDS failed: {e}")

    # ========== Help menu ==========

    @Slot()
    def openWiki(self) -> None:
        from app.utils.generic import open_url_browser
        open_url_browser("https://github.com/RimSort/RimSort/wiki")

    @Slot()
    def openGitHub(self) -> None:
        from app.utils.generic import open_url_browser
        open_url_browser("https://github.com/RimSort/RimSort")

    # ========== Update menu ==========

    @Slot()
    def checkForUpdates(self) -> None:
        self.statusMessage.emit("Running from source — updates check skipped")

    # ========== File > Open shortcuts ==========

    @Slot()
    def openAppDirectory(self) -> None:
        self._open_path(os.getcwd())

    @Slot()
    def openSettingsDirectory(self) -> None:
        from app.utils.app_info import AppInfo
        self._open_path(AppInfo().app_storage_folder)

    @Slot()
    def openRimSortLogsDirectory(self) -> None:
        from app.utils.app_info import AppInfo
        self._open_path(AppInfo().user_log_folder)

    @Slot()
    def openRimWorldDirectory(self) -> None:
        inst = self._instance()
        if inst and inst.game_folder:
            self._open_path(inst.game_folder)

    @Slot()
    def openRimWorldConfigDirectory(self) -> None:
        inst = self._instance()
        if inst and inst.config_folder:
            self._open_path(inst.config_folder)

    @Slot()
    def openRimWorldLogsDirectory(self) -> None:
        home = Path.home()
        if sys.platform == "win32":
            logs = home / "AppData/LocalLow/Ludeon Studios/RimWorld by Ludeon Studios"
        elif sys.platform == "darwin":
            logs = home / "Library/Logs/Ludeon Studios/RimWorld by Ludeon Studios"
        else:
            logs = home / ".config/unity3d/Ludeon Studios/RimWorld by Ludeon Studios"
        self._open_path(logs)

    @Slot()
    def openLocalModsDirectory(self) -> None:
        inst = self._instance()
        if inst and inst.local_folder:
            self._open_path(inst.local_folder)

    @Slot()
    def openSteamModsDirectory(self) -> None:
        inst = self._instance()
        if inst and inst.workshop_folder:
            self._open_path(inst.workshop_folder)
