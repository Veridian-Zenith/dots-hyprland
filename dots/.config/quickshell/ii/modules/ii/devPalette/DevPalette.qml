import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: root

    property ListModel flatModel: ListModel {}
    property var currentFilter: ""
    property int selectedIndex: 0
    property bool initialized: false

    function buildModel(): void {
        flatModel.clear()
        const q = currentFilter.toLowerCase().trim()

        // Projects
        var projectItems = []
        for (var i = 0; i < DevProjects.projects.count; i++) {
            var p = DevProjects.projects.get(i)
            if (!q || p.name.toLowerCase().includes(q) || p.path.toLowerCase().includes(q))
                projectItems.push(p)
        }
        if (projectItems.length > 0 || !q) {
            flatModel.append({ type: "section", label: "Projects", icon: "folder_open", path: "", cmd: "", action: "" })
            for (var pi = 0; pi < projectItems.length; pi++) {
                var pp = projectItems[pi]
                flatModel.append({ type: "project", label: pp.name, path: pp.path, icon: "folder", cmd: "", action: "" })
            }
        }

        // Commands
        var cmdItems = [
            { label: "Open Terminal", cmd: "", icon: "terminal", action: "terminal" },
            { label: "Open VS Code", cmd: "code", icon: "code", action: "code" },
            { label: "Open File Manager", cmd: "xdg-open .", icon: "folder_open", action: "cmd" },
            { label: openEditorLabel, cmd: "", icon: "edit_note", action: "editor" },
        ]
        var filteredCmds = cmdItems.filter(c => !q || c.label.toLowerCase().includes(q))
        if (filteredCmds.length > 0) {
            flatModel.append({ type: "section", label: "Commands", icon: "terminal", path: "", cmd: "", action: "" })
            for (var ci = 0; ci < filteredCmds.length; ci++) {
                var cc = filteredCmds[ci]
                flatModel.append({ type: "command", label: cc.label, cmd: cc.cmd, action: cc.action, icon: cc.icon, path: "" })
            }
        }

        // Git Actions
        var gitItems = [
            { label: "git status", cmd: "git status", icon: "info" },
            { label: "git log --oneline --graph", cmd: "git log --oneline --graph -20", icon: "history" },
            { label: "git pull", cmd: "git pull", icon: "download" },
            { label: "git push", cmd: "git push", icon: "upload" },
            { label: "git diff --stat", cmd: "git diff --stat", icon: "difference" },
            { label: "git commit", cmd: "git commit", icon: "commit" },
        ]
        var filteredGit = gitItems.filter(g => !q || g.label.toLowerCase().includes(q))
        if (filteredGit.length > 0) {
            flatModel.append({ type: "section", label: "Git Actions", icon: "call_split", path: "", cmd: "", action: "" })
            for (var gi = 0; gi < filteredGit.length; gi++) {
                var gg = filteredGit[gi]
                flatModel.append({ type: "git", label: gg.label, cmd: gg.cmd, icon: gg.icon, path: "", action: "" })
            }
        }

        // System Actions
        var sysItems = [
            { label: "Reload Hyprland", cmd: "hyprctl reload", icon: "refresh", action: "" },
            { label: "Reload Quickshell", cmd: "", icon: "restart_alt", action: "qsreload" },
            { label: "System Monitor (htop)", cmd: "htop", icon: "monitoring", action: "termcmd" },
            { label: "Screen Lock", cmd: "", icon: "lock", action: "lock" },
            { label: "Session (Logout)", cmd: "", icon: "power_settings_new", action: "session" },
        ]
        var filteredSys = sysItems.filter(s => !q || s.label.toLowerCase().includes(q))
        if (filteredSys.length > 0) {
            flatModel.append({ type: "section", label: "System", icon: "settings", path: "", cmd: "", action: "" })
            for (var si = 0; si < filteredSys.length; si++) {
                var ss = filteredSys[si]
                flatModel.append({ type: "system", label: ss.label, cmd: ss.cmd, action: ss.action, icon: ss.icon, path: "" })
            }
        }

        selectedIndex = 0
        for (var ri = 0; ri < flatModel.count; ri++) {
            if (flatModel.get(ri).type !== "section") {
                selectedIndex = ri
                break
            }
        }
    }

    property string openEditorLabel: DevProjects.activeGitRepoPath.length > 0 ? "Open Editor in Repo" : "Open Editor"

    Connections {
        target: DevProjects
        function onProjectsChanged() { if (root.initialized) root.buildModel() }
        function onActiveGitRepoPathChanged() {
            root.openEditorLabel = DevProjects.activeGitRepoPath.length > 0 ? "Open Editor in Repo" : "Open Editor"
        }
    }

    Loader {
        active: GlobalStates.devPaletteOpen
        sourceComponent: PanelWindow {
            id: paletteWindow
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.namespace: "quickshell:devpalette"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            visible: true
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            Component.onCompleted: {
                focusGrab.active = true
                Qt.callLater(() => { if (searchField) searchField.forceActiveFocus() })
            }

            HyprlandFocusGrab {
                id: focusGrab
                windows: [paletteWindow]
                active: true
                onCleared: {
                    GlobalStates.devPaletteOpen = false
                }
            }

            // Scrim
            Rectangle {
                anchors.fill: parent
                color: Appearance.colors.colScrim
                opacity: 0.7

                MouseArea {
                    anchors.fill: parent
                    onClicked: GlobalStates.devPaletteOpen = false
                }
            }

            // Centered palette
            Item {
                anchors.centerIn: parent
                width: Math.min(parent.width * 0.65, 700)
                height: Math.min(parent.height * 0.7, 600)

                Rectangle {
                    id: paletteBg
                    anchors.fill: parent
                    color: ColorUtils.transparentize(Appearance.vzcolors.bgPrimary, 0.08)
                    radius: Appearance.rounding.large
                    border.width: 1
                    border.color: Appearance.vzcolors.borderColor
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
                            GradientStop { position: 0.5; color: "transparent" }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.08) }
                        }
                    }
                }

                RectangularGlow {
                    anchors.fill: paletteBg
                    anchors.margins: -3
                    glowRadius: 8
                    spread: 0.08
                    color: Appearance.vzcolors.glowColor
                    cornerRadius: paletteBg.radius + 3
                    opacity: 0.15
                }

                StyledRectangularShadow {
                    target: paletteBg
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 0
                    spacing: 0

                    // Search bar
                    Rectangle {
                        id: searchBar
                        Layout.fillWidth: true
                        Layout.preferredHeight: 56
                        color: "transparent"

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 12
                            anchors.bottomMargin: 6
                            color: ColorUtils.transparentize(Appearance.vzcolors.bgSecondary, 0.5)
                            radius: Appearance.rounding.full
                            border.width: 1
                            border.color: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.85)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 16
                                spacing: 12

                                MaterialSymbol {
                                    text: "search"
                                    iconSize: 22
                                    color: Appearance.vzcolors.accentVibrant
                                }

                                TextField {
                                    id: searchField
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: Appearance.m3colors.m3onBackground
                                    font.pixelSize: Appearance.font.pixelSize.large
                                    placeholderText: "Search projects, commands, actions..."
                                    placeholderTextColor: Appearance.m3colors.m3onBackgroundVariant
                                    background: null
                                    verticalAlignment: TextInput.AlignVCenter
                                    focus: true

                                    Keys.onPressed: (event) => {
                                        if (event.key === Qt.Key_Escape) {
                                            GlobalStates.devPaletteOpen = false
                                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                            root.executeSelected()
                                        } else if (event.key === Qt.Key_Up) {
                                            root.navigateUp()
                                        } else if (event.key === Qt.Key_Down) {
                                            root.navigateDown()
                                        } else if (event.key === Qt.Key_Tab) {
                                            root.navigateDown()
                                        }
                                    }

                                    onTextChanged: {
                                        root.currentFilter = text
                                        root.buildModel()
                                    }
                                }
                            }
                        }
                    }

                    // Results list
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "transparent"

                        ListView {
                            id: resultsList
                            anchors.fill: parent
                            anchors.margins: 8
                            anchors.topMargin: 2
                            clip: true
                            model: root.flatModel
                            spacing: 2
                            currentIndex: root.selectedIndex

                            delegate: Item {
                                id: delegateRoot
                                required property int index
                                required property var modelData
                                implicitWidth: resultsList.width
                                implicitHeight: modelData.type === "section" ? 36 : 44

                                property bool isSelectable: modelData.type !== "section"

                                // Section header
                                Rectangle {
                                    visible: modelData.type === "section"
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    color: "transparent"

                                    RowLayout {
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 8

                                        MaterialSymbol {
                                            text: modelData.icon || "label"
                                            iconSize: 16
                                            color: Appearance.vzcolors.accentVibrant
                                            opacity: 0.7
                                        }

                                        StyledText {
                                            text: modelData.label
                                            font.pixelSize: Appearance.font.pixelSize.small
                                            font.bold: true
                                            color: Appearance.vzcolors.accentVibrant
                                            opacity: 0.8
                                        }
                                    }
                                }

                                // Item delegate
                                Rectangle {
                                    visible: modelData.type !== "section"
                                    anchors.fill: parent
                                    anchors.leftMargin: 8
                                    anchors.rightMargin: 8
                                    radius: Appearance.rounding.normal
                                    color: resultsList.currentIndex === delegateRoot.index ?
                                        ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.85) : "transparent"
                                    border.width: resultsList.currentIndex === delegateRoot.index ? 1 : 0
                                    border.color: resultsList.currentIndex === delegateRoot.index ?
                                        ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.7) : "transparent"

                                    Behavior on color {
                                        ColorAnimation { duration: 80 }
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 14
                                        anchors.rightMargin: 14
                                        spacing: 12

                                        MaterialSymbol {
                                            text: modelData.icon || "chevron_right"
                                            iconSize: 18
                                            color: modelData.type === "project" ? Appearance.vzcolors.accentVibrant :
                                                modelData.type === "git" ? "#f0c040" :
                                                modelData.type === "system" ? Appearance.m3colors.m3onBackground :
                                                Appearance.m3colors.m3onBackground
                                        }

                                        StyledText {
                                            Layout.fillWidth: true
                                            text: modelData.label
                                            font.pixelSize: Appearance.font.pixelSize.normal
                                            color: resultsList.currentIndex === delegateRoot.index ?
                                                Appearance.vzcolors.accentVibrant : Appearance.m3colors.m3onBackground
                                            elide: Text.ElideRight
                                        }

                                        // Action hint
                                        StyledText {
                                            visible: modelData.type === "project"
                                            text: "⏎ term • ⌘ code •  files"
                                            font.pixelSize: Appearance.font.pixelSize.small
                                            color: ColorUtils.transparentize(Appearance.m3colors.m3onBackground, 0.4)
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: resultsList.currentIndex = delegateRoot.index
                                        onClicked: {
                                            resultsList.currentIndex = delegateRoot.index
                                            root.executeSelected()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Footer hint
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: "transparent"

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 16

                            StyledText {
                                text: "↑↓ Navigate  •  ⏎ Execute  •  Esc Close"
                                font.pixelSize: Appearance.font.pixelSize.small
                                color: ColorUtils.transparentize(Appearance.m3colors.m3onBackground, 0.5)
                            }
                        }
                    }
                }
            }
        }
    }

    function navigateUp(): void {
        for (var i = selectedIndex - 1; i >= 0; i--) {
            if (flatModel.get(i).type !== "section") {
                selectedIndex = i
                resultsList.currentIndex = i
                return
            }
        }
    }

    function navigateDown(): void {
        for (var i = selectedIndex + 1; i < flatModel.count; i++) {
            if (flatModel.get(i).type !== "section") {
                selectedIndex = i
                resultsList.currentIndex = i
                return
            }
        }
    }

    function executeSelected(): void {
        if (selectedIndex < 0 || selectedIndex >= flatModel.count) return
        var item = flatModel.get(selectedIndex)
        if (!item || item.type === "section") return

        switch (item.type) {
            case "project":
                DevProjects.openProject(item.path)
                break
            case "command":
                if (item.action === "terminal") {
                    DevProjects.openTerminal()
                } else if (item.action === "code") {
                    Quickshell.execDetached(["code"])
                } else if (item.action === "editor") {
                    if (DevProjects.activeGitRepoPath.length > 0)
                        Quickshell.execDetached(["code", DevProjects.activeGitRepoPath])
                    else
                        Quickshell.execDetached(["code", DevProjects.devDir])
                } else if (item.action === "cmd" && item.cmd.length > 0) {
                    Quickshell.execDetached(["fish", "-c", item.cmd])
                }
                break
            case "git":
                if (DevProjects.activeGitRepoPath.length > 0) {
                    DevProjects.runInTerminal(`cd "${DevProjects.activeGitRepoPath}" && ${item.cmd}`)
                } else {
                    DevProjects.runInTerminal(item.cmd)
                }
                break
            case "system":
                if (item.action === "termcmd" && item.cmd.length > 0) {
                    DevProjects.runInTerminal(item.cmd)
                } else if (item.action === "qsreload") {
                    Quickshell.execDetached(["hyprctl", "reload"])
                    Quickshell.reload(true)
                } else if (item.action === "lock") {
                    Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.lock.screen()"])
                } else if (item.action === "session") {
                    GlobalStates.sessionOpen = true
                } else if (item.cmd.length > 0) {
                    Quickshell.execDetached(["fish", "-c", item.cmd])
                }
                break
        }

        GlobalStates.devPaletteOpen = false
    }

    // Context menu support: right-click or keybinding for alternative actions on projects
    property bool contextMode: false
    property bool showingContextMenu: false

    Component.onCompleted: {
        root.initialized = true
        root.buildModel()
    }

    IpcHandler {
        target: "devPalette"

        function toggle(): void {
            GlobalStates.devPaletteOpen = !GlobalStates.devPaletteOpen
            if (GlobalStates.devPaletteOpen) root.buildModel()
        }

        function open(): void {
            GlobalStates.devPaletteOpen = true
            root.buildModel()
        }

        function close(): void {
            GlobalStates.devPaletteOpen = false
        }
    }

    GlobalShortcut {
        name: "devPaletteToggle"
        description: "Toggles developer command palette"

        onPressed: {
            GlobalStates.devPaletteOpen = !GlobalStates.devPaletteOpen
            if (GlobalStates.devPaletteOpen) root.buildModel()
        }
    }
}
