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
    id: view
    property var comManager
    property var customWallpaper
    hoverEnabled: true
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
             
            UniDeskGlobals.translate(languageComboBox, lang)
        }
    }
    UniDeskText{
        id: labelColorMode
        text: qsTr("颜色模式")
        font: UniDeskTextStyle.little
        anchors.left: parent.left
        anchors.margins: 10
        height: optionColorMode.height
        anchors.verticalCenter: optionColorMode.verticalCenter
    }
    UniDeskComboBox {
        id: optionColorMode
        comManager: UniDeskSettingsWindow.comManager
        model: [qsTr("浅色"), qsTr("深色"), qsTr("跟随系统")]
        anchors.top: languageComboBox.bottom
        anchors.right: parent.right
        anchors.margins: 10
        currentIndex: UniDeskSettings.colorMode
        onActivated:  {
            UniDeskSettings.set("colorMode", currentIndex);
            UniDeskGlobals.updateIsLight();
        }
        onModelChanged: {
            currentIndex = UniDeskSettings.colorMode
            UniDeskGlobals.updateIsLight();
        }
    }
    UniDeskText{
        id: labelPrimaryColor
        text: qsTr("主题色")
        font: UniDeskTextStyle.little
        anchors.left: parent.left
        anchors.margins: 10
        height: optionPrimaryColor.height
        anchors.verticalCenter: optionPrimaryColor.verticalCenter
    }
    UniDeskColorPicker {
        id: optionPrimaryColor
        anchors.top: optionColorMode.bottom
        anchors.right: parent.right
        anchors.margins: 10
        onSelectedColorChanged:{
            UniDeskSettings.set("primaryColor", selectedColor);
             
        }
        Component.onCompleted:{
            selectedColor=UniDeskSettings.primaryColor
        }
    }
    UniDeskText{
        id: labelGlobalFont
        text: qsTr("全局字体")
        font: UniDeskTextStyle.little
        anchors.left: parent.left
        anchors.margins: 10
        height: optionGlobalFont.height
        anchors.verticalCenter: optionGlobalFont.verticalCenter
    }
    UniDeskFontBox{
        id: optionGlobalFont
        comManager: UniDeskSettingsWindow.comManager
        anchors.top: optionPrimaryColor.bottom
        anchors.right: parent.right
        anchors.margins: 10
        currentIndex: UniDeskTools.fontIndex(UniDeskSettings.globalFontFamily)
        onCurrentTextChanged: {
            UniDeskTextStyle.changeFontFamily(currentText);
            UniDeskSettings.set("globalFontFamily", currentText);
        }
    }
    UniDeskText{
        id: labelCustomFont
        text: qsTr("自定义字体")
        font: UniDeskTextStyle.little
        anchors.left: parent.left
        anchors.margins: 10
        height: optionCustomFont.height
        anchors.verticalCenter: optionCustomFont.verticalCenter
    }
    Rectangle {
        id: optionCustomFont
        anchors.top: optionGlobalFont.bottom
        anchors.right: parent.right
        anchors.margins: 10
        width: 300
        height: 200
        clip: true
        color: "transparent"
        ListView{
            id: customFontListView
            model: UniDeskTools.getCustomFonts()
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            delegate: Rectangle{
                anchors.left: parent ? parent.left : undefined
                anchors.right: parent ? parent.right : undefined
                color: "transparent"
                RowLayout{
                    id: fontRowLayout
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
                            customFontListView.model=UniDeskTools.getCustomFonts();
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
                    implicitWidth = fontRowLayout.childrenRect.width;
                    implicitHeight = fontRowLayout.childrenRect.height+25;
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
        anchors.top: optionCustomFont.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        mode: UniDeskFileMode.FileModeFile
        onSubmit: {
            if(UniDeskTools.isValidUrl(path)){
                UniDeskTools.addFontFamily(path.toString().slice(8));
                customFontListView.model=UniDeskTools.getCustomFonts();
            }
        }
    }
    UniDeskText{
        id: textWallpaper
        text: qsTr("壁纸")
        font: UniDeskTextStyle.small_
        anchors.top: customFontSelector.bottom
        anchors.left: parent.left
        anchors.margins: 10
    }
    ButtonGroup{
        id: button_group1
        onCheckedButtonChanged: {
            if (checkedButton === radioButtonOff) {
                UniDeskSettings.set("wallpaperMode", 0);
                customWallpaper.updateWallpaper();
            } else if (checkedButton === radioButtonApi) {
                UniDeskSettings.set("wallpaperMode", 1);
                customWallpaper.updateWallpaper();
            } else if (checkedButton === radioButtonImage) {
                UniDeskSettings.set("wallpaperMode", 2);
                customWallpaper.updateWallpaper();
            } else if (checkedButton === radioButtonVideo) {
                UniDeskSettings.set("wallpaperMode", 3);
                customWallpaper.updateWallpaper();
            }
        }
    }
    UniDeskRadioButton{
        id: radioButtonOff
        text: qsTr("关闭")
        anchors.top: textWallpaper.bottom
        anchors.left: parent.left
        anchors.margins: 10
        checked: customWallpaper.wallpaperMode === 0
        ButtonGroup.group: button_group1
    }
    UniDeskRadioButton{
        id: radioButtonApi
        text: qsTr("使用自定义API壁纸")
        anchors.top: radioButtonOff.bottom
        anchors.left: parent.left
        anchors.margins: 10
        checked: customWallpaper.wallpaperMode === 1
        ButtonGroup.group: button_group1
    }
    // 自定义API配置
    Column{
        id: apiConfigColumn
        anchors.top: radioButtonApi.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        visible: customWallpaper.wallpaperMode === 1
        spacing: 10
        
        // API地址和刷新间隔在同一行
        RowLayout{
            id: apiRowLayout
            width: parent.width
            
            Column{
                Layout.fillWidth: true
                UniDeskText{
                    text: qsTr("API地址")
                    font: UniDeskTextStyle.little
                }
                UniDeskTextField{
                    id: apiUrlField
                    width: parent.width
                    placeholderText: qsTr("https://api.example.com/images")
                    text: UniDeskSettings.get("wallpaperApiUrl") || ""
                    onEditingFinished: {
                        UniDeskSettings.set("wallpaperApiUrl", text);
                        
                    }
                }
            }
        }
        
        UniDeskText{
            text: qsTr("提取表达式")
            font: UniDeskTextStyle.little
        }
        UniDeskTextField{
            id: apiExpressionField
            width: parent.width
            placeholderText: qsTr("response.data[0].url")
            text: UniDeskSettings.get("wallpaperApiExpression") || ""
            onEditingFinished: {
                UniDeskSettings.set("wallpaperApiExpression", text);
                
            }
        }
        
    
        
        // API模式下的刷新间隔
        RowLayout{
            width: parent.width
            spacing: 10
            
            UniDeskText{
                text: qsTr("刷新间隔（秒）")
                font: UniDeskTextStyle.little
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            UniDeskSpinBox{
                id: spinboxRefresh
                editable: true
                from: 0
                to: 3600
                value: customWallpaper.refreshInterval
                onValueModified: {
                    UniDeskSettings.set("wallpaperRefreshInterval", value);
                    
                    customWallpaper.updateWallpaper();
                }
            }
        }
    }
    
    UniDeskRadioButton{
        id: radioButtonImage
        text: qsTr("自定义图片/动图")
        anchors.top: customWallpaper.wallpaperMode === 1 ? apiConfigColumn.bottom : radioButtonApi.bottom
        anchors.left: parent.left
        anchors.margins: 10
        checked: customWallpaper.wallpaperMode === 2
        ButtonGroup.group: button_group1
    }
    
    // 多图片配置（ListView方式）
    Column{
        id: imageConfigColumn
        anchors.top: radioButtonImage.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        visible: customWallpaper.wallpaperMode === 2
        spacing: 10
        
        UniDeskText{
            text: qsTr("图片列表")
            font: UniDeskTextStyle.little
        }
        
        // 图片列表容器
        Rectangle{
            width: parent.width
            height: 200
            border.width: 1
            border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
            radius: 5
            clip: true
            color: "transparent"
            ListView{
                id: imageListView
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                model: UniDeskSettings.get("wallpaperImageUrls") || []
                
                delegate: RowLayout{
                    width: parent.width
                    spacing: 5
                    
                    UniDeskPathSelector{
                        id: pathSelector
                        Layout.fillWidth: true
                        path: modelData
                        onSubmit: {
                            var urls = UniDeskSettings.get("wallpaperImageUrls") || [];
                            urls[index] = path.toString();
                            UniDeskSettings.set("wallpaperImageUrls", urls);
                            customWallpaper.updateWallpaper();
                        }
                    }
                    
                    UniDeskButton{
                        iconSource: "qrc:/media/img/delete-bin.svg"
                        iconSize: 15
                        bgHoverColor: Qt.rgba(1, 0, 0, 0.2)
                        bgPressColor: Qt.rgba(1, 0, 0, 0.4)
                        iconColor: Qt.rgba(1, 0, 0, 1)
                        radius: width / 2
                        onClicked: {
                            var urls = UniDeskSettings.get("wallpaperImageUrls") || [];
                            urls.splice(index, 1);
                            UniDeskSettings.set("wallpaperImageUrls", urls);
                            customWallpaper.updateWallpaper();
                            imageListView.model = urls;
                        }
                        Layout.alignment: Qt.AlignVCenter
                        horizontalPadding: 0
                        verticalPadding: 0
                        padding: 0
                        width: 24
                        height: 24
                    }
                }
                ScrollBar.vertical: ScrollBar {}
            }
        }
        
        // 新建项按钮
        UniDeskButton{
            id: addButton
            display: Button.TextOnly
            contentText: qsTr("添加图片")
            bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
            bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
            borderWidth: 1
            radius: 5
            onClicked: {
                var urls = UniDeskSettings.get("wallpaperImageUrls") || [];
                urls.push("");
                UniDeskSettings.set("wallpaperImageUrls", urls);
                customWallpaper.updateWallpaper();
                imageListView.model = urls;
            }
            anchors.left: parent.left
        }
        
        // 图片模式下的刷新间隔
        RowLayout{
            width: parent.width
            spacing: 10
            
            UniDeskText{
                text: qsTr("刷新间隔（秒）")
                font: UniDeskTextStyle.little
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            UniDeskSpinBox{
                id: spinboxRefreshImage
                editable: true
                from: 0
                to: 3600
                value: customWallpaper.refreshInterval
                onValueModified: {
                    UniDeskSettings.set("wallpaperRefreshInterval", value);
                       
                    customWallpaper.updateWallpaper();
                }
            }
        }
    }
    UniDeskRadioButton{
        id: radioButtonVideo
        text: qsTr("自定义视频")
        anchors.top: (customWallpaper.wallpaperMode === 2) ? imageConfigColumn.bottom : radioButtonImage.bottom
        anchors.left: parent.left
        anchors.margins: 10
        checked: customWallpaper.wallpaperMode === 3
        ButtonGroup.group: button_group1
    }
    UniDeskPathSelector{
        id: pathSelector2
        anchors.top: radioButtonVideo.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        path: customWallpaper.wallpaperVideoUrl
        visible: customWallpaper.wallpaperMode === 3
        onSubmit: {
            UniDeskSettings.set("wallpaperVideoUrl", path.toString());
            if (radioButtonVideo.checked) {
                customWallpaper.updateWallpaper();
            }
        }
    }
    UniDeskText{
        id: textVideoVolume
        text: qsTr("音量")
        font: UniDeskTextStyle.little
        anchors.left: parent.left
        anchors.verticalCenter: sliderVideoVolume.verticalCenter
        visible: customWallpaper.wallpaperMode === 3
        anchors.margins: 10
    }
    UniDeskSlider{
        id: sliderVideoVolume
        anchors.top: pathSelector2.bottom
        anchors.right: parent.right
        anchors.margins: 10
        visible: customWallpaper.wallpaperMode === 3
        value: customWallpaper.wallpaperVolume
        to: 100
        stepSize: 1
        onMoved: {
            UniDeskSettings.set("wallpaperVolume", value);
            customWallpaper.updateWallpaper();
        }
    }
    UniDeskText{
        id: textMainPanel
        text: qsTr("主面板")
        font: UniDeskTextStyle.small_
        anchors.top: (customWallpaper.wallpaperMode === 3) ? sliderVideoVolume.bottom : radioButtonVideo.bottom
        anchors.left: parent.left
        anchors.margins: 10
    }
    Column{
        id: mainPanelConfigColumn
        spacing: 10
        anchors.top: textMainPanel.bottom
        anchors.left: parent.left
        anchors.margins: 10
        UniDeskText{
            id: textMainPanelColorDark
            text: qsTr("颜色(深色)")
            font: UniDeskTextStyle.little
            height: colorPickerMainPanelColorDark.height
        }
        UniDeskText{
            id: textMainPanelColorLight
            text: qsTr("颜色(浅色)")
            font: UniDeskTextStyle.little
            height: colorPickerMainPanelColorLight.height
        }
        UniDeskText{
            id: textMainPanelOrientation
            text: qsTr("方向")
            font: UniDeskTextStyle.little
            height: comboBoxMainPanelOrientation.height
        }
        UniDeskText{
            id: textMainPanelPosition
            text: qsTr("位置")
            font: UniDeskTextStyle.little
            height: comboBoxMainPanelPosition.height
        }
    }
    UniDeskColorPicker{
        id: colorPickerMainPanelColorDark
        y: textMainPanelColorDark.y + mainPanelConfigColumn.y 
        anchors.right: parent.right
        anchors.margins: 10
        onSelectedColorChanged: {
            UniDeskSettings.set("mainPanelColorDark", selectedColor);
        }
        Component.onCompleted: {
            selectedColor = UniDeskSettings.mainPanelColorDark;
        }
    }
    UniDeskColorPicker{
        id: colorPickerMainPanelColorLight
        y: textMainPanelColorLight.y + mainPanelConfigColumn.y 
        anchors.right: parent.right
        anchors.margins: 10
        onSelectedColorChanged: {
            UniDeskSettings.set("mainPanelColorLight", selectedColor);
        }
        Component.onCompleted: {
            selectedColor = UniDeskSettings.mainPanelColorLight;
        }
    }
    UniDeskComboBox{
        id: comboBoxMainPanelOrientation
        y: textMainPanelOrientation.y + mainPanelConfigColumn.y 
        anchors.right: parent.right
        anchors.margins: 10
        model: [qsTr("横向"), qsTr("纵向")]
        currentIndex: UniDeskSettings.mainPanelOrientation
        onActivated: {
            UniDeskSettings.set("mainPanelOrientation", currentIndex);
        }
    }
    UniDeskComboBox{
        id: comboBoxMainPanelPosition
        y: textMainPanelPosition.y + mainPanelConfigColumn.y 
        anchors.right: parent.right
        anchors.margins: 10
        model: [qsTr("顶部"), qsTr("底部")]
        currentIndex: UniDeskSettings.mainPanelPosition
        onActivated: {
            UniDeskSettings.set("mainPanelPosition", currentIndex);
        }
    }
    UniDeskText{
        id: textMouse
        text: qsTr("鼠标")
        font: UniDeskTextStyle.small_
        anchors.left: parent.left
        anchors.top: mainPanelConfigColumn.bottom
        anchors.margins: 10
    }
    UniDeskCheckBox{
        id: checkBoxMouseCursorEnabled
        text: qsTr("启用自定义光标")
        anchors.top: textMouse.bottom
        anchors.left: parent.left
        anchors.margins: 10
        checked: UniDeskSettings.customCursorEnabled
        onCheckedChanged: {
            UniDeskSettings.set("customCursorEnabled", checked);
            view.updateCursorStyle();
        }
    }
    UniDeskText{
        id: textMouseCursorStylePath
        text: qsTr("自定义光标样式路径")
        anchors.top: checkBoxMouseCursorEnabled.bottom
        anchors.left: parent.left
        anchors.margins: 10
        height: pathSelector3.height
    }
    UniDeskPathSelector{
        id: pathSelector3
        y: textMouseCursorStylePath.y  
        anchors.left: textMouseCursorStylePath.right
        anchors.right: parent.right
        anchors.margins: 10
        mode: UniDeskFileMode.FileModeFolder
        path: UniDeskSettings.customCursorStylePath
        onSubmit: {
            UniDeskSettings.set("customCursorStylePath", path);
            view.updateCursorStyle();
        }
    }
    function updateCursorStyle(){
        if (UniDeskSettings.customCursorEnabled&&(!(UniDeskSettings.customCursorStylePath===""))) {
            UniDeskCursorManager.loadCustomByPath(UniDeskSettings.customCursorStylePath);
        } else {
            UniDeskCursorManager.restoreSystem();
        }
    }
    contentHeight: pathSelector3.height+pathSelector3.y+10
}