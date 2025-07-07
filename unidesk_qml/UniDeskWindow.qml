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
        background: "transparent"
    }
    property bool stayTop: false
    property bool showDark: false
    property bool showClose: true
    property bool showMinimize: true
    property bool showMaximize: true
    property bool showStayTop: false
    property bool autoMaximize: false
    property bool autoVisible: true
    property bool autoCenter: true
    property bool autoDestroy: true
    property bool useSystemAppBar
    property int __margins: 0
    property color resizeBorderColor: {
        if (window.active) {
            return LingmoTheme.dark ? Qt.rgba(51 / 255, 51 / 255, 51 / 255, 1) : Qt.rgba(110 / 255, 110 / 255, 110 / 255, 1);
        }
        return LingmoTheme.dark ? Qt.rgba(61 / 255, 61 / 255, 61 / 255, 1) : Qt.rgba(167 / 255, 167 / 255, 167 / 255, 1);
    }
    property int resizeBorderWidth: 1
    Component.onCompleted: {
        if (autoCenter) {
            moveWindowToDesktopCenter();
        }
        initArgument(argument);
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
            color: "transparent"
            radius: Window.window.visibility === Window.Maximized ? 0 : LingmoUnits.windowRadius
            border.width: window.resizeBorderWidth
            border.color: window.resizeBorderColor
            z: 999
        }
    }
    Item {
        id: layout_container
        anchors.fill: parent
        anchors.margins: window.__margins
        LingmoLoader {
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
        LingmoLoader {
            id: loader_border
            anchors.fill: parent
            sourceComponent: {
                if (window.useSystemAppBar || LingmoTools.isWin() || window.visibility === Window.Maximized || window.visibility === Window.FullScreen) {
                    return undefined;
                }
                return com_border;
            }
        }
    }
    function moveWindowToDesktopCenter() {
        window.setGeometry((Screen.desktopAvailableWidth - window.width) / 2 + Screen.virtualX, (Screen.desktopAvailableHeight - window.height) / 2 + Screen.virtualY, window.width, window.height);
    }
    function containerItem() {
        return layout_container;
    }
}