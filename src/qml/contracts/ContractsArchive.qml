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

    title: "Document Archive Summary"

    property string markdownText: ""
    property int contract_id: 0

    contentItem: ScrollView {
        ScrollBar.horizontal.interactive: true
        ScrollBar.vertical.interactive: true
        TextArea {
            id: ta
            readOnly: true
            wrapMode: TextEdit.WordWrap
            textFormat: TextEdit.MarkdownText
            text: markdownText
        }
    }
    footer: Item {
        width: parent.width
        height: 70
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 30
            anchors.rightMargin: 30
            anchors.topMargin: 12
            anchors.bottomMargin: 12
            spacing: 5
            Button_DF{
                visible: root.doc_id === 0 ? false : true
                Layout.fillHeight: true
                Layout.preferredWidth: 140
                text: qsTr("Delete contract")
                onClicked: del_dialog.open()
            }
            Item {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
            }
            Button_DF{
                visible: root.doc_id === 0 ? false : true
                Layout.fillHeight: true
                Layout.preferredWidth: 140
                text: qsTr("Copy Archive")
                onClicked: dir_dialog.open()
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Close")
                onClicked: {
                    root.close()
                }
            }
        }
    }

    FolderDialog {
        id: dir_dialog
        currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        onAccepted: {
            let dir = appSetting.toLocalDir(selectedFolder)
            modelContracts.requestSaveArchive(root.contract_id, dir);
        }
    }

    Dialog {
        id: del_dialog
        width: 400
        height: 150
        title: qsTr("Delete archived contract")

        Label {
            text: qsTr("Are you sure?")
        }
        footer: Item {
            width: parent.width
            height: 70
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 30
                anchors.rightMargin: 30
                anchors.topMargin: 12
                anchors.bottomMargin: 12
                spacing: 5
                Button_DF{
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                    text: qsTr("Delete")
                    onClicked:{
                        modelContracts.del(root.contract_id)
                        del_dialog.close()
                        root.close()
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.horizontalStretchFactor: 1
                }
                Button_DF {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                    text: qsTr("Cancel")
                    onClicked: {
                        del_dialog.close()
                    }
                }
            }
        }
    }


}
