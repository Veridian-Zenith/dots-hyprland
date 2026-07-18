pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs.modules.common.functions
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property string devDir: FileUtils.trimFileProtocol(`${Directories.home}/VZ_Dev`)
    readonly property string terminalCmd: "kitty"

    property ListModel projects: ListModel {}
    property string activeGitBranch: ""
    property string activeGitRepoPath: ""
    property string activeGitRepoName: ""
    property bool activeGitDirty: false
    property string activeWindowClass: ""
    property string activeWindowTitle: ""
    property int activePid: 0
    property bool scanning: false
    property bool detecting: false

    function scanProjects(): void {
        if (scanning) return
        scanning = true
        scanProc.running = true
    }

    function openProject(path: string): void {
        Quickshell.execDetached([root.terminalCmd, "-d", path])
    }

    function openProjectInEditor(path: string): void {
        Quickshell.execDetached(["code", path])
    }

    function openProjectInFileManager(path: string): void {
        Quickshell.execDetached(["xdg-open", path])
    }

    function openTerminal(): void {
        Quickshell.execDetached([root.terminalCmd])
    }

    function refreshGitContext(): void {
        detectGitForActiveWindow()
    }

    function runCommand(cmd: string): void {
        Quickshell.execDetached(["fish", "-c", cmd])
    }

    function runInTerminal(cmd: string): void {
        Quickshell.execDetached([root.terminalCmd, "-e", "fish", "-c", `${cmd}; exec fish -i`])
    }

    function detectGitForActiveWindow(): void {
        if (detecting) return
        detecting = true
        activeWinProc.running = true
    }

    function checkPathForGit(path: string): void {
        if (!path || path.length === 0) {
            root.activeGitBranch = ""
            root.activeGitRepoPath = ""
            root.activeGitRepoName = ""
            root.activeGitDirty = false
            detecting = false
            return
        }
        checkGitRepoProc.command = ["fish", "-c", `cd "${path}" && git rev-parse --show-toplevel 2>/dev/null`]
        checkGitRepoProc.running = true
    }

    Process {
        id: scanProc
        command: ["fish", "-c", `cd "${root.devDir}" && (ls -d */ 2>/dev/null; find . -maxdepth 3 -mindepth 2 -type d -exec test -d "{}/.git" \; -print 2>/dev/null) | sed 's|^\./||' | sort -u`]
        stdout: StdioCollector {
            onStreamFinished: {
                const dirs = text.trim().split('\n').filter(d => d.length > 0)
                root.projects.clear()
                for (const d of dirs) {
                    root.projects.append({ path: d, name: d.split('/').slice(-1)[0] })
                }
                root.scanning = false
            }
        }
    }

    Process {
        id: activeWinProc
        command: ["hyprctl", "activewindow", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const info = JSON.parse(text.trim())
                    root.activeWindowClass = info.class || ""
                    root.activeWindowTitle = info.title || ""
                    root.activePid = (info.pid && info.pid > 0) ? info.pid : 0

                    if (root.activePid > 0) {
                        cwdProc.command = ["fish", "-c", `readlink -f /proc/${root.activePid}/cwd 2>/dev/null`]
                        cwdProc.running = true
                    } else {
                        root.tryMatchTitleToProject()
                    }
                } catch (e) {
                    root.detecting = false
                }
            }
        }
    }

    Process {
        id: cwdProc
        stdout: StdioCollector {
            onStreamFinished: {
                const cwd = text.trim()
                if (cwd.length > 0 && cwd.startsWith("/")) {
                    root.checkPathForGit(cwd)
                } else {
                    root.tryMatchTitleToProject()
                }
            }
        }
    }

    Process {
        id: checkGitRepoProc
        stdout: StdioCollector {
            onStreamFinished: {
                const repoPath = text.trim()
                if (repoPath.length > 0) {
                    root.activeGitRepoPath = repoPath
                    root.activeGitRepoName = repoPath.split('/').slice(-1)[0]
                    gitBranchProc.command = ["fish", "-c", `git -C "${repoPath}" rev-parse --abbrev-ref HEAD 2>/dev/null`]
                    gitBranchProc.running = true
                } else {
                    root.activeGitBranch = ""
                    root.activeGitRepoPath = ""
                    root.activeGitRepoName = ""
                    root.activeGitDirty = false
                    root.detecting = false
                }
            }
        }
    }

    Process {
        id: gitBranchProc
        stdout: StdioCollector {
            onStreamFinished: {
                const branch = text.trim()
                root.activeGitBranch = branch
                if (branch.length > 0 && root.activeGitRepoPath.length > 0) {
                    gitStatusProc.command = ["fish", "-c", `git -C "${root.activeGitRepoPath}" status --porcelain 2>/dev/null | wc -l`]
                    gitStatusProc.running = true
                } else {
                    root.detecting = false
                }
            }
        }
    }

    Process {
        id: gitStatusProc
        stdout: StdioCollector {
            onStreamFinished: {
                const dirtyCount = parseInt(text.trim()) || 0
                root.activeGitDirty = dirtyCount > 0
                root.detecting = false
            }
        }
    }

    function tryMatchTitleToProject(): void {
        const title = root.activeWindowTitle.toLowerCase()
        for (var i = 0; i < root.projects.count; i++) {
            const p = root.projects.get(i)
            const nameLow = p.name.toLowerCase()
            if (title.includes(nameLow)) {
                root.checkPathForGit(p.path)
                return
            }
        }
        root.activeGitBranch = ""
        root.activeGitRepoPath = ""
        root.activeGitRepoName = ""
        root.activeGitDirty = false
        root.detecting = false
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            root.detectGitForActiveWindow()
        }
    }

    Component.onCompleted: {
        root.scanProjects()
        root.detectGitForActiveWindow()
    }
}
