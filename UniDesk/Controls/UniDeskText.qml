import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs 
import QtQml
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk

Text {
    property color textColor: UniDeskGlobals.isLight ? Qt.rgba(0,0,0,1) : Qt.rgba(1,1,1,1)
    property string fontFamily
    property double fontSize: UniDeskTextStyle.little.pixelSize
    id: control
    color: enabled ? textColor : (UniDeskGlobals.isLight ? Qt.rgba(131/255,131/255,131/255,1) : Qt.rgba(160/255,160/255,160/255,1))
    font: fontFamily ? UniDeskTools.font(fontFamily,fontSize) : UniDeskTextStyle.little
    verticalAlignment: Qt.AlignVCenter
}