import QtQuick 2.0
import QtGraphicalEffects 1.0
import Material 0.1

Rectangle {
    width: (parent.width + parent.anchors.margins * 2)
    height: (parent.height + parent.anchors.margins * 2)
    anchors.centerIn: parent
    visible: true

    property string default_message: "Loading ..."

    RadialGradient {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.3, 0.3, 0.3, 0.3) }
            GradientStop { position: 0.9; color: Qt.rgba(0.3, 0.3, 0.3, 0.05) }
        }
    }

    ProgressCircle {
        id: progressCircle
        anchors.centerIn: parent
        width: ((parent.width / 6) * 1)
        height: ((parent.height / 6) * 1)
        dashThickness: Units.dp(7)
        visible: !(parent.on)

        color: Palette.colors["orange"]["500"]

        MouseArea {
            id: mouseArea
            hoverEnabled: true
            anchors.fill: parent
        }

        states: State {
            name: "hovered"; when: mouseArea.pressed
            PropertyChanges { target: progressCircle; color: Palette.colors["orange"]["900"]; dashThickness: Units.dp(12) }
        }

        transitions: Transition {
            PropertyAnimation { property: "dashThickness"; easing.type: Easing.InOutQuad }
            ColorAnimation { duration: 200 }
        }

        onVisibleChanged: {
            if (visible === true) {
                if (message !== undefined)
                    snackbar.open(message);
                else
                    snackbar.open(default_message);
            } else {
                snackbar.opened = true;
            }
        }
    }
}
