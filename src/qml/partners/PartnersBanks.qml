import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../const.js" as Const
import "../controls"

Item {

    id: partners_bank

    property int partner_id: -1
    property int bank_id: -1

    function load() {
        modelPartnerBank.setPartnerID(partner_id)
    }

    QtObject {
        id: internal

        function open(idx) {
            partners_bank.bank_id = idx
            let card = modelPartnerBank.getCard(idx);
            bank_name.text = card.bank_name
            bank_code.text = card.bank_code
            bank_account.text = card.bank_account

            bank_form.open();
        }

        function add() {
            partners_bank.bank_id = 0
            bank_name.clear()
            bank_code.clear()
            bank_account.clear()

            bank_form.open();
        }

        function save(){
            let card = {}
            card.id = partners_bank.bank_id
            card.partner_id = partners_bank.partner_id
            card.bank_name = bank_name.text
            card.bank_code = bank_code.text
            card.bank_account = bank_account.text

            let res = modelPartnerBank.save(card)
            if (!res.r) bank_form.open()
        }

        function del(idx) {
            let res = modelPartnerBank.del(idx)
            if (res.r) bank_del.close()
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
                Layout.preferredWidth: partners_bank.width / 2
                Layout.topMargin: 5
                Layout.bottomMargin: 5
                placeholderText: qsTr("filter by title, account, code...")
                onTextChanged: modelProxyPartnerBank.setFilter(text)
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
            id: bt_table
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.verticalStretchFactor: 1
            Layout.leftMargin: 60
            Layout.rightMargin: 60
            model: modelProxyPartnerBank
            spacing: 5
            clip: true

            delegate: Rectangle {

                id: row
                width: bt_table.width
                height: 70
                color: Const.CLR_ROW
                radius: 5

                required property int b_id;
                required property string b_name;
                required property string b_code;
                required property string b_account;
                required property int index;

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        row.color = containsMouse ? Const.CLR_YELLOW : Const.CLR_ROW
                    }
                    onClicked: internal.open(b_id)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 10

                    Label {
                        Layout.preferredWidth: 150
                        Layout.fillHeight: true

                        text: b_code
                        font.pixelSize: Qt.application.font.pixelSize * .9
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        text: b_name
                        font.pixelSize: Qt.application.font.pixelSize * 1.2
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }

                    Label {
                        Layout.preferredWidth: 350
                        Layout.fillHeight: true

                        text: b_account
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
                            dia_del.m_id = b_id
                            dia_del.open()
                        }
                    }
                }
            }
        }
    }

    Dialog {
        id: bank_form
        x: partners_bank.width * .2
        y: partners_bank.width * .05
        width: partners_bank.width - (2 * (partners_bank.width * .2))
        height: 330
        title: qsTr("Bank")
        contentItem: ColumnLayout {
            spacing: 8
            TextField {
                id: bank_name
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                placeholderText: qsTr("Bank title")
            }

            TextField {
                id: bank_code
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                placeholderText: "SWIFT/BIC"
            }

            TextField {
                id: bank_account
                Layout.fillWidth: true
                Layout.preferredHeight: 40

                placeholderText: "IBAN"
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
                        if (bank_name.text.trim().length === 0) {
                            bank_name.focus = true
                        } else {
                            internal.save()
                            bank_form.accept()
                        }
                    }
                }
                Button_DF {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                    text: qsTr("Close")
                    onClicked: bank_form.close()
                }
            }
        }
    }

    AcceptDeleteDialog {
        id: dia_del
        x: partners_bank.width * .2
        y: partners_bank.width * .05
        onAccepted: internal.del(dia_del.m_id)

    }
}
