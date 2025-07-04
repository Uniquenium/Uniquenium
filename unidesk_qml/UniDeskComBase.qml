import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import unidesk_qml
import org.itcdt.unidesk
import org.itcdt.unidesk

UniDeskBase{
    id: base
    property alias bg: rect_bg
    color: "transparent"
    Rectangle{
        id: rect_bg
        anchors.fill: parent
        color: "transparent"
    }
    function baseClose(){
        base.close()
    }
}