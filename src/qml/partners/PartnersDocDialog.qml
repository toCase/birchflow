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
    z:5

    modal: true
    title: qsTr("Document")

    property int doc_id: 0
    property int partner_id: 0
    property bool has_file: false

    property alias p_name: doc_name.text
    property alias p_note: doc_note.text
    property alias p_file: doc_file.text

    function saveRequest() {
        let card = {}
        card.id = root.doc_id
        card.partner_id = root.partner_id
        card.name = doc_name.text
        card.note = doc_note.text
        card.file = doc_file.text

        let res = modelPartnerDoc.save(card)
        if (res.r) root.close()
    }

    function updateFileRequest() {
        let card = {}
        card.id = root.doc_id
        card.file = doc_file.text
        let res = modelPartnerDoc.updateFile(card);

    }

    function deleteFileRequest() {
        root.has_file = false;
        doc_file.clear();
        updateFileRequest();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            Label {
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth

                text: qsTr("Title")
                verticalAlignment: Qt.AlignVCenter
            }

            TextField {
                id: doc_name
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            Label {
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth

                text: qsTr("Description")
                verticalAlignment: Qt.AlignVCenter
            }

            TextField {
                id: doc_note
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            visible: !root.has_file

            Label {
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth

                text: qsTr("File")
                verticalAlignment: Qt.AlignVCenter
            }

            TextField {
                id: doc_file
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5
                Layout.bottomMargin: 5
            }

            ToolButton {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40

                text: "..."
                onClicked: dia_file.open()
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            spacing: 10

            visible: root.has_file

            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth

                icon.source: "qrc:/qt/qml/BirchFlow/img/del_doc"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON

                flat: true

                text: qsTr("Delete file")
                onClicked: deleteFileRequest()

            }

            Item {
                Layout.fillWidth: true
            }

            Loader {
                id: iconLoader
                Layout.preferredHeight: 32
                Layout.preferredWidth: 32
                active: has_file && doc_file.text.length > 0
                sourceComponent: Image {
                    id: file_icon
                    source: "qrc:/qt/qml/BirchFlow/img/" + doc_file.text
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    cache: false
                }
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 120

                icon.source: "qrc:/qt/qml/BirchFlow/img/open"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON

                flat: true

                text: qsTr("Open")
                onClicked: modelPartnerDoc.viewDoc(root.doc_id)
            }


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
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Delete")
                onClicked: {
                    modelPartnerDoc.del(root.doc_id)
                    root.close();
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Save")
                onClicked:  root.saveRequest()
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Close")
                onClicked: root.close()
            }
        }
    }


    FileDialog_DF {
        id: dia_file
        onAccepted: {
            doc_file.text = modelPartnerDoc.toLocalFile(currentFile);
            if (root.doc_id > 0) {
                updateFileRequest();
            }
        }
    }


}
