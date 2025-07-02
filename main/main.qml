import QtQuick 2.0
import QtQuick.Window 2.0
import unidesk_qml
import org.itcdt.unidesk

UniDeskBase {
    visible: true
    width: 640
    height: 480
    color: "transparent"
    Text{
        text: "PPP"
        font: UniDeskUnits.huge
        color: Qt.rgba(0/255,255/255,0/255,1)
        verticalAlignment: Qt.AlignVCenter
        anchors.fill: parent
    }
}