import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.GraphicalEffects
import UniDesk

Image{
    id: root
    property string iconSource
    property color iconColor
    property double iconSize: 15
    width: iconSize
    height: iconSize
    source: iconSource
    horizontalAlignment: Qt.AlignHCenter
    verticalAlignment: Qt.AlignVCenter
    ColorOverlay{
        anchors.fill: parent
        source: root
        color: root.iconColor
    }
}