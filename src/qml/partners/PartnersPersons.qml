import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../const.js" as Const
import "../controls"

Item {

    id: partner_person

    property int partner_id: -1
    property int person_id: -1

    function load() {
        modelPartnerPerson.setPartnerID(partner_id)
    }

    QtObject {
        id: internal

        function open(idx) {
            partner_person.person_id = idx
            let card = modelPartnerPerson.getCard(idx);
            form_name.text = card.full_name
            form_position.text = card.position
            form_phone.text = card.phone
            form_mail.text = card.mail
            form_messenger.text = card.messenger

            dia_form.open();
        }

        function add() {
            partner_person.person_id = 0
            form_name.clear()
            form_position.clear()
            form_phone.clear()
            form_mail.clear()
            form_messenger.clear()

            dia_form.open();
        }

        function save(){
            let card = {}
            card.id = partner_person.person_id
            card.partner_id = partner_person.partner_id
            card.full_name = form_name.text
            card.position = form_position.text
            card.phone = form_phone.text
            card.mail = form_mail.text
            card.messenger = form_messenger.text

            let res = modelPartnerPerson.save(card)
            if (!res.r) dia_form.open()
        }

        function del(idx) {
            let res = modelPartnerPerson.del(idx)
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
                Layout.preferredWidth: partner_person.width / 2
                Layout.topMargin: 5
                Layout.bottomMargin: 5
                placeholderText: qsTr("filter by name, address...")
                onTextChanged: modelProxyPartnerPerson.setFilter(text)
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
            model: modelProxyPartnerPerson
            spacing: 5
            clip: true

            delegate: Rectangle {

                id: row
                width: pt_table.width
                height: 70
                color: Const.CLR_ROW
                radius: 5

                required property int p_id;
                required property string p_name;
                required property string p_pos;
                required property string p_phone;
                required property string p_mail;
                required property string p_messenger;
                required property int index;

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        row.color = containsMouse ? Const.CLR_YELLOW : Const.CLR_ROW
                    }
                    onClicked: internal.open(p_id)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 5

                    Label {
                        Layout.preferredWidth: 150
                        Layout.fillHeight: true

                        text: p_pos
                        font.pixelSize: Qt.application.font.pixelSize * .8
                        font.bold: true
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        text: p_name
                        font.pixelSize: Qt.application.font.pixelSize * 1.2
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }

                    Column {
                        Layout.preferredWidth: 200
                        Layout.fillHeight: true

                        Label {
                            text: p_phone
                            font.pixelSize: Qt.application.font.pixelSize * .9
                            horizontalAlignment: Qt.AlignLeft
                            verticalAlignment: Qt.AlignVCenter
                        }

                        Label {
                            text: p_mail
                            font.pixelSize: Qt.application.font.pixelSize * .9
                            horizontalAlignment: Qt.AlignLeft
                            verticalAlignment: Qt.AlignVCenter
                        }
                    }

                    Label {
                        Layout.preferredWidth: 300
                        Layout.fillHeight: true

                        text: p_messenger
                        wrapMode: Text.WordWrap
                        font.pixelSize: Qt.application.font.pixelSize * .9
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }

                    ToolButton {
                        Layout.preferredHeight: 44
                        Layout.preferredWidth: 44

                        icon.source: "qrc:/qt/qml/BirchFlow/img/trash"
                        icon.width: 16
                        icon.height: 16
                        icon.color: Const.CLR_RED

                        onClicked: {
                            dia_del.m_id = p_id
                            dia_del.open()
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: dia_form
        x: partner_person.width * .2
        y: partner_person.width * .05
        width: partner_person.width - (2 * (partner_person.width * .2))
        height: 350
        title: qsTr("Contact person")

        contentItem: ColumnLayout {
            spacing: 8

            TextField {
                id: form_name
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                placeholderText: qsTr("Full name")
            }

            TextField {
                id: form_position
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                placeholderText: qsTr("Position")
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                spacing: 8

                TextField {
                    id: form_phone
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    placeholderText: qsTr("Phone number")
                }

                TextField {
                    id: form_mail
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40

                    placeholderText: qsTr("E-mail address")
                }
            }

            TextField {
                id: form_messenger
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                placeholderText: qsTr("Messengers")
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

    AcceptDeleteDialog {
        id: dia_del
        x: partner_person.width * .2
        y: partner_person.width * .05
        onAccepted: internal.del(m_id)
    }
}
