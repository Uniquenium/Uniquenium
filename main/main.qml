import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk.PyPlugin
import Qt.labs.platform as QLP

UniDeskObject{
    id: object
    property bool isSpread: true
    UniDeskComBase {
        id: base
        visible: true
        bg.color: "transparent"
        x: Screen.width-width-10
        y: 10
        width: btns.width
        height: object.isSpread ? btns.height+15 : btn_spread.height+15
        onWidthChanged:{
            x=Screen.width-width-10;
        }
        ColumnLayout{
            id: btns
            anchors.right: parent ? parent.right : undefined 
            spacing: 5
            UniDeskButton{
                id: btn_spread
                contentText: object.isSpread ? qsTr("收起") : qsTr("展开")
                iconSize: 15
                iconSource: object.isSpread ? "qrc:/media/img/arrow-up-s-line.svg" : "qrc:/media/img/arrow-down-s-line.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                radius: width / 2
                onClicked:{
                    object.isSpread = !object.isSpread
                }
            }
            UniDeskButton{
                id: btn_quit
                contentText: qsTr("退出")
                iconSize: 15
                iconSource: "qrc:/media/img/logout-box-line.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                radius: width / 2
                onClicked:{
                    confirm_exit_dialog.show();
                }
            }
            UniDeskButton{
                id: btn_system
                contentText: qsTr("系统")
                iconSize: 15
                iconSource: "qrc:/media/img/shut-down-line.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                radius: width / 2
                onClicked:{
                    system_menu.popup(btn_system,Qt.point(-152,0));
                }
            }
            UniDeskButton{
                id: btn_page
                contentText: qsTr("页面")
                iconSize: 15
                iconSource: "qrc:/media/img/carousel-view.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                radius: width / 2
                onClicked:{
                    page_menu.popup(btn_page,Qt.point(-152,0));
                }
            }
            UniDeskButton{
                id: btn_settings
                contentText: qsTr("设置")
                iconSize: 15
                iconSource: "qrc:/media/img/settings.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                radius: width / 2
                onClicked:{
                    UniDeskSettingsWindow.showActivate()
                }
            }
            UniDeskButton{
                id: btn_add
                contentText: qsTr("添加组件")
                iconSize: 15
                iconSource: "qrc:/media/img/add-line.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                radius: width / 2
                onClicked:{
                    UniDeskComWindow.parentId="";
                    UniDeskComWindow.showActivate();
                }
            }
        }
        
        Behavior on height{
            NumberAnimation{
                duration: 500
            }
        }
        UniDeskMenu{
            y: btn_system.y
            id: system_menu
            UniDeskMenuItem{
                id: mi_shutdown
                text: qsTr("关机")
                iconSource: "qrc:/media/img/shut-down-line.svg"
                onClicked: {
                    shutdown_dialog.showActivate();
                }
            }
            UniDeskMenuItem{
                id: mi_restart
                text: qsTr("重启")
                iconSource: "qrc:/media/img/restart-line.svg"
                onClicked: {
                    restart_dialog.showActivate();
                }
            }
            UniDeskMenuItem{
                id: mi_sleep
                text: qsTr("休眠")
                iconSource: "qrc:/media/img/rest-time-line.svg"
                onClicked: {
                    UniDeskTools.systemCommand("powercfg -h on")
                }
            }
            UniDeskMenuItem{
                id: mi_logout
                text: qsTr("注销")
                iconSource: "qrc:/media/img/logout-box-line.svg"
                onClicked: {
                    logout_dialog.showActivate();
                }
            }
            UniDeskMenuItem{
                id: mi_lock
                text: qsTr("锁屏")
                iconSource: "qrc:/media/img/lock.svg"
                onClicked: {
                    UniDeskTools.systemCommand("Rundll32.exe user32.dll,LockWorkStation")
                }
            }
            //系统有更新时显示更新选项
        }
        UniDeskMenu{
            y: btn_page.y
            id: page_menu
            UniDeskMenu{
                id: mi_toggle_page
                title: qsTr("切换页面")
                Repeater{
                    model: UniDeskComManager.page_list
                    UniDeskMenuItem{
                        text: model.text
                        onClicked: {
                            UniDeskComManager.toggle_page_to(model.idx);
                        }
                    }
                }
            }
            UniDeskMenuSeparator{
            }
            UniDeskMenuItem{
                id: mi_toggle_add
                text: qsTr("添加页面")
                iconSource: "qrc:/media/img/add-line.svg"
                onClicked: {
                    UniDeskComManager.new_page();
                }
            }
            UniDeskMenuItem{
                id: mi_layer
                text: qsTr("管理页面")
                iconSource: "qrc:/media/img/settings.svg"
                onClicked: {
                    UniDeskPageWindow.showActivate();
                }
            }
        }
        onFocusOut: {
            system_menu.close();
            page_menu.close();
        }
    }
    UniDeskMessageBox{
        id: confirm_exit_dialog
        title: qsTr("确认退出")
        text: qsTr("确认要退出吗？")
        Component.onCompleted: {
            addButton(qsTr("确认"));
            addButton(qsTr("取消"));
        }
        onButtonClicked: {
            if(clickedIndex==0){
                UniDeskComManager.close_all();
                base.baseClose();
                object.closeAllWindows();
                UniDeskGlobals.emitApplicationQuit();
            }
        }
    }
    UniDeskMessageBox{
        id: error_dialog
        title: qsTr("确认关机")
        text: qsTr("确认要关机吗？")
        Component.onCompleted: {
            addButton(qsTr("确定"));
            addButton(qsTr("取消"));
        }
        onButtonClicked: {
            if(clickedIndex==0){
                UniDeskTools.systemCommand("shutdown -s");
            }
        }
    }
    UniDeskMessageBox{
        id: restart_dialog
        title: qsTr("确认重启")
        text: qsTr("确认要重启吗？")
        Component.onCompleted: {
            addButton(qsTr("确定"));
            addButton(qsTr("取消"));
        }
        onButtonClicked: {
            if(clickedIndex==0){
                UniDeskTools.systemCommand("shutdown -r");
            }
        }
    }
    UniDeskMessageBox{
        id: logout_dialog
        title: qsTr("确认注销")
        text: qsTr("确认要注销吗？")
        Component.onCompleted: {
            addButton(qsTr("确定"));
            addButton(qsTr("取消"));
        }
        onButtonClicked: {
            if(clickedIndex==0){
                UniDeskTools.systemCommand("shutdown -l");
            }
        }
    }
    function closeAllWindows(){
        UniDeskSettingsWindow.close();
        UniDeskComWindow.close();
    }
    Component.onCompleted: {
        UniDeskSettingsWindow.hide();
    }
}