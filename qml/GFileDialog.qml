import QtQuick 2.4
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.2 as QuickControls
import Material 0.1
import Material.Extras 0.1
import Material.ListItems 0.1 as ListItem

Dialog {
    anchors.centerIn: parent
    hasActions: true

    onAccepted: {
        console.log('confirmed');
        close();
    }

    negativeButtonText: ""
    negativeButton.visible: false
    negativeButton.width: Units.dp(0)

    property string fileId: "default_id"
    property string filename: "File"
    property var owners: []
    property string date_created: "01/01/2000"
    property string date_last_modified: "01/01/2000"
    property string date_last_viewed_by_me: "01/01/2000"
    property string last_modifier: "Last modifier"

    View {
        id: view
        width: Math.max((driveInLine.width / 2), Units.dp(500))
        height: ((driveInLine.height / 2) + (Units.dp(32) * 2))

        ColumnLayout {
            id: column

            anchors {
                fill: parent
                topMargin: Units.dp(16)
                bottomMargin: Units.dp(16)
            }

            Label {
                text: filename
                style: "title"
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: Units.dp(16)
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Units.dp(8)
            }

            ListItem.Subtitled {
                text: "<b>Id</b>"
                subText: fileId
                action: Icon {
                    anchors.centerIn: parent
                    name: "notification/drive_eta"
                }
            }

            ListItem.Subtitled {
                text: "<b>Owners</b>"
                subText: owners.toString().replace(',', ', ')
                action: Icon {
                    anchors.centerIn: parent
                    name: "social/group"
                }
            }

            ListItem.Standard {
                text: '<b>Created :</b> ' + date_created
                action: Icon {
                    anchors.centerIn: parent
                    name: "editor/mode_edit"
                }
            }

            ListItem.Subtitled {
                text: '<b>Last modified :</b> ' + date_last_modified + ' by ' + last_modifier
                subText: {
                    /*var isLastModifier = true || false;
                    if (isLastModifier) {
                        return "You made this modification";
                    }*/

                    if (date_last_viewed_by_me === "01/01/1970") {
                        return "You've never seen this file";
                    }

                    var hasViewedModification = date_last_viewed_by_me >= date_last_modified;
                    if (hasViewedModification) {
                        return "You've seen this modification";
                    } else {
                        return "Last modification you've seen is on " + date_last_viewed_by_me;
                    }
                }

                action: Icon {
                    anchors.centerIn: parent
                    name: "notification/event_available"
                }
            }
        }
    }

    function openForFile(file) {
        fileId = file["id"];
        filename = file["title"];
        owners = file["ownerNames"];

        console.log('id :' + fileId);

        date_created = getNiceDateFromGDrive(file["createdDate"]);
        date_last_modified = getNiceDateFromGDrive(file["modifiedDate"]);

        if (file["lastViewedByMeDate"] !== undefined) {
            date_last_viewed_by_me = getNiceDateFromGDrive(file["lastViewedByMeDate"]);
        } else {
            date_last_viewed_by_me = "01/01/1970";
        }

        last_modifier = file["lastModifyingUserName"];

        open();
    }

    function getNiceDateFromGDrive(date) {
        var date_length = 10;   // "yyyy/mm/dd"

        var tmp = date.slice(0, date_length).split('-');
        var niceDate = tmp[2] + '/' + tmp[1] + '/' + tmp[0];

        return niceDate;
    }
}
