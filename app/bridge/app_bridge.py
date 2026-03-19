"""
Main application bridge for QML mode.
Directly uses the same utility functions as the original Widget UI.
"""

import sys
from pathlib import Path
from typing import Any

from loguru import logger
from PySide6.QtCore import QObject, Signal, Slot

from app.utils import constants as app_constants


class AppBridge(QObject):
    """Central bridge that initializes the RimTidy backend and exposes actions to QML."""

    modListsReady = Signal()
    statusMessage = Signal(str)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._settings = None
        self._settings_controller = None
        self._metadata_manager = None
        self._initialized = False
        self._i18n: object | None = None
        # Restore state (same as original _do_restore)
        self._active_restore: list[str] = []
        self._inactive_restore: list[str] = []
        self._active_last_save: list[str] = []

    def set_i18n(self, i18n: object) -> None:
        """Set the I18nBridge instance for translations."""
        self._i18n = i18n

    def _tr(self, key: str) -> str:
        """Translate using the i18n dictionary, falling back to the key itself."""
        if self._i18n is not None and hasattr(self._i18n, "t"):
            return self._i18n.t(key)  # type: ignore[union-attr]
        return key

    # ---- Initialization (mirrors AppController) ----

    @Slot()
    def initialize(self) -> None:
        if self._initialized:
            return
        try:
            self.statusMessage.emit("Loading settings...")
            self._init_settings()
            self.statusMessage.emit("Scanning mods...")
            self._init_metadata()
            self._initialized = True
            self.statusMessage.emit("Ready")
            logger.info(f"AppBridge initialized: {len(self._metadata_manager.internal_local_metadata)} mods found")
        except Exception as e:
            logger.error(f"AppBridge init failed: {e}")
            self.statusMessage.emit(f"Error: {e}")

    def _init_settings(self) -> None:
        from app.models.settings import Settings
        self._settings = Settings()
        self._settings.load()

    def _init_metadata(self) -> None:
        if not self._settings:
            return
        instance = self._settings.instances.get(self._settings.current_instance)
        if not instance or not instance.game_folder or not instance.config_folder:
            self.statusMessage.emit("Please configure game paths in Settings")
            return

        # SteamcmdInterface must be initialized before MetadataManager
        from app.utils.steam.steamcmd.wrapper import SteamcmdInterface
        SteamcmdInterface.instance(
            instance.steamcmd_install_path if instance else "",
            self._settings.steamcmd_validate_downloads,
        )

        from app.controllers.settings_controller import SettingsController
        from app.views.settings_dialog import SettingsDialog
        self._settings_controller = SettingsController(model=self._settings, view=SettingsDialog())

        from app.utils.metadata import MetadataManager
        self._metadata_manager = MetadataManager.instance(settings_controller=self._settings_controller)
        # Scan mod directories (same as original _do_refresh -> refresh_cache)
        self._metadata_manager.refresh_cache(is_initial=True)

    # ---- Mod list loading (mirrors __repopulate_lists -> get_mods_from_list) ----

    def _get_mod_lists(self) -> tuple[list[str], list[str]]:
        """Get active/inactive UUID lists. Same path as original _do_refresh."""
        if not self._metadata_manager or not self._settings:
            return [], []
        from app.utils import metadata as meta_utils
        instance = self._settings.instances.get(self._settings.current_instance)
        if not instance or not instance.config_folder:
            return [], []
        config_path = str(Path(instance.config_folder) / "ModsConfig.xml")
        active, inactive, _, _ = meta_utils.get_mods_from_list(config_path)
        # Cache initial state for Restore button (same as original Widget UI)
        if not self._active_restore:
            self._active_restore = list(active)
            self._inactive_restore = list(inactive)
        return active, inactive

    @Slot(result="QVariant")
    def getActiveModUuids(self) -> list[str]:
        return self._get_mod_lists()[0]

    @Slot(result="QVariant")
    def getInactiveModUuids(self) -> list[str]:
        return self._get_mod_lists()[1]

    # ---- Refresh (mirrors _do_refresh) ----

    @Slot()
    def refreshModLists(self) -> None:
        self.statusMessage.emit("Refreshing...")
        try:
            if self._metadata_manager:
                self._metadata_manager.refresh_cache()
            self.modListsReady.emit()
            self.statusMessage.emit("Ready")
        except Exception as e:
            logger.error(f"Refresh failed: {e}")
            self.statusMessage.emit(f"Refresh error: {e}")

    # ---- Save (mirrors _do_save exactly) ----

    @Slot("QVariant")
    def saveModList(self, active_uuids: list[str]) -> None:
        if not self._metadata_manager or not self._settings:
            return
        try:
            from app.utils.metadata import MetadataManager
            from app.utils.schema import generate_rimworld_mods_list
            from app.utils.xml import json_to_xml_write

            mm = MetadataManager.instance()
            instance = self._settings.instances.get(self._settings.current_instance)
            if not instance or not instance.config_folder:
                return

            # Convert UUIDs to package IDs (same logic as original _do_save)
            package_ids: list[str] = []
            for uuid in active_uuids:
                meta = mm.internal_local_metadata.get(uuid)
                if not meta:
                    continue
                pid = meta.get("packageid", "")
                if pid in package_ids:
                    logger.critical(f"Skipping duplicate package id: {pid}")
                    continue
                package_ids.append(pid)

            # Generate and write (exact same as original)
            game_version = mm.game_version or ""
            mods_config_data = generate_rimworld_mods_list(game_version, package_ids)
            config_path = str(Path(instance.config_folder) / "ModsConfig.xml")
            json_to_xml_write(mods_config_data, config_path)

            # Store restore state (same as original)
            from app.utils import metadata as meta_utils
            self._active_last_save = list(active_uuids)
            self._active_restore, self._inactive_restore, _, _ = meta_utils.get_mods_from_list(config_path)

            self.statusMessage.emit(f"Saved {len(package_ids)} mods")
            logger.info(f"Saved {len(package_ids)} active mods to ModsConfig.xml")
        except Exception as e:
            logger.error(f"Save failed: {e}")
            self.statusMessage.emit(f"Save error: {e}")

    # ---- Sort (mirrors _do_sort exactly) ----

    @Slot("QVariant", result="QVariant")
    def sortModList(self, active_uuids: list[str]) -> list[str]:
        if not self._metadata_manager or not self._settings_controller:
            return active_uuids
        try:
            from app.controllers.sort_controller import Sorter
            from app.utils.metadata import MetadataManager

            mm = MetadataManager.instance()
            active_mods = set(active_uuids)

            # Compile metadata (same as original _do_sort)
            mm.compile_metadata(uuids=list(active_mods))

            # Get package IDs
            active_package_ids = set()
            for uuid in active_mods:
                meta = mm.internal_local_metadata.get(uuid)
                if meta:
                    pid = meta.get("packageid")
                    if pid:
                        active_package_ids.add(pid)

            # Create sorter with same params as original
            sorter = Sorter(
                self._settings_controller.settings.sorting_algorithm,
                active_package_ids=active_package_ids,
                active_uuids=active_mods,
                use_moddependencies_as_loadTheseBefore=self._settings_controller.settings.use_moddependencies_as_loadTheseBefore,
            )
            success, new_order = sorter.sort()

            if success:
                self.statusMessage.emit(f"Sorted {len(new_order)} mods")
                return new_order
            else:
                self.statusMessage.emit("Sort failed: circular dependencies")
                return active_uuids
        except Exception as e:
            logger.error(f"Sort failed: {e}")
            self.statusMessage.emit(f"Sort error: {e}")
            return active_uuids

    # ---- Clear (mirrors _do_clear exactly) ----

    @Slot(result="QVariant")
    def getClearedLists(self) -> dict[str, list[str]]:
        """Returns {"active": [...], "inactive": [...]} with only base/DLC in active."""
        if not self._metadata_manager:
            return {"active": [], "inactive": []}

        mm = self._metadata_manager
        active_uuids: list[str] = []
        inactive_uuids: list[str] = []

        # Same DLC order as original _do_clear
        package_id_order = [
            app_constants.RIMWORLD_DLC_METADATA["294100"]["packageid"],
            app_constants.RIMWORLD_DLC_METADATA["1149640"]["packageid"],
            app_constants.RIMWORLD_DLC_METADATA["1392840"]["packageid"],
            app_constants.RIMWORLD_DLC_METADATA["1826140"]["packageid"],
            app_constants.RIMWORLD_DLC_METADATA["2380740"]["packageid"],
            app_constants.RIMWORLD_DLC_METADATA["3022790"]["packageid"],
        ]

        package_ids_set = set(
            mod_data["packageid"] for mod_data in mm.internal_local_metadata.values()
        )

        for package_id in package_id_order:
            if package_id in package_ids_set:
                active_uuids.extend(
                    uuid for uuid, mod_data in mm.internal_local_metadata.items()
                    if mod_data["data_source"] == "expansion" and mod_data["packageid"] == package_id
                )

        inactive_uuids.extend(
            uuid for uuid in mm.internal_local_metadata.keys() if uuid not in active_uuids
        )

        return {"active": active_uuids, "inactive": inactive_uuids}

    # ---- Restore (mirrors _do_restore) ----

    @Slot(result="QVariant")
    def getRestoreLists(self) -> dict[str, list[str]]:
        """Returns the last saved mod lists for restore."""
        if self._active_restore and self._inactive_restore:
            return {"active": self._active_restore, "inactive": self._inactive_restore}
        return {"active": [], "inactive": []}

    # ---- Run game (mirrors _do_run_game core logic) ----

    @Slot()
    def runGame(self) -> None:
        """Launch RimWorld — same logic as original _do_run_game."""
        if not self._settings:
            self.statusMessage.emit("Settings not loaded")
            return
        instance = self._settings.instances.get(self._settings.current_instance)
        if not instance or not instance.game_folder:
            self.statusMessage.emit("Game folder not configured")
            return

        try:
            from app.utils.generic import launch_game_process

            # Pass the game FOLDER (not exe), same as original:
            # game_install_path = Path(self.settings_controller.settings.instances[current_instance].game_folder)
            game_install_path = Path(instance.game_folder)

            # Get run args, same as original
            run_args: list[str] | str = instance.run_args if hasattr(instance, "run_args") else ""
            run_args = [run_args] if isinstance(run_args, str) else run_args

            launch_game_process(game_install_path, run_args)
            self.statusMessage.emit("Game launched!")
        except Exception as e:
            logger.error(f"Launch failed: {e}")
            self.statusMessage.emit(f"Launch error: {e}")

    # ---- Utility ----

    @Slot("QVariant", int, result="QVariant")
    def sortInactiveMods(self, uuids: list[str], sort_key: int) -> list[str]:
        """Sort inactive mod UUIDs by key: 0=name asc, 1=name desc, 2=author, 3=packageid."""
        if not self._metadata_manager:
            return uuids
        try:
            from app.sort.mod_sorting import ModsPanelSortKey, sort_uuids
            key_map = {
                0: (ModsPanelSortKey.MODNAME, False),
                1: (ModsPanelSortKey.MODNAME, True),
                2: (ModsPanelSortKey.AUTHOR, False),
                3: (ModsPanelSortKey.PACKAGEID, False),
            }
            key, desc = key_map.get(sort_key, (ModsPanelSortKey.MODNAME, False))
            return sort_uuids(uuids, key, descending=desc)
        except Exception as e:
            logger.error(f"Sort inactive failed: {e}")
            return uuids

    @Slot("QVariant", str, result="QVariant")
    def getModErrorsWarnings(self, uuids: list[str], list_type: str = "Active") -> dict[str, dict[str, str]]:
        """
        Compute errors/warnings for mod UUIDs.
        Mirrors original recalculate_internal_errors_warnings logic:
        - Invalid mod (both lists)
        - Version mismatch (both lists)
        - Missing dependencies (Active list only)
        - Alternative dependencies (Active list only, if setting enabled)
        - Incompatibilities (Active list only)
        - Load order violations (Active list only)
        - Use This Instead / recommended alternative (both lists)
        """
        if not self._metadata_manager:
            return {}
        mm = self._metadata_manager
        all_meta = mm.internal_local_metadata

        # Build lookup maps
        packageid_to_uuid: dict[str, str] = {}
        for uuid in uuids:
            meta = all_meta.get(uuid, {})
            pid = meta.get("packageid", "")
            if pid:
                packageid_to_uuid[pid] = uuid
        package_ids_set = set(packageid_to_uuid.keys())

        # Check settings
        consider_alternatives = False
        if self._settings:
            consider_alternatives = getattr(
                self._settings, "use_alternative_package_ids_as_satisfying_dependencies", False
            )

        # Steam DB name lookup helper
        steamdb_name = getattr(mm, "steamdb_packageid_to_name", {})

        def _resolve_name(pid: str) -> str:
            """Resolve package ID to mod name via local metadata or Steam DB."""
            return all_meta.get(packageid_to_uuid.get(pid, ""), {}).get(
                "name", steamdb_name.get(pid, pid)
            )

        result: dict[str, dict[str, str]] = {}
        total_errors = 0
        total_warnings = 0

        for i, uuid in enumerate(uuids):
            meta = all_meta.get(uuid, {})
            if not meta:
                continue

            error_parts: list[str] = []
            warning_parts: list[str] = []

            # ── Invalid mod (both lists) ──
            if meta.get("invalid"):
                error_parts.append(self._tr("Invalid mod (missing or malformed About.xml)"))

            # ── Version mismatch (both lists) ──
            try:
                if mm.is_version_mismatch(uuid):
                    warning_parts.append(self._tr("Mod and Game Version Mismatch"))
            except Exception:
                pass

            # ── Active list only checks ──
            if list_type == "Active":
                # Missing dependencies + alternative dependencies
                missing_deps: set[str] = set()
                alternative_deps: set[str] = set()
                deps = meta.get("dependencies", [])
                if deps and isinstance(deps, (list, set)):
                    for dep_entry in deps:
                        alt_ids: set[str] = set()
                        if isinstance(dep_entry, tuple):
                            dep_id = dep_entry[0]
                            if (
                                len(dep_entry) > 1
                                and isinstance(dep_entry[1], dict)
                                and isinstance(dep_entry[1].get("alternatives"), set)
                            ):
                                alt_ids = dep_entry[1]["alternatives"]
                        elif isinstance(dep_entry, str):
                            dep_id = dep_entry
                        else:
                            continue

                        satisfied = dep_id in package_ids_set
                        if not satisfied and consider_alternatives:
                            satisfied = any(alt in package_ids_set for alt in alt_ids)
                        if not satisfied:
                            missing_deps.add(dep_id)
                            if consider_alternatives and alt_ids:
                                alt_candidates = {a for a in alt_ids if a not in package_ids_set}
                                alternative_deps.update(alt_candidates if alt_candidates else alt_ids)

                if missing_deps:
                    error_parts.append(self._tr("Missing Dependencies:"))
                    for dep_id in missing_deps:
                        error_parts.append(f"  * {_resolve_name(dep_id)}")

                if consider_alternatives and alternative_deps:
                    warning_parts.append(self._tr("Alternative Dependencies:"))
                    for alt_id in alternative_deps:
                        warning_parts.append(f"  * {_resolve_name(alt_id)}")

                # Incompatibilities
                incomp = meta.get("incompatibilities", [])
                conflicting: set[str] = set()
                if incomp and isinstance(incomp, (list, set)):
                    for inc_id in incomp:
                        if isinstance(inc_id, str) and inc_id in package_ids_set:
                            conflicting.add(inc_id)
                if conflicting:
                    error_parts.append(self._tr("Incompatibilities:"))
                    for inc_id in conflicting:
                        error_parts.append(f"  * {_resolve_name(inc_id)}")

                # Load order violations
                load_after_names: list[str] = []
                load_before_names: list[str] = []
                for lb in meta.get("loadTheseBefore", []):
                    if isinstance(lb, tuple) and len(lb) > 1 and lb[1]:
                        lb_id = lb[0]
                        if lb_id in packageid_to_uuid:
                            lb_uuid = packageid_to_uuid[lb_id]
                            if lb_uuid in uuids and i <= uuids.index(lb_uuid):
                                load_after_names.append(_resolve_name(lb_id))

                for la in meta.get("loadTheseAfter", []):
                    if isinstance(la, tuple) and len(la) > 1 and la[1]:
                        la_id = la[0]
                        if la_id in packageid_to_uuid:
                            la_uuid = packageid_to_uuid[la_id]
                            if la_uuid in uuids and i >= uuids.index(la_uuid):
                                load_before_names.append(_resolve_name(la_id))

                if load_after_names:
                    warning_parts.append(self._tr("Should be Loaded After:"))
                    for name in load_after_names:
                        warning_parts.append(f"  * {name}")
                if load_before_names:
                    warning_parts.append(self._tr("Should be Loaded Before:"))
                    for name in load_before_names:
                        warning_parts.append(f"  * {name}")

            # ── Use This Instead / recommended alternative (both lists) ──
            try:
                replacement = mm.has_alternative_mod(uuid)
                if replacement:
                    alt_info = replacement.name or replacement.packageid or ""
                    warning_parts.append(
                        self._tr("Recommended alternative: {alternative}").format(alternative=alt_info)
                    )
            except Exception:
                pass

            if error_parts or warning_parts:
                errors_str = "\n".join(error_parts)
                warnings_str = "\n".join(warning_parts)
                total_errors += 1 if error_parts else 0
                total_warnings += 1 if warning_parts else 0
                result[uuid] = {
                    "errors": errors_str,
                    "warnings": warnings_str,
                    "errors_warnings": (errors_str + "\n" + warnings_str).strip(),
                }

        result["__summary__"] = {
            "errors": str(total_errors),
            "warnings": str(total_warnings),
            "errors_warnings": "",
        }
        return result

    @Slot(result=str)
    def getGameVersion(self) -> str:
        if self._metadata_manager:
            return self._metadata_manager.game_version or ""
        return ""

    @Slot(result=bool)
    def isInitialized(self) -> bool:
        return self._initialized
