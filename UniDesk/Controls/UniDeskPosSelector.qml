import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.GraphicalEffects
import UniDesk.Controls
import UniDesk

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
                    control.editingComponent.x = value;
                    control.editingComponent.saveComToFile();
                }
            }
            Component.onCompleted: {
                value=control.editingComponent ? control.editingComponent.x : 0
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
                    control.editingComponent.y = value;
                    control.editingComponent.saveComToFile();
                }
            }  
            Component.onCompleted: {
                value = control.editingComponent ? control.editingComponent.y : 0
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
                    control.editingComponent.saveComToFile();
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
                    control.editingComponent.saveComToFile();
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
                        control.editingComponent.x = control.horizontalAlignComponent.x;
                    }
                    else{
                        control.editingComponent.x=0;
                    }
                    control.editingComponent.saveComToFile();  
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
                        control.editingComponent.x = control.horizontalAlignComponent.x + control.horizontalAlignComponent.width/2 - control.editingComponent.width/2;
                    }
                    else{
                        control.editingComponent.x = UniDeskTools.desktopGeometry(editingComponent).width /2 - control.editingComponent.width /2;
                    }
                    control.editingComponent.saveComToFile();
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
                        control.editingComponent.x = control.horizontalAlignComponent.x + control.horizontalAlignComponent.width - control.editingComponent.width;
                    }
                    else{
                        control.editingComponent.x = UniDeskTools.desktopGeometry(editingComponent).width - control.editingComponent.width;
                    }
                    control.editingComponent.saveComToFile();
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
                        control.editingComponent.y = control.verticalAlignment.y;
                    }
                    else{
                        control.editingComponent.y=0;
                    }
                    control.editingComponent.saveComToFile();
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
                        control.editingComponent.y = control.verticalAlignment.y + control.verticalAlignment.height/2 - control.editingComponent.height/2;
                    }
                    else{
                        control.editingComponent.y = UniDeskTools.desktopGeometry(editingComponent).height /2 - control.editingComponent.height /2;
                    }
                    control.editingComponent.saveComToFile();
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
                        control.editingComponent.y = control.verticalAlignment.y + control.verticalAlignment.height - control.editingComponent.height;
                    }
                    else{
                        control.editingComponent.y = UniDeskTools.desktopGeometry(editingComponent).height - control.editingComponent.height;
                    }
                    control.editingComponent.saveComToFile();
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