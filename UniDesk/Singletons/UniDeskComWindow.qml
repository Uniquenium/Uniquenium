pragma Singleton
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk.PyPlugin

UniDeskWindow{
    id: window
    width: 500
    height: 350
    title: qsTr("选择控件")
    property string parentId
    ScrollView{
        anchors.fill: parent
        anchors.margins: 10
        UniDeskText{
            id: text1
            text: qsTr("基础控件")
            font: UniDeskTextStyle.small
            anchors.top: parent.top
            anchors.left: parent.left
        }
        RowLayout{
            spacing: 10
            anchors.top: text1.bottom
            anchors.left: parent.left
            UniDeskButton{
                id: button1
                display: Button.TextBesideIcon
                contentText: qsTr("文字")
                iconSource: "qrc:/media/img/text.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    UniDeskComManager.add_com("UDCText",contentText,window.parentId);
                    window.close();
                }
            }
            UniDeskButton{
                id: button2
                display: Button.TextBesideIcon
                contentText: qsTr("按钮")
                iconSource: "qrc:/media/img/arrow-down-box-line.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    window.close();
                }
            }
            UniDeskButton{
                id: button3
                display: Button.TextBesideIcon
                contentText: qsTr("图片")
                iconSource: "qrc:/media/img/image.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    window.close();
                }
            }
            UniDeskButton{
                id: button4
                display: Button.TextBesideIcon
                contentText: qsTr("图表")
                iconSource: "qrc:/media/img/line-chart-line.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    window.close();
                }
            }
            UniDeskButton{
                id: button5
                display: Button.TextBesideIcon
                contentText: qsTr("分区框")
                iconSource: "qrc:/media/img/checkbox.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    window.close();
                }
            }
            UniDeskButton{
                id: button6
                display: Button.TextBesideIcon
                contentText: qsTr("分组")
                iconSource: "qrc:/media/img/layout-2-fill.svg"
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    window.close();
                }
            }
        }
    }
}