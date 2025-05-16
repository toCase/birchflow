import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../controls"
import "../const.js" as Const
import DocFlow.models 1.0

Dialog {
    id: dia_doc
    z: 5

    modal: true

    signal setOpen(bool a, int type_id);

    // title: "Doc"

    property int doc_id: 0
    property int type_id: -1
    property bool has_file: false

    property alias doc_num: dia_num.text
    property alias doc_date: dia_date.df_date
    property alias doc_title: dia_title.text
    property alias desc: dia_desc.text
    property alias file: dia_file.text

    function saveRequest() {
        let card = {}
        card.id = dia_doc.doc_id
        card.type_id = dia_doc.type_id
        card.num = dia_num.text
        card.doc_date = dia_date.df_date
        card.title = dia_title.text
        card.description = dia_desc.text
        card.file = dia_file.text

        let res = modelContractDocs.saveDoc(card);
        if (res.r) {
            dia_doc.close()
            dia_doc.setOpen(true, dia_doc.type_id)
        }
    }

    function deleteRequest() {
        let res = modelContractDocs.deleteDoc(dia_doc.type_id, dia_doc.doc_id);
        if (res) {
            dia_doc.close()
            dia_doc.setOpen(true, dia_doc.type_id)
        }
    }

    function updateFileRequest(){
        let card = {}
        card.id = dia_doc.doc_id
        card.type_id = dia_doc.type_id
        card.file = dia_file.text
        let res = modelContractDocs.updateFile(card)
    }

    function deleteFileRequest(){
        dia_doc.has_file = false
        dia_file.clear();
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
            spacing: 10
            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                text: "Number: "
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }
            TextField {
                id: dia_num
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                Layout.topMargin: 5
            }
            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                text: "Date:"
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }
            DateEdit_DF {
                id: dia_date
                Layout.preferredWidth: 150
                Layout.fillHeight: true
            }
            Item {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            spacing: 10

            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                text: "Title: "

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }

            TextField {
                id: dia_title
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            spacing: 10

            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                text: "Description: "

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }

            TextField {
                id: dia_desc
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            visible: !dia_doc.has_file
            spacing: 10
            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                text: "File: "

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }

            TextField {
                id: dia_file
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5
            }

            ToolButton {
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40

                text: "..."
                onClicked: dialog_file.open()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            visible: dia_doc.has_file
            spacing: 10
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 120

                icon.source: "qrc:/qt/qml/DocFlow/img/del_doc"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON

                flat: true

                text: "DELETE FILE"
                onClicked: deleteFileRequest()

            }

            Item {
                Layout.fillWidth: true
            }

            Loader {
                id: iconLoader
                Layout.preferredHeight: 32
                Layout.preferredWidth: 32
                active: has_file && dia_file.text.length > 0
                sourceComponent: Image {
                    id: file_icon
                    source: "qrc:/qt/qml/DocFlow/img/" + dia_file.text
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    cache: false
                }
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 120
                // Layout.topMargin: -5
                // Layout.bottomMargin: -5

                icon.source: "qrc:/qt/qml/DocFlow/img/open"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON

                flat: true

                text: "OPEN"
                onClicked: modelContractDocs.viewDoc(doc_form.type_id, doc_form.doc_id)
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
                id: but_del
                visible: dia_doc.doc_id === 0 ? false : true
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Delete")
                onClicked: dia_doc.deleteRequest()
            }
            Item {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Save")
                onClicked:  {
                    dia_doc.saveRequest()
                }
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Close")
                onClicked: {

                    dia_doc.close()
                    dia_doc.setOpen(false, -1)
                }
            }
        }
    }

    FileDialog {
        id: dialog_file
        currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.OpenFile
        nameFilters: [
            "All supported files (*.txt *.md *.nfo *.asc *.log *.ini *.doc *.docx *.odt *.rtf
                                    *.pages *.wps *.sxw *.pdf *.ps *.djvu *.tex *.rtfd *.xml
                *.json *.yaml *.yml *.csv *.xls *.xlsx *.ppt *.pptx *.epub *.fb2 *.msg *.eml)",
            "Text (*.txt *.md *.nfo *.asc *.log *.ini)",
            "Office (*.doc *.docx *.odt *.rtf *.pages *.wps *.sxw)",
            "Formatted (*.pdf *.ps *.djvu *.tex *.rtfd)",
            "Structured (*.xml *.json *.yaml *.yml *.csv)",
            "Tables/Presentations (*.xls *.xlsx *.ppt *.pptx)",
            "E-books/Other (*.epub *.fb2 *.msg *.eml)"
        ]
        onAccepted: {
            dia_file.text = modelContractDocs.toLocalFile(selectedFile);
            if (dia_doc.doc_id > 0) {
                updateFileRequest();
            }
        }
    }

}
