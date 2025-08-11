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
        return super().mousePressEvent(event)
    def mouseReleaseEvent(self, event: QMouseEvent):
        self._edges=None
        if event.button()==Qt.MouseButton.RightButton:
            self.rightClicked.emit()
        return super().mouseReleaseEvent(event)
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
        return super().mousePressEvent(event)
    def mouseDoubleClickEvent(self, event: QMouseEvent):
        if event.button()==Qt.MouseButton.LeftButton:
            if self.appBarHovered():
                if self.visibility()!=self.Visibility.Maximized and self.visibility()!=self.Visibility.FullScreen:
                    self.showMaximized()
                else:
                    self.showNormal()
        return super().mouseDoubleClickEvent(event)
    def mouseReleaseEvent(self, event: QMouseEvent):
        self._edges=None
        if event.button()==Qt.MouseButton.RightButton:
            self.rightClicked.emit()
        return super().mouseReleaseEvent(event)
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


# 自定义的树形节点类
class TreeNode():
    # 初始化节点数据和父亲节点
    def __init__(self, data, parent=None):
        # 存储节点数据
        self._data = data
        # 存储父节点
        self._parent = parent
        # 存储子节点
        self._children = []

    # 添加一个子节点
    def appendChild(self, child):
        self._children.append(child)

    # 删除一个子节点
    def removeChild(self, item):
        self._children.remove(item)

    # 获取某一行的子节点
    def child(self, row):
        return self._children[row]

    # 获取子节点的个数
    def childCount(self):
        return len(self._children)

    # 获取列数
    def columnCount(self):
        return 1

    # 获取节点某一列的数据
    def data(self, column):
        if column == 0:
            return self._data
    def setData(self, column,data):
        if column==0:
            self._data=data

    # 获取父节点
    def parent(self):
        return self._parent

    # 获取该节点在父节点中的行号
    def row(self):
        if self._parent:
            return self._parent._children.index(self)

    # 判断节点是否包含子节点
    def hasChildren(self):
        return len(self._children) > 0

    def insertChild(self,child):
        self._children.insert(child)
    def popChild(self,index):
        self._children.pop(index)

# 自定义的树形数据模型
class UniDeskTreeModel(QAbstractItemModel):
    # 初始化根节点
    def __init__(self, root=None, parent=None):
        super().__init__(parent)
        # 如果没有传入根节点，则创建一个空的根节点作为根
        self._root = root or TreeNode(None)
        # self._root = root

    # 获取某个节点在模型中的Index
    def index(self, row, column, parent=QModelIndex()):
        if not self.hasIndex(row, column, parent):
            return QModelIndex()

        if not parent.isValid():
            parentItem = self._root
        else:
            parentItem = parent.internalPointer()

        childItem = parentItem.child(row)
        if childItem:
            return self.createIndex(row, column, childItem)
        else:
            return QModelIndex()

    # 获取某个节点的父节点的Index
    def parent(self, index: QModelIndex):
        if not index.isValid():
            return QModelIndex()

        childItem = index.internalPointer()
        parentItem = childItem.parent()

        if parentItem == self._root or parentItem==None:
            return QModelIndex()

        return self.createIndex(parentItem.row(), 0, parentItem)

    # 获取某个节点的子节点个数
    def rowCount(self, parent=QModelIndex()):
        if parent.column() > 0:
            return 0

        if not parent.isValid():
            parentItem = self._root
        else:
            parentItem = parent.internalPointer()

        return parentItem.childCount()

    # 获取列数，这里只有一列
    def columnCount(self, parent=QModelIndex()):
        return 1
    # 获取某个节点的数据
    def data(self, index: QModelIndex, role=Qt.ItemDataRole.DisplayRole):
        if not index.isValid():
            return None

        item = index.internalPointer()
        if role == Qt.ItemDataRole.DisplayRole:
            return item.data(index.column())
    @Slot(QModelIndex,str)
    def setData(self, index: QModelIndex,data,role=Qt.ItemDataRole.EditRole):
        if not index.isValid():
            return None

        item = index.internalPointer()
        if role == Qt.ItemDataRole.EditRole:
            return item.setData(index.column(),data)
    
    def flags(self, index: QModelIndex):
        if not index.isValid():
            return Qt.ItemFlag.NoItemFlags

        return super().flags(index)
    
    @Slot(int,QModelIndex)
    def insertRow(self, row, /, parent: QModelIndex = ...):
        self.layoutAboutToBeChanged.emit()
        parentItem=parent.internalPointer()
        child=TreeNode("",parentItem)
        parentItem.insertChild(row,child)
        self.layoutChanged.emit()
    @Slot(int,QModelIndex)
    def removeRow(self, row, /, parent: QModelIndex = ...):
        self.layoutAboutToBeChanged.emit()
        parentItem=parent.internalPointer()
        parentItem.popChild(row)
        self.layoutChanged.emit()
    def findR(self,data,parent:QModelIndex):
        parentItem=parent.internalPointer()
        if not parent.isValid():
            parentItem=self._root
        for i in range(parentItem.childCount()):
            idx=self.createIndex(i,0,parentItem.child(i))
            if parentItem.child(i)._data==data:
                return idx
            idx=self.findR(data,idx)
            if idx.isValid():
                return idx
        return self.createIndex(-1,-1)
    @Slot(str ,result=QModelIndex)
    def find(self,data):
        return self.findR(data,QModelIndex())
    @Slot(QModelIndex,result=QModelIndex)
    def appendRow(self,parent=QModelIndex()):
        self.layoutAboutToBeChanged.emit()
        if parent.isValid():
            parentItem=parent.internalPointer()
        else:
            parentItem=self._root
        child=TreeNode("",parentItem)
        parentItem.appendChild(child)
        self.layoutChanged.emit()
        return self.createIndex(parentItem.childCount()-1,0,child)

        


