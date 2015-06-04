import QtQuick 2.4
import Material 0.1

Item {
    anchors.fill: parent
    property alias loader: loadSource

    property string error_page: "LoaderErrorPage"
    property string previous_src: ""
    property string toLoad: ""
    property string source: ""

    onToLoadChanged: {
        actualizeSource(toLoad);
    }

    function actualizeSource(new_source) {
        if (new_source !== error_page) {
            previous_src = source;
        }
        source = new_source;
    }

    Loader {
        id: loadSource
        anchors.fill: parent
        asynchronous: true
        visible: status === Loader.Ready
        source: Qt.resolvedUrl("%.qml").arg(getSource().replace(" ", ""));

        function getSource() {
            return parent.source;
        }
    }

    ProgressCircle {
        anchors.centerIn: parent
        visible: loadSource.status === Loader.Loading
    }

    Item {
        id: error;
        anchors.fill: parent;
        visible: ((loadSource.status === Loader.Error) || (loadSource.status === Loader.Null))

        Label {
            anchors.centerIn: parent
            style: "display1"
            text: "Can't open <b>" + loadSource.getSource() + "</b>"
        }
    }
}
