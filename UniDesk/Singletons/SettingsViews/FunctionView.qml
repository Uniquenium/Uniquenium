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
        UniDeskText{
            text: qsTr("主题")
            font: UniDeskTextStyle.small_
            Layout.topMargin: 10
        }
        RowLayout{
            Layout.fillWidth: true
            spacing: 10
            UniDeskText{
                text: qsTr("保存/加载路径")
                font: UniDeskTextStyle.little
                Layout.alignment: Qt.AlignVCenter
            }
            UniDeskPathSelector{
                id: themePathSelector
                Layout.fillWidth: true
                mode: UniDeskFileMode.FileModeFolder
                parentWindow: UniDeskSettingsWindow
            }
        }
        UniDeskText{
            text: qsTr("加载主题将覆盖外观设置、页面组件布局、插件")
            color: UniDeskTools.switchColor("#666666", "#999999", "#AAAAAA", "#555555", true, false, false)
            font: UniDeskTextStyle.little
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }
        RowLayout{
            Layout.fillWidth: true
            spacing: 10
            UniDeskButton{
                Layout.fillWidth: true
                display: Button.TextOnly
                contentText: qsTr("保存为主题")
                enabled: !UniDeskThemeManager.isWorking
                borderWidth: 1
                radius: 5
                onClicked: {
                    var p = themePathSelector.path.toString();
                    if (p === "") {
                        UniDeskSettingsWindow.showError(qsTr("请先选择保存路径"));
                        return;
                    }
                    UniDeskThemeManager.saveTheme(p);
                    UniDeskTools.showFileInExplorer(p);
                }
            }
            UniDeskButton{
                Layout.fillWidth: true
                display: Button.TextOnly
                contentText: qsTr("从主题加载")
                enabled: !UniDeskThemeManager.isWorking
                borderWidth: 1
                radius: 5
                onClicked: {
                    var p = themePathSelector.path.toString();
                    if (p === "") {
                        UniDeskSettingsWindow.showError(qsTr("请先选择加载路径"));
                        return;
                    }
                    loadConfirm.themePath = p;
                    loadConfirm.showActivate();
                }
            }
        }
        UniDeskMessageBox{
            id: loadConfirm
            property string themePath: ""
            title: qsTr("确认加载主题")
            text: qsTr("加载主题将覆盖当前的外观设置、页面组件布局和插件\n程序将在加载完成后自动重启\n是否继续？")
            Component.onCompleted: {
                addButton(qsTr("继续加载"));
                addButton(qsTr("取消"));
            }
            onButtonClicked: {
                if(clickedIndex===0){
                    UniDeskThemeManager.loadTheme(themePath);
                }
                themePath = "";
            }
        }
        ProgressBar{
            Layout.fillWidth: true
            visible: UniDeskThemeManager.isWorking
            value: UniDeskThemeManager.progress
        }
        UniDeskText{
            text: UniDeskThemeManager.progressMessage
            visible: UniDeskThemeManager.isWorking
            font: UniDeskTextStyle.little
        }
        Connections{
            target: UniDeskThemeManager
            function onErrorOccurred(message){
                UniDeskSettingsWindow.showError(message);
            }
            function onFinished(success, message){
                if(success){
                    UniDeskSettingsWindow.showSuccess(message);
                } else {
                    UniDeskSettingsWindow.showError(message);
                }
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
            UniDeskSettings.set("function.language", lang)
            UniDeskGlobals.translate(languageComboBox, lang)
        }
    }
}