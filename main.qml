import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtMultimedia
import UniDesk
import UniDesk.Controls
import UniDesk.Singletons
import Qt.labs.platform as QLP

UniDeskObject{
    id: rootObject
    property bool appVisible: true
    UniDeskRoot{
        id: object
        x:0
        y:0
        width: Screen.desktopAvailableWidth
        height: Screen.desktopAvailableHeight
        title: qsTr("UniDesk")
        visible: rootObject.appVisible
        color: "transparent"
        Rectangle{
            id: rect_bg
            anchors.fill: parent
            color: "transparent"
        }
        property bool isExpand: true
        UniDeskComManager{
            id: component_manager
            root: object
            comWindow: UniDeskComWindow
        }
        Item {
            id: base
            visible: true
            x: Screen.desktopAvailableWidth-width-10
            y: 10
            width: btns.width
            height: object.isExpand ? btns.height+15 : btn_spread.height+15
            clip: true
            ColumnLayout{
                id: btns
                anchors.right: parent ? parent.right : undefined 
                spacing: 5
                UniDeskButton{
                    id: btn_spread
                    contentText: object.isExpand ? qsTr("收起") : qsTr("展开")
                    iconSize: 15
                    iconSource: object.isExpand ? "qrc:/media/img/arrow-up-s-line.svg" : "qrc:/media/img/arrow-down-s-line.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                    radius: width / 2
                    onClicked:{
                        object.isExpand = !object.isExpand
                    }
                }
                UniDeskButton{
                    id: btn_quit
                    contentText: qsTr("退出")
                    iconSize: 15
                    iconSource: "qrc:/media/img/logout-box-line.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                    radius: width / 2
                    onClicked:{
                        confirm_exit_dialog.showActivate();
                    }
                }
                UniDeskButton{
                    id: btn_system
                    contentText: qsTr("系统")
                    iconSize: 15
                    iconSource: "qrc:/media/img/shut-down-line.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                    radius: width / 2
                    onClicked:{
                        system_menu.popup(btn_system,Qt.point(-152,0));
                    }
                }
                UniDeskButton{
                    id: btn_previous_page
                    contentText: qsTr("上一页")
                    iconSize: 15
                    iconSource: "qrc:/media/img/arrow-up-line.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                    radius: width / 2
                    disabled: component_manager.is_first_page()
                    onClicked:{
                        component_manager.previous_page();
                    }
                }
                UniDeskButton{
                    id: btn_page
                    contentText: qsTr("页面")
                    iconSize: 15
                    iconSource: "qrc:/media/img/carousel-view.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                    radius: width / 2
                    onClicked:{
                        page_menu.popup(btn_page,Qt.point(-152,0));
                    }
                }
                UniDeskButton{
                    id: btn_next_page
                    contentText: qsTr("下一页")
                    iconSize: 15
                    iconSource: "qrc:/media/img/arrow-down-line.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                    radius: width / 2
                    disabled: component_manager.is_last_page()
                    onClicked:{
                        component_manager.next_page();
                    }
                }
                UniDeskButton{
                    id: btn_settings
                    contentText: qsTr("设置")
                    iconSize: 15
                    iconSource: "qrc:/media/img/settings.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                    radius: width / 2
                    onClicked:{
                        UniDeskSettingsWindow.showActivate()
                    }
                }
                UniDeskButton{
                    id: btn_add
                    contentText: qsTr("添加组件")
                    iconSize: 15
                    iconSource: "qrc:/media/img/add-line.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                    radius: width / 2
                    onClicked:{
                        component_manager.parentOfNewCom=object.contentItem;
                        UniDeskComWindow.pageid=component_manager.currentPid;
                        UniDeskComWindow.showActivate();
                    }
                }
            }
            Behavior on height{
                NumberAnimation{
                    duration: 500
                }
            }
            UniDeskMenu{
                y: btn_system.y
                id: system_menu
                UniDeskMenuItem{
                    id: mi_shutdown
                    text: qsTr("关机")
                    iconSource: "qrc:/media/img/shut-down-line.svg"
                    onClicked: {
                        shutdown_dialog.showActivate();
                    }
                }
                UniDeskMenuItem{
                    id: mi_restart
                    text: qsTr("重启")
                    iconSource: "qrc:/media/img/restart-line.svg"
                    onClicked: {
                        restart_dialog.showActivate();
                    }
                }
                UniDeskMenuItem{
                    id: mi_sleep
                    text: qsTr("休眠")
                    iconSource: "qrc:/media/img/rest-time-line.svg"
                    onClicked: {
                        UniDeskTools.systemCommand("powercfg -h on")
                    }
                }
                UniDeskMenuItem{
                    id: mi_logout
                    text: qsTr("注销")
                    iconSource: "qrc:/media/img/logout-box-line.svg"
                    onClicked: {
                        logout_dialog.showActivate();
                    }
                }
                UniDeskMenuItem{
                    id: mi_lock
                    text: qsTr("锁屏")
                    iconSource: "qrc:/media/img/lock.svg"
                    onClicked: {
                        UniDeskTools.systemCommand("Rundll32.exe user32.dll,LockWorkStation")
                    }
                }
                //系统有更新时显示更新选项
            }
            UniDeskMenu{
                y: btn_page.y
                id: page_menu
                UniDeskMenu{
                    id: mi_toggle_page
                    title: qsTr("切换页面")
                    Instantiator {
                        id: inst
                        model: component_manager.page_list
                        UniDeskMenuItem {
                            text: model.text
                            font.family: UniDeskTextStyle.little.family
                            font.pixelSize: UniDeskTextStyle.little.pixelSize
                            font.bold: component_manager.pindex2pid(index) === component_manager.currentPid
                            onTriggered: component_manager.toggle_page_to(model.pid)
                        }
                        onObjectAdded: function(index, obj){
                            mi_toggle_page.insertItem(index, obj)
                        }
                        onObjectRemoved: function(index,obj){
                            mi_toggle_page.removeItem(obj)
                        }
                    }
                }
                UniDeskMenuSeparator{
                }
                UniDeskMenuItem{
                    id: mi_toggle_add
                    text: qsTr("添加页面")
                    iconSource: "qrc:/media/img/add-line.svg"
                    onClicked: {
                        component_manager.new_page();
                    }
                }
                UniDeskMenuItem{
                    id: mi_layer
                    text: qsTr("管理页面")
                    iconSource: "qrc:/media/img/settings.svg"
                    onClicked: {
                        UniDeskPageWindow.showActivate();
                    }
                }
            }
        }
        UniDeskMessageBox{
            id: confirm_exit_dialog
            title: qsTr("确认退出")
            text: qsTr("确认要退出吗？")
            Component.onCompleted: {
                addButton(qsTr("确定"));
                addButton(qsTr("取消"));
            }
            onButtonClicked: {
                if(clickedIndex==0){
                    object.exitAll();
                }
            }
        }
        UniDeskMessageBox{
            id: shutdown_dialog
            title: qsTr("确认关机")
            text: qsTr("确认要关机吗？")
            Component.onCompleted: {
                addButton(qsTr("确定"));
                addButton(qsTr("取消"));
            }
            onButtonClicked: {
                if(clickedIndex==0){
                    UniDeskTools.systemCommand("shutdown -s -t 0");
                }
            }
        }
        UniDeskMessageBox{
            id: restart_dialog
            title: qsTr("确认重启")
            text: qsTr("确认要重启吗？")
            Component.onCompleted: {
                addButton(qsTr("确定"));
                addButton(qsTr("取消"));
            }
            onButtonClicked: {
                if(clickedIndex==0){
                    UniDeskTools.systemCommand("shutdown -r -t 0");
                }
            }
        }
        UniDeskMessageBox{
            id: logout_dialog
            title: qsTr("确认注销")
            text: qsTr("确认要注销吗？")
            Component.onCompleted: {
                addButton(qsTr("确定"));
                addButton(qsTr("取消"));
            }
            onButtonClicked: {
                if(clickedIndex==0){
                    UniDeskTools.systemCommand("shutdown -l -t 0");
                }
            }
        }
        function closeAllWindows(){
            UniDeskSettingsWindow.close();
            UniDeskComWindow.close();
            UniDeskPageWindow.close();
            custom_wallpaper.close();
        }
        function exitAll(){
            object.closeAllWindows();
            UniDeskExpr.stopThread();
            UniDeskGlobals.emitApplicationQuit();
        }
        onMouseMoved:(pos) => {
            
            updateMouseClickThrough(pos);
            //Check  if the mouse is on "base"
            

        }
        onMousePressed:(button, pos) => {
        }
        onMouseReleased:(button, pos) => {
        }
        Component.onCompleted: {
            UniDeskPluginMgr.setEngine(QQMLENGINE);
            UniDeskPluginMgr.loadPlugins();
            UniDeskSettingsWindow.customWallpaper=custom_wallpaper;
            UniDeskSettingsWindow.comManager=component_manager;
            UniDeskComWindow.comManager=component_manager;
            UniDeskPageWindow.comManager=component_manager;
            UniDeskPageWindow.comWindow=UniDeskComWindow;
            component_manager.loadComponentTypesFromData();
            component_manager.currentPid=UniDeskComponentsData.getCurrentPage();
            component_manager.loadPagesFromData();
            component_manager.loadComponentsFromData();
            
            // 插件加载完成后初始化壁纸
            custom_wallpaper.initWallpaper();
        }
        function updateMouseClickThrough(pos){
            let moac=component_manager.mouse_on_any_com(pos)
            let bcgp=base.contains(base.mapFromGlobal(pos))
            mouseClickThrough=!(moac||bcgp);
        }
    }
    UniDeskCustomWallpaper{
        id: custom_wallpaper
        x:0
        y:0
        width: Screen.width
        height: Screen.height
        visible: rootObject.appVisible
        color: "transparent"
        property real refreshInterval: 0
        property string temporaryImageUrl: ""
        Rectangle {
            id: wallpaperRect
            anchors.fill: parent
            color: UniDeskGlobals.isLight ? "white" : "black"
        }
        // 壁纸图片
        AnimatedImage {
            id: wallpaperImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: {
                if(custom_wallpaper.wallpaperMode === 0){
                    return UniDeskTools.get_system_wallpaper();
                }
                else if (custom_wallpaper.wallpaperMode === 1){
                    return custom_wallpaper.temporaryImageUrl;
                }
                else{
                    return custom_wallpaper.wallpaperImageUrl;
                }
            }
            visible: 
            custom_wallpaper.wallpaperMode === 0 ||
            custom_wallpaper.wallpaperMode === 1 || custom_wallpaper.wallpaperMode === 2
            z: 32767
        }
        
        // 壁纸视频
        MediaPlayer {
            id: wallpaperMediaPlayer
            source: custom_wallpaper.wallpaperVideoUrl
            autoPlay: false  // 禁用自动播放，手动控制
            loops: MediaPlayer.Infinite
            audioOutput: AudioOutput {
                id: wallpaperAudioOutput
                volume: custom_wallpaper.wallpaperVolume / 100.0
            }
            videoOutput: wallpaperVideo

        }
        VideoOutput {
            id: wallpaperVideo
            anchors.fill: parent
            visible: custom_wallpaper.wallpaperMode === 3
            fillMode: VideoOutput.PreserveAspectCrop
        }
        // 监听wallpaperMode变化
        onWallpaperModeChanged: {
            if (wallpaperMode === 3) {
                wallpaperMediaPlayer.play();
            }
            else{
                wallpaperMediaPlayer.stop();
            }
        }
        
        // 监听wallpaperVideoUrl变化
        onWallpaperVideoUrlChanged: {
            if (wallpaperMode === 3) {
                wallpaperMediaPlayer.source = wallpaperVideoUrl;
                wallpaperMediaPlayer.play();
            }
        }
        
        // 监听wallpaperVolume变化
        onWallpaperVolumeChanged: {
            wallpaperAudioOutput.volume = wallpaperVolume / 100.0;
        }
        // 程序退出时清理MediaPlayer，防止音频线程崩溃
        Component.onDestruction: {
            wallpaperMediaPlayer.stop();
            wallpaperMediaPlayer.source = "";
        }
        // 壁纸刷新定时器
        Timer {
            id: wallpaperRefreshTimer
            interval: 1000 * custom_wallpaper.refreshInterval
            running: custom_wallpaper.wallpaperMode === 1 && custom_wallpaper.refreshInterval > 0
            repeat: true
            onTriggered: {
                custom_wallpaper.fetchLoliconWallpaper();
            }
        }
        
        // 获取Lolicon壁纸
        function fetchLoliconWallpaper() {
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        try {
                            var response = JSON.parse(xhr.responseText);
                            if (response.data && response.data.length > 0) {
                                var url = response.data[0].urls.original;
                                custom_wallpaper.temporaryImageUrl = url;
                                custom_wallpaper.updateWallpaper();
                            }
                        } catch (e) {
                            console.error("Failed to parse Lolicon API response:", e);
                        }
                    } else {
                        console.error("HTTP request failed with status:", xhr.status);
                    }
                }
            }
            xhr.open("GET", "https://api.lolicon.app/setu/v2?r18=0&num=1");
            xhr.send();
        }
        
        // 更新壁纸
        function updateWallpaper() {
            custom_wallpaper.refreshInterval = UniDeskSettings.get("wallpaperRefreshInterval");
            custom_wallpaper.wallpaperMode = UniDeskSettings.get("wallpaperMode");
            custom_wallpaper.wallpaperImageUrl = UniDeskSettings.get("wallpaperImageUrl");
            custom_wallpaper.wallpaperVideoUrl = UniDeskSettings.get("wallpaperVideoUrl");
            custom_wallpaper.wallpaperVolume = UniDeskSettings.get("wallpaperVolume");
            if(custom_wallpaper.wallpaperMode === 0){
                wallpaperImage.source = UniDeskTools.get_system_wallpaper();
            }
            else if (custom_wallpaper.wallpaperMode === 1){
                wallpaperImage.source = custom_wallpaper.temporaryImageUrl;
            }
            else{
                wallpaperImage.source = custom_wallpaper.wallpaperImageUrl;
            }
        }
        // 初始化壁纸（延迟到插件加载完成后调用）
        function initWallpaper() {
            updateWallpaper();
            // 如果是视频模式，手动启动MediaPlayer
            if (custom_wallpaper.wallpaperMode === 3 && custom_wallpaper.wallpaperVideoUrl !== "") {
                wallpaperMediaPlayer.source = custom_wallpaper.wallpaperVideoUrl;
                wallpaperMediaPlayer.play();
            }
        }
        // 组件创建完成时不自动初始化，等待插件加载
        Component.onCompleted: {
            // 等待主窗口的Component.onCompleted调用initWallpaper()
        }
    }
    Connections {
        target: UniDeskSystemTray
        function onShowWindow() {
            appVisible = true
            UniDeskSystemTray.setWindowVisible(appVisible)
        }
        function onHideWindow() {
            appVisible = false
            UniDeskSystemTray.setWindowVisible(appVisible)
        }
        function onOpenSettings() {
            appVisible = true
            UniDeskSystemTray.setWindowVisible(appVisible)
            UniDeskSettingsWindow.showActivate()
        }
        function onOpenPageManager() {
            appVisible = true
            UniDeskSystemTray.setWindowVisible(appVisible)
            UniDeskPageWindow.showActivate()
        }
        function onExitApp() {
            object.exitAll()
        }
    }
    Component.onCompleted: {
        UniDeskSystemTray.setIcon(":/media/logo/uq-l-bg.png")
        UniDeskSystemTray.setTooltip(qsTr("UniDesk"))
        UniDeskSystemTray.setVisible(true)
        UniDeskSystemTray.setWindowVisible(appVisible)
    }
}
