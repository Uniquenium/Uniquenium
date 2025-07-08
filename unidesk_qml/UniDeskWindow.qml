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
    default property alias contentData: layout_content.data
    property url windowIcon
    property bool fixSize: false
    property var windowVisibility: window.visibility
    property string title
    property Item appBar: Rectangle{
        color: "transparent"
        height: layout_btns.height
        UniDeskText{
            id: appBar_text
            text: window.title
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.top: parent.top
            anchors.topMargin: (parent.height-height)/2
        }
        RowLayout{
            id: layout_btns
            anchors.right: parent.right
            UniDeskButton{
                id: close_button
                Layout.alignment: Qt.AlignVCenter
                iconSize: 15
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                iconColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1).darker(1.5)
                iconSource: "qrc:/media/img/close.svg"
                radius: height/2
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
    Component.onCompleted: {
        if (autoCenter) {
            moveWindowToDesktopCenter();
        }
        if (window.autoVisible) {
            if (window.autoMaximize) {
                window.visibility = Window.Maximized;
            } else {
                window.show();
            }
        }
    }
    Component {
        id: com_border
        Rectangle {
            color: UniDeskGlobals.isLight ? Qt.rgba(1, 1, 1 , 0.7) : Qt.rgba(0,0,0, 0.7)
            radius: Window.window && Window.window.visibility === Window.Maximized ? 0 : 3
            border.width: 1
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
}