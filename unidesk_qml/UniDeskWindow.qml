import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import unidesk_qml
import org.itcdt.unidesk

UniDeskWindowBase{
    id: window
    color: "transparent"
    property string minimizeText: qsTr("最小化")
    property string restoreText: qsTr("还原")
    property string maximizeText: qsTr("最大化")
    property string closeText: qsTr("关闭")
    default property alias contentData: layout_content.data
    property url windowIcon
    property bool fixSize: false
    property bool isRestore: window && (Window.Maximized === window.visibility || Window.FullScreen === window.visibility)
    property var windowVisibility: window.visibility
    property double appBarHeight: appBar.height
    property double appBarRightBorder: appBar.width-layout_btns.width
    property bool isPrevMaximized
    property double prevX
    property double prevY
    property double prevWidth
    property double prevHeight
    property Item appBar: Rectangle{
        height: layout_btns.height+10
        radius: 3
        color: UniDeskSettings.primaryColor
        UniDeskText{
            id: appBar_text
            text: window.title
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: (parent.height-height)/2
            font.pixelSize: 20
        }
        RowLayout{
            id: layout_btns
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.top: parent.top
            anchors.topMargin: (parent.height-height)/2
            UniDeskButton{
                id: minimize_button
                Layout.alignment: Qt.AlignVCenter
                padding: 0
                verticalPadding: 0
                horizontalPadding: 0
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                iconSize: 15
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                iconSource: "qrc:/media/img/subtract.svg"
                text: window.minimizeText
                radius: height/2
                visible: window.showMinimize
                onClicked: {
                    window.showMinimized();
                }
            }
            UniDeskButton{
                id: maximize_button
                Layout.alignment: Qt.AlignVCenter
                padding: 0
                verticalPadding: 0
                horizontalPadding: 0
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                iconSize: 13
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                iconSource: window.isRestore ? "qrc:/media/img/checkbox-multi.svg" : "qrc:/media/img/checkbox.svg"
                text: window.isRestore ? window.restoreText : window.maximizeText
                radius: height/2
                visible: window.showMaximize
                onClicked: {
                    if(window.isRestore){
                        window.isPrevMaximized=false;
                        window.showNormal();
                    }
                    else{
                        window.isPrevMaximized=true;
                        window.showMaximized();
                    }
                }
            }
            UniDeskButton{
                id: close_button
                Layout.alignment: Qt.AlignVCenter
                padding: 0
                verticalPadding: 0
                horizontalPadding: 0
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                iconSize: 15
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                iconSource: "qrc:/media/img/close.svg"
                text: window.closeText
                radius: height/2
                visible: window.showClose
                onClicked: {
                    window.close()
                }
            }
        }
    }
    property bool showClose: true
    property bool showMinimize: true
    property bool showMaximize: true
    property bool autoMaximize: false
    property bool autoCenter: true
    property int __margins: 0
    minimumWidth: 200
    minimumHeight: 200
    Component.onCompleted: {
        if (autoCenter) {
            moveWindowToDesktopCenter();
        }
        if (window.autoVisible) {
            if (window.autoMaximize) {
                isPrevMaximized = true;
                window.visibility = Window.Maximized;
            } else {
                window.show();
            }
        }
        window.prevX=x;
        window.prevY=y;
        window.prevWidth=width;
        window.prevHeight=height;
    }
    Component {
        id: com_border
        Rectangle {
            color: UniDeskGlobals.isLight ? Qt.rgba(1, 1, 1 , 0.7) : Qt.rgba(0,0,0, 0.7)
            radius: Window.window && Window.window.visibility === Window.Maximized ? 0 : 3
            border.width: Window.window && Window.window.visibility === Window.Maximized ? 0 : 1
            border.color: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
            z: 999
        }
    }
    Component {
        id: com_app_bar
        Item {
            data: window.appBar
            Component.onCompleted: {
                window.appBar.width = Qt.binding(function () {
                    return this.parent.width;
                });
            }
        }
    }
    Item {
        id: layout_container
        anchors.fill: parent
        anchors.margins: window.__margins
        Loader {
            id: loader_border
            anchors.fill: parent
            sourceComponent: com_border
        }
        Loader {
            id: loader_app_bar
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
                margins: 1
            }
            height: {
                return window.appBar.height;
            }
            sourceComponent: com_app_bar
        }
        Item {
            id: layout_content
            anchors {
                top: loader_app_bar.bottom
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                margins: 2
            }
            clip: true
        }
    }
    function moveWindowToDesktopCenter() {
        window.setGeometry((Screen.desktopAvailableWidth - window.width) / 2 , (Screen.desktopAvailableHeight - window.height) / 2 , window.width, window.height);
    }
    function containerItem() {
        return layout_container;
    }
    onWindowVisibilityChanged:{
        if(window.visibility===Window.Windowed&&isPrevMaximized){
            showMaximized();
        }
        else if(window.visibility===Window.Windowed){
            window.setGeometry(prevX,prevY,prevWidth,prevHeight);
        }
    }
    onXChanged: {
        if(window.visibility===Window.Windowed){
            prevX=x;
        }
    }
    onYChanged: {
        if(window.visibility===Window.Windowed){
            prevY=y;
        }
    }
    onWidthChanged: {
        if(window.visibility===Window.Windowed){
            prevWidth=width;
        }
    }
    onHeightChanged: {
        if(window.visibility===Window.Windowed){
            prevHeight=height;
        }
    }
}