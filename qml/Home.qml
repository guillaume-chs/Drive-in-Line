import QtQuick 2.4
import QtQuick.Dialogs 1.0
import QtGraphicalEffects 1.0
import Material 0.1

Item {
    id: home
    property bool on: false
    property alias home_page: columnLayout

    property int homeMargins: 25
    anchors.margins: Units.dp(homeMargins)
    anchors.fill: parent

    property var actualFile
    property var actualDir
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

    MouseArea {
        anchors.fill: parent

        RadialGradient {
            id: gradient
            visible: false
            width: home.width + Units.dp(homeMargins)
            height: home.height + Units.dp(homeMargins)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "blue" }
                GradientStop { position: 0.8; color: "lightblue" }
            }
        }

        DropArea {
            anchors.fill: parent
            onContainsDragChanged: {
                if (containsDrag) {
                    gradient.visible = true;
                } else {
                    gradient.visible = false;
                }
            }

            onDropped: {
                console.log('dropped file(s)');

                var filesUri = ',' + drop.urls.toString();
                var filesUrl = filesUri.split(',file://');

                snackbar.open("Uploading <b>" + (filesUrl.length >= 2 ? filesUrl[1] : "files") + "</b>");

                for (var i = 1; i < filesUrl.length; i++) {
                    var url = filesUrl[i];
                    gdrive.uploadFile(url, function (result) {
                        home.getActualDir();
                    });
                }
            }
        }
    }

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
            model: home.numberOfRows
            delegate: Row {
                width: columnLayout.width
                spacing: Units.dp(home.rowSpacing)

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
                            font.pixelSize: Units.dp(home.fontSize)

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
                                    home.actualDir = modelData;
                                    home.getActualDir();
                                } else {
                                    home.actualFile = modelData;
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
                                                return Units.dp(home.fontSize);
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
                                        font.pixelSize: Units.dp(home.fontSize);
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

    Dialog {
        id: renameDialog
        title: "Rename file"
        hasActions: true
        property string base_title: "Rename "
        property string dialog_text: ""

        TextField {
            id: optionText
            text: renameDialog.dialog_text
            width: parent.width
            placeholderText: "Filename"
        }

        onAccepted: {
            home.actualFile["title"] = optionText.text;
            console.log('new filename : ' + optionText.text);
            gdrive.renameFile(home.actualFile['id'], optionText.text, function(result) {
                home.getActualDir();
            });
        }

        onRejected: {
            renameDialog.dialog_text = home.actualFile["title"];
        }

        function openForFile(file) {
            renameDialog.title = base_title + "<b>" + home.actualFile["title"] + "</b>";
            renameDialog.dialog_text = home.actualFile["title"];
            renameDialog.open();
        }
    }

    FileDialog {
        id: fileDialog
        visible: false
        title: "Please choose a file"
        selectFolder: true
        selectMultiple: false
        selectExisting: true
        onAccepted: {
            var url = fileDialog.fileUrl.toString() + "/";
            console.log("You chose: " + url);
            gdrive.downloadFile(home.actualFile["id"], url.slice(7, url.length) + home.actualFile["title"]);
        }
        onRejected: {
            console.log("Canceled");
        }
    }

    BottomActionSheet {
        id: actionSheet
        maxHeight: (driveInLine.height / 2)
        property string base_title: "What to do with "
        actions: [
            Action {
                id: open
                iconName: "action/open_in_new"
                name: "Open"
                onTriggered: {
                    gdrive.openFile(home.actualFile['id'], function(result) {
                        snackbar.open('File <b>' + home.actualFile['title'] + '</b> opened');
                    });
                }
            },
            Action {
                id: rename
                iconName: "content/create"
                name: "Rename"
                onTriggered: {
                    renameDialog.openForFile(home.actualFile);
                }
            },
            Action {
                id: download
                iconName: "file/file_download"
                name: "Download"
                onTriggered: {
                    fileDialog.open();
                }
            },
            Action {
                id: details
                iconName: "action/settings"
                name: "Details"
                onTriggered: {
                    gfileDialog.openForFile(home.actualFile);
                }

                hasDividerAfter: true
            },
            Action {
                id: share
                iconName: "social/share"
                name: "Share"
            },
            Action {
                id: move
                iconName: "content/forward"
                name: "Move"
            },
            Action {
                id: suppress
                iconName: "action/delete"
                name: "Delete"
            }
        ]

        function openForFile(file) {
            title = base_title + "<b>" + file["title"] + "</b>";
            actionSheet.open();
        }
    }

    GDriveLoader {
        id: gdriveLoader
        visible: !(home.on)
        property string message: "Retreiving data from Google Drive ..."
    }

    GFileDialog {
        id: gfileDialog
        // visible: false
    }

    Snackbar {
        id: snackbar
    }

    Component.onCompleted: {
        if (gdrive.isConnected) {
            initialize();
        } else {
            gdrive.gDriveInitialized.connect(initialize);
        }
    }

    function initialize() {
        console.log('Initialized ' + gdrive);

        if (gdrive !== undefined) {
            home.getDir('root', 'root');
        }
    }

    function getActualDir() {
        home.getDir(home.actualDir["id"], home.actualDir["title"]);
    }

    function getDir(id, dir_name) {
        home.on = false;

        if (dir_name === undefined || dir_name.length <= 0) {
            dir_name = 'root';
        }
        if (id === undefined || id.length <= 0) {
            id = 'root';
        }

        gdrive.getDirFiles(id, function(result) {
            if (result !== undefined && result.length > 0) {
                if (dir_name === 'root')
                    page.title = "My Drive";
                else
                    page.title += (" > " + dir_name);
                home.on = true;
                home.actualDir = {"id": id, "title": dir_name}

                result.sort(compareFiles);
                home.files = result;
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
