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
        width: ((parent.width / 6) * 1)
        height: ((parent.height / 6) * 1)
        anchors.centerIn: parent

        dashThickness: normal_thickness
        visible: !(parent.on)
        color: normal_color

        property var normal_thickness: Units.dp(7)
        property var normal_color: Palette.colors["orange"]["500"]

        property var hovered_thickness: Units.dp(12)
        property var hovered_color: Palette.colors["orange"]["900"]

        states: [
            State {
                name: "hovered"
                PropertyChanges { target: progressCircle; color: hovered_color; dashThickness: hovered_thickness }
            },
            State {
                name: "normal"
                PropertyChanges { target: progressCircle; color: normal_color; dashThickness:  normal_thickness }
            }
        ]

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

    MouseArea {
        id: mouseArea
        width: parent.width / 1.66
        height: parent.height / 1.66
        anchors.centerIn: parent

        hoverEnabled: true
        onEntered: {
            console.log('mouseEntered');
            progressCircle.state = "hovered";
        }
        onExited: {
            console.log('mouseExited');
            progressCircle.state = "normal";
        }
    }
}
