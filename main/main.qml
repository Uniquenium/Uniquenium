import QtQuick 
import QtQuick.Controls 
import unidesk_qml
import org.itcdt.unidesk

UniDeskBase {
    id: base
    visible: true
    color: "transparent"
    x: Screen.width-width-10
    y: 10
    width: btn_quit.width
    UniDeskButton{
        id: btn_quit
        contentText: qsTr("退出")
        iconWidth: 15
        iconHeight: 15
        iconSource: "qrc:/media/img/logout-box-line.svg"
        onClicked:{
            base.close()
        }
    }
}