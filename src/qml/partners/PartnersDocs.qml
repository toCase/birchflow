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
            // partner_doc.doc_id = idx
            // let card = modelPartnerDoc.getCard(idx);
            // form_name.text = card.name
            // form_file.text = card.file
            // form_note.text = card.note
            // form_created.text = "Date at: " + card.created

            // row_file.visible = false
            // but_open.visible = true

            // dia_form.open();
            // console.log(partner_doc.doc_id);

            // ///

            let card = modelPartnerDoc.getCard(idx);
            doc_dialog.doc_id = idx;
            doc_dialog.partner_id = partner_doc.partner_id;
            doc_dialog.p_name = card.name;
            doc_dialog.p_note = card.note;
            doc_dialog.p_file = card.file;
            doc_dialog.has_file = card.file === "" ? false : true;
            doc_dialog.open();
        }

        function add() {
            doc_dialog.doc_id = 0
            doc_dialog.partner_id = partner_doc.partner_id
            doc_dialog.p_name = ""
            doc_dialog.p_note = ""
            doc_dialog.p_file = ""
            doc_dialog.has_file = false

            doc_dialog.open()
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
                placeholderText: qsTr("filter by title, description...")
                onTextChanged: modelProxyPartnerDoc.setFilter(text)
            }
            Item {
                Layout.fillWidth: true
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 80

                text: qsTr("ADD")
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
                        row.color = containsMouse ? Const.CLR_YELLOW : Const.CLR_ROW
                    }
                    onClicked: internal.open(d_id)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 10

                    Loader {
                        Layout.preferredHeight: 36
                        Layout.preferredWidth: 36
                        Layout.alignment: Layout.Center
                        active: row.d_file.length > 0

                        sourceComponent: Image {
                            source: "qrc:/qt/qml/BirchFlow/img/" + d_file
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                        }
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

                        icon.source: "qrc:/qt/qml/BirchFlow/img/open"
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

                        icon.source: "qrc:/qt/qml/BirchFlow/img/trash"
                        icon.width: 16
                        icon.height: 16
                        icon.color: Const.CLR_RED

                        onClicked: {
                            dia_del.m_id = d_id
                            dia_del.open()
                        }
                    }
                }
            }
        }
    }

    PartnersDocDialog {
        id: doc_dialog
        x: partner_doc.width * .2
        y: partner_doc.width * .05
        width: partner_doc.width - (2 * (partner_doc.width * .2))
        height: 305
    }

    AcceptDeleteDialog {
        id: dia_del
        x: partner_doc.width * .2
        y: partner_doc.width * .05
        onAccepted: modelPartnerDoc.del(dia_del.m_id)
    }

}
