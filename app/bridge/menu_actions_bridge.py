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
        self._i18n: object | None = None

    def set_i18n(self, i18n: object) -> None:
        """Set the I18nBridge instance for translations."""
        self._i18n = i18n

    def _tr(self, key: str) -> str:
        """Translate using the i18n dictionary, falling back to the key itself."""
        if self._i18n is not None and hasattr(self._i18n, "t"):
            return self._i18n.t(key)  # type: ignore[union-attr]
        return key

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

    def _do_generate_todds_txt(self, target: str = "auto") -> str:
        """Generate todds.txt listing target mod folders.

        Args:
            target: "active" = active mods only, "inactive" = inactive mods only,
                    "all" = all mod folders, "auto" = respect settings.
        """
        from tempfile import gettempdir

        s = self._settings()
        inst = s.instances.get(s.current_instance)
        todds_txt_path = str(Path(gettempdir()) / "todds.txt")

        if os.path.exists(todds_txt_path):
            os.remove(todds_txt_path)

        # Resolve "auto" to the setting value
        if target == "auto":
            target = "active" if s.todds_active_mods_target else "all"

        if target == "all":
            # Write entire local + workshop folders
            with open(todds_txt_path, "a", encoding="utf-8") as f:
                if inst and inst.local_folder and inst.local_folder != "":
                    f.write(os.path.abspath(inst.local_folder) + "\n")
                if inst and inst.workshop_folder and inst.workshop_folder != "":
                    f.write(os.path.abspath(inst.workshop_folder) + "\n")
        elif target in ("active", "inactive"):
            from app.utils import metadata as meta_utils

            mm = self._mm()
            if not inst or not inst.config_folder:
                logger.warning("No config folder configured, falling back to all mods")
                with open(todds_txt_path, "a", encoding="utf-8") as f:
                    if inst and inst.local_folder:
                        f.write(os.path.abspath(inst.local_folder) + "\n")
                    if inst and inst.workshop_folder:
                        f.write(os.path.abspath(inst.workshop_folder) + "\n")
            else:
                config_path = str(Path(inst.config_folder) / "ModsConfig.xml")
                active_uuids, _, _, _ = meta_utils.get_mods_from_list(config_path)
                active_uuid_set = set(active_uuids)
                all_uuids = set(mm.internal_local_metadata.keys())

                if target == "active":
                    selected_uuids = active_uuid_set
                else:  # inactive
                    selected_uuids = all_uuids - active_uuid_set

                with open(todds_txt_path, "a", encoding="utf-8") as f:
                    for uuid in selected_uuids:
                        meta = mm.internal_local_metadata.get(uuid, {})
                        mod_path = meta.get("path")
                        if mod_path:
                            f.write(os.path.abspath(mod_path) + "\n")

        logger.info(f"Generated todds.txt at: {todds_txt_path} (target={target})")
        return todds_txt_path

    def _create_todds_runner(self, is_pre_launch: bool) -> "RunnerPanel":
        """Create and configure the todds runner UI panel — mirrors main_content_panel."""
        from app.windows.runner_panel import RunnerPanel

        s = self._settings()
        runner = RunnerPanel(
            todds_dry_run_support=s.todds_dry_run,
            auto_close_on_complete=is_pre_launch,
        )

        base_title = self._tr("RimTidy - todds Texture Encoder")
        suffix = self._tr(" (pre-launch)") if is_pre_launch else ""
        runner.setWindowTitle(f"{base_title}{suffix}")

        # Patch RunnerPanel text for Chinese localization
        # (RunnerPanel uses Qt tr() which has no .qm loaded in QML mode)
        runner._i18n_subprocess_killed = self._tr("Subprocess killed!")
        runner._i18n_subprocess_completed = self._tr("Subprocess completed.")
        runner._i18n_process_complete_title = self._tr("Process Complete")
        runner._i18n_process_complete_text = self._tr("Process complete, you can close the window.")
        runner._i18n_close_window = self._tr("Close Window")
        runner._i18n_initiating = self._tr("Initiating todds...")
        runner._i18n_courtesy = self._tr("Courtesy of joseasoler#1824")
        runner._i18n_preset_fmt = self._tr("Using configured preset: {preset}")
        runner._i18n_exec_cmd_fmt = self._tr("Executing command:")

        if not is_pre_launch:
            self._todds_runner = runner  # prevent GC

        runner.show()
        return runner

    def _run_todds_optimize(self, target: str) -> None:
        """Shared todds optimization logic for different targets."""
        try:
            from app.utils.todds.wrapper import ToddsInterface

            s = self._settings()
            logger.info(f"Optimizing textures with todds (target={target})...")

            todds_interface = ToddsInterface(
                preset=s.todds_preset,
                dry_run=s.todds_dry_run,
                overwrite=s.todds_overwrite,
            )

            todds_runner = self._create_todds_runner(is_pre_launch=False)
            todds_txt_path = self._do_generate_todds_txt(target=target)

            todds_interface.execute_todds_cmd(todds_txt_path, todds_runner)
            self.statusMessage.emit(self._tr("todds optimization started"))
        except Exception as e:
            logger.error(f"Optimize textures failed: {e}")
            self.statusMessage.emit(f"{self._tr('Optimize textures failed')}: {e}")

    @Slot()
    def optimizeTextures(self) -> None:
        """Run todds optimization respecting settings target."""
        self._run_todds_optimize("auto")

    @Slot()
    def optimizeActiveModsTextures(self) -> None:
        """Run todds optimization on active mods only."""
        self._run_todds_optimize("active")

    @Slot()
    def optimizeInactiveModsTextures(self) -> None:
        """Run todds optimization on inactive mods only."""
        self._run_todds_optimize("inactive")

    @Slot()
    def optimizeAllModsTextures(self) -> None:
        """Run todds optimization on all mods."""
        self._run_todds_optimize("all")

    @Slot()
    def deleteDdsTextures(self) -> None:
        """Delete .dds textures using todds clean preset — mirrors main_content_panel._do_delete_dds_textures."""
        try:
            from PySide6.QtWidgets import QMessageBox
            from app.utils.todds.wrapper import ToddsInterface

            reply = QMessageBox.question(
                None,
                self._tr("Delete DDS Textures"),
                self._tr("Delete all .dds texture files?\nThis cannot be undone."),
            )
            if reply != QMessageBox.StandardButton.Yes:
                return

            s = self._settings()
            logger.info("Deleting .dds textures with todds...")

            todds_interface = ToddsInterface(
                preset="clean",
                dry_run=s.todds_dry_run,
            )

            todds_runner = self._create_todds_runner(is_pre_launch=False)
            todds_txt_path = self._do_generate_todds_txt()

            todds_interface.execute_todds_cmd(todds_txt_path, todds_runner)
            self.statusMessage.emit(self._tr("todds clean started"))
        except Exception as e:
            logger.error(f"Delete DDS failed: {e}")
            self.statusMessage.emit(f"{self._tr('Delete DDS failed')}: {e}")

    @Slot()
    def deleteGeneratedDdsOnly(self) -> None:
        """Delete only generated .dds files (those with a corresponding .png source)."""
        try:
            from glob import glob

            from PySide6.QtWidgets import QMessageBox

            reply = QMessageBox.question(
                None,
                self._tr("Delete Generated DDS"),
                self._tr(
                    "Delete .dds files that have a corresponding .png source?\n"
                    "This only removes DDS files generated by optimization,\n"
                    "mod-original DDS files (without .png) will be kept."
                ),
            )
            if reply != QMessageBox.StandardButton.Yes:
                return

            s = self._settings()
            inst = s.instances.get(s.current_instance)
            if not inst:
                self.statusMessage.emit(self._tr("No instance configured"))
                return

            # Collect mod folders to scan
            folders = []
            if inst.local_folder and os.path.exists(inst.local_folder):
                folders.append(inst.local_folder)
            if inst.workshop_folder and os.path.exists(inst.workshop_folder):
                folders.append(inst.workshop_folder)

            # Find and delete DDS files that have a corresponding PNG
            deleted_count = 0
            scanned_count = 0
            failed_files: list[str] = []
            for folder in folders:
                for dds_file in glob(
                    os.path.join(folder, "**", "*.dds"), recursive=True
                ):
                    scanned_count += 1
                    png_file = dds_file.replace(".dds", ".png")
                    if os.path.exists(png_file):
                        try:
                            os.remove(dds_file)
                            deleted_count += 1
                        except OSError as e:
                            logger.error(f"Failed to delete {dds_file}: {e}")
                            failed_files.append(str(dds_file))

            logger.info(
                f"Deleted {deleted_count} generated DDS files (with PNG source)"
            )

            # Show completion dialog
            if failed_files:
                QMessageBox.warning(
                    None,
                    self._tr("Delete Complete (with errors)"),
                    self._tr(
                        "Scanned {scanned} .dds files.\n"
                        "Deleted {deleted} generated .dds files.\n"
                        "Failed to delete {failed} files."
                    ).format(
                        scanned=scanned_count,
                        deleted=deleted_count,
                        failed=len(failed_files),
                    ),
                )
            else:
                QMessageBox.information(
                    None,
                    self._tr("Delete Complete"),
                    self._tr(
                        "Scanned {scanned} .dds files.\n"
                        "Deleted {deleted} generated .dds files.\n"
                        "Mod-original .dds files (without .png) were kept."
                    ).format(scanned=scanned_count, deleted=deleted_count),
                )
            self.statusMessage.emit(
                self._tr("Deleted {deleted} generated .dds files").format(
                    deleted=deleted_count
                )
            )
        except Exception as e:
            logger.error(f"Delete generated DDS failed: {e}")
            self.statusMessage.emit(f"Delete generated DDS failed: {e}")

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
