"""
Bridge object that exposes mod info properties to QML.
When a mod is selected, call displayModInfo(uuid) to update all properties.
"""

import os
from datetime import datetime
from pathlib import Path

from loguru import logger
from PySide6.QtCore import Property, QObject, QThread, Signal, Slot


class _TranslateWorker(QThread):
    """Background thread for translation using translators library."""

    finished = Signal(str)
    error = Signal(str)

    def __init__(self, text: str, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._text = text

    def run(self) -> None:
        try:
            import re

            import translators as ts

            # Clean up source text: collapse whitespace, remove excessive newlines
            clean = re.sub(r"\n{3,}", "\n\n", self._text).strip()

            # Skip if already Chinese
            chinese_chars = len(re.findall(r"[\u4e00-\u9fff]", clean))
            if chinese_chars > len(clean) * 0.3:
                self.finished.emit(clean)
                return

            result = ts.translate_text(
                clean, translator="bing", to_language="zh-Hans"
            )
            self.finished.emit(str(result))
        except Exception as e:
            self.error.emit(str(e))


class ModInfoBridge(QObject):
    """Exposes selected mod's metadata as QML-bindable properties."""

    infoChanged = Signal()
    translateResult = Signal(str)  # successful translation
    translateError = Signal(str)  # error message

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._name = ""
        self._package_id = ""
        self._authors = ""
        self._mod_version = ""
        self._supported_versions = ""
        self._folder_size = ""
        self._path = ""
        self._last_touched = ""
        self._filesystem_time = ""
        self._external_times = ""
        self._description = "<center>Welcome to RimTidy!</center>"
        self._preview_image = ""
        self._is_invalid = False
        self._is_scenario = False
        self._scenario_summary = ""
        self._user_notes = ""
        self._uuid = ""
        self._data_source = ""

    def _get(self, attr: str) -> str:
        return getattr(self, attr)

    # --- Properties ---
    @Property(str, notify=infoChanged)
    def name(self) -> str:
        return self._name

    @Property(str, notify=infoChanged)
    def packageId(self) -> str:
        return self._package_id

    @Property(str, notify=infoChanged)
    def authors(self) -> str:
        return self._authors

    @Property(str, notify=infoChanged)
    def modVersion(self) -> str:
        return self._mod_version

    @Property(str, notify=infoChanged)
    def supportedVersions(self) -> str:
        return self._supported_versions

    @Property(str, notify=infoChanged)
    def folderSize(self) -> str:
        return self._folder_size

    @Property(str, notify=infoChanged)
    def modPath(self) -> str:
        return self._path

    @Property(str, notify=infoChanged)
    def lastTouched(self) -> str:
        return self._last_touched

    @Property(str, notify=infoChanged)
    def filesystemTime(self) -> str:
        return self._filesystem_time

    @Property(str, notify=infoChanged)
    def externalTimes(self) -> str:
        return self._external_times

    @Property(str, notify=infoChanged)
    def description(self) -> str:
        return self._description

    @Property(str, notify=infoChanged)
    def previewImage(self) -> str:
        return self._preview_image

    @Property(bool, notify=infoChanged)
    def isInvalid(self) -> bool:
        return self._is_invalid

    @Property(bool, notify=infoChanged)
    def isScenario(self) -> bool:
        return self._is_scenario

    @Property(str, notify=infoChanged)
    def scenarioSummary(self) -> str:
        return self._scenario_summary

    @Property(str, notify=infoChanged)
    def userNotes(self) -> str:
        return self._user_notes

    @Property(str, notify=infoChanged)
    def uuid(self) -> str:
        return self._uuid

    @Property(str, notify=infoChanged)
    def dataSource(self) -> str:
        return self._data_source

    # --- Slots ---

    @Slot(str)
    def displayModInfo(self, uuid: str) -> None:
        """Fetch metadata for uuid and update all properties."""
        try:
            from app.utils.metadata import MetadataManager

            mm = MetadataManager.instance()
            meta = mm.internal_local_metadata.get(uuid, {})
        except Exception:
            meta = {}

        self._uuid = uuid
        self._is_invalid = bool(meta.get("invalid"))
        self._is_scenario = bool(meta.get("scenario"))
        self._data_source = meta.get("data_source", "")

        # Name
        name = meta.get("name")
        self._name = name if isinstance(name, str) else "Unknown mod"

        # Package ID
        self._package_id = meta.get("packageid", "")

        # Authors
        authors = meta.get("authors")
        if isinstance(authors, str):
            self._authors = authors
        elif isinstance(authors, dict):
            li = authors.get("li")
            if isinstance(li, list):
                self._authors = ", ".join(str(a) for a in li)
            else:
                self._authors = str(li) if li else ""
        elif isinstance(authors, list):
            self._authors = ", ".join(str(a) for a in authors)
        else:
            self._authors = ""

        # Version
        mv = meta.get("modversion", "")
        if isinstance(mv, dict):
            self._mod_version = mv.get("#text", "")
        else:
            self._mod_version = str(mv) if mv else ""

        # Supported versions
        sv = meta.get("supportedversions")
        if isinstance(sv, dict):
            li = sv.get("li")
            if isinstance(li, list):
                self._supported_versions = ", ".join(str(v) for v in li)
            else:
                self._supported_versions = str(li) if li else ""
        elif isinstance(sv, str):
            self._supported_versions = sv
        else:
            self._supported_versions = ""

        # Path
        self._path = meta.get("path", "")

        # Folder size
        mod_path = meta.get("path", "")
        if mod_path and os.path.isdir(mod_path):
            try:
                total = sum(f.stat().st_size for f in Path(mod_path).rglob("*") if f.is_file())
                if total >= 1024 * 1024:
                    self._folder_size = f"{total / (1024*1024):.1f} MB"
                elif total >= 1024:
                    self._folder_size = f"{total / 1024:.1f} KB"
                else:
                    self._folder_size = f"{total} B"
            except Exception:
                self._folder_size = ""
        else:
            self._folder_size = ""

        # Timestamps
        self._last_touched = self._format_timestamp(meta.get("internal_time_touched"))
        if mod_path and os.path.exists(mod_path):
            try:
                self._filesystem_time = self._format_timestamp(int(os.path.getmtime(mod_path)))
            except Exception:
                self._filesystem_time = ""
        else:
            self._filesystem_time = ""

        # External times
        parts = []
        for key, label in [
            ("external_time_created", "Created"),
            ("external_time_updated", "Updated"),
            ("internal_time_updated", "Steam Updated"),
        ]:
            ts = meta.get(key)
            if ts:
                formatted = self._format_timestamp(ts)
                if formatted:
                    parts.append(f"{label}: {formatted}")
        self._external_times = "\n".join(parts)

        # Scenario summary
        self._scenario_summary = meta.get("summary", "") if self._is_scenario else ""

        # Description
        desc = meta.get("description", "")
        if isinstance(desc, str):
            self._description = desc
        else:
            self._description = ""

        # Preview image
        self._preview_image = self._find_preview_image(mod_path)

        self.infoChanged.emit()
        logger.debug(f"ModInfoBridge updated for: {self._name}")

    @Slot(str)
    def openFolder(self, path: str) -> None:
        """Open a folder in the system file manager."""
        if path and os.path.isdir(path):
            try:
                from app.utils.generic import platform_specific_open

                platform_specific_open(path)
            except Exception as e:
                logger.error(f"Failed to open folder: {e}")

    @staticmethod
    def _format_timestamp(ts: object) -> str:
        if not ts:
            return ""
        try:
            dt = datetime.fromtimestamp(int(ts))
            return dt.strftime("%Y-%m-%d %H:%M:%S")
        except (ValueError, OSError, OverflowError, TypeError):
            return ""

    @Slot(str)
    def translateText(self, text: str) -> None:
        """Translate text to Chinese via free Baidu Translate (async)."""
        if not text or not text.strip():
            self.translateError.emit("No text to translate")
            return
        worker = _TranslateWorker(text.strip(), self)
        worker.finished.connect(self.translateResult.emit)
        worker.error.connect(self.translateError.emit)
        worker.finished.connect(worker.deleteLater)
        worker.error.connect(worker.deleteLater)
        worker.start()

    @staticmethod
    def _find_preview_image(mod_path: str) -> str:
        """Find Preview.png (case-insensitive) and return file:// URL."""
        if not mod_path or not os.path.isdir(mod_path):
            return ""
        about_dir = Path(mod_path)
        # Look for About folder
        for d in about_dir.iterdir():
            if d.is_dir() and d.name.lower() == "about":
                # Look for Preview.png
                for f in d.iterdir():
                    if f.is_file() and f.name.lower() == "preview.png":
                        return f.as_uri()
        return ""
