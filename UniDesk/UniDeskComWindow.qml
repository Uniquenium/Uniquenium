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
    width: 500
    height: 350
    title: qsTr("选择控件")
    signal textSelected()
    signal linkSelected()
    signal frameSelected()
    signal groupSelected()
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
                display: Button.TextOnly
                contentText: qsTr("文字")
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    textSelected();
                    window.close();
                }
            }
            UniDeskButton{
                id: button2
                display: Button.TextOnly
                contentText: qsTr("链接")
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    linkSelected();
                    window.close();
                }
            }
            UniDeskButton{
                id: button3
                display: Button.TextOnly
                contentText: qsTr("分区框")
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    frameSelected();
                    window.close();
                }
            }
            UniDeskButton{
                id: button4
                display: Button.TextOnly
                contentText: qsTr("分组")
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    groupSelected();
                    window.close();
                }
            }

        }
    }
}