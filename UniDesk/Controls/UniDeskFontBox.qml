pragma ComponentBehavior: Bound
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.PyPlugin

UniDeskComboBox{
    id: control
    model: fontList
    property list<string> fontList: UniDeskTools.applicationFontFamilies()
    enableFontDelegate: true
    editable: true
    width: 300
    Connections{
        target: UniDeskTools
        function onCustomFontsChanged() {
            var family=control.currentText
            control.fontList = UniDeskTools.applicationFontFamilies();
            if (control.fontList.indexOf(family) === -1) {
                control.currentIndex = control.fontList.indexOf("微软雅黑");
            } else {
                control.currentIndex = control.fontList.indexOf(family);
            }
        }
    }
}