pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string deviceName: "wlan0"
    property bool wifi: true
    property bool ethernet: false

    property bool wifiEnabled: false
    property bool wifiScanning: false
    property bool wifiConnecting: connectProc.running || passwordConnectProc.running

    property string wifiConnectTargetSsid: ""
    property bool askingPassword: false

    property var rawNetworks: []

    readonly property var active: rawNetworks.find(n => n.active) ?? null
    readonly property var friendlyWifiNetworks: [...rawNetworks].sort((a, b) => {
        if (a.active && !b.active) return -1;
        if (!a.active && b.active) return 1;
        return b.strength - a.strength;
    })

    property string wifiStatus: "disconnected"
    property string networkName: ""
    property int networkStrength: 100

    property string materialSymbol: root.ethernet
        ? "lan"
        : (root.wifiEnabled && root.wifiStatus === "connected")
            ? (
                root.networkStrength > 83 ? "signal_wifi_4_bar" :
                root.networkStrength > 67 ? "network_wifi" :
                root.networkStrength > 50 ? "network_wifi_3_bar" :
                root.networkStrength > 33 ? "network_wifi_2_bar" :
                root.networkStrength > 17 ? "network_wifi_1_bar" :
                "signal_wifi_0_bar"
            )
            : (root.wifiStatus === "connecting" || root.wifiStatus === "roaming")
                ? "signal_wifi_statusbar_not_connected"
                : (root.wifiStatus === "disconnected")
                    ? "wifi_find"
                    : (root.wifiStatus === "disabled")
                        ? "signal_wifi_off"
                        : "signal_wifi_bad"

    Component {
        id: wifiAccessPointComponent
        QtObject {
            property string ssid: ""
            property string name: ""
            property int strength: 70
            property bool active: false
            property string security: "psk"
        }
    }

    function enableWifi(enabled = true): void {
        const cmd = enabled ? "on" : "off";
        iwdExec.exec(["iwctl", "device", root.deviceName, "set-property", "Powered", cmd]);
        pollTimer.restart();
    }

    function toggleWifi(): void {
        enableWifi(!wifiEnabled);
    }

    function rescanWifi(): void {
        iwdExec.exec(["iwctl", "station", root.deviceName, "scan"]);
        pollTimer.restart();
    }

    function disconnectWifiNetwork(): void {
        iwdExec.exec(["iwctl", "station", root.deviceName, "disconnect"]);
        pollTimer.restart();
    }

    function connectToWifiNetwork(ssid: string): void {
        root.askingPassword = false;
        root.wifiConnectTargetSsid = ssid;
        connectProc.exec(["iwctl", "station", root.deviceName, "connect", ssid]);
    }

    function submitPassword(ssid: string, password: string): void {
        root.askingPassword = false;
        root.wifiConnectTargetSsid = ssid;
        passwordConnectProc.exec(["iwctl", "--passphrase", password, "station", root.deviceName, "connect", ssid]);
    }

    function openPublicWifiPortal() {
        Quickshell.execDetached(["xdg-open", "http://nmcheck.gnome.org/"])
    }

    Timer {
        id: pollTimer
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!updateStateProc.running) {
                updateStateProc.running = true;
            }
        }
    }

    Process { id: iwdExec }

    Process {
        id: connectProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.askingPassword = true;
            } else {
                root.wifiConnectTargetSsid = "";
            }
            pollTimer.restart();
        }
    }

    Process {
        id: passwordConnectProc
        onExited: (exitCode, exitStatus) => {
            if (exitCode !== 0) {
                root.askingPassword = true;
            } else {
                root.wifiConnectTargetSsid = "";
            }
            pollTimer.restart();
        }
    }

    Process {
        id: updateStateProc
        running: false
        command: ["busctl", "call", "net.connman.iwd", "/", "org.freedesktop.DBus.ObjectManager", "GetManagedObjects", "--json=short"]

        // FIX 1: Use StdioCollector instead of SplitParser
        // StdioCollector gathers the entire stdout into `text` and fires streamFinished
        stdout: StdioCollector {
            onStreamFinished: {
                const buffer = updateStateProc.stdout.text;
                if (!buffer || buffer.trim().length === 0) return;

                try {
                    const parsed = JSON.parse(buffer.trim());

                    // FIX 2: busctl --json=short wraps the reply in a "data" array.
                    // The first element is the actual ObjectManager result (a dict of paths).
                    // Structure: { "type": "a{oa{sa{sv}}}", "data": [[ [path, {iface: {prop: {type, data}}}], ... ]] }
                    const objects = parsed.data?.[0] ?? parsed;

                    let devName = root.deviceName;
                    let power = false;
                    let status = "disconnected";
                    let activeSSID = "";
                    let scanning = false;

                    let discoveredSsidMap = {};

                    for (const path in objects) {
                        const obj = objects[path];

                        const deviceIface = obj["net.connman.iwd.Device"];
                        if (deviceIface && deviceIface.Mode?.data === "station") {
                            devName = deviceIface.Name?.data ?? devName;
                            power = deviceIface.Powered?.data ?? false;
                        }

                        const stationIface = obj["net.connman.iwd.Station"];
                        if (stationIface) {
                            status = stationIface.State?.data ?? status;
                            scanning = stationIface.Scanning?.data ?? false;
                        }

                        const networkIface = obj["net.connman.iwd.Network"];
                        if (networkIface) {
                            const targetSsid = networkIface.Name?.data;
                            const isConnected = networkIface.Connected?.data ?? false;
                            const securityType = networkIface.Type?.data ?? "open";

                            if (targetSsid) {
                                discoveredSsidMap[targetSsid] = {
                                    active: isConnected,
                                    security: securityType,
                                    strength: isConnected ? root.networkStrength : 75
                                };

                                if (isConnected) {
                                    activeSSID = targetSsid;
                                }
                            }
                        }
                    }

                    let nextRawNetworks = [];

                    root.rawNetworks.forEach(oldObj => {
                        if (discoveredSsidMap[oldObj.ssid]) {
                            const meta = discoveredSsidMap[oldObj.ssid];
                            oldObj.active = meta.active;
                            oldObj.security = meta.security;
                            oldObj.strength = meta.strength;
                            nextRawNetworks.push(oldObj);
                            delete discoveredSsidMap[oldObj.ssid];
                        } else {
                            oldObj.destroy();
                        }
                    });

                    for (const newSsid in discoveredSsidMap) {
                        const meta = discoveredSsidMap[newSsid];
                        const instance = wifiAccessPointComponent.createObject(root, {
                            "ssid": newSsid,
                            "name": newSsid,
                            "active": meta.active,
                            "security": meta.security,
                            "strength": meta.strength
                        });
                        if (instance) {
                            nextRawNetworks.push(instance);
                        }
                    }

                    root.deviceName = devName;
                    root.wifiEnabled = power;
                    root.wifiStatus = status;
                    root.wifiScanning = scanning;
                    root.networkName = activeSSID;
                    root.rawNetworks = nextRawNetworks;

                } catch (e) {
                    console.warn("Error processing iwd state update:", e);
                }
            }
        }
    }
}