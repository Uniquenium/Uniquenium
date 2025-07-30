import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs 
import QtQml
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import org.uniquenium.unidesk

Text {
    property color textColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    property url fontSource: ""
    property string fontFamily: ""
    property double fontSize: UniDeskUnits.little.pixelSize
    id: control
    color: enabled ? textColor : (UniDeskGlobals.isLight ? Qt.rgba(131/255,131/255,131/255,1) : Qt.rgba(160/255,160/255,160/255,1))
    font: fontSource!=="" ?UniDeskTools.font(loadedFont.name,fontSize):UniDeskUnits.little
    FontLoader{
        id: loadedFont
        source: control.fontSource !== "" ? control.fontSource : undefined
    }
    verticalAlignment: Qt.AlignVCenter
}