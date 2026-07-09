pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: root
    property string filePath: Directories.pywalThemePath

    function reapplyTheme() {
        themeFileView.reload()
    }

    function applyColors(fileContent) {
        try {
            const json = JSON.parse(fileContent)
            const colors = json.colors
            const special = json.special

            // Only use pywal colors — no hardcoded palette
            const walBg = colors.color0
            const walFg = colors.color7
            const walAccent = colors.color2

            // Update M3 background/surface colors from pywal
            Appearance.m3colors.m3background = walBg
            Appearance.m3colors.m3onBackground = walFg
            Appearance.m3colors.m3surface = ColorUtils.mix(walBg, walFg, 0.98)
            Appearance.m3colors.m3surfaceDim = walBg
            Appearance.m3colors.m3surfaceBright = ColorUtils.mix(walBg, walFg, 0.90)
            Appearance.m3colors.m3surfaceContainerLowest = ColorUtils.mix(walBg, walFg, 0.95)
            Appearance.m3colors.m3surfaceContainerLow = ColorUtils.mix(walBg, walFg, 0.92)
            Appearance.m3colors.m3surfaceContainer = ColorUtils.mix(walBg, walFg, 0.88)
            Appearance.m3colors.m3surfaceContainerHigh = ColorUtils.mix(walBg, walFg, 0.82)
            Appearance.m3colors.m3surfaceContainerHighest = ColorUtils.mix(walBg, walFg, 0.75)
            Appearance.m3colors.m3onSurface = walFg
            Appearance.m3colors.m3surfaceVariant = ColorUtils.mix(walBg, walFg, 0.70)
            Appearance.m3colors.m3onSurfaceVariant = ColorUtils.mix(walFg, walBg, 0.60)
            Appearance.m3colors.m3inverseSurface = walFg
            Appearance.m3colors.m3inverseOnSurface = walBg
            Appearance.m3colors.m3outline = ColorUtils.mix(walBg, walFg, 0.50)
            Appearance.m3colors.m3outlineVariant = ColorUtils.mix(walBg, walFg, 0.40)
            Appearance.m3colors.m3shadow = "#000000"
            Appearance.m3colors.m3scrim = "#000000"

            // M3 accent colors — pywal-driven but subtle
            Appearance.m3colors.m3surfaceTint = walAccent
            Appearance.m3colors.m3primary = walAccent
            Appearance.m3colors.m3onPrimary = "#000000"
            Appearance.m3colors.m3primaryContainer = ColorUtils.mix(walAccent, walBg, 0.15)
            Appearance.m3colors.m3onPrimaryContainer = walFg
            Appearance.m3colors.m3inversePrimary = ColorUtils.mix(walAccent, walFg, 0.50)
            Appearance.m3colors.m3secondary = ColorUtils.mix(walAccent, walFg, 0.70)
            Appearance.m3colors.m3onSecondary = "#000000"
            Appearance.m3colors.m3secondaryContainer = ColorUtils.mix(walAccent, walBg, 0.12)
            Appearance.m3colors.m3onSecondaryContainer = walFg
            Appearance.m3colors.m3tertiary = colors.color3
            Appearance.m3colors.m3onTertiary = "#000000"
            Appearance.m3colors.m3tertiaryContainer = ColorUtils.mix(colors.color3, walBg, 0.15)
            Appearance.m3colors.m3onTertiaryContainer = walFg
            Appearance.m3colors.m3error = colors.color1
            Appearance.m3colors.m3onError = walFg
            Appearance.m3colors.m3errorContainer = ColorUtils.mix(colors.color1, walBg, 0.20)
            Appearance.m3colors.m3onErrorContainer = walFg
            Appearance.m3colors.m3primaryFixed = walAccent
            Appearance.m3colors.m3primaryFixedDim = ColorUtils.mix(walAccent, walBg, 0.25)
            Appearance.m3colors.m3onPrimaryFixed = "#000000"
            Appearance.m3colors.m3onPrimaryFixedVariant = walFg
            Appearance.m3colors.m3secondaryFixed = ColorUtils.mix(walAccent, walFg, 0.80)
            Appearance.m3colors.m3secondaryFixedDim = ColorUtils.mix(walAccent, walBg, 0.35)
            Appearance.m3colors.m3onSecondaryFixed = "#000000"
            Appearance.m3colors.m3onSecondaryFixedVariant = walFg
            Appearance.m3colors.m3tertiaryFixed = colors.color3
            Appearance.m3colors.m3tertiaryFixedDim = ColorUtils.mix(colors.color3, walBg, 0.35)
            Appearance.m3colors.m3onTertiaryFixed = "#000000"
            Appearance.m3colors.m3onTertiaryFixedVariant = walFg

            // Terminal colors
            Appearance.m3colors.term0 = colors.color0
            Appearance.m3colors.term1 = colors.color1
            Appearance.m3colors.term2 = colors.color2
            Appearance.m3colors.term3 = colors.color3
            Appearance.m3colors.term4 = colors.color4
            Appearance.m3colors.term5 = colors.color5
            Appearance.m3colors.term6 = colors.color6
            Appearance.m3colors.term7 = colors.color7
            Appearance.m3colors.term8 = colors.color8
            Appearance.m3colors.term9 = colors.color9
            Appearance.m3colors.term10 = colors.color10
            Appearance.m3colors.term11 = colors.color11
            Appearance.m3colors.term12 = colors.color12
            Appearance.m3colors.term13 = colors.color13
            Appearance.m3colors.term14 = colors.color14
            Appearance.m3colors.term15 = colors.color15

            // Website semantic colors — entirely pywal-driven, matching website opacity levels
            Appearance.vzcolors.bgPrimary = walBg
            Appearance.vzcolors.bgSecondary = ColorUtils.mix(walBg, walFg, 0.88)
            Appearance.vzcolors.accentVibrant = walAccent
            Appearance.vzcolors.accentMuted = ColorUtils.transparentize(walAccent, 0.40)   // 60% opaque — website rgba(accent,0.6)
            Appearance.vzcolors.glowColor = ColorUtils.mix(walAccent, walFg, 0.35)         // Bright visible glow (lightened accent)
            Appearance.vzcolors.gradient1 = walAccent
            Appearance.vzcolors.gradient2 = colors.color1
            Appearance.vzcolors.gradient3 = walAccent
            Appearance.vzcolors.borderColor = ColorUtils.transparentize(walAccent, 0.80)   // 20% opaque — website rgba(accent,0.2)
            Appearance.vzcolors.textColorSecondary = ColorUtils.mix(walFg, walBg, 0.65)    // ~#d1d5db equivalent
            
            // Update Hyprland shell overrides after color application
            root.updateHyprlandConfig()

        } catch (e) {
            console.error("Failed to apply Pywal colors: " + e)
        }
    }

    function colorToHypr(c, opacity) {
        const r = Math.round(c.r * 255).toString(16).padStart(2, '0')
        const g = Math.round(c.g * 255).toString(16).padStart(2, '0')
        const b = Math.round(c.b * 255).toString(16).padStart(2, '0')
        const a = opacity !== undefined ? Math.round(opacity * 255).toString(16).padStart(2, '0') : 'FF'
        return `rgba(${r}${g}${b}${a})`
    }

    function updateHyprlandConfig() {
        const accent = Appearance.vzcolors.accentVibrant
        const bg = Appearance.vzcolors.bgPrimary
        const activeBorder = root.colorToHypr(accent, 0.35)
        const inactiveBorder = root.colorToHypr(accent, 0.08)
        const bgColor = root.colorToHypr(bg, 1.0)
        const fp = FileUtils.trimFileProtocol(Directories.home) + "/.config/hypr/hyprland/shellOverrides/main.lua"

        writeOverrideProc.command = ["bash", "-c",
            `echo '-- Auto-generated by shell -- DO NOT EDIT' > ${fp} && ` +
            `echo 'hl.config({' >> ${fp} && ` +
            `echo '    general = {' >> ${fp} && ` +
            `echo '        col = {' >> ${fp} && ` +
            `echo "            active_border   = \\"${activeBorder}\\"," >> ${fp} && ` +
            `echo "            inactive_border = \\"${inactiveBorder}\\"," >> ${fp} && ` +
            `echo '        },' >> ${fp} && ` +
            `echo '    },' >> ${fp} && ` +
            `echo '    misc = {' >> ${fp} && ` +
            `echo "        background_color = \\"${bgColor}\\"," >> ${fp} && ` +
            `echo '    },' >> ${fp} && ` +
            `echo '})' >> ${fp}`
        ]
        writeOverrideProc.running = true
    }

    property string overrideFile: FileUtils.trimFileProtocol(Directories.home) + "/.config/hypr/hyprland/shellOverrides/main.lua"

    Process {
        id: writeOverrideProc
        onExited: {
            hyprctlReloadProc.running = true
        }
    }

    Process {
        id: hyprctlReloadProc
        command: ["hyprctl", "reload"]
    }

    Timer {
        id: delayedFileRead
        interval: 100
        repeat: false
        running: false
        onTriggered: {
            root.applyColors(themeFileView.text())
        }
    }

    FileView {
        id: themeFileView
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            this.reload()
            delayedFileRead.start()
        }
        onLoadedChanged: {
            if (themeFileView.loaded) {
                root.applyColors(themeFileView.text())
            }
        }
        onLoadFailed: console.error("Failed to load Pywal theme file at: " + root.filePath)
    }
}
