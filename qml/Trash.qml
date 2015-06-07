import QtQuick 2.0
import Material 0.1

Item {
    id: trash
    property bool on: false
    property alias trash_page: columnLayout

    property int homeMargins: 25
    anchors.margins: Units.dp(homeMargins)
    anchors.fill: parent

    property var actualFile
    property var files: []
    onFilesChanged: {
        requestDraw();
    }

    property int fontSize: 15
    property int itemWidth: 200
    property int itemHeight: 40
    property int cardMargin: 20
    property int labelMargin: 15
    property int colSpacing: 25
    property int rowSpacing: 10
    property int itemsPerLine: nbItemsPerLine()
    property int numberOfRows: nbOfRows()

    Column {
        id: columnLayout
        anchors.fill: parent
        spacing: Units.dp(colSpacing)
        visible: true

        property var cardWidth: {
            return Math.max(Units.dp(itemWidth), ((columnLayout.width - (rowSpacing * 2)) / itemsPerLine))
        }

        property int maxTextLength: calculateMaxLength(fontSize)
        function calculateMaxLength(pixelSize) {
            var marginCard = (Units.dp(cardMargin) * 2);
            var marginLabel = (Units.dp(labelMargin) * 2);
            var total_width = cardWidth /*- marginCard - marginLabel*/;

            return Math.round(total_width / (pixelSize / 2), 0);
        }

        onWidthChanged: {
            requestDraw();
        }

        Repeater {
            id: columnRepeater
            model: trash.numberOfRows
            delegate: Row {
                width: columnLayout.width
                spacing: Units.dp(trash.rowSpacing)

                Repeater {
                    model: {
                        var items = [];
                        var begin = index * itemsPerLine;

                        for (var i = begin; i < (begin + itemsPerLine) && i < files.length; i++)
                            items.push(files[i]);

                        return items;
                    }

                    delegate: Card {
                        id: card
                        width: columnLayout.cardWidth
                        height: Units.dp(itemHeight)
                        anchors.margins: Units.dp(cardMargin)
                        elevation: (isFolder ? 1 : 0)
                        enabled: true
                        flat: true
                        backgroundColor: (isFolder ? folder_bg_color : file_bg_color)

                        property var folder_bg_color: "white"
                        property var file_bg_color: Qt.rgba(0, 0, 0, 0.1)
                        property var hover_bg_color: Palette.colors["teal"]["200"]

                        property bool isFolder: gdrive.isFolder(modelData)

                        Label {
                            id: cardLabel
                            style: "title"
                            font.weight: Font.Normal
                            font.pixelSize: Units.dp(trash.fontSize)

                            property string fullText: modelData["title"].toString()
                            property string textToPrint: shortenText(columnLayout.maxTextLength)
                            text: textToPrint

                            anchors {
                                left: parent.left
                                verticalCenter: parent.verticalCenter
                                margins: Units.dp(labelMargin)
                            }
                        }

                        function shortenText(maxLength) {
                            var base = cardLabel.fullText;
                            var ellipsis = "…";

                            if (base.length > maxLength) {
                                base = base.slice(0, maxLength - ellipsis.length) + ellipsis;
                            }
                            return base;
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true

                            onPressed: {
                                if (isFolder) {
                                    trash.getActualDir();
                                } else {
                                    trash.actualFile = modelData;
                                    actionSheet.openForFile(modelData);
                                }
                            }

                            onEntered: { state = "hovered"; }
                            onExited:  { state = "normal";  }

                            states: [
                                State {
                                    name: "hovered"
                                    PropertyChanges {
                                        target: cardLabel
                                        font.pixelSize: {
                                            if (fullText.length >= columnLayout.maxTextLength) {
                                                return Units.dp(13);
                                            } else {
                                                return Units.dp(trash.fontSize);
                                            }
                                        }
                                        text: {
                                            if (fullText.length >= columnLayout.maxTextLength) {
                                                var newFontSize = 13;
                                                var newMaxLength = columnLayout.calculateMaxLength(newFontSize);
                                                return card.shortenText(newMaxLength);
                                            } else {
                                                return fullText;
                                            }
                                        }
                                    }
                                    PropertyChanges {
                                        target: card
                                        backgroundColor: hover_bg_color
                                    }
                                },

                                State {
                                    name: "normal"
                                    PropertyChanges {
                                        target: cardLabel
                                        font.pixelSize: Units.dp(trash.fontSize);
                                        text: textToPrint
                                    }
                                    PropertyChanges {
                                        target: card
                                        backgroundColor: {
                                            if (isFolder) {
                                                return folder_bg_color;
                                            } else {
                                                return file_bg_color;
                                            }
                                        }
                                    }
                                }
                            ]

                            transitions: [
                                Transition {
                                    NumberAnimation   { target: cardLabel; property: "font.pixelSize";  duration: 200 }
                                    PropertyAnimation { target: cardLabel; property: "text";            duration: 200 }
                                    ColorAnimation    { target: card;                                   duration: 200 }
                                }
                            ]
                        }
                    }
                }
            }
        }
    }

    function nbItemsPerLine() {
        var totalItemWidth = itemWidth;
        var totalWidth = columnLayout.width - (rowSpacing * 2);

        var result = Math.round(totalWidth / totalItemWidth, 0);
        return (result > 0 ? result : 0);
    }

    function nbOfRows() {
        var result = Math.round((files.length - 1) / itemsPerLine, 0);
        return (result > 0 ? result : 0);
    }

    function requestDraw() {
        itemsPerLine = nbItemsPerLine();
        numberOfRows = nbOfRows();
    }


    BottomActionSheet {
        id: actionSheet
        maxHeight: (driveInLine.height / 2)
        anchors.margins: Units.dp(16)
        property string base_title: "What to do with "
        actions: [
            Action {
                id: move
                iconName: "content/forward"
                name: "Untrash file"
                onTriggered: {
                    snackbar.open('Untrashing <b>' + trash.actualFile['title'] + '</b>');
                    gdrive.untrashFile(trash.actualFile["id"], function(result) {
                        trash.getTrash();
                    });
                }
            },
            Action {
                id: details
                iconName: "action/settings"
                name: "Details"
                onTriggered: {
                    gfileDialog.openForFile(trash.actualFile);
                }

                hasDividerAfter: true
            },
            Action {
                id: suppress
                iconName: "action/delete"
                name: "Delete"
                onTriggered: {
                    // Ask for configuration before any deletion
                    snackbar.open('Permanently deleted <b>' + trash.actualFile['title'] + '</b>');
                }
            }
        ]

        function openForFile(file) {
            title = base_title + "<b>" + file["title"] + "</b>";
            actionSheet.open();
        }
    }

    GDriveLoader {
        id: gdriveLoader
        visible: !(trash.on)
        property string message: "Retreiving trashed files ..."
    }

    GFileDialog {
        id: gfileDialog
        // visible: false
    }

    Snackbar {
        id: snackbar
    }

    Component.onCompleted: {
        page.title = "My Drive  >  Trash";

        if (gdrive.isConnected) {
            initialize();
        } else {
            gdrive.gDriveInitialized.connect(initialize);
        }
    }

    function initialize() {
        console.log('Initialized ' + gdrive);

        if (gdrive !== undefined) {
            trash.getTrash();
        }
    }

    function getTrash() {
        trash.on = false;

        gdrive.getTrashFiles(function(result) {
            trash.on = true;
            console.log(result);
            if (result !== undefined && result.length > 0) {
                result.sort(compareFiles);
                trash.files = result;
            }
        });
    }

    function compareFiles(file1, file2) {
        var is1Dossier = gdrive.isFolder(file1);
        var is2Dossier = gdrive.isFolder(file2);

        if (is1Dossier) {
            if (is2Dossier && (file1["title"] > file2["title"])) {
                return 1;
            }
            return -1;
        } else {
            if (!is2Dossier && (file1["title"] < file2["title"])) {
                return -1;
            }
            return 1;
        }
    }
}
