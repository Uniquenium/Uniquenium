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
    
    UniDeskText{
        id: textLanguage
        text: qsTr("显示语言")
        font: UniDeskTextStyle.little
        anchors.left: parent.left
        anchors.margins: 10
        anchors.verticalCenter: languageComboBox.verticalCenter
    }
    
    UniDeskComboBox{
        id: languageComboBox
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        model: ["中文", "English"]
        currentIndex: ["zh_CN", "en_US"].indexOf(UniDeskSettings.language)
        onActivated: {
            var lang = ["zh_CN", "en_US"][currentIndex]
            UniDeskSettings.set("language", lang)
            UniDeskSettings.notify("language")
            UniDeskGlobals.translate(languageComboBox, lang)
        }
        onModelChanged: {
            currentIndex = ["zh_CN", "en_US"].indexOf(UniDeskSettings.language)
        }
    }
}