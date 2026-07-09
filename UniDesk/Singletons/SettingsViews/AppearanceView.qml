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
    contentHeight: textMouse.height+textMouse.y-labelColorMode.y+30
    hoverEnabled: true
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
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 10
        currentIndex: UniDeskSettings.colorMode
        onActivated:  {
            UniDeskSettings.set("colorMode", currentIndex);
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
            UniDeskSettings.notify("primaryColor")
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
            } else if (checkedButton === radioButtonLolicon) {
                UniDeskSettings.set("wallpaperMode", 1);
                customWallpaper.updateWallpaper();
                customWallpaper.fetchLoliconWallpaper();
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
        id: radioButtonLolicon
        text: qsTr("使用Lolicon Api壁纸")
        anchors.top: radioButtonOff.bottom
        anchors.left: parent.left
        anchors.margins: 10
        checked: customWallpaper.wallpaperMode === 1
        ButtonGroup.group: button_group1
    }
    UniDeskText{
        id: textRefreshInterval
        text: qsTr("刷新间隔（秒，设为0不刷新）")
        font: UniDeskTextStyle.little
        anchors.left: parent.left
        anchors.verticalCenter: spinboxRefresh.verticalCenter
        visible: customWallpaper.wallpaperMode === 1
        anchors.margins: 10
    }
    UniDeskSpinBox{
        id: spinboxRefresh
        anchors.top: radioButtonLolicon.bottom
        anchors.right: parent.right
        anchors.margins: 10
        editable: true
        from: 0
        to: 3600
        value: customWallpaper.refreshInterval
        visible: customWallpaper.wallpaperMode === 1
        onValueModified: {
            UniDeskSettings.set("wallpaperRefreshInterval", value);
            customWallpaper.updateWallpaper();
        }
    }
    UniDeskRadioButton{
        id: radioButtonImage
        text: qsTr("自定义图片/动图")
        anchors.top: customWallpaper.wallpaperMode === 1 ? spinboxRefresh.bottom : radioButtonLolicon.bottom
        anchors.left: parent.left
        anchors.margins: 10
        checked: customWallpaper.wallpaperMode === 2
        ButtonGroup.group: button_group1
    }
    UniDeskPathSelector{
        id: pathSelector1
        anchors.top: radioButtonImage.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        path: customWallpaper.wallpaperImageUrl
        visible: customWallpaper.wallpaperMode === 2
        onSubmit: {
            UniDeskSettings.set("wallpaperImageUrl", path.toString());
            if (radioButtonImage.checked) {
                customWallpaper.updateWallpaper();
            }
        }
    }
    UniDeskRadioButton{
        id: radioButtonVideo
        text: qsTr("自定义视频")
        anchors.top: (customWallpaper.wallpaperMode === 2) ? pathSelector1.bottom : radioButtonImage.bottom
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
        id: textMouse
        text: qsTr("鼠标")
        font: UniDeskTextStyle.small_
        anchors.top: (customWallpaper.wallpaperMode === 3) ? sliderVideoVolume.bottom : radioButtonVideo.bottom
        anchors.left: parent.left
        anchors.margins: 10
    }
}