import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "controls"
import "dash"
import "const.js" as Const
import DocFlow.models 1.0

Item {
    id: root

    function load() {
        let data = dashManager.dashTopData();
        dash_partner.title = qsTr("Partners")
        dash_partner.main_value = data.partners_count
        dash_partner.add_value = data.partner_new === 0 ? "" : "+" + String(data.partner_new) + qsTr(" new partner")
        dash_partner.clr_title = Const.CLR_GREEN
        dash_partner.icon_title = "qrc:/qt/qml/BirchFlow/img/partner"

        dash_contract.title = qsTr("Contracts")
        dash_contract.main_value = data.contracts_count
        dash_contract.add_value = data.contract_new === 0 ? "" : "+" + String(data.contract_new) + qsTr(" new contracts")
        dash_contract.clr_title = Const.CLR_YELLOW
        dash_contract.icon_title = "qrc:/qt/qml/BirchFlow/img/document"

        dash_docs.title = qsTr("Documents")
        dash_docs.main_value = data.doc_count
        dash_docs.add_value = data.pay_count === 0 ? qsTr("no payment documents") : qsTr("payment documents - ") + String(data.pay_doc) + "%"
        dash_docs.clr_title = Const.CLR_ORANGE
        dash_docs.icon_title = "qrc:/qt/qml/BirchFlow/img/folder"

        dash_file.title = qsTr("Files")
        dash_file.main_value = data.file_fail
        dash_file.add_value = data.file_fail === 0 ? qsTr("no missing files") : qsTr("please, add missing files");
        dash_file.clr_title = data.file_fail === 0 ? Const.CLR_GREEN : Const.CLR_RED
        dash_file.icon_title = data.file_fail === 0 ? "qrc:/qt/qml/BirchFlow/img/icon-ok" : "qrc:/qt/qml/BirchFlow/img/exclamation"

        dash_contracts.updateData()
        dash_chart.load()

        modelContracts.load();
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 30
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 150

            spacing: 15

            DashNumberValue {
                id: dash_partner
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            DashNumberValue {
                id: dash_contract
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            DashNumberValue {
                id: dash_docs
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            DashNumberValue {
                id: dash_file
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.verticalStretchFactor: 1

            spacing: 15

            DashContracts {
                id: dash_contracts
                Layout.fillHeight: true
                Layout.preferredWidth: root.width * .3
            }

            DashPaymentChart {
                id: dash_chart
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1


            }

        }

        DashTroubleContracts {
            id: dash_table
            Layout.fillWidth: true
            Layout.preferredHeight: 200
        }
    }

}
