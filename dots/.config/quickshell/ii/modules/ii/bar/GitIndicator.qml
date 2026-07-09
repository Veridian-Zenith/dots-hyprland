import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: root

    implicitWidth: indicator.implicitWidth + 16
    implicitHeight: parent?.height ?? 30
    visible: DevProjects.activeGitBranch.length > 0

    property color branchColor: DevProjects.activeGitDirty ?
        "#f0c040" : Appearance.vzcolors.accentVibrant

    Rectangle {
        id: indicator
        anchors.verticalCenter: parent.verticalCenter
        height: Math.min(parent.height - 8, 26)
        radius: height / 2
        color: ColorUtils.transparentize(branchColor, 0.85)
        border.width: 1
        border.color: ColorUtils.transparentize(branchColor, 0.7)
        implicitWidth: row.implicitWidth + 16

        Behavior on border.color {
            ColorAnimation { duration: 200 }
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 4

            MaterialSymbol {
                text: "call_split"
                iconSize: 14
                color: branchColor
            }

            StyledText {
                text: DevProjects.activeGitBranch
                font.pixelSize: Appearance.font.pixelSize.small
                font.bold: true
                color: branchColor
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Revealer {
                reveal: DevProjects.activeGitDirty
                Layout.fillHeight: true
                MaterialSymbol {
                    text: "circle"
                    iconSize: 8
                    color: "#f0c040"
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                gitPopupLoader.active = !gitPopupLoader.active
            }
        }
    }

    Loader {
        id: gitPopupLoader
        active: false

        sourceComponent: PanelWindow {
            id: gitPopupWindow
            color: "transparent"

            exclusionMode: ExclusionMode.Ignore
            exclusiveZone: 0
            WlrLayershell.namespace: "quickshell:gitpopup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

            anchors.top: !Config.options.bar.bottom
            anchors.bottom: Config.options.bar.bottom

            implicitWidth: 280
            implicitHeight: gitPopupContent.implicitHeight + 24

            margins {
                left: root.QsWindow?.mapFromItem(root, 0, 0).x ?? 0
                top: Config.options.bar.bottom ? undefined : (Appearance.sizes.barHeight + 4)
                bottom: !Config.options.bar.bottom ? undefined : (Appearance.sizes.barHeight + 4)
                right: 0
            }

            onVisibleChanged: {
                if (visible) GlobalFocusGrab.addDismissable(gitPopupWindow)
                else GlobalFocusGrab.removeDismissable(gitPopupWindow)
            }

            Connections {
                target: GlobalFocusGrab
                function onDismissed() { gitPopupLoader.active = false }
            }

            StyledRectangularShadow {
                target: gitPopupContent
            }

            RectangularGlow {
                anchors.fill: gitPopupContent
                anchors.margins: -2
                glowRadius: 5
                spread: 0.05
                color: Appearance.vzcolors.glowColor
                cornerRadius: gitPopupContent.radius + 2
                opacity: 0.12
            }

            Rectangle {
                id: gitPopupContent
                anchors.fill: parent
                anchors.margins: 10
                color: ColorUtils.transparentize(Appearance.vzcolors.bgPrimary, 0.15)
                radius: Appearance.rounding.normal
                border.width: 1
                border.color: Appearance.vzcolors.borderColor
                clip: true

                ColumnLayout {
                    id: gitPopupCol
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        MaterialSymbol {
                            text: "call_split"
                            iconSize: 18
                            color: root.branchColor
                        }
                        StyledText {
                            Layout.fillWidth: true
                            text: DevProjects.activeGitRepoName
                            font.pixelSize: Appearance.font.pixelSize.normal
                            font.bold: true
                            color: Appearance.m3colors.m3onBackground
                            elide: Text.ElideRight
                        }
                    }

                    StyledText {
                        text: DevProjects.activeGitBranch + (DevProjects.activeGitDirty ? " (dirty)" : "")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: root.branchColor
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Appearance.vzcolors.borderColor
                        Layout.topMargin: 4
                        Layout.bottomMargin: 4
                    }

                    // Quick actions
                    Repeater {
                        model: [
                            { label: "Status", cmd: "git status", icon: "info" },
                            { label: "Log", cmd: "git log --oneline --graph -15", icon: "history" },
                            { label: "Pull", cmd: "git pull", icon: "download" },
                            { label: "Push", cmd: "git push", icon: "upload" },
                            { label: "Diff", cmd: "git diff --stat", icon: "difference" },
                            { label: "Open in Terminal", cmd: "", icon: "terminal", action: "terminal" },
                            { label: "Open in VS Code", cmd: "", icon: "code", action: "code" },
                        ]

                        delegate: Rectangle {
                            id: actionDelegate
                            required property int index
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: Appearance.rounding.small
                            color: actionMouse.containsMouse ?
                                ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.88) : "transparent"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                MaterialSymbol {
                                    text: modelData.icon
                                    iconSize: 16
                                    color: actionMouse.containsMouse ?
                                        Appearance.vzcolors.accentVibrant : Appearance.m3colors.m3onBackground
                                }
                                StyledText {
                                    Layout.fillWidth: true
                                    text: modelData.label
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    color: actionMouse.containsMouse ?
                                        Appearance.vzcolors.accentVibrant : Appearance.m3colors.m3onBackground
                                }
                            }

                            MouseArea {
                                id: actionMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.action === "terminal") {
                                        DevProjects.openProject(DevProjects.activeGitRepoPath)
                                    } else if (modelData.action === "code") {
                                        DevProjects.openProjectInEditor(DevProjects.activeGitRepoPath)
                                    } else if (modelData.cmd.length > 0) {
                                        DevProjects.runInTerminal(`cd "${DevProjects.activeGitRepoPath}" && ${modelData.cmd}`)
                                    }
                                    gitPopupLoader.active = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: DevProjects
        function onActiveGitBranchChanged() {
            root.visible = DevProjects.activeGitBranch.length > 0
        }
    }
}
