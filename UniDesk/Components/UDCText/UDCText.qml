import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk.Components.UDCText

UniDeskComBase{
    id: base
    visible: true
    geoWidth: cont.width ? cont.width : 100
    geoHeight: cont.height ? cont.height : 100
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
    property int style: Text.Normal
    property color styleColor: UniDeskSettings.primaryColor
    property int textFormat: Text.RichText
    property int wrapMode: Text.Wrap
    property int maxWidth: 1000
    property int maxHeight: 1000
    optionsWindow: optionsText
    chosen: optionsText ? optionsText.visible : false
    UniDeskText{
        id: cont
        x: base.rotationOffsetX()
        y: base.rotationOffsetY()
        text: base.textContent ? UniDeskExpr.convertStr(base.textContent) : qsTr("请输入文本内容")
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
        wrapMode: base.wrapMode
        rotation: base.rotation
        transformOrigin: Item.TopLeft
        onTextChanged:{
            cont.width=base.maxWidth;
            cont.width=Math.min(base.maxWidth, cont.contentWidth);
            cont.height=base.maxHeight;
            cont.height=Math.min(base.maxHeight, cont.contentHeight);
            optionsText.updateMaxSize();
        }
    }
    UniDeskMenu{
        id: menu
        UniDeskMenuItem{
            text: qsTr("编辑")
            iconSource: "qrc:/media/img/edit.svg"
            onClicked: {
                optionsText.show()
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
            cont.text=base.textContent ? UniDeskExpr.convertStr(base.textContent) : qsTr("请输入文本内容");
        }
        repeat: true
    }
    UDCTextOptions{
        id: optionsText
        editingComponent: base
        comManager: base.comManager
    }
    onRightClicked: {
        menu.popup(cont);
    }
    onEndDrag: {
        geoX=x+rotationOffsetX();
        geoY=y+rotationOffsetY();
        optionsText.updatePosition();
        saveComToFile();
    }
    onGeoXChanged:{
        optionsText.updatePosition();
    }
    onGeoYChanged:{
        optionsText.updatePosition();
    }
    function propertyData(){
        return {
            "type": base.type,
            "identification": base.identification,
            "pageid": base.pageid,
            "x": base.geoX,
            "y": base.geoY,
            "canMove": base.canMove,
            "canResize": base.canResize,
            "textContent": base.textContent,
            "textColorR": base.textColor.r,
            "textColorG": base.textColor.g,
            "textColorB": base.textColor.b,
            "textColorA": base.textColor.a,
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
            "styleColorR": base.styleColor.r,
            "styleColorG": base.styleColor.g,
            "styleColorB": base.styleColor.b,
            "styleColorA": base.styleColor.a,
            "textFormat": base.textFormat,
            "rotation": base.rotation,
            "wrapMode": base.wrapMode,
            "maxWidth": base.maxWidth,
            "maxHeight": base.maxHeight
        }
    }
    function loadPropertyData(data){
        if(data.type!==undefined){base.type=data.type;}
        if(data.identification!==undefined){base.identification=data.identification;}       
        if(data.pageid!==undefined){base.pageid=data.pageid;}
        if(data.x!==undefined){base.geoX=data.x;}
        if(data.y!==undefined){base.geoY=data.y;}
        if(data.canMove!==undefined){base.canMove=data.canMove;}
        if(data.canResize!==undefined){base.canResize=data.canResize;}
        if(data.textContent!==undefined){base.textContent=data.textContent;}
        if(data.textColorR!==undefined){base.textColor=Qt.rgba(data.textColorR,data.textColorG,data.textColorB,data.textColorA);}
        if(data.fontFamily!==undefined){base.fontFamily=data.fontFamily;}
        if(data.fontSize!==undefined){base.fontSize=data.fontSize;}
        if(data.smallCaps!==undefined){base.smallCaps=data.smallCaps;}
        if(data.bold!==undefined){base.bold=data.bold;}
        if(data.italic!==undefined){base.italic=data.italic;}
        if(data.underline!==undefined){base.underline=data.underline;}
        if(data.strikeout!==undefined){base.strikeout=data.strikeout;}
        if(data.letterSpacing!==undefined){base.letterSpacing=data.letterSpacing;}
        if(data.wordSpacing!==undefined){base.wordSpacing=data.wordSpacing;}    
        if(data.lineHeight!==undefined){base.lineHeight=data.lineHeight;}
        if(data.weight!==undefined){base.weight=data.weight;}
        if(data.style!==undefined){base.style=data.style;}
        if(data.styleColorR!==undefined){base.styleColor=Qt.rgba(data.styleColorR,data.styleColorG,data.styleColorB,data.styleColorA);}
        if(data.textFormat!==undefined){base.textFormat=data.textFormat;}
        if(data.rotation!==undefined){base.rotation=data.rotation;}
        if(data.wrapMode!==undefined){base.wrapMode=data.wrapMode;}
        if(data.maxWidth!==undefined){base.maxWidth=data.maxWidth;}else{base.maxWidth=1000;}
        if(data.maxHeight!==undefined){base.maxHeight=data.maxHeight;}else{base.maxHeight=1000;}
    }
    function saveComToFile(){
        var data= propertyData();
        UniDeskComponentsData.updateComponent(base.comManager.getIndexById(base.identification), data);
    }
    onMaxWidthChanged:{
        cont.width=base.maxWidth;
        cont.width=Math.min(base.maxWidth, cont.contentWidth);
        optionsText.updateMaxSize();
    }
    onMaxHeightChanged:{
        cont.height=base.maxHeight;
        cont.height=Math.min(base.maxHeight, cont.contentHeight);
        optionsText.updateMaxSize();
    }
    Component.onCompleted:{
        flushText.start();
        cont.width=base.maxWidth;
        cont.width=Math.min(base.maxWidth, cont.contentWidth);
        cont.height=base.maxHeight;
        cont.height=Math.min(base.maxHeight, cont.contentHeight);
        optionsText.updateMaxSize();
    }
    onCloseSignal: ()=>{
        if(optionsText){
            optionsText.close();
        }
        flushText.stop();
    }
}
