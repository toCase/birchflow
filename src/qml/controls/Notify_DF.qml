import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts

Popup {
    id: popup
    objectName: "myPopup"
    parent: Overlay.overlay

    property int typeNote: 1
    property string textNote: ""

    closePolicy: Popup.NoAutoClose
    x: 15
    y: 15
    z: 10
    width: 400
    height: 60
    modal: false
    dim: false

    padding: 0

    background: Rectangle {
        anchors.fill: parent
        radius: 5
        color: "transparent"
    }

    Rectangle {
        anchors.fill: parent

        radius: 5
        color: {
            if (typeNote === 1) {
                "#6AA84F"
            } else if (typeNote === 2) {
                "#F44336"
            } else {
                "#3D85C6"
            }
        }

        Label {
            anchors.fill: parent
            anchors.margins: 15

            text: textNote

            font.pixelSize: Qt.application.font.pixelSize * 1.2
            wrapMode: Text.WordWrap
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
        }
    }

    Timer {
        running: true
        repeat: false
        interval: {
            if (typeNote === 1) {
                3000
            } else if (typeNote === 2) {
                7000
            } else {
                5000
            }
        }
        onTriggered: popup.close()
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
    }

    Component.onCompleted: {
        open()
    }
}
