import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick

GroupButton {
    id: button
    property string buttonIcon
    baseWidth: 40
    baseHeight: 40
    clickedWidth: baseWidth + 20
    toggled: false
    buttonRadius: (altAction && toggled) ? Appearance?.rounding.normal : Math.min(baseHeight, baseWidth) / 2
    buttonRadiusPressed: Appearance?.rounding?.small
    colBackground: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 1)
    colBackgroundHover: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.88)
    colBackgroundToggled: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.78)
    colBackgroundToggledHover: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.65)

    contentItem: MaterialSymbol {
        anchors.centerIn: parent
        iconSize: 22
        fill: toggled ? 1 : 0
        color: toggled ? Appearance.vzcolors.accentVibrant : Appearance.m3colors.m3onBackground
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: buttonIcon

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
    }

}
