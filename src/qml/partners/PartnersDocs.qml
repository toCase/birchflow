import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../const.js" as Const
import "../controls"

Item {

    id: partner_doc

    property int partner_id: -1
    property int doc_id: -1

    function load() {
        modelPartnerDoc.setPartnerID(partner_id)
    }

    QtObject {
        id: internal

        function open(idx) {
            partner_doc.doc_id = idx
            let card = modelPartnerDoc.getCard(idx);
            form_name.text = card.name
            form_file.text = card.file
            form_note.text = card.note
            form_created.text = "Date at: " + card.created

            row_file.visible = false
            but_open.visible = true

            dia_form.open();
            console.log(partner_doc.doc_id);
        }

        function add() {
            partner_doc.doc_id = 0
            form_name.clear()
            form_file.clear()
            form_note.clear()
            form_created.text = ""

            row_file.visible = true
            but_open.visible = false

            dia_form.open();
        }

        function save(){

            let card = {}
            card.id = partner_doc.doc_id
            card.partner_id = partner_doc.partner_id
            card.name = form_name.text
            card.file = form_file.text
            card.note = form_note.text

            let res = modelPartnerDoc.save(card)
            if (!res.r) dia_form.open()

        }

        function del(idx) {
            let res = modelPartnerDoc.del(idx)
            if (res.r) dia_del.close()
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.leftMargin: 60
            Layout.rightMargin: 60

            TextField {
                id: bt_filter
                Layout.fillHeight: true
                Layout.preferredWidth: partner_doc.width / 2
                Layout.topMargin: 5
                Layout.bottomMargin: 5
                placeholderText: "filter..."
                onTextChanged: modelProxyPartnerDoc.setFilter(text)
            }
            Item {
                Layout.fillWidth: true
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 80

                text: "ADD"
                onClicked: internal.add()
            }

        }

        ListView {
            id: pt_table
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.verticalStretchFactor: 1
            Layout.leftMargin: 60
            Layout.rightMargin: 60
            model: modelProxyPartnerDoc
            spacing: 5
            clip: true

            delegate: Rectangle {

                id: row
                width: pt_table.width
                height: 70
                color: Const.CLR_ROW
                radius: 5

                required property int d_id;
                required property string d_name;
                required property string d_file;
                required property string d_note;
                required property int index;

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        row.color = containsMouse ? "#4b5159" : Const.CLR_ROW
                    }
                    onClicked: internal.open(d_id)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 10

                    Image {
                        Layout.preferredHeight: 42
                        Layout.preferredWidth: 42

                        source: "qrc:/qt/qml/DocFlow/img/" + d_file
                        fillMode: Image.PreserveAspectFit
                        mipmap: true
                    }

                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        text: d_name
                        font.pixelSize: Qt.application.font.pixelSize * 1.2
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }

                    Label {
                        Layout.preferredWidth: 400
                        Layout.fillHeight: true

                        text: d_note
                        font.pixelSize: Qt.application.font.pixelSize * .9
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }

                    ToolButton {
                        Layout.preferredHeight: 44
                        Layout.preferredWidth: 44

                        icon.source: "qrc:/qt/qml/DocFlow/img/open"
                        icon.width: 16
                        icon.height: 16
                        icon.color: Const.CLR_ICON

                        onClicked: {
                            modelPartnerDoc.viewDoc(d_id)
                        }
                    }

                    ToolButton {
                        Layout.preferredHeight: 44
                        Layout.preferredWidth: 44

                        icon.source: "qrc:/qt/qml/DocFlow/img/trash"
                        icon.width: 16
                        icon.height: 16
                        icon.color: Const.CLR_RED

                        onClicked: {
                            dia_del.item_id = d_id
                            dia_del.open()
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: dia_form
        x: partner_doc.width * .2
        y: partner_doc.width * .05
        width: partner_doc.width - (2 * (partner_doc.width * .2))
        height: 320
        title: "Document"
        contentItem: ColumnLayout {
            spacing: 8

            TextField {
                id: form_name
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                placeholderText: "Name document"
            }


            RowLayout {
                id: row_file

                TextField {
                    id: form_file
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    placeholderText: "File..."
                }

                ToolButton {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40

                    text: "..."
                    onClicked: dia_file.open()
                }
            }

            TextField {
                id: form_note
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                placeholderText: "Note..."
            }


            Label {
                id: form_created

                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight

                font.pixelSize: Qt.application.font.pixelSize * .8
                font.italic: true
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
                    id: but_open
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                    text: qsTr("Open file")
                    onClicked: modelPartnerDoc.viewDoc(partner_doc.doc_id)
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
                        if (form_name.text.trim().length === 0) {
                            form_name.focus = true
                        } else {
                            internal.save()
                            dia_form.accept()
                        }
                    }
                }
                Button_DF {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                    text: qsTr("Close")
                    onClicked: dia_form.close()
                }
            }
        }
    }

    Dialog {
        id: dia_del
        x: partner_doc.width * .2
        y: partner_doc.width * .05
        width: partner_doc.width - (2 * (partner_doc.width * .2))
        height: 150
        title: "Delete"
        standardButtons: Dialog.Ok | Dialog.Cancel
        property int item_id: 0
        contentItem: Label {
            text: "Are you sure?"
        }
        onAccepted: internal.del(item_id)
    }

    FileDialog {
        id: dia_file
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
        onAccepted: form_file.text = modelPartnerDoc.toLocalFile(selectedFile);
    }
}
