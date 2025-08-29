import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Layouts
import UniDesk.Controls
import UniDesk

Rectangle {
    property string title: ""
    property string minimizeText: qsTr("最小化")
    property string restoreText: qsTr("还原")
    property string maximizeText: qsTr("最大化")
    property string closeText: qsTr("关闭")

    property bool showDark: false
    property bool showClose: true
    property bool showMinimize: true
    property bool showMaximize: true
    property bool showStayTop: true
    property bool titleVisible: true
    property url icon
    property int iconSize: 20
    property bool isMac: UniDeskUtils.isMacos(
                             ) // May be used in future for multi-platform
    property alias buttonMinimize: minimize_button
    property alias buttonMaximize: maximize_button
    property alias buttonClose: close_button
    property alias layoutStandardbuttons: layout_standard_buttons

    // Some helpers
    property var maxClickListener: function () {
        if (UniDeskUtils.isMacos()) {
            if (d.win.visibility === Window.FullScreen
                    || d.win.visibility === Window.Maximized)
                d.win.showNormal()
            else
                d.win.showFullScreen()
        } else {
            if (d.win.visibility === Window.Maximized
                    || d.win.visibility === Window.FullScreen)
                d.win.showNormal()
            else
                d.win.showMaximized()
            d.hoverMaxBtn = false
        }
    }
    property var minClickListener: function () {
        if (d.win.transientParent != null) {
            d.win.transientParent.showMinimized()
        } else {
            d.win.showMinimized()
        }
    }
    property var closeClickListener: function () {
        d.win.close()
    }

    id: control
    color: Qt.rgba(0, 0, 0, 0)
    height: visible ? 30 : 0
    opacity: visible
    z: 65535
    UniDeskText{
        id: appBar_text
        text: control.title
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: (parent.height-height)/2
        font.family: UniDeskTextStyle.little.family
        font.pixelSize: 20
    }
    Item {
        id: d
        property var hitTestList: []
        property bool hoverMaxBtn: false
        property var win: Window.window
        property bool stayTop: {
            if (d.win instanceof UniDeskWindow) {
                return d.win.stayTop
            }
            return false
        }
        property bool isRestore: win
                                 && (Window.Maximized === win.visibility
                                     || Window.FullScreen === win.visibility)
        property bool resizable: win && !(win.height === win.maximumHeight
                                          && win.height === win.minimumHeight
                                          && win.width === win.maximumWidth
                                          && win.width === win.minimumWidth)
        function containsPointToItem(point, item) {
            var pos = item.mapToGlobal(0, 0)
            var rect = Qt.rect(pos.x, pos.y, item.width, item.height)
            if (point.x > rect.x && point.x < (rect.x + rect.width)
                    && point.y > rect.y && point.y < (rect.y + rect.height)) {
                return true
            }
            return false
        }
    }

    // A menubar for macOS
    // Component {
    //     id: com_macos_buttons
    //     RowLayout {
    //         LingmoImageButton {
    //             Layout.preferredHeight: 12
    //             Layout.preferredWidth: 12
    //             normalImage: "../Image/btn_close_normal.png"
    //             hoveredImage: "../Image/btn_close_hovered.png"
    //             pushedImage: "../Image/btn_close_pushed.png"
    //             visible: showClose
    //             onClicked: closeClickListener()
    //         }
    //         LingmoImageButton {
    //             Layout.preferredHeight: 12
    //             Layout.preferredWidth: 12
    //             normalImage: "../Image/btn_min_normal.png"
    //             hoveredImage: "../Image/btn_min_hovered.png"
    //             pushedImage: "../Image/btn_min_pushed.png"
    //             onClicked: minClickListener()
    //             visible: showMinimize
    //         }
    //         LingmoImageButton {
    //             Layout.preferredHeight: 12
    //             Layout.preferredWidth: 12
    //             normalImage: "../Image/btn_max_normal.png"
    //             hoveredImage: "../Image/btn_max_hovered.png"
    //             pushedImage: "../Image/btn_max_pushed.png"
    //             onClicked: maxClickListener()
    //             visible: d.resizable && showMaximize
    //         }
    //     }
    // }

    // ***************
    // * Real Layout *
    // ***************
    RowLayout {
        id: layout_standard_buttons
        height: parent.height
        anchors.right: parent.right
        spacing: 0
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
            text: control.minimizeText
            radius: height/2
            visible: control.showMinimize
            onClicked: {
                control.minClickListener();
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
            iconSource: control.isRestore ? "qrc:/media/img/checkbox-multi.svg" : "qrc:/media/img/checkbox.svg"
            text: control.isRestore ? control.restoreText : control.maximizeText
            radius: height/2
            visible: control.showMaximize
            onClicked: {
                control.maxClickListener();
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
            text: control.closeText
            radius: height/2
            visible: control.showClose
            onClicked: {
                control.closeClickListener();
            }
        }
    }
    
    // Buttons for macOS
    // LingmoLoader {
    //     id: layout_macos_buttons
    //     anchors {
    //         verticalCenter: parent.verticalCenter
    //         left: parent.left
    //         leftMargin: 10
    //     }
    //     sourceComponent: isMac ? com_macos_buttons : undefined
    // }
}
