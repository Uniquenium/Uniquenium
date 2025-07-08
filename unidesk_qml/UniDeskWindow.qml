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
    property Item appBar: Rectangle{
        color: "transparent"
        height: 30
    }
    property bool stayHelp: false
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
    Item {
        id: layout_container
        anchors.fill: parent
        anchors.margins: window.__margins
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
        Loader {
            id: loader_border
            anchors.fill: parent
            sourceComponent: com_border
        }
    }
    function moveWindowToDesktopCenter() {
        window.setGeometry((Screen.desktopAvailableWidth - window.width) / 2 , (Screen.desktopAvailableHeight - window.height) / 2 , window.width, window.height);
    }
    function containerItem() {
        return layout_container;
    }
}