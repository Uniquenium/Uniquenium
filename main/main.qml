import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import unidesk_qml
import org.itcdt.unidesk

UniDeskObject{
    id: object
    property bool isSpread: true
    UniDeskComBase {
        id: base
        visible: true
        bg.color: "transparent"
        x: Screen.width-width-10
        y: 10
        width: btns.width+showLayer*152
        height: object.isSpread ? btns.height+15 : btn_spread.height+15
        property int showLayer: system_menu&&page_menu&&mi_toggle_page ? (system_menu.visible || page_menu.visible)+mi_toggle_page.visible : 0
        ColumnLayout{
            id: btns
            anchors.right: parent ? parent.right : undefined 
            spacing: 5
            UniDeskButton{
                id: btn_spread
                contentText: object.isSpread ? qsTr("收起") : qsTr("展开")
                iconSize: 15
                iconSource: object.isSpread ? "qrc:/media/img/arrow-up-s-line.svg" : "qrc:/media/img/arrow-down-s-line.svg"
                bgHoverColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(1,1,1,0.5).lighter(1.2)
                bgPressColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(1,1,1,0.5).lighter(1.5)
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
                bgHoverColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(1,1,1,0.5).lighter(1.2)
                bgPressColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(1,1,1,0.5).lighter(1.5)
                radius: width / 2
                onClicked:{
                    manager.close_all();
                    base.baseClose();
                }
            }
            UniDeskButton{
                id: btn_system
                contentText: qsTr("系统")
                iconSize: 15
                iconSource: "qrc:/media/img/shut-down-line.svg"
                bgHoverColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(1,1,1,0.5).lighter(1.2)
                bgPressColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(1,1,1,0.5).lighter(1.5)
                radius: width / 2
                onClicked:{
                    system_menu.open()
                }
            }
            UniDeskButton{
                id: btn_page
                contentText: qsTr("页面")
                iconSize: 15
                iconSource: "qrc:/media/img/carousel-view.svg"
                bgHoverColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(1,1,1,0.5).lighter(1.2)
                bgPressColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(1,1,1,0.5).lighter(1.5)
                radius: width / 2
                onClicked:{
                    page_menu.popup(btn_page,Qt.point(-152,0))
                }
            }
            UniDeskButton{
                id: btn_edit
                contentText: qsTr("编辑")
                iconSize: 15
                iconSource: "qrc:/media/img/edit.svg"
                bgHoverColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(1,1,1,0.5).lighter(1.2)
                bgPressColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(1,1,1,0.5).lighter(1.5)
                radius: width / 2
                onClicked:{
                    base.baseClose();
                }
            }
            UniDeskButton{
                id: btn_settings
                contentText: qsTr("设置")
                iconSize: 15
                iconSource: "qrc:/media/img/settings.svg"
                bgHoverColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(1,1,1,0.5).lighter(1.2)
                bgPressColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(1,1,1,0.5).lighter(1.5)
                radius: width / 2
                onClicked:{
                    base.baseClose();
                }
            }
            UniDeskButton{
                id: btn_add
                contentText: qsTr("添加组件")
                iconSize: 15
                iconSource: "qrc:/media/img/add-line.svg"
                bgHoverColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(1,1,1,0.5).lighter(1.2)
                bgPressColor: UniDeskSettings.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(1,1,1,0.5).lighter(1.5)
                radius: width / 2
                onClicked:{
                    manager.add_com_text("文字",Qt.rgba(0,0,0,1),"qrc:/media/font/ZhuZiAWan2.ttf","",30)
                }
            }
        }
        Behavior on height{
            NumberAnimation{
                duration: 500
            }
        }
        UniDeskMenu{
            x: btn_system.x-width-2
            y: btn_system.y
            id: system_menu
            UniDeskMenuItem{
                id: mi_shutdown
                text: qsTr("关机")
                iconSource: "qrc:/media/img/shut-down-line.svg"
                onClicked: {
                    UniDeskTools.systemCommand("shutdown -s")
                }
            }
            UniDeskMenuItem{
                id: mi_restart
                text: qsTr("重启")
                iconSource: "qrc:/media/img/restart-line.svg"
                onClicked: {
                    UniDeskTools.systemCommand("shutdown -r")
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
                    UniDeskTools.systemCommand("shutdown -l")
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
        }
        UniDeskMenu{
            y: btn_page.y
            id: page_menu
            UniDeskMenu{
                id: mi_toggle_page
                title: qsTr("切换页面")
                Repeater{
                    model: manager.page_list
                    UniDeskMenuItem{
                        text: model.text
                        onClicked: {
                            manager.toggle_page_to(model.idx);
                        }
                    }
                }
            }
            UniDeskMenuItem{
                id: mi_toggle_add
                text: qsTr("添加页面")
                iconSource: "qrc:/media/img/carousel-view.svg"
                onClicked: {
                    manager.new_page();
                }
            }
        }
        onFocusOut: {
            system_menu.close();
            page_menu.close();
        }
    }
    UniDeskComManager{
        id: manager
    }
}