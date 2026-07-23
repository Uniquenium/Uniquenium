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
            y: UniDeskSettings.mainPanelPosition == UniDeskMainPanelPosition.Top ? 10 : Screen.desktopAvailableHeight-height-10
            function isHorizontal(){
                return UniDeskSettings.mainPanelOrientation == UniDeskMainPanelOrientation.Horizontal 
            }
            function isVertical(){
                return UniDeskSettings.mainPanelOrientation == UniDeskMainPanelOrientation.Vertical 
            }
            function iconCollapse(){
                if(base.isVertical()){
                    if(UniDeskSettings.mainPanelPosition == UniDeskMainPanelPosition.Top){
                        return "qrc:/media/img/arrow-up-s-line.svg"
                    }else{
                        return "qrc:/media/img/arrow-down-s-line.svg"
                    }
                }else{
                    return "qrc:/media/img/arrow-right-s-line.svg"
                }
            }
            function iconExpand(){
                if(base.isVertical()){
                    if(UniDeskSettings.mainPanelPosition == UniDeskMainPanelPosition.Top){
                        return "qrc:/media/img/arrow-down-s-line.svg"
                    }else{
                        return "qrc:/media/img/arrow-up-s-line.svg"
                    }
                }else{
                    return "qrc:/media/img/arrow-left-s-line.svg"
                }
            }
            width: base.isHorizontal() ? (object.isExpand ? btns.width : btn_spread.width) : btns.width
            height: base.isVertical() ? (object.isExpand ? btns.height : btn_spread.height) : btns.height
            clip: true
            GridLayout{
                id: btns
                anchors.right: parent ? parent.right : undefined 
                columnSpacing: 5
                rowSpacing: 5
                layoutDirection: Qt.RightToLeft
                flow: base.isHorizontal() ? GridLayout.LeftToRight : GridLayout.TopToBottom
                UniDeskButton{
                    id: btn_spread
                    contentText: object.isExpand ? qsTr("收起") : qsTr("展开")
                    iconSize: 15
                    iconSource: object.isExpand ? base.iconCollapse() : base.iconExpand()
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? UniDeskSettings.mainPanelColorLight : UniDeskSettings.mainPanelColorDark
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
                    iconNormalColor: UniDeskGlobals.isLight ? UniDeskSettings.mainPanelColorLight : UniDeskSettings.mainPanelColorDark
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
                    iconNormalColor: UniDeskGlobals.isLight ? UniDeskSettings.mainPanelColorLight : UniDeskSettings.mainPanelColorDark
                    radius: width / 2
                    onClicked:{
                        system_menu.popup(btn_system,Qt.point(-152,0));
                    }
                }
                UniDeskButton{
                    id: btn_page
                    contentText: qsTr("页面")
                    iconSize: 15
                    iconSource: "qrc:/media/img/carousel-view.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? UniDeskSettings.mainPanelColorLight : UniDeskSettings.mainPanelColorDark
                    radius: width / 2
                    onClicked:{
                        page_menu.popup(btn_page,Qt.point(-152,0));
                    }
                }
                UniDeskButton{
                    id: btn_settings
                    contentText: qsTr("设置")
                    iconSize: 15
                    iconSource: "qrc:/media/img/settings.svg"
                    bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                    bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                    iconNormalColor: UniDeskGlobals.isLight ? UniDeskSettings.mainPanelColorLight : UniDeskSettings.mainPanelColorDark
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
                    iconNormalColor: UniDeskGlobals.isLight ? UniDeskSettings.mainPanelColorLight : UniDeskSettings.mainPanelColorDark
                    radius: width / 2
                    onClicked:{
                        component_manager.parentOfNewCom=object.contentItem;
                        UniDeskComWindow.pageid=component_manager.currentPid;
                        UniDeskComWindow.showActivate();
                    }
                }
            }
            Behavior on width{
                NumberAnimation{
                    duration: base.isHorizontal() ? 500 : 0
                }
            }
            Behavior on height{
                NumberAnimation{
                    duration: base.isVertical() ? 500 : 0
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
                    id: mi_previous_page
                    text: qsTr("上一页")
                    iconSource: "qrc:/media/img/arrow-up-line.svg"
                    disabled: component_manager.is_first_page()
                    onClicked: {
                        component_manager.previous_page();
                    }
                }
                UniDeskMenuItem{
                    id: mi_next_page
                    text: qsTr("下一页")
                    iconSource: "qrc:/media/img/arrow-down-line.svg"
                    disabled: component_manager.is_last_page()
                    onClicked: {
                        component_manager.next_page();
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
            UniDeskCursorManager.restoreSystem();
            wallpaperMediaPlayer.stop();
            wallpaperMediaPlayer.source = "";
            object.closeAllWindows();
            UniDeskExpr.stopTimer();
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
            custom_wallpaper.updateWallpaper();
            custom_wallpaper.fetchCustomApiWallpaper();
            custom_wallpaper.nextImage();
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
            //强制改变一次qsTr得到的内容   确保ComboBox的currentIndex正确
            UniDeskGlobals.translate(object, "en_US")
            // 加载保存的语言设置
            UniDeskGlobals.translate(object, UniDeskSettings.language)
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
        property int currentImageIndex: 0
        property list<string> imageUrls: []
        // 壁纸图片
        UniDeskImage{
            id: wallpaperImage
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: {
                if(custom_wallpaper.wallpaperMode === 0){
                    return "";
                }
                else if (custom_wallpaper.wallpaperMode === 1){
                    return custom_wallpaper.temporaryImageUrl;
                }
                else{
                    return custom_wallpaper.wallpaperImageUrl;
                }
            }
            visible: 
            custom_wallpaper.wallpaperMode === 1 || custom_wallpaper.wallpaperMode === 2
        }
        
        // 壁纸视频
        MediaPlayer {
            id: wallpaperMediaPlayer
            source: custom_wallpaper.wallpaperMode === 3 ? custom_wallpaper.wallpaperVideoUrl : ""
            autoPlay: true
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
            if (wallpaperMode === 1) {
                custom_wallpaper.fetchCustomApiWallpaper();
            }
            if (wallpaperMode === 2) {
                custom_wallpaper.nextImage();
            }
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
            else{
                wallpaperMediaPlayer.stop();
            }
        }
        
        // 监听wallpaperVolume变化
        onWallpaperVolumeChanged: {
            wallpaperAudioOutput.volume = wallpaperVolume / 100.0;
        }
        
        // 壁纸刷新定时器
        Timer {
            id: wallpaperRefreshTimer
            interval: 1000 * custom_wallpaper.refreshInterval
            running: (custom_wallpaper.wallpaperMode === 1 || custom_wallpaper.wallpaperMode === 2) && custom_wallpaper.refreshInterval > 0
            repeat: true
            onTriggered: {
                if (custom_wallpaper.wallpaperMode === 1) {
                    custom_wallpaper.fetchCustomApiWallpaper();
                } else if (custom_wallpaper.wallpaperMode === 2) {
                    custom_wallpaper.nextImage();
                }
            }
        }
        
        // 获取自定义API壁纸
        function fetchCustomApiWallpaper() {
            var apiUrl = custom_wallpaper.wallpaperApiUrl;
            var expression = custom_wallpaper.wallpaperApiExpression;
            
            if (!apiUrl || !expression) {
                console.error("Custom API URL or expression is empty");
                return;
            }
            
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200) {
                        try {
                                // 使用UniDeskExpr.evalResponse解析响应并执行表达式
                                // 表达式示例: response.data[0].urls.original
                                var url = UniDeskExpr.evalResponse(xhr.responseText, expression).toString();

                                if (url && !url.startsWith("Error:")) {
                                    custom_wallpaper.temporaryImageUrl = url;
                                } else if (url.startsWith("Error:")) {
                                    console.error("Failed to evaluate expression:", url);
                                }
                        } catch (e) {
                            console.error("Failed to parse API response:", e);
                        }
                    } else {
                        console.error("HTTP request failed with status:", xhr.status);
                    }
                }
            }
            xhr.open("GET", apiUrl);
            xhr.setRequestHeader("Accept", "application/json");
            xhr.send();
        }
        
        // 切换到下一张图片（多图片模式）
        function nextImage() {
            var urls = custom_wallpaper.imageUrls;
            if (urls.length === 0) {
                return;
            }
            custom_wallpaper.currentImageIndex = (custom_wallpaper.currentImageIndex + 1) % urls.length;
            custom_wallpaper.wallpaperImageUrl = urls[custom_wallpaper.currentImageIndex];
        }
        
        // 更新壁纸
        function updateWallpaper() {
            custom_wallpaper.refreshInterval = UniDeskSettings.get("wallpaperRefreshInterval");
            custom_wallpaper.wallpaperMode = UniDeskSettings.get("wallpaperMode");
            custom_wallpaper.imageUrls = UniDeskSettings.get("wallpaperImageUrls") || [];
            custom_wallpaper.wallpaperVideoUrl = UniDeskSettings.get("wallpaperVideoUrl");
            custom_wallpaper.wallpaperVolume = UniDeskSettings.get("wallpaperVolume");
            custom_wallpaper.wallpaperApiUrl = UniDeskSettings.get("wallpaperApiUrl");
            custom_wallpaper.wallpaperApiExpression = UniDeskSettings.get("wallpaperApiExpression");
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
    UniDeskHotkey {
        id: hotkeyOpenSettings
        sequence: UniDeskSettings.hotkey_open_settings
        onActivated: {
            UniDeskSettingsWindow.showActivate();
        }
    }
    UniDeskHotkey {
        id: hotkeyOpenPageManager
        sequence: UniDeskSettings.hotkey_open_page_manager
        onActivated: {
            UniDeskPageWindow.showActivate();
        }
    }
    Component.onCompleted: {
        UniDeskSystemTray.setIcon(":/media/logo/uq-l-bg.png")
        UniDeskSystemTray.setTooltip(qsTr("UniDesk"))
        UniDeskSystemTray.setVisible(true)
        UniDeskSystemTray.setWindowVisible(appVisible)
    }
}
