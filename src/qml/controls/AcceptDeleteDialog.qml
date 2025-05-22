import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../controls"
import "../const.js" as Const
import DocFlow.models 1.0

Dialog {
    id: root
    z: 5
    modal: true
    title: "Delete"

    property int m_id: 0

    width: 600
    height: 150

    contentItem: Label {
        text: qsTr("Are you sure? The data you entered will be deleted permanently!")
    }

    footer: Item {
        width: parent.width
        height: 60
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            anchors.topMargin: 8
            anchors.bottomMargin: 8
            spacing: 5
            Button_DF{
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Delete")
                onClicked: root.accept()
            }
            Item {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Cancel")
                onClicked: root.close()
            }
        }
    }

}
