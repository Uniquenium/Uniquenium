import QtQuick 
import QtQuick.Controls 
import unidesk_qml
import org.itcdt.unidesk

UniDeskBase {
    id: base
    visible: true
    color: "white"
    UniDeskButton{
        id: btn_quit
        bgNormalColor:"green"
        iconSource: "qrc:/media/img/logout-box-line.svg"
        onClicked:{
            base.close()
        }
    }
}