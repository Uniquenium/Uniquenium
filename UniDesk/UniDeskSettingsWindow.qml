import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk
import org.uniquenium.unidesk

UniDeskWindow{
    id: window
    width: 1000
    height: 700
    title: qsTr("设置")
    UniDeskTabBar{
        id: tabBar
        x: 10
        UniDeskTabButton{
            text: qsTr("系统")
            //任务栏、桌面壁纸、鼠标样式
        }
        UniDeskTabButton{
            text: qsTr("外观")
            //颜色模式，各控件颜色、字体、圆角大小、外框粗细、主面板外观
        }
        UniDeskTabButton{
            text: qsTr("行为")
            //开机启动，检查更新的模式、显示语言、
        }
        UniDeskTabButton{
            text: qsTr("页面")
            //页面重命名、删除、新建、切换效果设置、系统桌面图标显示
        }
        UniDeskTabButton{
            text: qsTr("热键")
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
        ScrollView{   
            UniDeskText{
                id: text1
                text: qsTr("任务栏")
                font: UniDeskTextStyle.small
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 10
            }
            UniDeskCheckBox{
                id: checkbox1
                text: qsTr("隐藏任务栏")
                anchors.top: text1.bottom
                anchors.left: text1.left
                checked: UniDeskSettings.hideTaskbar
                onCheckedChanged: {
                    UniDeskTools.setTaskbarVisible(!checked);
                    UniDeskSettings.hideTaskbar=checked
                }
            }
            UniDeskText{
                id: text2
                text: qsTr("壁纸")
                font: UniDeskTextStyle.small
                anchors.top: checkbox1.bottom
                anchors.left: parent.left
                anchors.margins: 10
            }
            ButtonGroup{
                id: button_group1
            }
            UniDeskRadioButton{
                id: radioButton1
                text: qsTr("使用Lolicon Api随机壁纸")
                anchors.top: text2.bottom
                anchors.left: parent.left
                anchors.margins: 10
                ButtonGroup.group: button_group1
            }
            UniDeskText{
                id: text2_2
                text: qsTr("刷新间隔（秒，设为0不刷新）")
                font: UniDeskTextStyle.little
                anchors.left: parent.left
                anchors.verticalCenter: spinbox1.verticalCenter
                anchors.margins: 10
            }
            UniDeskSpinBox{
                id: spinbox1
                anchors.top: radioButton1.bottom
                anchors.right: parent.right
                anchors.margins: 10
                editable: true
                to: 3600
            }
            UniDeskRadioButton{
                id: radioButton2
                text: qsTr("自定义壁纸（按回车确认）")
                anchors.top: spinbox1.bottom
                anchors.left: parent.left
                anchors.margins: 10
                ButtonGroup.group: button_group1
            }
            UniDeskPathSelector{
                id: pathSelector1
                anchors.top: radioButton2.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10
                path: UniDeskTools.get_wallpaper()
                onSubmit: {
                    UniDeskTools.set_wallpaper(path);
                }
            }
            UniDeskText{
                id: text3
                text: qsTr("鼠标")
                font: UniDeskTextStyle.small
                anchors.top: pathSelector1.bottom
                anchors.left: parent.left
                anchors.margins: 10
            }
        }
        ScrollView{
            UniDeskText{
                id: label1
                text: qsTr("颜色模式")
                font: UniDeskTextStyle.little
                anchors.left: parent.left
                anchors.margins: 10
                height: option1.height
                anchors.verticalCenter: option1.verticalCenter
            }
            UniDeskComboBox {
                id: option1
                model: [qsTr("浅色"), qsTr("深色"), qsTr("跟随系统")]
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 10
                currentIndex: UniDeskSettings.colorMode
                onCurrentIndexChanged: {
                    UniDeskSettings.colorMode=currentIndex;
                    UniDeskGlobals.updateIsLight(0);
                }
            }
            UniDeskText{
                id: label2
                text: qsTr("主题色")
                font: UniDeskTextStyle.little
                anchors.left: parent.left
                anchors.margins: 10
                height: option2.height
                anchors.verticalCenter: option2.verticalCenter
            }
            UniDeskColorPicker {
                id: option2
                anchors.top: option1.bottom
                anchors.right: parent.right
                anchors.margins: 10
                onSelectedColorChanged:{
                    UniDeskSettings.primaryColor=selectedColor;
                    UniDeskSettings.notify("primaryColor")
                }
                Component.onCompleted:{
                    selectedColor=UniDeskSettings.primaryColor
                }
            }
            UniDeskText{
                id: label3
                text: qsTr("全局字体")
                font: UniDeskTextStyle.little
                anchors.left: parent.left
                anchors.margins: 10
                height: option2.height
                anchors.verticalCenter: option3.verticalCenter
            }
            UniDeskFontBox{
                id: option3
                anchors.top: option2.bottom
                anchors.right: parent.right
                anchors.margins: 10
                currentIndex: UniDeskTools.fontIndex(UniDeskSettings.globalFontFamily)
                onCurrentTextChanged: {
                    UniDeskTextStyle.changeFontFamily(currentText)
                    UniDeskSettings.globalFontFamily=currentText
                }
            }
            UniDeskText{
                id: label4
                text: qsTr("自定义字体")
                font: UniDeskTextStyle.little
                anchors.left: parent.left
                anchors.margins: 10
                height: option3.height
                anchors.verticalCenter: option4.verticalCenter
            }
            Rectangle {
                id: option4
                anchors.top: option3.bottom
                anchors.right: parent.right
                anchors.margins: 10
                width: 300
                height: 200
                clip: true
                ListView{
                    id: option4_listView
                    model: UniDeskTools.getCustomFonts()
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10
                    delegate: Rectangle{
                        anchors.left: parent ? parent.left : undefined
                        anchors.right: parent ? parent.right : undefined
                        RowLayout{   
                            id: font_row_layout
                            anchors.fill: parent
                            anchors.margins: 10
                            UniDeskText{
                                text: modelData[1]
                                font.family: modelData[1]
                                font.pixelSize: 20
                                Layout.fillWidth: true
                            }
                            UniDeskButton{
                                iconSource: "qrc:/media/img/delete-bin.svg"
                                iconSize: 15
                                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
                                radius: width / 2
                                onClicked: {
                                    UniDeskTools.removeFontFamily(modelData[0]);
                                    option4_listView.model=UniDeskTools.getCustomFonts();
                                }
                                Layout.alignment: Qt.AlignRight
                                horizontalPadding: 0
                                verticalPadding: 0
                                padding: 0
                                width: 20
                                height: 20
                            }
                        }
                        Component.onCompleted: {
                            implicitWidth = font_row_layout.childrenRect.width;
                            implicitHeight = font_row_layout.childrenRect.height+25;
                        }
                        border.width: 1
                        border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
                        radius: 5
                    }
                    ScrollBar.vertical: ScrollBar {}
                }
                border.width: 1
                border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
                radius: 5
            }
            UniDeskPathSelector{
                id: customFontSelector
                anchors.top: option4.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10
                mode: UniDeskDefines.FileModeFile
                onSubmit: {
                    if(UniDeskTools.isValidUrl(path)){
                        UniDeskTools.addFontFamily(path.toString().slice(8));
                        option4_listView.model=UniDeskTools.getCustomFonts();
                    }
                }
            }
        }
        ScrollView{
            
        }
        ScrollView{
            
        }
        ScrollView{
            
        }
        ScrollView{
            Image{
                id: unidesk_img
                source: UniDeskGlobals.isLight ? "qrc:/media/logo/uniquenium-l.png":"qrc:/media/logo/uniquenium-d.png"
                sourceSize: Qt.size(width,height)
                width: parent.width-100
                height: width/(1750/338)
                x: (parent.width-width)/2
                y: 10
            }
            UniDeskText{
                id: title
                text: "v1.0.0"//基本组件制作完成后再开始更改版本号
                font: UniDeskTextStyle.large
                x: (parent.width-width)/2
                y: unidesk_img.y+unidesk_img.height+10
            }
            ColumnLayout{
                anchors.top: title.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 10
                spacing: 10
                UniDeskText{
                    id: contributors_title
                    text: qsTr("贡献者")
                    font: UniDeskTextStyle.medium
                }
                RowLayout{
                    spacing: 10
                    UniDeskTextButton{
                        text: "Admibrill"
                        webLink: "https://github.com/admibrill"
                        font: UniDeskTextStyle.little
                    }
                }
                UniDeskText{
                    text: qsTr("相关链接")
                    font: UniDeskTextStyle.medium
                }
                RowLayout{
                    spacing: 10
                    UniDeskTextButton{
                        text: "仓库地址"
                        webLink: "https://github.com/ITCraftDevelopmentTeam/unique-desktop"
                        font: UniDeskTextStyle.little
                    }
                    UniDeskTextButton{
                        text: "官网"
                        //后续添加官网链接
                        font: UniDeskTextStyle.little
                    }
                }
            }
        }
    }
}