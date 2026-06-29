pragma Singleton
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQml
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk
import "./SettingsViews" as UDSV

UniDeskWindow{
    id: window
    width: 1000
    height: 700
    title: qsTr("设置")
    autoDestroy: false// keep the system appbar hidden (temporary solution)
    autoVisible: false
    property var comManager
    property var customWallpaper
    UniDeskTabBar{
        id: tabBar
        x: 10
        UniDeskTabButton{
            text: qsTr("行为")
            //任务栏、桌面壁纸、鼠标样式，桌面图标显示、开机启动，检查更新的模式、显示语言、
        }
        UniDeskTabButton{
            text: qsTr("外观")
            //颜色模式，各控件颜色、字体、圆角大小、外框粗细、主面板外观
        }
        UniDeskTabButton{
            text: qsTr("热键")
        }
        UniDeskTabButton{
            text: qsTr("插件")
        }
        UniDeskTabButton{
            text: qsTr("关于")
            //仓库链接、鸣谢、版本、检查更新、官网链接
        }
    }
    SwipeView{
        currentIndex: tabBar.currentIndex
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        interactive: false
        UDSV.BehaviorView{
            comManager: window.comManager
            customWallpaper: window.customWallpaper
        }
        UDSV.AppearanceView{
            comManager: window.comManager
            customWallpaper: window.customWallpaper
        }
        UDSV.HotkeysView{
            comManager: window.comManager
            customWallpaper: window.customWallpaper
        }
        UDSV.PluginsView{
            comManager: window.comManager
            customWallpaper: window.customWallpaper
        }
        UDSV.AboutView{
            comManager: window.comManager
            customWallpaper: window.customWallpaper
        }
    }
}
