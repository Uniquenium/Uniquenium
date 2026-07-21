import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk

UniDeskButton {
    id: control
    property var current: ["Ctrl", "Shift", "A"]
    property string title: qsTr("激活快捷键")
    property string message: qsTr("按下快捷键组合以更改快捷键")
    property string positiveText: qsTr("保存")
    property string neutralText: qsTr("取消")
    property string negativeText: qsTr("重置")
    property bool registered: true
    property color errorColor: Qt.rgba(250 / 255, 85 / 255, 85 / 255, 1)
    signal accepted
    padding: 0
    verticalPadding: 0
    horizontalPadding: 0
    text: ""
    property color normalColor: "transparent"
    property color hoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
    property color pressedColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
    property color disableColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.7) : Qt.rgba(0,0,0,0.5).lighter(1.7)
    
    QtObject {
        id: d
        /**
         * Map key_code to corresponding string
         * 
         * @function keyToString
         * @param {number} key_code: See enum Qt::Key
         * @param {boolean} shift: When true, return shifted function of that key
         * @returns {string} String representation of the key
         * @since 3.0.0
         */
        function keyToString(key_code, shift = true) {
            switch (key_code) {
            case Qt.Key_Period:
                return ".";
            case Qt.Key_Greater:
                return shift ? ">" : ".";
            case Qt.Key_Comma:
                return ",";
            case Qt.Key_Less:
                return shift ? "<" : ",";
            case Qt.Key_Slash:
                return "/";
            case Qt.Key_Question:
                return shift ? "?" : "/";
            case Qt.Key_Semicolon:
                return ";";
            case Qt.Key_Colon:
                return shift ? ":" : ";";
            case Qt.Key_Apostrophe:
                return "'";
            case Qt.Key_QuoteDbl:
                return shift ? "'" : "\"";
            case Qt.Key_QuoteLeft:
                return "`";
            case Qt.Key_AsciiTilde:
                return shift ? "~" : "`";
            case Qt.Key_Minus:
                return "-";
            case Qt.Key_Underscore:
                return shift ? "_" : "-";
            case Qt.Key_Equal:
                return "=";
            case Qt.Key_Plus:
                return shift ? "+" : "=";
            case Qt.Key_BracketLeft:
                return "[";
            case Qt.Key_BraceLeft:
                return shift ? "{" : "[";
            case Qt.Key_BracketRight:
                return "]";
            case Qt.Key_BraceRight:
                return shift ? "}" : "]";
            case Qt.Key_Backslash:
                return "\\";
            case Qt.Key_Bar:
                return shift ? "|" : "\\";
            case Qt.Key_Up:
                return "Up";
            case Qt.Key_Down:
                return "Down";
            case Qt.Key_Right:
                return "Right";
            case Qt.Key_Left:
                return "Left";
            case Qt.Key_Space:
                return "Space";
            case Qt.Key_PageDown:
                return "PgDown";
            case Qt.Key_PageUp:
                return "PgUp";
            case Qt.Key_0:
                return "0";
            case Qt.Key_1:
                return "1";
            case Qt.Key_2:
                return "2";
            case Qt.Key_3:
                return "3";
            case Qt.Key_4:
                return "4";
            case Qt.Key_5:
                return "5";
            case Qt.Key_6:
                return "6";
            case Qt.Key_7:
                return "7";
            case Qt.Key_8:
                return "8";
            case Qt.Key_9:
                return "9";
            case Qt.Key_Exclam:
                return shift ? "!" : "1";
            case Qt.Key_At:
                return shift ? "@" : "2";
            case Qt.Key_NumberSign:
                return shift ? "#" : "3";
            case Qt.Key_Dollar:
                return shift ? "$" : "4";
            case Qt.Key_Percent:
                return shift ? "%" : "5";
            case Qt.Key_AsciiCircum:
                return shift ? "^" : "6";
            case Qt.Key_Ampersand:
                return shift ? "&" : "7";
            case Qt.Key_Asterisk:
                return shift ? "*" : "8";
            case Qt.Key_ParenLeft:
                return shift ? "(" : "9";
            case Qt.Key_ParenRight:
                return shift ? ")" : "0";
            case Qt.Key_A:
                return "A";
            case Qt.Key_B:
                return "B";
            case Qt.Key_C:
                return "C";
            case Qt.Key_D:
                return "D";
            case Qt.Key_E:
                return "E";
            case Qt.Key_F:
                return "F";
            case Qt.Key_G:
                return "G";
            case Qt.Key_H:
                return "H";
            case Qt.Key_I:
                return "I";
            case Qt.Key_J:
                return "J";
            case Qt.Key_K:
                return "K";
            case Qt.Key_L:
                return "L";
            case Qt.Key_M:
                return "M";
            case Qt.Key_N:
                return "N";
            case Qt.Key_O:
                return "O";
            case Qt.Key_P:
                return "P";
            case Qt.Key_Q:
                return "Q";
            case Qt.Key_R:
                return "R";
            case Qt.Key_S:
                return "S";
            case Qt.Key_T:
                return "T";
            case Qt.Key_U:
                return "U";
            case Qt.Key_V:
                return "V";
            case Qt.Key_W:
                return "W";
            case Qt.Key_X:
                return "X";
            case Qt.Key_Y:
                return "Y";
            case Qt.Key_Z:
                return "Z";
            case Qt.Key_F1:
                return "F1";
            case Qt.Key_F2:
                return "F2";
            case Qt.Key_F3:
                return "F3";
            case Qt.Key_F4:
                return "F4";
            case Qt.Key_F5:
                return "F5";
            case Qt.Key_F6:
                return "F6";
            case Qt.Key_F7:
                return "F7";
            case Qt.Key_F8:
                return "F8";
            case Qt.Key_F9:
                return "F9";
            case Qt.Key_F10:
                return "F10";
            case Qt.Key_F11:
                return "F11";
            case Qt.Key_F12:
                return "F12";
            case Qt.Key_Home:
                return "Home";
            case Qt.Key_End:
                return "End";
            case Qt.Key_Insert:
                return "Insert";
            case Qt.Key_Delete:
                return "Delete";
            }
            return "";
        }
    }
    background: Item {
        implicitHeight: 42
        implicitWidth: contentItem.childrenRect.width
        Rectangle {
            id: rect_bg
            anchors.fill: parent
            radius: control.radius
            color: "transparent"
        }
    }
    contentItem: Item {
        implicitWidth: childrenRect.width
        implicitHeight: layout_row.height
        UniDeskText {
            id: text_error
            text: qsTr("Conflict")
            color: control.errorColor
            visible: !control.registered
            anchors {
                verticalCenter: layout_rect.verticalCenter
                
            }
        }
        Rectangle {
            id: layout_rect
            border.color: UniDeskGlobals.isLight ? "#000000" : "#FFFFFF"
            border.width: 1
            radius: control.radius
            color: {
                if (!control.enabled) {
                    return control.disableColor;
                }
                if (control.pressed) {
                    return control.pressedColor;
                }
                return control.hovered ? control.hoverColor : control.normalColor;
            }
            height: control.height
            width: layout_row.width
            anchors {
                left: text_error.left
                leftMargin: 4
            }
            Row {
                id: layout_row
                spacing: 5
                anchors.centerIn: parent
                Item {
                    width: 8
                    height: 1
                }
                Repeater {
                    model: control.current
                    delegate: Loader {
                        property var keyText: modelData
                        sourceComponent: com_item_key
                    }
                }
                Item {
                    width: 3
                    height: 1
                }
                UniDeskIcon {
                    iconSource: "qrc:/media/img/edit.svg"
                    iconSize: 13
                    anchors {
                        verticalCenter: parent.verticalCenter
                    }
                }
                Item {
                    width: 8
                    height: 1
                }
            }
        }
        
    }
    Component {
        id: com_item_key
        Rectangle {
            id: item_key_control
            color: UniDeskSettings.primaryColor
            width: Math.max(item_text.implicitWidth + 12, 28)
            height: Math.max(item_text.implicitHeight, 28)
            radius: 4
            UniDeskText {
                id: item_text
                color: UniDeskGlobals.isLight ? Qt.rgba(0, 0, 0, 1) : Qt.rgba(1, 1, 1, 1)
                text: keyText
                anchors.centerIn: parent
            }
        }
    }
    UniDeskDialog {
        id: content_dialog
        property var keysModel: []
        title: control.title
        autoVisible: false
        autoDestroy: false
        width: 400
        height: 200
        onVisibleChanged: {
            if (visible) {
                content_dialog.keysModel = control.current;
            }
        }
        // 消息文本
        UniDeskText {
            id: dialog_message
            text: control.message
            font: UniDeskTextStyle.little
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 30
        }
        // 快捷键显示区域
        Item {
            id: key_area
            anchors.top: dialog_message.bottom
            anchors.bottom: buttons_row.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 20
            anchors.bottomMargin: 20
            Component.onCompleted: {
                forceActiveFocus();
            }
            Keys.enabled: true
            Keys.onPressed: event => {
                var keyNames = [];
                if (event.modifiers & Qt.AltModifier) {
                    keyNames.push("Alt");
                }
                if (event.modifiers & Qt.ControlModifier) {
                    keyNames.push("Ctrl");
                }
                if (event.modifiers & Qt.ShiftModifier) {
                    keyNames.push("Shift");
                }
                var keyName = d.keyToString(event.key, false);
                if (keyName !== "") {
                    keyNames.push(keyName);
                    content_dialog.keysModel = keyNames;
                }
                event.accepted = true;
            }
            Keys.onTabPressed: event => {
                event.accepted = true;
            }
            Row {
                spacing: 5
                anchors.centerIn: parent
                Repeater {
                    model: content_dialog.keysModel
                    delegate: Loader {
                        property var keyText: modelData
                        sourceComponent: com_item_key
                    }
                }
            }
        }
        // 按钮区域
        Row {
            id: buttons_row
            spacing: 10
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottomMargin: 20
            // 取消按钮
            UniDeskButton {
                display: Button.TextOnly
                contentText: control.neutralText
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    content_dialog.close();
                }
            }
            // 重置按钮
            UniDeskButton {
                display: Button.TextOnly
                contentText: control.negativeText
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    content_dialog.keysModel = control.current;
                    key_area.forceActiveFocus();
                }
            }
            // 保存按钮
            UniDeskButton {
                display: Button.TextOnly
                contentText: control.positiveText
                bgHoverColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.2) : Qt.rgba(0,0,0,0.5).lighter(1.2)
                bgPressColor: UniDeskGlobals.isLight ? Qt.rgba(1,1,1,0.5).darker(1.5) : Qt.rgba(0,0,0,0.5).lighter(1.5)
                borderWidth: 1
                radius: 5
                onClicked: {
                    control.current = content_dialog.keysModel;
                    control.accepted();
                    content_dialog.close();
                }
            }
        }
    }
    onClicked: {
        content_dialog.showActivate();
        key_area.forceActiveFocus();
    }
}
