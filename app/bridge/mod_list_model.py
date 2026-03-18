"""
QAbstractListModel that bridges mod list data from Python MetadataManager to QML ListView.
Supports drag-drop reordering, multi-select, and all mod metadata roles.
"""

from enum import IntEnum
from typing import Any

from loguru import logger
from PySide6.QtCore import (
    QAbstractListModel,
    QByteArray,
    QModelIndex,
    QObject,
    Qt,
    Signal,
    Slot,
)


class ModListRoles(IntEnum):
    """Custom roles for mod list data access from QML."""

    UuidRole = Qt.ItemDataRole.UserRole + 1
    NameRole = Qt.ItemDataRole.UserRole + 2
    PackageIdRole = Qt.ItemDataRole.UserRole + 3
    DataSourceRole = Qt.ItemDataRole.UserRole + 4
    HasCSharpRole = Qt.ItemDataRole.UserRole + 5
    HasXmlRole = Qt.ItemDataRole.UserRole + 6
    HasGitRole = Qt.ItemDataRole.UserRole + 7
    HasSteamcmdRole = Qt.ItemDataRole.UserRole + 8
    ErrorsRole = Qt.ItemDataRole.UserRole + 9
    WarningsRole = Qt.ItemDataRole.UserRole + 10
    ErrorsWarningsRole = Qt.ItemDataRole.UserRole + 11
    FilteredRole = Qt.ItemDataRole.UserRole + 12
    InvalidRole = Qt.ItemDataRole.UserRole + 13
    MismatchRole = Qt.ItemDataRole.UserRole + 14
    AlternativeRole = Qt.ItemDataRole.UserRole + 15
    ModColorRole = Qt.ItemDataRole.UserRole + 16
    IsNewRole = Qt.ItemDataRole.UserRole + 17
    InSaveRole = Qt.ItemDataRole.UserRole + 18
    WarningToggledRole = Qt.ItemDataRole.UserRole + 19
    PathRole = Qt.ItemDataRole.UserRole + 20
    AuthorsRole = Qt.ItemDataRole.UserRole + 21
    VersionRole = Qt.ItemDataRole.UserRole + 22


