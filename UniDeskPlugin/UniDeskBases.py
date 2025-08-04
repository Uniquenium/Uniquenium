from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *

class UniDeskBase(QQuickWindow):
    focusOut=Signal()
    rightClicked=Signal()
    def __init__(self):
        super().__init__()
        self.setFlag(Qt.WindowType.FramelessWindowHint,True)
        self.setFlag(Qt.WindowType.WindowStaysOnBottomHint,True)
        self.setFlag(Qt.WindowType.Tool,True)
        self._edges=None
        self._margins=4
    def focusOutEvent(self, arg__1):
        self.focusOut.emit()
        return super().focusOutEvent(arg__1)
    def mouseMoveEvent(self, event: QMouseEvent):
        if self.visibility()!=self.Visibility.Maximized and self.visibility()!=self.Visibility.FullScreen and self.property("fixSize")==False:
            p=event.pos()
            self._edges = None
            if p.x() < self._margins:
                self._edges = Qt.Edge.LeftEdge if self._edges==None else self._edges | Qt.Edge.LeftEdge
            if p.x() > (self.width() - self._margins) :
                self._edges = Qt.Edge.RightEdge if self._edges==None else self._edges | Qt.Edge.RightEdge
            if p.y() < self._margins :
                self._edges = Qt.Edge.TopEdge if self._edges==None else self._edges | Qt.Edge.TopEdge
            if p.y() > (self.height() - self._margins) :
                self._edges = Qt.Edge.BottomEdge if self._edges==None else self._edges | Qt.Edge.BottomEdge
            self.updateCursor()
        return super().mouseMoveEvent(event)
    def mousePressEvent(self, event: QMouseEvent):
        if event.button()==Qt.MouseButton.LeftButton:
            if self._edges!=None and self.property("canResize"):
                self.startSystemResize(self._edges)
            elif self.property("canMove"):
                self.startSystemMove()
        elif event.button()==Qt.MouseButton.RightButton:
            self.rightClicked.emit()
        return super().mousePressEvent(event)
    def mouseReleaseEvent(self, arg__1):
        self._edges=None
        return super().mouseReleaseEvent(arg__1)
    def updateCursor(self):
        if self._edges == None:
            self.setCursor(Qt.CursorShape.ArrowCursor)
        elif self._edges == Qt.Edge.LeftEdge or self._edges == Qt.Edge.RightEdge:
            self.setCursor(Qt.CursorShape.SizeHorCursor)
        elif self._edges == Qt.Edge.TopEdge or self._edges == Qt.Edge.BottomEdge:
            self.setCursor(Qt.CursorShape.SizeVerCursor)
        elif self._edges == Qt.Edge.LeftEdge | Qt.Edge.TopEdge or self._edges == Qt.Edge.RightEdge | Qt.Edge.BottomEdge:
            self.setCursor(Qt.CursorShape.SizeFDiagCursor)
        elif self._edges == Qt.Edge.RightEdge | Qt.Edge.TopEdge or self._edges == Qt.Edge.LeftEdge | Qt.Edge.BottomEdge:
            self.setCursor(Qt.CursorShape.SizeBDiagCursor)
    


class UniDeskWindowBase(QQuickWindow):
    focusOut=Signal()
    rightClicked=Signal()
    def __init__(self):
        super().__init__()
        self.setFlag(Qt.WindowType.FramelessWindowHint,True)
        self.setFlag(Qt.WindowType.Window,True)
        self.setFlag(Qt.WindowType.WindowMinimizeButtonHint,True)
        self.setFlag(Qt.WindowType.CustomizeWindowHint,True)
        self._edges=None
        self._margins=4
    def focusOutEvent(self, arg__1):
        self.focusOut.emit()
        return super().focusOutEvent(arg__1)
    def mouseMoveEvent(self, event: QMouseEvent):
        if self.visibility()!=self.Visibility.Maximized and self.visibility()!=self.Visibility.FullScreen and self.property("fixSize")==False:
            p=event.pos()
            self._edges = None
            if p.x() < self._margins:
                self._edges = Qt.Edge.LeftEdge if self._edges==None else self._edges | Qt.Edge.LeftEdge
            if p.x() > (self.width() - self._margins) :
                self._edges = Qt.Edge.RightEdge if self._edges==None else self._edges | Qt.Edge.RightEdge
            if p.y() < self._margins :
                self._edges = Qt.Edge.TopEdge if self._edges==None else self._edges | Qt.Edge.TopEdge
            if p.y() > (self.height() - self._margins) :
                self._edges = Qt.Edge.BottomEdge if self._edges==None else self._edges | Qt.Edge.BottomEdge
            self.updateCursor()
        return super().mouseMoveEvent(event)
    def mousePressEvent(self, event: QMouseEvent):
        if event.button()==Qt.MouseButton.LeftButton:
            if self._edges!=None:
                self.startSystemResize(self._edges)
            elif self.appBarHovered() and self.visibility()!=self.Visibility.Maximized and self.visibility()!=self.Visibility.FullScreen:
                self.startSystemMove()
        elif event.button()==Qt.MouseButton.RightButton:
            self.rightClicked.emit()
        return super().mousePressEvent(event)
    def mouseDoubleClickEvent(self, event: QMouseEvent):
        if event.button()==Qt.MouseButton.LeftButton:
            if self.appBarHovered():
                if self.visibility()!=self.Visibility.Maximized and self.visibility()!=self.Visibility.FullScreen:
                    self.showMaximized()
                else:
                    self.showNormal()
        return super().mouseDoubleClickEvent(event)
    def mouseReleaseEvent(self, arg__1):
        self._edges=None
        return super().mouseReleaseEvent(arg__1)
    def updateCursor(self):
        if self._edges == None:
            self.setCursor(Qt.CursorShape.ArrowCursor)
        elif self._edges == Qt.Edge.LeftEdge or self._edges == Qt.Edge.RightEdge:
            self.setCursor(Qt.CursorShape.SizeHorCursor)
        elif self._edges == Qt.Edge.TopEdge or self._edges == Qt.Edge.BottomEdge:
            self.setCursor(Qt.CursorShape.SizeVerCursor)
        elif self._edges == Qt.Edge.LeftEdge | Qt.Edge.TopEdge or self._edges == Qt.Edge.RightEdge | Qt.Edge.BottomEdge:
            self.setCursor(Qt.CursorShape.SizeFDiagCursor)
        elif self._edges == Qt.Edge.RightEdge | Qt.Edge.TopEdge or self._edges == Qt.Edge.LeftEdge | Qt.Edge.BottomEdge:
            self.setCursor(Qt.CursorShape.SizeBDiagCursor)
    def appBarHovered(self):
        return self.mapFromGlobal(QCursor.pos()).x()<self.property("appBarRightBorder") and self.mapFromGlobal(QCursor.pos()).y()<self.property("appBarHeight")