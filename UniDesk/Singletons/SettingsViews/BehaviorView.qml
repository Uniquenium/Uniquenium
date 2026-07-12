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
        model: [qsTr("中文"), qsTr("English")]
        currentIndex: {
            if (UniDeskSettings.language === "zh_CN") return 0
            else if (UniDeskSettings.language === "en_US") return 1
            return 0
        }
        onActivated: {
            var lang = currentIndex === 0 ? "zh_CN" : "en_US"
            UniDeskSettings.set("language", lang)
            UniDeskSettings.notify("language")
            
            var locale = currentIndex === 0 ? "zh_CN" : "en_US"
            UniDeskGlobals.translate(languageComboBox, locale)
        }
    }
}