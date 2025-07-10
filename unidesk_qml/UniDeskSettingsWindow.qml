import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import unidesk_qml
import org.itcdt.unidesk

UniDeskWindow{
    id: window
    width: 1000
    height: 700
    title: qsTr("设置")
    UniDeskTabBar{
        id: tabBar
        UniDeskTabButton{
            text: qsTr("系统")
            //任务栏、桌面壁纸、鼠标样式、桌面图标显示
        }
        UniDeskTabButton{
            text: qsTr("外观")
            //颜色模式，各控件颜色、字体、圆角大小、外框粗细
        }
        UniDeskTabButton{
            text: qsTr("行为")
            //开机启动，检查更新的模式、显示语言、文件保存位置
        }
        UniDeskTabButton{
            text: qsTr("页面")
            //页面重命名、删除、新建、切换效果设置
        }
        UniDeskTabButton{
            text: qsTr("关于")
            //仓库链接、鸣谢、版本、检查更新
        }
    }
    SwipeView{
        currentIndex: tabBar.currentIndex
        anchors.top: tabBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        interactive: false
        Item{

        }
        Item{
            
        }
        Item{
            
        }
        Item{
            
        }
        ScrollView{
            Image{
                id: unidesk_img
                source: UniDeskGlobals.isLight ? "qrc:/media/logo/uniquedesktop-l-bg.png":"qrc:/media/logo/uniquedesktop-d-bg.png"
                sourceSize: Qt.size(width,height)
                width: 400
                height: 200
                x: (parent.width-width)/2
                y: 10
            }
            UniDeskText{
                id: title
                text: "UniqueDesktop v1.0.0"//基本组件制作完成后再开始更改版本号
                x: (parent.width-width)/2
                y: unidesk_img.y+unidesk_img.height+10
            }
        }
    }
}