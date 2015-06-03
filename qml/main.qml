import QtQuick 2.4
import Material 0.1
import Material.Extras 0.1
import Material.ListItems 0.1 as ListItem

import io.thp.pyotherside 1.4

ApplicationWindow {
    id: driveInLine
    title: "Drive-in-Line : a Google Drive client for Linux"

    property var myDriveMenu: [ "Home", "Recent files", "Trash" ]
    property var historyMenu: [ "All history", "New files", "Updated files", "Deleted files" ]
    property var sections: [ myDriveMenu, historyMenu ]
    property var sectionTitles: [ "My Drive", "History" ]
    property string selectedComponent: myDriveMenu[0]

    property alias gdrive: gdrive

    theme {
        primaryColor: Palette.colors["orange"]["500"]
        primaryDarkColor: Palette.colors["orange"]["700"]
        accentColor: Palette.colors["teal"]["500"]
        tabHighlightColor: "white"
    }
    clientSideDecorations: false
    width: Units.dp(1000)
    height: Units.dp(750)
    initialPage: page

    Page {
        id: page
        title: "My Drive"
        tabs: [
            // Each tab can have text and an icon
            {
                text: "My Drive",
                icon: "action/home"
            },
            {
                text: "History",
                icon: "action/history"
            }
        ]
        actionBar.maxActionCount: navDrawer.enabled ? 3 : 4
        backAction: navDrawer.action

        NavigationDrawer {
            id: navDrawer
            enabled: page.width < Units.dp(600)

            Flickable {
                anchors.fill: parent
                contentHeight: Math.max(content.implicitHeight, height)

                Column {
                    id: content
                    anchors.fill: parent

                    Repeater {
                        model: sections
                        delegate: Column {
                            width: parent.width

                            ListItem.Subheader {
                                text: sectionTitles[index]
                            }

                            Repeater {
                                model: modelData
                                delegate: ListItem.Standard {
                                    text: modelData
                                    selected: modelData === driveInLine.selectedComponent
                                    onClicked: {
                                        driveInLine.selectedComponent = modelData
                                        navDrawer.close()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        TabView {
            id: tabView
            anchors.fill: parent
            currentIndex: page.selectedTab
            model: sections

            delegate: Item {
                id: panel
                width: tabView.width
                height: tabView.height
                clip: true

                property string selectedComponent: modelData[0]

                Sidebar {
                    id: sidebar
                    expanded: !navDrawer.enabled

                    Column {
                        width: parent.width

                        Repeater {
                            model: modelData
                            delegate: ListItem.Standard {
                                text: modelData
                                selected: modelData === panel.selectedComponent
                                onClicked: {
                                    driveInLine.selectedComponent = modelData;
                                    panel.selectedComponent = modelData;
                                }
                            }
                        }
                    }
                }

                Flickable {
                    id: flickable
                    anchors {
                        left: sidebar.right
                        right: parent.right
                        top: parent.top
                        bottom: parent.bottom
                    }
                    clip: true
                    contentHeight: Math.max(myLoader.implicitHeight + 40, height)

                    MyLoader {
                        id: myLoader
                        toLoad: {
                            if (navDrawer.enabled) {
                                return driveInLine.selectedComponent;
                            } else {
                                return panel.selectedComponent;
                            }
                        }
                    }
                }

                Scrollbar {
                    flickableItem: flickable
                }
            }
        }
    }

    GDriveClient {
        // client gérant les accès au module gdrive
        id: gdrive
        signal gDriveInitialized
    }

    Component.onCompleted: {
        setX(200);
        setY(200);
    }
}




/*VisualItemModel {
    id: tabs

    // Tab 1 "My drive"
    Rectangle {
        width: tabView.width
        height: tabView.height
        color: Palette.colors.red["200"]

        Rectangle {
            width: (dossier1.implicitWidth + Units.dp(25))
            height: (dossier1.implicitHeight + Units.dp(25))
            color: Palette.colors.grey["300"]

            Label {
                id: dossier1
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                color: Palette.colors.grey["800"]
                text: "Mon premier dossier"
            }
        }

        Button {
            anchors.centerIn: parent
            darkBackground: true
            text: "Check your history"
            onClicked: page.selectedTab = 1
        }
    }

    // Tab 2 "History"
    Rectangle {
        width: tabView.width
        height: tabView.height
        color: Palette.colors.purple["200"]
    }
}*/
