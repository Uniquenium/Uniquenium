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

ScrollView{
    property var comManager
    property var customWallpaper
    hoverEnabled: true
    ColumnLayout{
        id: columnLayout
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10
        anchors.margins: 10
        UniDeskText{
            id: languageText
            Layout.preferredHeight: languageComboBox.height
            text: qsTr("显示语言")
            font: UniDeskTextStyle.little
            Layout.alignment: Qt.AlignVCenter
        }     
        UniDeskCheckBox{
            id: autoStartCheckBox
            text: qsTr("开机自启")
            font: UniDeskTextStyle.little
            Layout.alignment: Qt.AlignVCenter
            checked: UniDeskTools.isAppAutoStartEnabled()
            onCheckedChanged: {
                UniDeskTools.setAppAutoStart(checked)
            }
        }
    }
    
    UniDeskComboBox{
        id: languageComboBox
        y: languageText.y + columnLayout.y
        anchors.right: parent.right
        anchors.margins: 10
        model: ["中文", "English"]
        currentIndex: ["zh_CN", "en_US"].indexOf(UniDeskSettings.language)
        onActivated: {
            var lang = ["zh_CN", "en_US"][currentIndex]
            UniDeskSettings.set("language", lang)
            UniDeskGlobals.translate(languageComboBox, lang)
        }
    }
}