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
    contentHeight: main_column.height
    Column {
        id: main_column
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10
        UniDeskText {
            id: text_open_settings
            text: qsTr("打开设置")
            font: UniDeskTextStyle.little
            height: hotkeyPickerOpenSettings.height
            anchors.left: parent.left
        }
        UniDeskText {
            id: text_open_page_manager
            text: qsTr("打开页面管理器")
            font: UniDeskTextStyle.little
            height: hotkeyPickerOpenPageManager.height
            anchors.left: parent.left
        }
    }
    UniDeskHotkeyPicker {
        id: hotkeyPickerOpenSettings
        current: UniDeskSettings.hotkey_open_settings.split("+")
        anchors.right: parent.right
        anchors.margins: 10
        y: text_open_settings.y 
        onAccepted: {
            UniDeskSettings.set("hotkey_open_settings", current.join("+"))
        }
    }
    UniDeskHotkeyPicker {
        id: hotkeyPickerOpenPageManager
        current: UniDeskSettings.hotkey_open_page_manager.split("+")
        anchors.right: parent.right
        anchors.margins: 10
        y: text_open_page_manager.y 
        onAccepted: {
            UniDeskSettings.set("hotkey_open_page_manager", current.join("+"))
        }
    }
}