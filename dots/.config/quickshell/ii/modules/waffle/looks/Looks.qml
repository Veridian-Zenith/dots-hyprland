pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: root

    readonly property QtObject colors: QtObject {
        // Base backgrounds
        property color bg0Base: Appearance.m3colors.m3background
        property color bg0Border: ColorUtils.transparentize(Appearance.m3colors.m3primary, 0.85)
        property color bg1: Appearance.colors.colLayer1
        property color bg1Base: Appearance.colors.colLayer1Base
        property color bg1Hover: Appearance.colors.colLayer1Hover
        property color bg1Active: Appearance.colors.colLayer1Active
        property color bg1Border: ColorUtils.transparentize(Appearance.m3colors.m3primary, 0.8)
        property color bg2: Appearance.colors.colLayer2
        property color bg2Base: Appearance.colors.colLayer2Base
        property color bg2Hover: Appearance.colors.colLayer2Hover
        property color bg2Active: Appearance.colors.colLayer2Active
        property color bg2Border: ColorUtils.transparentize(Appearance.m3colors.m3primary, 0.75)
        // Panel
        property color bgPanelBody: Appearance.colors.colBackgroundSurfaceContainer
        property color bgPanelFooter: Appearance.colors.colLayer1
        property color bgPanelFooterBackground: Appearance.colors.colLayer1Base
        property color bgPanelSeparator: ColorUtils.transparentize(Appearance.m3colors.m3primary, 0.7)
        // Controls
        property color controlBg: Appearance.colors.colLayer2
        property color controlBgInactive: Appearance.colors.colLayer1
        property color controlFg: Appearance.colors.colOnSurface
        // Accent
        property color accent: Appearance.m3colors.m3primary
        property color accentHover: Appearance.colors.colPrimaryHover
        property color accentActive: Appearance.colors.colPrimaryActive
        property color accentFg: Appearance.m3colors.m3onPrimary
        // Text
        property color fg: Appearance.m3colors.m3onSurface
        property color fg1: Appearance.m3colors.m3onSurfaceVariant
        property color subfg: Appearance.m3colors.m3outline
        // Special
        property color danger: Appearance.m3colors.m3error
        property color link: Appearance.m3colors.m3primary
        property color selection: ColorUtils.transparentize(Appearance.m3colors.m3primary, 0.7)
        property color selectionFg: Appearance.m3colors.m3onPrimary
        // Shadows
        property color shadow: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.8)
        property color ambientShadow: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.88)
    }

    readonly property QtObject font: QtObject {
        readonly property QtObject family: QtObject {
            readonly property string ui: Appearance.font.family.main
            readonly property string monospace: Appearance.font.family.monospace
        }
        readonly property QtObject pixelSize: QtObject {
            readonly property int normal: Appearance.font.pixelSize.normal
            readonly property int large: Appearance.font.pixelSize.large
            readonly property int larger: Appearance.font.pixelSize.larger
            readonly property int huge: Appearance.font.pixelSize.huge
        }
        readonly property QtObject weight: QtObject {
            readonly property int regular: Font.Normal
            readonly property int medium: Font.DemiBold
            readonly property int bold: Font.Bold
        }
        readonly property QtObject variableAxes: QtObject {
            readonly property var ui: Appearance.font.variableAxes.main
        }
    }

    readonly property QtObject radius: QtObject {
        readonly property int small: Appearance.rounding.small
        readonly property int medium: Appearance.rounding.normal
        readonly property int large: Appearance.rounding.large
        readonly property int full: Appearance.rounding.full
    }

    readonly property bool dark: Appearance.m3colors.darkmode
    readonly property real backgroundTransparency: Appearance.backgroundTransparency
    readonly property string iconsPath: Directories.assetsPath + "/icons/fluent"

    readonly property QtObject transition: QtObject {
        function createObject(parent) {
            return Appearance.animation.elementMoveFast.numberAnimation.createObject(parent)
        }
        readonly property QtObject enter: QtObject {
            function createObject(parent) {
                return Appearance.animation.elementMoveEnter.numberAnimation.createObject(parent)
            }
        }
        readonly property QtObject resize: QtObject {
            function createObject(parent) {
                return Appearance.animation.elementResize.numberAnimation.createObject(parent)
            }
        }
        readonly property QtObject opacity: QtObject {
            function createObject(parent) {
                return Appearance.animation.elementMoveFast.numberAnimation.createObject(parent)
            }
        }
        readonly property QtObject move: QtObject {
            function createObject(parent) {
                return Appearance.animation.elementMove.numberAnimation.createObject(parent)
            }
        }
        readonly property QtObject longMovement: QtObject {
            function createObject(parent) {
                return Appearance.animation.elementMove.numberAnimation.createObject(parent)
            }
        }
        readonly property QtObject scroll: QtObject {
            function createObject(parent) {
                return Appearance.animation.scroll.numberAnimation.createObject(parent)
            }
        }
        readonly property QtObject rotate: QtObject {
            function createObject(parent) {
                return Appearance.animation.elementMoveFast.numberAnimation.createObject(parent)
            }
        }
        readonly property QtObject anchor: QtObject {
            function createObject(parent) {
                return Appearance.animation.elementResize.numberAnimation.createObject(parent)
            }
        }
        readonly property QtObject easing: QtObject {
            readonly property QtObject bezierCurve: QtObject {
                readonly property list<real> easeIn: Appearance.animationCurves.emphasizedAccel
                readonly property list<real> easeOut: Appearance.animationCurves.emphasizedDecel
                readonly property list<real> easeInOut: Appearance.animationCurves.emphasized
            }
        }
    }
}
