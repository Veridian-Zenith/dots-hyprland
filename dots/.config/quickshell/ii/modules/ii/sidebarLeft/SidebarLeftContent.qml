import qs.services
import qs.modules.common
import qs.modules.common.widgets
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Qt.labs.synchronizer

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: 6
    anchors.fill: parent
    property bool aiChatEnabled: Config.options.policies.ai !== 0
    property bool translatorEnabled: Config.options.sidebar.translator.enable
    property bool animeEnabled: Config.options.policies.weeb !== 0
    property bool animeCloset: Config.options.policies.weeb === 2
    property var tabButtonList: [
        ...(root.aiChatEnabled ? [{"icon": "neurology", "name": Translation.tr("Intelligence")}] : []),
        ...(root.translatorEnabled ? [{"icon": "translate", "name": Translation.tr("Translator")}] : []),
        ...((root.animeEnabled && !root.animeCloset) ? [{"icon": "bookmark_heart", "name": Translation.tr("Anime")}] : [])
    ]
    property int tabCount: pages.length
    property var pages: []

    function focusActiveItem() {
        if (tabBar.currentIndex >= 0 && tabBar.currentIndex < pages.length) {
            let page = pages[tabBar.currentIndex]
            if (page) page.forceActiveFocus()
        }
    }

    Keys.onPressed: (event) => {
        if (event.modifiers === Qt.ControlModifier) {
            if (event.key === Qt.Key_PageDown) {
                if (tabBar.currentIndex < pages.length - 1)
                    tabBar.setCurrentIndex(tabBar.currentIndex + 1)
                event.accepted = true;
            }
            else if (event.key === Qt.Key_PageUp) {
                if (tabBar.currentIndex > 0)
                    tabBar.setCurrentIndex(tabBar.currentIndex - 1)
                event.accepted = true;
            }
        }
    }

    ColumnLayout {
        anchors {
            fill: parent
            margins: sidebarPadding
        }
        spacing: sidebarPadding

        Toolbar {
            visible: tabButtonList.length > 0
            Layout.alignment: Qt.AlignHCenter
            enableShadow: false
            ToolbarTabBar {
                id: tabBar
                Layout.alignment: Qt.AlignHCenter
                tabButtonList: root.tabButtonList
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Appearance.rounding.normal
            color: Appearance.colors.colLayer1
            clip: true

            Item {
                id: pageContainer
                anchors.fill: parent
                property var pages: []

                function showPage(index: int) {
                    for (let i = 0; i < pages.length; i++)
                        pages[i].visible = (i === index)
                }

                Connections {
                    target: tabBar
                    function onCurrentIndexChanged() {
                        pageContainer.showPage(tabBar.currentIndex)
                    }
                }

                Component.onCompleted: {
                    function addPage(comp) {
                        let page = comp.createObject(pageContainer, {
                            visible: false,
                        })
                        page.anchors.fill = pageContainer
                        pageContainer.pages.push(page)
                    }
                    if (root.aiChatEnabled) addPage(aiChat)
                    if (root.translatorEnabled) addPage(translator)
                    if (root.animeEnabled && !root.animeCloset) addPage(anime)
                    if (pages.length > 0) pages[0].visible = true
                }
            }
        }

        Component {
            id: aiChat
            AiChat {}
        }
        Component {
            id: translator
            Translator {}
        }
        Component {
            id: anime
            Anime {}
        }
        Component {
            id: placeholder
            Item {
                StyledText {
                    anchors.centerIn: parent
                    text: root.animeCloset ? Translation.tr("Nothing") : Translation.tr("Enjoy your empty sidebar...")
                    color: Appearance.colors.colSubtext
                }
            }
        }
    }
}