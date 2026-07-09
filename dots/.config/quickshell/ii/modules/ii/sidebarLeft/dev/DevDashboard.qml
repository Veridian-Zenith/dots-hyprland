import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io

Rectangle {
    id: root

    radius: Appearance.rounding.small
    color: "transparent"
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // Git context card
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 36
            radius: height / 2
            color: Appearance.vzcolors.bgSecondary
            border.width: 1
            border.color: DevProjects.activeGitDirty ? "#f0c040" : Appearance.vzcolors.borderColor
            visible: DevProjects.activeGitBranch.length > 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 4
                spacing: 6

                MaterialSymbol {
                    text: "call_split"
                    iconSize: 16
                    color: DevProjects.activeGitDirty ? "#f0c040" : Appearance.vzcolors.accentVibrant
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    StyledText {
                        Layout.fillWidth: true
                        text: DevProjects.activeGitRepoName
                        font.pixelSize: Appearance.font.pixelSize.small
                        font.bold: true
                        color: Appearance.m3colors.m3onBackground
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                    StyledText {
                        Layout.fillWidth: true
                        text: DevProjects.activeGitBranch + (DevProjects.activeGitDirty ? " *" : "")
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: DevProjects.activeGitDirty ? "#f0c040" : ColorUtils.transparentize(Appearance.m3colors.m3onBackground, 0.5)
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }
                }

                RippleButton {
                    implicitWidth: 24
                    implicitHeight: 24
                    buttonRadius: 12
                    colBackground: "transparent"
                    colBackgroundHover: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.85)
                    colRipple: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.7)

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "terminal"
                        iconSize: 14
                        color: Appearance.vzcolors.accentVibrant
                    }
                    StyledToolTip { text: "Open repo in terminal" }
                    onClicked: DevProjects.openProject(DevProjects.activeGitRepoPath)
                }

                RippleButton {
                    implicitWidth: 24
                    implicitHeight: 24
                    buttonRadius: 12
                    colBackground: "transparent"
                    colBackgroundHover: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.85)
                    colRipple: ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.7)

                    MaterialSymbol {
                        anchors.centerIn: parent
                        text: "code"
                        iconSize: 14
                        color: Appearance.vzcolors.accentVibrant
                    }
                    StyledToolTip { text: "Open in VS Code" }
                    onClicked: DevProjects.openProjectInEditor(DevProjects.activeGitRepoPath)
                }
            }
        }

        // Quick actions grid
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            rowSpacing: 4
            columnSpacing: 4

            Repeater {
                model: [
                    { icon: "terminal", tooltip: "Open Terminal", action: "terminal", label: "Term" },
                    { icon: "code", tooltip: "Open VS Code", action: "code", label: "Code" },
                    { icon: "refresh", tooltip: "Reload Hyprland", action: "hyprctl reload", label: "Reload" },
                    { icon: "restart_alt", tooltip: "Reload Shell", action: "qsreload", label: "Restart" },
                    { icon: "monitoring", tooltip: "System Monitor", action: "btop", label: "Monitor", span: 2 },
                ]

                delegate: Rectangle {
                    id: actionBtn
                    required property int index
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.columnSpan: modelData.span || 1
                    Layout.preferredHeight: 34
                    radius: Appearance.rounding.small
                    color: actionMouse.containsMouse ?
                        ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.88) : "transparent"
                    border.width: actionMouse.containsMouse ? 1 : 0
                    border.color: actionMouse.containsMouse ?
                        ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.8) : "transparent"

                    Behavior on color { ColorAnimation { duration: 80 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6

                        MaterialSymbol {
                            text: modelData.icon
                            iconSize: 16
                            color: actionMouse.containsMouse ?
                                Appearance.vzcolors.accentVibrant : ColorUtils.transparentize(Appearance.m3colors.m3onBackground, 0.7)
                        }
                        StyledText {
                            text: modelData.label
                            font.pixelSize: 10
                            font.bold: true
                            color: actionMouse.containsMouse ?
                                Appearance.vzcolors.accentVibrant : ColorUtils.transparentize(Appearance.m3colors.m3onBackground, 0.7)
                        }
                    }

                    MouseArea {
                        id: actionMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (modelData.action === "terminal") {
                                DevProjects.openTerminal()
                            } else if (modelData.action === "code") {
                                Quickshell.execDetached(["code"])
                            } else if (modelData.action === "qsreload") {
                                Quickshell.execDetached(["hyprctl", "reload"])
                                Quickshell.reload(true)
                            } else if (modelData.action === "btop") {
                                DevProjects.runInTerminal("btop")
                            } else {
                                Quickshell.execDetached(["fish", "-c", modelData.action])
                            }
                        }
                    }

                    StyledToolTip { text: modelData.tooltip }
                }
            }
        }

        // Projects header
        StyledText {
            Layout.fillWidth: true
            text: "Projects"
            font.pixelSize: Appearance.font.pixelSize.small
            font.bold: true
            color: Appearance.vzcolors.accentVibrant
            visible: DevProjects.projects.count > 0
        }

        // Projects list
        ListView {
            id: projectList
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: DevProjects.projects
            spacing: 2
            clip: true

            delegate: Rectangle {
                id: projectDelegate
                required property int index
                required property var modelData
                implicitWidth: projectList.width
                implicitHeight: 32
                radius: Appearance.rounding.small
                color: projectMouse.containsMouse ?
                    ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.88) : "transparent"

                Behavior on color { ColorAnimation { duration: 80 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 6
                    anchors.rightMargin: 2
                    spacing: 6

                    MaterialSymbol {
                        text: "folder"
                        iconSize: 14
                        color: Appearance.vzcolors.accentVibrant
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: modelData.name
                        font.pixelSize: Appearance.font.pixelSize.small
                        color: projectMouse.containsMouse ?
                            Appearance.vzcolors.accentVibrant : Appearance.m3colors.m3onBackground
                        elide: Text.ElideRight
                    }

                    // Action buttons - only show on hover
                    Repeater {
                        model: [
                            { icon: "terminal", action: "term", tooltip: "Open in Terminal" },
                            { icon: "code", action: "code", tooltip: "Open in VS Code" },
                        ]

                        delegate: Rectangle {
                            required property int index
                            required property var modelData
                            implicitWidth: 22
                            implicitHeight: 22
                            radius: 11
                            color: actionBtnMouse.containsMouse ?
                                ColorUtils.transparentize(Appearance.vzcolors.accentVibrant, 0.8) : "transparent"
                            visible: projectMouse.containsMouse

                            MaterialSymbol {
                                anchors.centerIn: parent
                                text: modelData.icon
                                iconSize: 12
                                color: Appearance.vzcolors.accentVibrant
                            }

                            StyledToolTip { text: modelData.tooltip }

                            MouseArea {
                                id: actionBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (modelData.action === "term")
                                        DevProjects.openProject(projectDelegate.modelData.path)
                                    else
                                        DevProjects.openProjectInEditor(projectDelegate.modelData.path)
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: projectMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton
                    onClicked: DevProjects.openProject(modelData.path)
                }
            }
        }
    }

    Component.onCompleted: {
        DevProjects.scanProjects()
        DevProjects.refreshGitContext()
    }
}
