pragma Singleton
import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk
import UniDesk.Components.UDCText

UniDeskObject{
    id: launcher
    function launch(){
        print(1);
        UDCTextTools.startThread();
    }
}