from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *
from enum import Enum, auto
class UniDeskDefines(QObject):
    @QEnum
    class ColorMode(Enum):
        ColorModeLight = 0
        ColorModeDark = 1
        ColorModeSystem = 2
    @QEnum    
    class FileMode(Enum):  
        FileModeFile = auto()
        FileModeFolder = auto()
    @QEnum
    class ApiRequestType(Enum):
        ApiTypeGet = 0
        ApiTypePost = 1
    def __init__(self):
        super().__init__()