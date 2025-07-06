import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import Qt5Compat.GraphicalEffects
import Qt5Compat.GraphicalEffects

Image{
    id: root
    property string iconSource
    property color iconColor
    property double iconSize: 15
    width: iconSize
    height: iconSize
    source: iconSource
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    ColorOverlay{
        anchors.fill: parent
        source: root
        color: root.iconColor
    }
}