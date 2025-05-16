import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../const.js" as Const
import "../controls"

Item {

    id: partner_form_edit

    property int partner_id: 0

    function load(idx) {
        let card = modelPartners.getCard(idx)
        cfe_code.text = card.code
        cfe_sname.text = card.name
        cfe_fname.text = card.full_name
        cfe_oaddress.text = card.off_address
        cfe_raddress.text = card.real_address
        cfe_url.text = card.url
        cfe_note.text = card.note
        // cfe_created.text = card.created
    }

    QtObject {
        id: internal

        function save(){
            let card = {}
            card.id = partner_form_edit.partner_id
            card.code = cfe_code.text
            card.name = cfe_sname.text
            card.full_name = cfe_fname.text
            card.off_address = cfe_oaddress.text
            card.real_address = cfe_raddress.text
            card.url = cfe_url.text
            card.note = cfe_note.text

            let res = modelPartners.save(card)
        }

        function del() {

        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: parent.width * .2
        anchors.rightMargin: parent.width * .2

        spacing: 30

        Label {
            Layout.fillWidth: true
            Layout.preferredHeight: 60

            text: "Partner details: "
            font.pixelSize: Qt.application.font.pixelSize * 1.5
            font.bold: true
            font.italic: true
            color: Const.CLR_YELLOW
            verticalAlignment: Qt.AlignVCenter
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 2

            color: Const.CLR_YELLOW
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            spacing: 40

            TextField {
                id: cfe_code
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                placeholderText: "Reg Code: "

            }

            TextField {
                id: cfe_sname
                Layout.fillWidth: true
                Layout.fillHeight: true
                placeholderText: "Short Name: "

            }
        }

        TextField {
            id: cfe_fname
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: "Full Name: "

        }

        TextField {
            id: cfe_oaddress
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: "Official address: "

        }

        TextField {
            id: cfe_raddress
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: "Real address: "

        }

        TextField {
            id: cfe_url
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: "URL: "

        }

        TextField {
            id: cfe_note
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            placeholderText: "Note: "

        }
        Label {
            id: cfe_created
            Layout.preferredHeight: implicitHeight
            Layout.fillWidth: true

        }



        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            spacing: 5
            Button_DF {
                Layout.preferredWidth: 100
                Layout.fillHeight: true

                text: "Delete"


                onClicked: internal.del()
            }

            Item {
                Layout.fillWidth: true
            }
            Button_DF {
                Layout.preferredWidth: 100
                Layout.fillHeight: true

                text: "Save"

                onClicked: internal.save()
            }

        }
        Item {
            Layout.fillHeight: true
            Layout.verticalStretchFactor: 1
        }
    }

}
