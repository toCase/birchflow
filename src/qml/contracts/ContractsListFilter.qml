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
    z: 5
    modal: true
    title: qsTr("Filter")



    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            spacing: 10

            CheckBox {
                id: f_partner_enable
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                checked: false

                text: qsTr("Partner:")
            }
            ComboBox {
                id: f_partner
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.horizontalStretchFactor: 3
                Layout.topMargin: 5
                model: modelPartnerCombo
                textRole: "c_name"
                valueRole: "c_id"
            }
            Item {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44


            CheckBox {
                id: f_date_enable
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                checked: false
                text: qsTr("Date from:")
            }
            DateEdit_DF {
                id: f_from
                Layout.preferredWidth: 150
                Layout.fillHeight: true
                df_date: new Date().toLocaleString(Qt.locale(), String(appSetting.getValue("dateFormat")));
            }

            Label {
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                text: qsTr("to:")
                verticalAlignment: Qt.AlignVCenter
            }
            DateEdit_DF {
                id: f_to
                Layout.preferredWidth: 150
                Layout.fillHeight: true
                df_date: new Date().toLocaleString(Qt.locale(), String(appSetting.getValue("dateFormat")));
            }
            Item {
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44


            CheckBox {
                id: f_status_enable
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth
                checked: false
                text: qsTr("Status:")
            }

            ComboBox {
                id: f_status
                Layout.preferredWidth: 150
                Layout.fillHeight: true
                Layout.topMargin: 5
                model: StatusModel.getStatusList()
                valueRole: "value"
                textRole: "text"
            }
            Item {
                Layout.fillWidth: true
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
                text: qsTr("Reset")
                onClicked: {
                    f_partner_enable.checked = false
                    f_status_enable.checked = false
                    f_date_enable.checked = false
                    modelProxyContracts.setFilter({})
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
                text: qsTr("Accept")
                onClicked: {
                    let filter = {}
                    if (f_status_enable.checked) {
                        filter.status = f_status.currentValue
                    }
                    if (f_partner_enable.checked) {
                        filter.partner = f_partner.currentText
                    }
                    if (f_date_enable.checked) {
                        filter.from = f_from.df_date
                        filter.to = f_to.df_date
                    }

                    modelProxyContracts.setFilter(filter)
                    root.close()
                }
            }
        }
    }
}
