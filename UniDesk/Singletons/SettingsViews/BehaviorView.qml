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
        id: textWallpaper
        text: qsTr("壁纸")
        font: UniDeskTextStyle.small_
        anchors.top: parent.top
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