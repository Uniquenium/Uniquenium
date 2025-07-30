pragma ComponentBehavior: Bound
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk
import org.uniquenium.unidesk

UniDeskComboBox{
    id: control
    model: fontList
    property list<string> fontList: UniDeskTools.systemFontFamilies()
    enableFontDelegate: true
    editable: true
    width: 300
}