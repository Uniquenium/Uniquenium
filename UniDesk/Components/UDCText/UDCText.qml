import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk.Components.UDCText
import UniDesk.Components.UDCText.PyPlugins
import UniDesk.PyPlugin

UniDeskComBase{
    id: base
    visible: true
    width: cont.width
    height: cont.height
    type: "UDCText"
    property string textContent: qsTr("文字")
    property color textColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    property string fontFamily: UniDeskTextStyle.family
    property real fontSize: 30
    property bool smallCaps: false
    property bool bold: false
    property bool italic: false
    property bool underline: false
    property bool strikeout: false
    property real letterSpacing: 0
    property real wordSpacing: 0
    property real lineHeight: 1
    property int weight: Font.Normal
    property var style: Text.Normal
    property color styleColor: UniDeskSettings.primaryColor
    property var textFormat: Text.RichText
    chosen: optionsText ? optionsText.visible : false
    UniDeskText{
        id: cont
        text: base.textContent ? UDCTextTools.convertStr(base.textContent) : qsTr("请输入文本内容")
        textColor: base.textColor
        font.family: base.fontFamily
        font.pixelSize: base.fontSize
        font.capitalization: base.smallCaps ? Font.SmallCaps : Font.MixedCase
        font.bold: base.bold
        font.italic: base.italic
        font.underline: base.underline
        font.strikeout: base.strikeout
        font.letterSpacing: base.letterSpacing
        font.wordSpacing: base.wordSpacing
        lineHeight: base.lineHeight
        font.weight: base.weight
        style: base.style
        styleColor: base.styleColor
        textFormat: base.textFormat
    }
    UniDeskMenu{
        id: menu
        UniDeskMenuItem{
            text: qsTr("编辑")
            iconSource: "qrc:/media/img/edit.svg"
            onClicked: {
                optionsText.showActivate()
            }
        }
        UniDeskMenuItem{
            id: mi_drag
            text: qsTr("可拖动")
            iconSource: "qrc:/media/img/move.svg"
            checkable: true
            onClicked: {
                base.canMove=checked;
                checked=!checked;
                base.saveComToFile();
                menu.close();
            }
            Component.onCompleted: {
                checked=base.canMove;
            }
            Connections{
                target: base
                function onCanMoveChanged(){
                    mi_drag.checked=base.canMove;
                }
            }
        }
        UniDeskMenuItem{
            text: qsTr("删除")
            iconSource: "qrc:/media/img/delete-bin.svg"
            onClicked: {
                base.deleteCom();
            }
        }
    }
    Timer{
        id: flushText
        interval: 50
        onTriggered: {
            cont.text=base.textContent ? UDCTextTools.convertStr(base.textContent) : qsTr("请输入文本内容");
        }
        repeat: true
    }
    UDCTextOptions{
        id: optionsText
        editingComponent: base
        comManager: UniDeskComManager
    }
    onRightClicked: {
        menu.popup(base)
    }
    onXChanged:{
        saveComToFile();
    }
    onYChanged:{
        saveComToFile();
    }
    function propertyData(){
        return {
            "type": base.type,
            "identification": base.identification,
            "pageIdx": base.pageIdx,
            "x": base.x,
            "y": base.y,
            "canMove": base.canMove,
            "canResize": base.canResize,
            "textContent": base.textContent,
            "textColor": base.textColor,
            "fontFamily": base.fontFamily,
            "fontSize": base.fontSize,
            "smallCaps": base.smallCaps,
            "bold": base.bold,
            "italic": base.italic,
            "underline": base.underline,
            "strikeout": base.strikeout,
            "letterSpacing": base.letterSpacing,
            "wordSpacing": base.wordSpacing,
            "lineHeight": base.lineHeight,
            "weight": base.weight,
            "style": base.style,
            "styleColor": base.styleColor,
            "textFormat": base.textFormat
        }
    }
    function saveComToFile(){
        var data= propertyData();
        UniDeskComponentsData.updateComponent(UniDeskComManager.getIndexById(identification), data);
    }
    Component.onCompleted:{
        flushText.start();
    }
    Component.onDestruction: {
        if(optionsText){
            optionsText.close();
        }
        flushText.stop();
    }
}