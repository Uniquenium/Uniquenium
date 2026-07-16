import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQml
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk.Controls
import UniDesk.Singletons
import UniDesk

ScrollView{
    property var comManager
    property var customWallpaper
    Image{
        id: unideskLogo
        source: UniDeskGlobals.isLight ? "qrc:/media/logo/uniquenium-l.png":"qrc:/media/logo/uniquenium-d.png"
        sourceSize: Qt.size(width,height)
        width: parent.width-100
        height: width/(1750/338)
        x: (parent.width-width)/2
        y: 10
    }
    UniDeskText{
        id: versionText
        text: "V"+UniDeskTools.getModuleVersionMajor()+"."+UniDeskTools.getModuleVersionMinor()+"."+UniDeskTools.getModuleVersionPatch()
        font: UniDeskTextStyle.large
        x: (parent.width-width)/2
        y: unideskLogo.y+unideskLogo.height+10
    }
    ColumnLayout{
        anchors.top: versionText.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10
        spacing: 10
        UniDeskText{
            id: contributorsTitle
            text: qsTr("贡献者")
            font: UniDeskTextStyle.medium
        }
        RowLayout{
            spacing: 10
            UniDeskTextButton{
                text: "Admibrill"
                webLink: "https://github.com/admibrill"
                font: UniDeskTextStyle.little
            }
        }
        UniDeskText{
            id: relatedLinksTitle
            text: qsTr("相关链接")
            font: UniDeskTextStyle.medium
        }
        RowLayout{
            spacing: 10
            UniDeskTextButton{
                text: qsTr("仓库地址")
                webLink: "https://github.com/Uniquenium/Uniquenium"
                font: UniDeskTextStyle.little
            }
            UniDeskTextButton{
                text: qsTr("官网")
                font: UniDeskTextStyle.little
            }
        }
    }
}