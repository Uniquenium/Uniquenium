from PySide6.QtGui import *
from PySide6.QtQml import *
from PySide6.QtQuick import *
from PySide6.QtCore import *
import json
import datetime
import os
import importlib


data = {
    "./data/settings.json": {
        "hideTaskbar": False,
        "colorMode": 2,
        "primaryColor": {
            "<type>": "QColor",
            "red": 0,
            "green": 100,
            "blue": 255,
            "alpha": 255
        },
        "globalFontFamily":"微软雅黑",
        "customFontFamilyPaths":[
            
        ]
    },
    "./data/components.json": {
        "pages": [],
        "pageIndex": 0,
        "components": [],
    },
}
def object2json(obj):
    if isinstance(obj,QColor):
        return {
            "<type>":"QColor",
            "red": obj.red(),
            "green": obj.green(),
            "blue": obj.blue(),
            "alpha": obj.alpha()
        }
    if isinstance(obj, dict):
        new_obj = {}
        for key, value in obj.items():
            new_obj[key] = object2json(value)
        return new_obj
    if isinstance(obj, list):
        new_obj = []
        for i in obj:
            new_obj.append(object2json(i))
        return new_obj
    return obj
def json2object(jso):
    if isinstance(jso,dict):
        if jso.get("<type>")=="QColor":
            return QColor(jso['red'],jso['green'],jso['blue'],jso["alpha"])
    
    if isinstance(jso, dict):
        new_obj = {}
        for key, value in jso.items():
            new_obj[key] = json2object(value)
        return new_obj
    if isinstance(jso, list):
        new_obj = []
        for i in jso:
            new_obj.append(json2object(i))
        return new_obj
    return jso

for i in data:
    try:
        with open(i, "r", encoding="utf-8") as f:
            data[i] = json.load(f)
    except:
        with open(i, "w", encoding="utf-8") as f:
            json.dump(data[i], f, indent=4)
        with open(i, "r", encoding="utf-8") as f:
            data[i] = json.load(f)



def Data(file, prop):
    return json2object(data[file][prop])


def dumpData(file, prop, val):
    data[file][prop] = object2json(val)
    with open(file, "w", encoding="utf-8") as f:
        json.dump(data[file], f, indent=4)


def DataAll(file):
    return data[file]


def dumpDataAll(file, val):
    data[file] = val
    with open(file, "w", encoding="utf-8") as f:
        json.dump(data[file], f, indent=4)


class UniDeskSettings(QQuickItem):
    for i in data["./data/settings.json"]:
        exec(
            i
            + "Changed=Signal(type(Data('./data/settings.json','"
            + i
            + "')))"
        )
        exec(
            i
            + "=Property(type(Data('./data/settings.json','"
            + i
            + "')),(lambda self: Data('./data/settings.json','"
            + i
            + "')),(lambda self,val: dumpData('./data/settings.json','"
            + i
            + "',val)),notify="
            + i
            + "Changed)"
        )

    def __init__(self, parent=None):
        super().__init__(parent)

    def get(prop):
        return Data("./data/settings.json",prop)
    
    def set(prop, val):
        dumpData("./data/settings.json",prop,val)

    @Slot(str)
    def notify(self, prop):
        exec("self."+prop+"Changed.emit(Data(\"./data/settings.json\",prop))")

class UniDeskComponentsData(QQuickItem):
    def __init__(self):
        super().__init__()
    @Slot(result=list)
    def getPages(self):
        return Data("./data/components.json","pages")
    @Slot(result=list)
    def getComponents(self):
        return Data("./data/components.json","components")
    @Slot(int,dict)
    def updatePage(self,pageIndex,page):
        pages = Data("./data/components.json","pages")
        if pageIndex < 0 or pageIndex >= len(pages):
            return
        pages[pageIndex] = page
        dumpData("./data/components.json","pages",pages)
    @Slot(int,dict)
    def updateComponent(self,componentIndex,component):
        components = Data("./data/components.json","components")
        if componentIndex < 0 or componentIndex >= len(components):
            return
        components[componentIndex] = component
        dumpData("./data/components.json","components",components)
    @Slot(dict)
    def addComponent(self,component):
        components = Data("./data/components.json","components")
        components.append(object2json(component))
        dumpData("./data/components.json","components",components)
    @Slot(str)
    def removeComponent(self, componentIdentification):
        components = Data("./data/components.json","components")
        components = [i for i in components if i.get("identification")!=componentIdentification]
        dumpData("./data/components.json","components",components)
    @Slot(dict)
    def addPage(self,page):
        pages = Data("./data/components.json","pages")
        pages.append(object2json(page))
        dumpData("./data/components.json","pages",pages)
    @Slot(int,dict)
    def insertPage(self,index,page):
        pages = Data("./data/components.json","pages")
        pages.insert(index,object2json(page))
        dumpData("./data/components.json","pages",pages)
    @Slot(int)
    def removePage(self,idx):
        pages = Data("./data/components.json","pages")
        pages = [i for i in pages if i.get("idx")!=idx]
        dumpData("./data/components.json","pages",pages)
    @Slot(int)
    def setCurrentPage(self,idx):
        dumpData("./data/components.json","pageIndex",idx)
    @Slot(result=int)
    def getCurrentPage(self):
        return Data("./data/components.json","pageIndex")
    @Slot(result=list)
    def getComponentTypes(self):
        with open("./UniDesk/Components/components-list","r",encoding="utf-8") as f:
            p= f.readlines()
        return p
    def loadComponentPyPlugins():
        with open("./UniDesk/Components/components-list","r",encoding="utf-8") as f:
            for i in f.readlines():
                with open("./UniDesk/Components/"+i+"/pyplugins-list","r",encoding="utf-8") as ff:
                    for j in ff.readlines():
                        m=importlib.import_module("UniDesk.Components."+i+"."+j)
                        try:
                            for singleton,typeobj,name,funcs in m.__pluginloadlist__:
                                if singleton=="singleton":
                                    qmlRegisterSingletonType(typeobj,"UniDesk.Components."+i+".PyPlugins",1,0,name)
                                else:
                                    qmlRegisterType(typeobj,"UniDesk."+i+".PyPlugins",1,0,name)
                        except Exception as e:
                            print(e.args)
    def startFuncs():
        with open("./UniDesk/Components/components-list","r",encoding="utf-8") as f:
            for i in f.readlines():
                with open("./UniDesk/Components/"+i+"/pyplugins-list","r",encoding="utf-8") as ff:
                    for j in ff.readlines():
                        m=importlib.import_module("UniDesk.Components."+i+"."+j)
                        try:
                            for singleton,typeobj,name,funcs in m.__pluginloadlist__:
                                for func in funcs:
                                    func()
                        except Exception as e:
                            print(e.args)