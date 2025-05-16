import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../const.js" as Const
import "../controls"
import DocFlow.models 1.0

Item {
    id: contract_list

    signal open(int contract_id)

    QtObject {
        id: internal
        function add() {
            dia_form.contract_id = 0;

            dia_form.c_type = 0
            dia_form.c_num = ""
            dia_form.c_date = new Date().toLocaleString(Qt.locale(), String(appSetting.getValue("dateFormat")));
            dia_form.valid_from = new Date().toLocaleString(Qt.locale(), String(appSetting.getValue("dateFormat")));
            dia_form.valid_to = new Date().toLocaleString(Qt.locale(), String(appSetting.getValue("dateFormat")));
            dia_form.partner = -1
            dia_form.amount = ""
            dia_form.currency = Number(appSetting.getValue("currency"))
            dia_form.desc = ""
            dia_form.file = ""
            dia_form.is_file = false

            dia_form.open();
        }

        function edit(idx) {
            let card = modelContracts.getCard(idx)

            dia_form.contract_id = card.id;
            dia_form.c_type = TypeModel.getRow(card.type_id)
            dia_form.c_num = card.num
            dia_form.c_date = card.c_date
            dia_form.valid_from = card.valid_from
            dia_form.valid_to = card.valid_to
            dia_form.partner = modelPartnerCombo.getRow(card.partner_id)
            dia_form.amount = card.amount
            dia_form.currency = modelCurrency.getRow(card.currency_id)
            dia_form.desc = card.description
            dia_form.file = card.file
            dia_form.status = StatusModel.getRow(card.status)

            dia_form.is_file = card.file === "" ? false : true
            dia_form.open();
        }

        function view_arch(idx) {
            let md = modelContracts.getInfo(idx)
            dia_archive.markdownText = md
            dia_archive.contract_id = idx
            dia_archive.open();
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
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 80
                text: "FILTER"
                onClicked: dia_filter.open();
            }

            TextField {
                id: cm_filter
                Layout.fillHeight: true
                Layout.preferredWidth: contract_list.width / 2
                Layout.topMargin: 5
                Layout.bottomMargin: 5

                placeholderText: "filter..."
                onTextEdited: modelProxyContracts.setQuickFilter(text)
            }
            Item {
                Layout.fillWidth: true
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 80
                text: "ADD"
                onClicked: internal.add();
            }
        }



        ListView {
            id: table
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.verticalStretchFactor: 1
            Layout.leftMargin: 60
            Layout.rightMargin: 60

            model: modelProxyContracts
            spacing: 5
            clip: true

            delegate: Rectangle {

                id: row
                width: table.width
                height: 75
                color: Const.CLR_ROW
                radius: 5

                required property int c_id;
                required property string c_num;
                required property string c_date;
                required property string partner;
                required property string valid_from;
                required property string valid_to;
                required property string amount;
                required property string currency;
                required property int status;
                required property int c_type;
                required property string c_paid
                required property int index;

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        row.color = containsMouse ? "#4b5159" : Const.CLR_ROW
                    }
                    onClicked: {
                        if (row.status === 4) {
                            internal.view_arch(c_id)
                        } else {
                            contract_list.open(c_id)
                        }
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 15

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 3
                        color: {
                            if (c_type === 1) {
                                Const.CLR_GREEN
                            } else if (c_type === 2) {
                                Const.CLR_ORANGE
                            }
                        }
                        radius: 3
                    }

                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 70
                        text: row.c_num                        
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9

                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 60
                        text: row.c_date
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.fillWidth:  true
                        text: row.partner
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 1.1
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 200
                        text: row.valid_from + " - " + row.valid_to
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        text: row.amount + " " + row.currency
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 80
                        text: row.c_paid
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        color:  {
                            if (row.status === 1) {
                                Const.CLR_GREEN
                            } else if (row.status === 2) {
                                Const.CLR_RED
                            } else if (row.status === 3) {
                                Const.CLR_ORANGE
                            } else if (row.status === 4) {
                                Const.CLR_YELLOW
                            }
                        }
                        text: {
                            if (row.status === 1) {
                                qsTr("ACTIVE")
                            } else if (row.status === 2) {
                                qsTr("ABORTED")
                            } else if (row.status === 3) {
                                qsTr("COMPLETED")
                            } else if (row.status === 4) {
                                qsTr("ARCHIVED")
                            }
                        }
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                        font.bold: true
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter

                    }

                    ToolButton {
                        Layout.preferredHeight: 44
                        Layout.preferredWidth: 44
                        enabled: row.status !== 4
                        icon.source: "qrc:/qt/qml/DocFlow/img/edit"
                        icon.width: 16
                        icon.height: 16
                        icon.color: Const.CLR_ICON
                        onClicked: internal.edit(c_id)
                    }
                }
            }
        }
    }

    ContractsForm {
        id: dia_form
        x: contract_list.width * .15
        y: contract_list.width * .05
        width: contract_list.width - (2 * (contract_list.width * .15))
        height: 460

    }

    ContractsArchive {
        id: dia_archive
        x: contract_list.width * .15
        y: contract_list.width * .05
        width: contract_list.width - (2 * (contract_list.width * .15))
        height: contract_list.height - (2 * (contract_list.height * .05))

    }

    ContractsListFilter {
        id: dia_filter
        x: contract_list.width * .15
        y: contract_list.width * .05
        width: contract_list.width - (2 * (contract_list.width * .15))
        height: 300
    }

}
