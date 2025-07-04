import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs 
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import org.itcdt.unidesk

Text {
    property color textColor: UniDeskSettings.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    id:text
    color: enabled ? textColor : (UniDeskSettings.isLight ? Qt.rgba(131/255,131/255,131/255,1) : Qt.rgba(160/255,160/255,160/255,1))
    font: UniDeskUnits.little
}