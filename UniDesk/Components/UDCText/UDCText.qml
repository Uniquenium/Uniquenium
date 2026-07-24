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
    property int horizontalAlignment: Text.AlignHCenter
    property int verticalAlignment: Text.AlignVCenter
    optionsWindow: optionsText
    chosen: comManager.selectMode===UniDeskComponentSelectMode.NoSelect ? (optionsWindow.visible) : selected
    width: 100
    height: 50
    UniDeskText{
        id: cont
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
        horizontalAlignment: base.horizontalAlignment
        verticalAlignment: base.verticalAlignment
        width: base.width
        height: base.height
        opacity: base.itemOpacity
    }
    UniDeskMenu{
        id: menu
        UniDeskMenuItem{
            text: qsTr("编辑")
            iconSource: "qrc:/media/img/edit.svg"
            onClicked: {
                optionsText.show()
                base.comManager.select_com(base);
            }
        }
        UniDeskMenuItem{
            text: qsTr("复制")
            iconSource: "qrc:/media/img/copy.svg"
            onClicked: {
                base.copyCom();
            }
        }
        UniDeskMenuItem{
            text: qsTr("新建子组件")
            iconSource: "qrc:/media/img/add-line.svg"
            onClicked: {
                base.createSubComponent();
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
        if(base.comManager.selectMode===UniDeskComponentSelectMode.NoSelect){
            menu.popup(cont);
        }
    }
    function propertyData(){
        return {
            "type": base.type,
            "identification": base.identification,
            "pageid": base.pageid,
            "x": base.x,
            "y": base.y,
            "name": base.name,
            "parent": base.parent === comManager.root.contentItem ? "Desktop" : base.parent.identification,
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
            "horizontalAlignment": base.horizontalAlignment,
            "verticalAlignment": base.verticalAlignment,
            "opacity": base.itemOpacity,
            "width": base.width,
            "height": base.height
        }
    }
    function loadPropertyData(data){
        if(data.type!==undefined){base.type=data.type;}
        if(data.identification!==undefined){base.identification=data.identification;}       
        if(data.pageid!==undefined){base.pageid=data.pageid;}
        if(data.x!==undefined){base.x=data.x;}
        if(data.y!==undefined){base.y=data.y;}
        if(data.name!==undefined){base.name=data.name;}
        if(data.parent!==undefined){base.parent=base.comManager.getComById(data.parent);}
        if(data.width!==undefined){base.width=data.width;}
        if(data.height!==undefined){base.height=data.height;}
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
        if(data.horizontalAlignment!==undefined){base.horizontalAlignment=data.horizontalAlignment;}else{base.horizontalAlignment=Text.AlignHCenter;}
        if(data.verticalAlignment!==undefined){base.verticalAlignment=data.verticalAlignment;}else{base.verticalAlignment=Text.AlignVCenter;}
        if(data.opacity!==undefined){base.itemOpacity=data.opacity;}else{base.itemOpacity=1;}
    }
    function saveComToFile(){
        var data= propertyData();
        UniDeskComponentsData.updateComponent(base.comManager.getIndexById(base.identification), data);
    }
    Component.onCompleted:{
        flushText.start();
    }
    onCloseSignal: ()=>{
        if(optionsText){
            optionsText.close();
        }
        flushText.stop();
    }
}
