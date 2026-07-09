import QtQuick
import qs.modules.common
import qs.modules.common.functions

Rectangle {
    id: root

    radius: Appearance.rounding.normal
    color: ColorUtils.transparentize(Appearance.vzcolors.bgPrimary, 0.15)
    border.width: 1
    border.color: Appearance.vzcolors.borderColor

    clip: true
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.03) }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.05) }
        }
    }

    signal openAudioOutputDialog()
    signal openAudioInputDialog()
    signal openBluetoothDialog()
    signal openNightLightDialog()
    signal openWifiDialog()
}
