pragma ComponentBehavior: Bound
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk

UniDeskButton {
    id: control

    property bool enableFontDelegate: false
    property bool enableComDelegate: false
    property var comManager
    property int currentIndex: 0
    property var model: []
    property bool editable: false
    property string displayText: model[currentIndex]
    property string editText: displayText
    property int inputMethodHints: Qt.ImhNoPredictiveText
    property var validator: null
    property bool selectTextByMouse: false
    property string currentText: displayText ? displayText : editText
    signal activated()
    padding: 5
    height: 30
    verticalPadding: 0
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    leftPadding: padding + (!control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    rightPadding: padding + (control.mirrored || !indicator || !indicator.visible ? 0 : indicator.width + spacing)
    

    UniDeskIcon {
        id: icon_
        x: control.mirrored ? control.padding : control.width - width - control.padding
        y: control.topPadding + (control.availableHeight - height) / 2
        source: menu.visible ? "qrc:/media/img/arrow-up-s-line.svg" : "qrc:/media/img/arrow-down-s-line.svg"
        iconSize: 15
        opacity: enabled ? 1 : 0.3
        iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    }

    contentItem: UniDeskTextField {
        id: field
        leftPadding: !control.mirrored ? 12 : control.editable && activeFocus ? 3 : 1
        rightPadding: control.mirrored ? 12 : control.editable && activeFocus ? 3 : 1
        

        text: control.editable ? control.editText : control.displayText
        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        inputMethodHints: control.inputMethodHints
        validator: control.validator
        selectByMouse: control.selectTextByMouse

        color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        verticalAlignment: Text.AlignVCenter

        background: Rectangle {
            visible: control.enabled && control.editable && !control.flat
            border.width: 0
            border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
            color: "transparent"
        }
        enableFontDelegate: control.enableFontDelegate
        onPressed:{
            if(field.activeFocus){
                control.clicked()
            }
        }
        onAccepted:{
            for(var i=0;i<control.model.length;i++){
                if(control.model[i]===text){
                    control.currentIndex = i;
                    control.activated()
                    break;
                }
            }
        }
    }
    Item{
        id: d
        property var window: Window.window
    }
    background: Rectangle {
        implicitWidth: 140
        implicitHeight: 40

        color: control.hovered ? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2) :"transparent"
        border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
        border.width: 1
        radius: 5
        visible: !control.flat || control.down
    }
    onClicked: {
        if(menu.count !==0){
            var pos = control.mapToItem(null, 0, 0)
            var containerHeight = menu.count*36
            if(d.window.height>pos.y+control.height+containerHeight){
                menu.y = control.height
            }else if(pos.y>containerHeight){
                menu.y = -containerHeight
            }else{
                menu.y = d.window.height-(pos.y+containerHeight)
            }
            menu.open()
        }
    }
    UniDeskMenu{
        id:menu
        width: control.width
        height: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin)
        onAboutToHide: {
            icon_.source = "qrc:/media/img/arrow-down-s-line.svg"
        }
        onAboutToShow: {
            icon_.source = "qrc:/media/img/arrow-up-s-line.svg"
        }
        popupType: Popup.Item
        Instantiator{
            id: instantiator
            model: control.model
            delegate: UniDeskMenuItem {
                required property var model
                required property int index
                text: control.model[index]
                font: control.enableFontDelegate ? UniDeskTools.font(control.model[index],13) : UniDeskTextStyle.little  
                hoverEnabled: control.hoverEnabled
                onHighlightedChanged: {
                    if(control.enableComDelegate){
                        let com=control.getComByIndex(index)
                        if(com){
                            com.indicated=highlighted;
                        }
                    }
                }
                onTriggered: {
                    control.currentIndex=index;
                    control.activated()
                }
            }
            onObjectAdded: function(index, obj){
                menu.insertItem(index, obj)
            }
            onObjectRemoved: function(index,obj){
                menu.removeItem(obj)
            }
        }
    }
}
