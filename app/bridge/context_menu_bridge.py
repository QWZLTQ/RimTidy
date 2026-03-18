"""
Bridge for mod context menu actions.
Replicates the right-click menu from the original Widget UI.
"""

from loguru import logger
from PySide6.QtCore import QObject, Signal, Slot


class ContextMenuBridge(QObject):
    """Handles right-click context menu actions for mod items."""

    statusMessage = Signal(str)

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)

    def _mm(self):  # type: ignore[no-untyped-def]
        from app.utils.metadata import MetadataManager
        return MetadataManager.instance()

    @Slot(str, result="QVariant")
    def getModMenuInfo(self, uuid: str) -> dict:
        """Return info needed to build the context menu for a mod."""
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            return {
                "name": meta.get("name", ""),
                "packageid": meta.get("packageid", ""),
                "path": meta.get("path", ""),
                "dataSource": meta.get("data_source", ""),
                "hasUrl": bool(meta.get("url") or meta.get("steam_url")),
                "url": meta.get("url") or meta.get("steam_url") or "",
                "hasSteamUri": bool(meta.get("steam_uri")),
                "steamUri": meta.get("steam_uri", ""),
                "hasGit": bool(meta.get("git_repo")),
                "hasSteamcmd": bool(meta.get("steamcmd")),
                "publishedfileid": meta.get("publishedfileid", ""),
            }
        except Exception as e:
            logger.error(f"getModMenuInfo failed: {e}")
            return {}

    @Slot(str)
    def openModFolder(self, uuid: str) -> None:
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            path = meta.get("path", "")
            if path:
                from app.utils.generic import platform_specific_open
                platform_specific_open(path)
        except Exception as e:
            logger.error(f"openModFolder failed: {e}")

    @Slot(str)
    def openModUrl(self, uuid: str) -> None:
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            url = meta.get("url") or meta.get("steam_url")
            if url:
                from app.utils.generic import open_url_browser
                open_url_browser(url)
        except Exception as e:
            logger.error(f"openModUrl failed: {e}")

    @Slot(str)
    def openModInSteam(self, uuid: str) -> None:
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            uri = meta.get("steam_uri")
            if uri:
                from app.utils.generic import open_url_browser
                open_url_browser(uri)
        except Exception as e:
            logger.error(f"openModInSteam failed: {e}")

    @Slot(str)
    def copyPackageIdToClipboard(self, uuid: str) -> None:
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            pid = meta.get("packageid", "")
            if pid:
                from app.utils.generic import copy_to_clipboard_safely
                copy_to_clipboard_safely(pid)
                self.statusMessage.emit(f"Copied: {pid}")
        except Exception as e:
            logger.error(f"copyPackageId failed: {e}")

    @Slot(str)
    def copyUrlToClipboard(self, uuid: str) -> None:
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            url = meta.get("url") or meta.get("steam_url") or ""
            if url:
                from app.utils.generic import copy_to_clipboard_safely
                copy_to_clipboard_safely(url)
                self.statusMessage.emit(f"Copied: {url}")
        except Exception as e:
            logger.error(f"copyUrl failed: {e}")

    @Slot(str)
    def toggleWarning(self, uuid: str) -> None:
        """Toggle warning suppression for a mod."""
        try:
            from app.models.settings import Settings
            from app.controllers.metadata_db_controller import AuxMetadataController
            s = Settings(); s.load()
            meta = self._mm().internal_local_metadata.get(uuid, {})
            mod_path = meta.get("path", "")
            if mod_path:
                aux = AuxMetadataController.get_or_create_cached_instance(s.aux_db_path)
                with aux.Session() as session:
                    entry = aux.get(session, mod_path)
                    new_val = not (entry.warning_toggled if entry else False)
                    aux.update(session, mod_path, warning_toggled=new_val)
                    self.statusMessage.emit(f"Warning {'suppressed' if new_val else 'enabled'}")
        except Exception as e:
            logger.error(f"toggleWarning failed: {e}")

    @Slot(str)
    def editModRules(self, uuid: str) -> None:
        """Open rule editor for a mod."""
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            pid = meta.get("packageid", "")
            if pid:
                from app.utils.event_bus import EventBus
                EventBus().do_rule_editor.emit()
                self.statusMessage.emit(f"Rule editor opened for {pid}")
        except Exception as e:
            logger.error(f"editModRules failed: {e}")

    @Slot(str)
    def openModFolderInEditor(self, uuid: str) -> None:
        """Open mod folder in configured text editor."""
        try:
            from app.models.settings import Settings
            s = Settings(); s.load()
            editor = s.text_editor_location
            if not editor:
                self.statusMessage.emit("No text editor configured")
                return
            meta = self._mm().internal_local_metadata.get(uuid, {})
            path = meta.get("path", "")
            if path:
                from app.utils.generic import launch_process
                launch_process(editor, [path])
        except Exception as e:
            logger.error(f"openModFolderInEditor failed: {e}")

    @Slot(str)
    def changeModColor(self, uuid: str) -> None:
        """Change a mod's color via QColorDialog."""
        try:
            from PySide6.QtWidgets import QColorDialog
            color = QColorDialog.getColor()
            if color.isValid():
                from app.utils.aux_db_utils import auxdb_update_mod_color
                from app.models.settings import Settings
                from app.controllers.settings_controller import SettingsController
                from app.views.settings_dialog import SettingsDialog
                s = Settings(); s.load()
                sc = SettingsController(model=s, view=SettingsDialog())
                auxdb_update_mod_color(sc, uuid, color)
                self.statusMessage.emit(f"Color changed to {color.name()}")
        except Exception as e:
            logger.error(f"changeModColor failed: {e}")

    @Slot(str)
    def resetModColor(self, uuid: str) -> None:
        """Reset a mod's color."""
        try:
            from app.utils.aux_db_utils import auxdb_update_mod_color
            from app.models.settings import Settings
            from app.controllers.settings_controller import SettingsController
            from app.views.settings_dialog import SettingsDialog
            s = Settings(); s.load()
            sc = SettingsController(model=s, view=SettingsDialog())
            auxdb_update_mod_color(sc, uuid, None)
            self.statusMessage.emit("Mod color reset")
        except Exception as e:
            logger.error(f"resetModColor failed: {e}")

    @Slot(str)
    def redownloadGitMod(self, uuid: str) -> None:
        """Re-pull a git-based mod."""
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            path = meta.get("path", "")
            if path and meta.get("git_repo"):
                import pygit2
                repo = pygit2.Repository(path)
                remote = repo.remotes["origin"]
                remote.fetch()
                # Reset to remote HEAD
                branch = repo.head.shorthand
                remote_ref = repo.references.get(f"refs/remotes/origin/{branch}")
                if remote_ref:
                    repo.reset(remote_ref.target, pygit2.GIT_RESET_HARD)
                self.statusMessage.emit(f"Updated git mod: {meta.get('name', '')}")
                logger.info(f"Git pull for: {path}")
        except Exception as e:
            logger.error(f"redownloadGitMod failed: {e}")
            self.statusMessage.emit(f"Git update failed: {e}")

    @Slot(str)
    def redownloadSteamcmdMod(self, uuid: str) -> None:
        """Re-download a mod via SteamCMD."""
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            pfid = meta.get("publishedfileid", "")
            if pfid:
                from app.utils.event_bus import EventBus
                EventBus().do_download_mods_with_steamcmd.emit([pfid])
                self.statusMessage.emit(f"SteamCMD download started for {meta.get('name', '')}")
        except Exception as e:
            logger.error(f"redownloadSteamcmdMod failed: {e}")

    @Slot(str)
    def resubscribeSteamMod(self, uuid: str) -> None:
        """Re-subscribe to a workshop mod via Steam."""
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            pfid = meta.get("publishedfileid", "")
            if pfid:
                from app.utils.generic import open_url_browser
                open_url_browser(f"steam://url/CommunityFilePage/{pfid}")
                self.statusMessage.emit(f"Opening Steam for: {meta.get('name', '')}")
        except Exception as e:
            logger.error(f"resubscribeSteamMod failed: {e}")

    @Slot(str)
    def unsubscribeSteamMod(self, uuid: str) -> None:
        """Unsubscribe from a workshop mod."""
        try:
            meta = self._mm().internal_local_metadata.get(uuid, {})
            pfid = meta.get("publishedfileid", "")
            if pfid:
                from app.utils.event_bus import EventBus
                EventBus().do_steamworks_api_call.emit([["unsubscribe", pfid]])
                self.statusMessage.emit(f"Unsubscribing: {meta.get('name', '')}")
        except Exception as e:
            logger.error(f"unsubscribeSteamMod failed: {e}")

    @Slot(str)
    def deleteModFolder(self, uuid: str) -> None:
        """Delete mod from disk."""
        try:
            import shutil
            meta = self._mm().internal_local_metadata.get(uuid, {})
            path = meta.get("path", "")
            if path:
                from pathlib import Path
                p = Path(path)
                if p.exists() and p.is_dir():
                    shutil.rmtree(str(p))
                    self.statusMessage.emit(f"Deleted: {meta.get('name', path)}")
                    logger.info(f"Deleted mod folder: {path}")
        except Exception as e:
            logger.error(f"deleteModFolder failed: {e}")