class ModListModel(QAbstractListModel):
    """
    List model backing a QML ListView. Each item represents a mod identified by UUID.
    Metadata is fetched from MetadataManager on demand.
    """

    countChanged = Signal(int)
    listUpdated = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._uuids: list[str] = []
        # Optional per-item overrides (errors, warnings, colors, etc.)
        self._item_meta: dict[str, dict[str, Any]] = {}

    # ---- QAbstractListModel API ----

    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:
        return len(self._uuids)

    def data(self, index: QModelIndex, role: int = Qt.ItemDataRole.DisplayRole) -> Any:
        if not index.isValid() or index.row() >= len(self._uuids):
            return None

        uuid = self._uuids[index.row()]
        meta = self._get_metadata(uuid)
        item_meta = self._item_meta.get(uuid, {})

        if role == Qt.ItemDataRole.DisplayRole or role == ModListRoles.NameRole:
            name = meta.get("name") if meta else None
            return name if isinstance(name, str) else "Unknown mod"

        if role == ModListRoles.UuidRole:
            return uuid
        if role == ModListRoles.PackageIdRole:
            return meta.get("packageid", "") if meta else ""
        if role == ModListRoles.DataSourceRole:
            return meta.get("data_source", "local") if meta else "local"
        if role == ModListRoles.HasCSharpRole:
            return meta.get("csharp") is not None if meta else False
        if role == ModListRoles.HasXmlRole:
            return meta.get("csharp") is None if meta else True
        if role == ModListRoles.HasGitRole:
            if meta:
                return meta.get("data_source") == "local" and bool(meta.get("git_repo")) and not meta.get("steamcmd")
            return False
        if role == ModListRoles.HasSteamcmdRole:
            if meta:
                return meta.get("data_source") == "local" and bool(meta.get("steamcmd"))
            return False
        if role == ModListRoles.ErrorsRole:
            return item_meta.get("errors", "")
        if role == ModListRoles.WarningsRole:
            return item_meta.get("warnings", "")
        if role == ModListRoles.ErrorsWarningsRole:
            return item_meta.get("errors_warnings", "")
        if role == ModListRoles.FilteredRole:
            return item_meta.get("filtered", False)
        if role == ModListRoles.InvalidRole:
            return item_meta.get("invalid", meta.get("invalid", False) if meta else False)
        if role == ModListRoles.MismatchRole:
            return item_meta.get("mismatch", False)
        if role == ModListRoles.AlternativeRole:
            return item_meta.get("alternative", "")
        if role == ModListRoles.ModColorRole:
            return item_meta.get("mod_color", "")
        if role == ModListRoles.IsNewRole:
            return item_meta.get("is_new", False)
        if role == ModListRoles.InSaveRole:
            return item_meta.get("in_save", False)
        if role == ModListRoles.WarningToggledRole:
            return item_meta.get("warning_toggled", False)
        if role == ModListRoles.PathRole:
            return meta.get("path", "") if meta else ""
        if role == ModListRoles.AuthorsRole:
            authors = meta.get("authors") if meta else None
            if isinstance(authors, str):
                return authors
            if isinstance(authors, dict):
                li = authors.get("li")
                if isinstance(li, list):
                    return ", ".join(str(a) for a in li)
                return str(li) if li else ""
            if isinstance(authors, list):
                return ", ".join(str(a) for a in authors)
            return ""
        if role == ModListRoles.VersionRole:
            return meta.get("modversion", "") if meta else ""

        return None

    def roleNames(self) -> dict[int, QByteArray]:
        return {
            Qt.ItemDataRole.DisplayRole: QByteArray(b"display"),
            ModListRoles.UuidRole: QByteArray(b"uuid"),
            ModListRoles.NameRole: QByteArray(b"name"),
            ModListRoles.PackageIdRole: QByteArray(b"packageId"),
            ModListRoles.DataSourceRole: QByteArray(b"dataSource"),
            ModListRoles.HasCSharpRole: QByteArray(b"hasCSharp"),
            ModListRoles.HasXmlRole: QByteArray(b"hasXml"),
            ModListRoles.HasGitRole: QByteArray(b"hasGit"),
            ModListRoles.HasSteamcmdRole: QByteArray(b"hasSteamcmd"),
            ModListRoles.ErrorsRole: QByteArray(b"errors"),
            ModListRoles.WarningsRole: QByteArray(b"warnings"),
            ModListRoles.ErrorsWarningsRole: QByteArray(b"errorsWarnings"),
            ModListRoles.FilteredRole: QByteArray(b"filtered"),
            ModListRoles.InvalidRole: QByteArray(b"invalid"),
            ModListRoles.MismatchRole: QByteArray(b"mismatch"),
            ModListRoles.AlternativeRole: QByteArray(b"alternative"),
            ModListRoles.ModColorRole: QByteArray(b"modColor"),
            ModListRoles.IsNewRole: QByteArray(b"isNew"),
            ModListRoles.InSaveRole: QByteArray(b"inSave"),
            ModListRoles.WarningToggledRole: QByteArray(b"warningToggled"),
            ModListRoles.PathRole: QByteArray(b"modPath"),
            ModListRoles.AuthorsRole: QByteArray(b"authors"),
            ModListRoles.VersionRole: QByteArray(b"modVersion"),
        }

    # ---- Drag & Drop support ----

    def flags(self, index: QModelIndex) -> Qt.ItemFlag:
        default = super().flags(index)
        if index.isValid():
            return default | Qt.ItemFlag.ItemIsDragEnabled | Qt.ItemFlag.ItemIsDropEnabled
        return default | Qt.ItemFlag.ItemIsDropEnabled

    def moveRow(
        self,
        sourceParent: QModelIndex,
        sourceRow: int,
        destinationParent: QModelIndex,
        destinationRow: int,
    ) -> bool:
        if sourceRow < 0 or sourceRow >= len(self._uuids):
            return False
        if destinationRow < 0 or destinationRow > len(self._uuids):
            return False
        # Qt docs: beginMoveRows fails if dest == source or dest == source+1 (no-op move)
        if destinationRow == sourceRow or destinationRow == sourceRow + 1:
            return False

        self.beginMoveRows(sourceParent, sourceRow, sourceRow, destinationParent, destinationRow)
        uuid = self._uuids.pop(sourceRow)
        insert_at = destinationRow if destinationRow < sourceRow else destinationRow - 1
        if insert_at < 0:
            insert_at = 0
        if insert_at > len(self._uuids):
            insert_at = len(self._uuids)
        self._uuids.insert(insert_at, uuid)
        self.endMoveRows()
        self.listUpdated.emit()
        return True

    # ---- Python API ----

    @Slot(list)
    def populate(self, uuids: list[str]) -> None:
        """Replace the entire list with new UUIDs."""
        self.beginResetModel()
        self._uuids = list(uuids)
        self.endResetModel()
        self.countChanged.emit(len(self._uuids))
        self.listUpdated.emit()
        logger.debug(f"ModListModel populated with {len(self._uuids)} mods")

    @Slot(result=list)
    def getUuids(self) -> list[str]:
        """Return current UUID list (preserves order)."""
        return list(self._uuids)

    @Slot(int, int)
    def moveItem(self, fromIndex: int, toIndex: int) -> None:
        """Move an item within the list (called from QML drag-drop)."""
        if fromIndex == toIndex:
            return
        # For moveRow, if moving down, Qt expects dest = target + 1
        dest = toIndex if toIndex < fromIndex else toIndex + 1
        self.moveRow(QModelIndex(), fromIndex, QModelIndex(), dest)

    @Slot(list)
    def removeByUuids(self, uuids: list[str]) -> None:
        """Remove items by UUID list."""
        uuid_set = set(uuids)
        rows_to_remove = [i for i, u in enumerate(self._uuids) if u in uuid_set]
        # Remove from end to preserve indices
        for row in reversed(rows_to_remove):
            self.beginRemoveRows(QModelIndex(), row, row)
            self._uuids.pop(row)
            self.endRemoveRows()
        self.countChanged.emit(len(self._uuids))
        self.listUpdated.emit()

    @Slot(list, int)
    def insertUuids(self, uuids: list[str], at: int = -1) -> None:
        """Insert UUIDs at position (default: end)."""
        if at < 0 or at > len(self._uuids):
            at = len(self._uuids)
        if not uuids:
            return
        self.beginInsertRows(QModelIndex(), at, at + len(uuids) - 1)
        for i, uuid in enumerate(uuids):
            self._uuids.insert(at + i, uuid)
        self.endInsertRows()
        self.countChanged.emit(len(self._uuids))
        self.listUpdated.emit()

    @Slot(str, str, "QVariant")
    def setItemMeta(self, uuid: str, key: str, value: Any) -> None:
        """Set per-item metadata override (errors, warnings, color, etc.)."""
        if uuid not in self._item_meta:
            self._item_meta[uuid] = {}
        self._item_meta[uuid][key] = value
        # Find row and emit dataChanged
        try:
            row = self._uuids.index(uuid)
            idx = self.index(row)
            self.dataChanged.emit(idx, idx)
        except ValueError:
            pass

    @Slot("QVariant")
    def setBatchItemMeta(self, data: Any) -> None:
        """Set metadata for multiple items at once. Accepts QJSValue or dict."""
        # Convert QJSValue to Python dict if needed
        if hasattr(data, "toVariant"):
            data = data.toVariant()
        if not isinstance(data, dict):
            logger.warning(f"setBatchItemMeta: expected dict, got {type(data)}")
            return
        self._item_meta.update(data)
        if self._uuids:
            self.dataChanged.emit(
                self.index(0),
                self.index(len(self._uuids) - 1),
            )

    @Slot(int, result=str)
    def getUuidAt(self, row: int) -> str:
        """Get UUID at a specific row index."""
        if 0 <= row < len(self._uuids):
            return self._uuids[row]
        return ""

    def _get_metadata(self, uuid: str) -> dict[str, Any] | None:
        """Fetch metadata from MetadataManager. Returns None if not found."""
        try:
            from app.utils.metadata import MetadataManager

            mm = MetadataManager.instance()
            return mm.internal_local_metadata.get(uuid)
        except Exception:
            return None
