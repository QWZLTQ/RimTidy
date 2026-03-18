"""
Custom frameless title bar widget for modern UI style.
Provides window dragging, minimize/maximize/close buttons.
Menu bar stays below the title bar as a separate widget.
"""

from PySide6.QtCore import QPoint, QSize, Qt
from PySide6.QtGui import QColor, QMouseEvent, QPainter, QPen
from PySide6.QtWidgets import (
    QHBoxLayout,
    QLabel,
    QStyle,
    QStyleOption,
    QToolButton,
    QWidget,
)

_ICON_COLOR = QColor("#5C5C5C")
_ICON_COLOR_CLOSE_HOVER = QColor("#FFFFFF")


class MinimizeButton(QToolButton):
    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setFixedSize(46, 32)
        self.setCursor(Qt.CursorShape.PointingHandCursor)

    def paintEvent(self, event: object) -> None:
        opt = QStyleOption()
        opt.initFrom(self)
        p = QPainter(self)
        self.style().drawPrimitive(QStyle.PrimitiveElement.PE_Widget, opt, p, self)
        p.setPen(QPen(_ICON_COLOR, 1))
        cx, cy = self.width() // 2, self.height() // 2
        p.drawLine(cx - 5, cy, cx + 5, cy)
        p.end()


class MaximizeButton(QToolButton):
    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setFixedSize(46, 32)
        self.setCursor(Qt.CursorShape.PointingHandCursor)
        self.is_maximized = False

    def paintEvent(self, event: object) -> None:
        opt = QStyleOption()
        opt.initFrom(self)
        p = QPainter(self)
        self.style().drawPrimitive(QStyle.PrimitiveElement.PE_Widget, opt, p, self)
        p.setPen(QPen(_ICON_COLOR, 1))
        p.setBrush(Qt.BrushStyle.NoBrush)
        cx, cy = self.width() // 2, self.height() // 2
        if self.is_maximized:
            p.drawRect(cx - 3, cy - 1, 7, 7)
            p.drawRect(cx - 5, cy - 4, 7, 7)
        else:
            p.drawRect(cx - 5, cy - 4, 10, 8)
        p.end()


class CloseButton(QToolButton):
    def __init__(self, parent: QWidget | None = None) -> None:
        super().__init__(parent)
        self.setFixedSize(46, 32)
        self.setCursor(Qt.CursorShape.PointingHandCursor)
        self._hovered = False

    def enterEvent(self, event: object) -> None:
        self._hovered = True
        self.update()
        super().enterEvent(event)  # type: ignore[arg-type]

    def leaveEvent(self, event: object) -> None:
        self._hovered = False
        self.update()
        super().leaveEvent(event)  # type: ignore[arg-type]

    def paintEvent(self, event: object) -> None:
        opt = QStyleOption()
        opt.initFrom(self)
        p = QPainter(self)
        self.style().drawPrimitive(QStyle.PrimitiveElement.PE_Widget, opt, p, self)
        color = _ICON_COLOR_CLOSE_HOVER if self._hovered else _ICON_COLOR
        p.setPen(QPen(color, 1))
        cx, cy = self.width() // 2, self.height() // 2
        p.drawLine(cx - 4, cy - 4, cx + 4, cy + 4)
        p.drawLine(cx + 4, cy - 4, cx - 4, cy + 4)
        p.end()


class CustomTitleBar(QWidget):
    """
    A custom title bar: app title on the left, window controls on the right.
    No heavy animations — keeps the UI responsive.
    """

    def __init__(self, parent: QWidget) -> None:
        super().__init__(parent)
        self._window = parent
        self._drag_pos: QPoint | None = None

        self.setObjectName("customTitleBar")
        self.setFixedHeight(34)

        layout = QHBoxLayout(self)
        layout.setContentsMargins(14, 0, 0, 0)
        layout.setSpacing(0)

        # App title
        self.title_label = QLabel("RimTidy")
        self.title_label.setObjectName("titleBarLabel")
        layout.addWidget(self.title_label)

        # Spacer
        layout.addStretch()

        # Window control buttons
        self.btn_minimize = MinimizeButton(self)
        self.btn_minimize.setObjectName("titleBarBtnMinimize")
        self.btn_minimize.clicked.connect(self._on_minimize)
        layout.addWidget(self.btn_minimize)

        self.btn_maximize = MaximizeButton(self)
        self.btn_maximize.setObjectName("titleBarBtnMaximize")
        self.btn_maximize.clicked.connect(self._on_maximize)
        layout.addWidget(self.btn_maximize)

        self.btn_close = CloseButton(self)
        self.btn_close.setObjectName("titleBarBtnClose")
        self.btn_close.clicked.connect(self._on_close)
        layout.addWidget(self.btn_close)

    def set_title(self, title: str) -> None:
        self.title_label.setText(title)

    def paintEvent(self, event: object) -> None:
        opt = QStyleOption()
        opt.initFrom(self)
        p = QPainter(self)
        self.style().drawPrimitive(QStyle.PrimitiveElement.PE_Widget, opt, p, self)
        p.end()

    def _on_minimize(self) -> None:
        self._window.showMinimized()

    def _on_maximize(self) -> None:
        if self._window.isMaximized():
            self._window.showNormal()
            self.btn_maximize.is_maximized = False
        else:
            self._window.showMaximized()
            self.btn_maximize.is_maximized = True
        self.btn_maximize.update()

    def _on_close(self) -> None:
        self._window.close()

    # --- Window dragging ---

    def mousePressEvent(self, event: QMouseEvent) -> None:
        if event.button() == Qt.MouseButton.LeftButton:
            self._drag_pos = event.globalPosition().toPoint() - self._window.pos()
        super().mousePressEvent(event)

    def mouseMoveEvent(self, event: QMouseEvent) -> None:
        if self._drag_pos is not None and event.buttons() & Qt.MouseButton.LeftButton:
            if self._window.isMaximized():
                ratio = event.position().x() / self.width()
                self._window.showNormal()
                self.btn_maximize.is_maximized = False
                self.btn_maximize.update()
                new_x = int(self._window.width() * ratio)
                self._drag_pos = QPoint(new_x, event.position().toPoint().y())
            self._window.move(event.globalPosition().toPoint() - self._drag_pos)
        super().mouseMoveEvent(event)

    def mouseReleaseEvent(self, event: QMouseEvent) -> None:
        self._drag_pos = None
        super().mouseReleaseEvent(event)

    def mouseDoubleClickEvent(self, event: QMouseEvent) -> None:
        if event.button() == Qt.MouseButton.LeftButton:
            self._on_maximize()
        super().mouseDoubleClickEvent(event)

    def sizeHint(self) -> QSize:
        return QSize(self._window.width(), 34)
