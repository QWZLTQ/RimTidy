"""
Bridge that exposes status bar messages to QML.
"""

from PySide6.QtCore import Property, QObject, Signal, Slot


class StatusBridge(QObject):
    """Status bar message bridge for QML."""

    messageChanged = Signal()

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self._message = "Ready"

    @Property(str, notify=messageChanged)
    def message(self) -> str:
        return self._message

    @Slot(str)
    def setMessage(self, msg: str) -> None:
        if self._message != msg:
            self._message = msg
            self.messageChanged.emit()
