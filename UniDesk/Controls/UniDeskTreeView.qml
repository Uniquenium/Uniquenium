import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.GraphicalEffects
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk

TreeView{
    id: control
    selectionModel: ItemSelectionModel{}
    rowSpacing: 10
    property bool enableComDelegate: false
    property Component extraDelegate
    delegate: Item {
        id: treeDelegate
        implicitWidth: control.width
        implicitHeight: 30
        readonly property real indent: 20
        readonly property real padding: 5

        // Assigned to by TreeView:
        required property TreeView treeView
        required property bool isTreeNode
        required property bool expanded
        required property int hasChildren
        required property int depth

        TapHandler {
            onTapped: treeView.toggleExpanded(row)
        }
        HoverHandler{
            onHoveredChanged: {
                rect_.color=hovered? UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.05) : Qt.rgba(0,0,0,0.5).lighter(1.05)  : "transparent"   
                if(control.enableComDelegate){
                    var com=UniDeskComManager.getComById(model.display)
                    if(com){
                        com.indicated=hovered;
                    }
                }
            }
        }
        UniDeskIcon {
            id: indicator
            visible: treeDelegate.isTreeNode && treeDelegate.hasChildren
            x: padding + (treeDelegate.depth * treeDelegate.indent)
            anchors.verticalCenter: label.verticalCenter
            iconSource: "qrc:/media/img/arrow-right-s-line.svg"
            rotation: treeDelegate.expanded ? 90 : 0
            Behavior on rotation{
                RotationAnimation{
                    direction: RotationAnimation.Shortest
                    duration: 50
                }
            }
        }

        UniDeskText {
            id: label
            x: padding + (treeDelegate.isTreeNode ? (treeDelegate.depth + 1) * treeDelegate.indent : 0)
            width: treeDelegate.width - treeDelegate.padding - x
            clip: true
            text: model.display
            font: UniDeskTextStyle.little
            anchors.verticalCenter: rect_.verticalCenter
        }
        Rectangle{
            id: rect_
            anchors.fill: parent
            color:  "transparent"
            radius: 5
            border.width: 1
            border.color: UniDeskGlobals.isLight? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,0)
        }
        Component.onCompleted: {
            if(control.extraDelegate){
                var newCom=control.extraDelegate.createObject(treeDelegate,{"model":model})
                newCom.anchors.right=treeDelegate.right
                newCom.anchors.verticalCenter=treeDelegate.verticalCenter
            }
        }
    }
}