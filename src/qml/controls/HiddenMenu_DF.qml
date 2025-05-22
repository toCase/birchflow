import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../const.js" as Const
import "../controls"

Item {
    id: root
    width: 20
    height: 140

    signal changeExpand(bool e)
    signal makeReport()
    signal makeZip()

    property bool isOpen : root.width === 70 ? true : false

    property bool expanded: false

    function expand() {
        root.expanded = !root.expanded
        appSetting.setValue("doc_expand", root.expanded)
        root.changeExpand(root.expanded)
    }

    Behavior on width {
        NumberAnimation {
            duration: 350
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        id: menu
        x: 0
        width: root.width - 20
        height: root.height
        color: Const.CLR_ROW

        bottomRightRadius: 5

        Column {
            visible: root.isOpen
            anchors.fill: parent
            spacing: 2
            padding: 2

            Button_DF {
                width: 44;
                height: 44;
                flat: true

                icon.source: root.expanded ? "qrc:/qt/qml/BirchFlow/img/exp-up" : "qrc:/qt/qml/BirchFlow/img/exp-down"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON
                onClicked: root.expand()
            }
            Button_DF {
                width: 44;
                height: 44;
                flat: true

                icon.source: "qrc:/qt/qml/BirchFlow/img/report"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON
                onClicked: root.makeReport()
            }
            Button_DF {
                width: 44;
                height: 44;
                flat: true

                icon.source: "qrc:/qt/qml/BirchFlow/img/zip-file"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON
                onClicked: root.makeZip()
            }
        }
    }

    Rectangle {
        id: toggle
        x: root.width - 20
        width: 20
        height: 30
        color: Const.CLR_YELLOW

        topRightRadius: 5
        bottomRightRadius: 5

        Label {
            anchors.centerIn: parent
            text: (root.width === 70) ? "<" : ">"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.width = (root.width === 70) ? 20 : 70
                if (root.width === 20) hideTimer.start()
                if (root.width === 70) hideTimer.stop()

            }
        }
    }

    Component.onCompleted: {
        root.expanded = appSetting.getValue("doc_expand", false)
    }

    Timer {
        id: hideTimer
        repeat: false
        interval: 10000
        onTriggered: {
            root.width = (root.width === 70) ? 20 : 70
        }
    }
}
