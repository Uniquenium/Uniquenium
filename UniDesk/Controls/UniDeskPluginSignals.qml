import QtQuick
import QtQuick.Controls
import UniDesk
import UniDesk.Controls

UniDeskObject{
    id: root

    property string pluginId: ""

    signal languageChanged

    

    

    Connections{
        target: UniDeskSettings
        function onLanguageChanged() {
            root.languageChanged()
        }
    }
}