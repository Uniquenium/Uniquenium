import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk
import org.uniquenium.unidesk

Item{
    id: control
    property var editingComponent
    property var horizontalAlignComponent
    property var verticalAlignment
    GridLayout{
        id: gridLayout
        columnSpacing: 10
        rowSpacing: 10
        anchors.fill: parent
        UniDeskText{
            id: text1
            text: qsTr("横向位置")
            font: UniDeskTextStyle.little
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.column: 0
            Layout.row: 0
        }
        UniDeskText{
            id: text2
            text: qsTr("相对")
            font: UniDeskTextStyle.little
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter| Qt.AlignRight
            horizontalAlignment: Qt.AlignRight
            Layout.column: 0
            Layout.row: 1
        }
        UniDeskText{
            id: text3
            text: qsTr("纵向位置")
            font: UniDeskTextStyle.little
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.column: 0
            Layout.row: 2
        }
        UniDeskText{
            id: text4
            text: qsTr("相对")
            font: UniDeskTextStyle.little
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter| Qt.AlignRight
            horizontalAlignment: Qt.AlignRight
            Layout.column: 0
            Layout.row: 3
        }
        UniDeskSpinBox{
            id: horizontalCoordTextField
            Layout.column: 2
            Layout.row: 0
            editable: true
            from: 0
            to: UniDeskTools.desktopGeometry(editingComponent).width - 10
            onValueChanged:{
                if(control.editingComponent){
                    control.editingComponent.visualX = value;
                }
            }
            Component.onCompleted: {
                value=control.editingComponent ? control.editingComponent.visualX : 0
            }
        }
        UniDeskSpinBox{
            id: verticalCoordTextField
            Layout.column: 2
            Layout.row: 2
            editable: true
            from: 0
            to: UniDeskTools.desktopGeometry(editingComponent).height - 10 
            onValueChanged:{
                if(control.editingComponent){
                    control.editingComponent.visualY = value;
                }
            }  
            Component.onCompleted: {
                value = control.editingComponent ? control.editingComponent.visualY : 0
            }
        }
        UniDeskComBox{
            id: horizontalComBox
            Layout.preferredWidth: 200
            editingComponent: control.editingComponent
            Layout.column: 1
            Layout.row: 1
            onCurrentTextChanged: {
                if(control.editingComponent){
                    if(currentIndex === 0){
                        control.horizontalAlignComponent = undefined;
                    }else{
                        control.horizontalAlignComponent = UniDeskComManager.getComById(currentText);
                    }
                }
            }
        }
        UniDeskComBox{
            id: verticalComBox
            Layout.preferredWidth: 200
            editingComponent: control.editingComponent
            Layout.column: 1
            Layout.row: 3
            onCurrentTextChanged: {
                if(control.editingComponent){
                    if(currentIndex === 0){
                        control.verticalAlignment = undefined;
                    }else{
                        control.verticalAlignment = UniDeskComManager.getComById(currentText);
                    }
                }
            }
        }
        RowLayout{
            spacing: 10
            UniDeskButton{
                id: horiAlignLeftButton
                contentText: qsTr("左对齐")
                display: Button.TextOnly
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    if(control.horizontalAlignComponent){
                        control.editingComponent.visualX = control.editingComponent.parentComponent ? 
                        control.horizontalAlignComponent.x-control.editingComponent.parentComponent.x : 
                        control.horizontalAlignComponent.x;
                    }
                    else{
                        control.editingComponent.visualX=0;
                    }
                }
            }
            UniDeskButton{
                id: horiAlignCenterButton
                contentText: qsTr("居中对齐")
                display: Button.TextOnly
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    if(control.horizontalAlignComponent){
                        control.editingComponent.visualX = control.editingComponent.parentComponent ? 
                        control.horizontalAlignComponent.x + control.horizontalAlignComponent.width/2 - control.editingComponent.width/2 - control.editingComponent.parentComponent.x : 
                        control.horizontalAlignComponent.x + control.horizontalAlignComponent.width/2 - control.editingComponent.width/2;
                    }
                    else{
                        control.editingComponent.visualX = UniDeskTools.desktopGeometry(editingComponent).width /2 - control.editingComponent.width /2;
                    }
                }
            }
            UniDeskButton{
                id: horiAlignRightButton
                contentText: qsTr("右对齐")
                display: Button.TextOnly
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    if(control.horizontalAlignComponent){
                        control.editingComponent.visualX = control.editingComponent.parentComponent ? 
                        control.horizontalAlignComponent.x + control.horizontalAlignComponent.width - control.editingComponent.width - control.editingComponent.parentComponent.x : 
                        control.horizontalAlignComponent.x + control.horizontalAlignComponent.width - control.editingComponent.width;
                    }
                    else{
                        control.editingComponent.visualX = UniDeskTools.desktopGeometry(editingComponent).width - control.editingComponent.width;
                    }
                }
            }
            Layout.column: 2
            Layout.row: 1
            Layout.alignment: Qt.AlignRight
        }
        RowLayout{
            spacing: 10
            UniDeskButton{
                id: vertAlignTopButton
                contentText: qsTr("上对齐")
                display: Button.TextOnly
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    if(control.verticalAlignment){
                        control.editingComponent.visualY = control.editingComponent.parentComponent ? 
                        control.verticalAlignment.y-control.editingComponent.parentComponent.y : 
                        control.verticalAlignment.y;
                    }
                    else{
                        control.editingComponent.visualY=0;
                    }
                }
            }
            UniDeskButton{
                id: vertAlignCenterButton
                contentText: qsTr("居中对齐")
                display: Button.TextOnly
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    if(control.verticalAlignment){
                        control.editingComponent.visualY = control.editingComponent.parentComponent ? 
                        control.verticalAlignment.y + control.verticalAlignment.height/2 - control.editingComponent.height/2 - control.editingComponent.parentComponent.y : 
                        control.verticalAlignment.y + control.verticalAlignment.height/2 - control.editingComponent.height/2;
                    }
                    else{
                        control.editingComponent.visualY = UniDeskTools.desktopGeometry(editingComponent).height /2 - control.editingComponent.height /2;
                    }
                }
            }
            UniDeskButton{
                id: vertAlignBottomButton
                contentText: qsTr("下对齐")
                display: Button.TextOnly
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    if(control.verticalAlignment){
                        control.editingComponent.visualY = control.editingComponent.parentComponent ? 
                        control.verticalAlignment.y + control.verticalAlignment.height - control.editingComponent.height - control.editingComponent.parentComponent.y : 
                        control.verticalAlignment.y + control.verticalAlignment.height - control.editingComponent.height;
                    }
                    else{
                        control.editingComponent.visualY = UniDeskTools.desktopGeometry(editingComponent).height - control.editingComponent.height;
                    }
                }
            }
            Layout.column: 2
            Layout.row: 3
            Layout.alignment: Qt.AlignRight
        }
    }
    Component.onCompleted: {
        implicitWidth=gridLayout.childrenRect.width
        implicitHeight=gridLayout.childrenRect.height
    }
}