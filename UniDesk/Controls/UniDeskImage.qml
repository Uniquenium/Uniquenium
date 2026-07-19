import QtQuick 
import QtQuick.Controls 
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Templates as T
import QtQuick.Controls.Basic
import Qt5Compat.GraphicalEffects
import UniDesk

AnimatedImage{
    id: control
    
    // 是否启用切换动画
    property bool animationEnabled: true
    playing: status === Image.Ready
    // 动画持续时间（毫秒）
    property int animationDuration: 300
    
    opacity: source.toString() !== "" ? 1 : 0
    // 原图片（切换时显示）
    AnimatedImage{
        id: front_img
        anchors.fill: parent
        visible: false
        opacity: 1
        playing: status === Image.Ready
        fillMode: control.fillMode
        // 淡出动画
        Behavior on opacity {
            NumberAnimation {
                duration: control.animationDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
    
    // 监听source变化，实现切换动画
    onSourceChanged: {
        if (animationEnabled) {
            // 显示front_img（原图片）
            front_img.visible = true
            // 触发淡出动画
            front_img.opacity = 0
            // 动画结束后隐藏front_img
            setTimeout(function() {
                front_img.visible = false
                front_img.opacity = 1
                // 更新front_img为新图片，以便下次切换使用
                front_img.source = control.source
            }, animationDuration)
        }
    }
    
    
    // 初始化时设置front_img
    Component.onCompleted: {
        front_img.source = control.source
    }
    
    // 辅助函数：延迟执行
    function setTimeout(func, delay) {
        var timer = Qt.createQmlObject("import QtQuick; Timer { interval: " + delay + "; repeat: false; running: true }", control, "setTimeoutTimer")
        timer.triggered.connect(function() {
            func()
            timer.destroy()
        })
    }
    // 淡出动画
    Behavior on opacity {
        NumberAnimation {
            duration: control.animationDuration 
            easing.type: Easing.InOutQuad
        }
    }
}