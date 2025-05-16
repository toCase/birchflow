import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "const.js" as Const
import "controls"

Item {
    id: setting

    function load() {
        setting_vault.text = appSetting.getValue("vault", "");
        setting_payment.checked = appSetting.getValue("calcPay", "payment") === "payment"
        setting_invoice.checked = appSetting.getValue("calcPay", "payment") === "invoice"
        setting_dateA.checked = appSetting.getValue("dateFormat", "dd-MM-yyyy") === "dd.MM.yyyy"
        setting_dateB.checked = appSetting.getValue("dateFormat", "dd-MM-yyyy") === "MM-dd-yyyy"
        setting_dateC.checked = appSetting.getValue("dateFormat", "dd-MM-yyyy") === "dd-MM-yyyy"
        setting_dateD.checked = appSetting.getValue("dateFormat", "dd-MM-yyyy") === "dd/MM/yyyy"
        setting_lang.currentIndex = appSetting.getValue("lang", 0);
        setting_currency.currentIndex = appSetting.getValue("currency", 0);

        setting_archive_enable.checked = appSetting.getValue("archive_enable", true)
        setting_archive_month.realValue = appSetting.getValue("archive_month", 3)

        setting_delete_enable.checked = appSetting.getValue("delete_enable", false)
        setting_delete_month.realValue = appSetting.getValue("delete_month", 1)
    }

    ScrollView {
        anchors.fill: parent

        contentWidth: availableWidth

        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 15
            anchors.bottomMargin: 15
            anchors.leftMargin: 60
            anchors.rightMargin: 60


            spacing: 30

            Page {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                header: Label {
                    text: qsTr("Vault")
                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                }
                contentItem: ColumnLayout {
                    spacing: 5
                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight

                        text: qsTr("Select a directory that will be the storage for documents")
                        font.pixelSize: Qt.application.font.pixelSize * .9
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        spacing: 5

                        TextField {
                            id: setting_vault
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            Layout.topMargin: 5
                            Layout.bottomMargin: 5
                            readOnly: true
                        }
                        Button_DF {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 60

                            text: "..."
                            onClicked: vaultDialog.open();

                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        radius: 2
                        color: Const.CLR_YELLOW
                    }
                }
            }
            Page {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                header: Label {
                    text: qsTr("Calculation pay amount")
                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                }
                contentItem: ColumnLayout {
                    spacing: 5
                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight

                        text: qsTr("Выберите метод расчета суммы оплат по договору: платежи или счет со статусом оплачено")
                        font.pixelSize: Qt.application.font.pixelSize * .9
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        spacing: 5

                        ButtonGroup { id: sett_pay }

                        RadioButton {
                            id: setting_payment
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                            text: qsTr("Payment")
                            ButtonGroup.group: sett_pay
                            onClicked: appSetting.setValue("calcPay", "payment")
                        }
                        RadioButton {
                            id: setting_invoice
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                            text: qsTr("Invoice")
                            ButtonGroup.group: sett_pay
                            onClicked: appSetting.setValue("calcPay", "invoice")
                        }

                        Item {
                            Layout.fillWidth: true

                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        radius: 2
                        color: Const.CLR_YELLOW
                    }
                }
            }
            Page {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                header: Label {
                    text: qsTr("Date format")
                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                }
                contentItem: ColumnLayout {
                    spacing: 5
                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight

                        text: qsTr("Выберите метод расчета суммы оплат по договору: платежи или счет со статусом оплачено")
                        font.pixelSize: Qt.application.font.pixelSize * .9
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        spacing: 5

                        ButtonGroup { id: sett_date }

                        RadioButton {
                            id: setting_dateA
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                            text: qsTr("dd.MM.yyyy")
                            ButtonGroup.group: sett_date
                            onClicked: appSetting.setValue("dateFormat", "dd.MM.yyyy")
                        }
                        RadioButton {
                            id: setting_dateB
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                            text: qsTr("MM-dd-yyyy")
                            ButtonGroup.group: sett_date
                            onClicked: appSetting.setValue("dateFormat", "MM-dd-yyyy")
                        }
                        RadioButton {
                            id: setting_dateC
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                            text: qsTr("dd-MM-yyyy")
                            ButtonGroup.group: sett_date
                            onClicked: appSetting.setValue("dateFormat", "dd-MM-yyyy")
                        }
                        RadioButton {
                            id: setting_dateD
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                            text: qsTr("dd/MM/yyyy")
                            ButtonGroup.group: sett_date
                            onClicked: appSetting.setValue("dateFormat", "dd/MM/yyyy")
                        }

                        Item {
                            Layout.fillWidth: true

                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        radius: 2
                        color: Const.CLR_YELLOW
                    }
                }
            }
            Page {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                header: Label {
                    text: qsTr("Localisation")
                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                }
                contentItem: ColumnLayout {
                    spacing: 5
                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight

                        text: qsTr("Select a lang")
                        font.pixelSize: Qt.application.font.pixelSize * .9
                    }
                    ComboBox {
                        id: setting_lang
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 200
                        Layout.topMargin: 5
                        Layout.bottomMargin: 5
                        model: ["English", "Ukraine"]
                        onActivated: appSetting.setValue("lang", currentIndex)
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        radius: 2
                        color: Const.CLR_YELLOW
                    }
                }
            }
            Page {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                header: Label {
                    text: qsTr("Currency")
                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                }
                contentItem: ColumnLayout {
                    spacing: 5
                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight

                        text: qsTr("Select default currency. Этот параметр будет ставить эту валюту при создании новых документов.
                    Вы сможете изменять валюту документов и создавать документы в любой валюте без ограничений.")
                        font.pixelSize: Qt.application.font.pixelSize * .9
                    }
                    ComboBox {
                        id: setting_currency
                        Layout.preferredHeight: 40
                        Layout.preferredWidth: 80
                        Layout.topMargin: 5
                        Layout.bottomMargin: 5
                        model: modelCurrency
                        textRole: "code"
                        valueRole: "cid"
                        onActivated: appSetting.setValue("currency", currentIndex)
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        radius: 2
                        color: Const.CLR_YELLOW
                    }
                }
            }
            Page {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                header: Label {
                    text: qsTr("Aрхивация")
                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                }
                contentItem: ColumnLayout {
                    spacing: 5
                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight

                        text: qsTr("Установите период, по истечении которого завершенный документ автоматически будет переведен в архив.")
                        font.pixelSize: Qt.application.font.pixelSize * .9
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        spacing: 5
                        CheckBox {
                            id: setting_archive_enable
                            Layout.fillHeight: true
                            Layout.preferredWidth: 120
                            text: "Archivation"
                            onClicked: {
                                appSetting.setValue("archive_enable", setting_archive_enable.checked)
                                appSetting.setValue("archive_month", setting_archive_month.realValue)
                            }
                        }
                        FloatInput_DF {
                            id: setting_archive_month
                            enabled: setting_archive_enable.checked
                            Layout.fillHeight: true
                            Layout.preferredWidth: 80
                            decimals: 0
                            realFrom: 1
                            realTo: 48
                            realStepSize: 1
                            realValue: 1
                            onValueModified: {
                                appSetting.setValue("archive_month", setting_archive_month.realValue)
                            }
                        }
                        Label {
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                            text: qsTr("month")
                            horizontalAlignment: Qt.AlignLeft
                            verticalAlignment: Qt.AlignVCenter

                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        radius: 2
                        color: Const.CLR_YELLOW
                    }
                }
            }
            Page {
                Layout.fillWidth: true
                Layout.preferredHeight: 90
                header: Label {
                    text: qsTr("Deleting")
                    font.pixelSize: Qt.application.font.pixelSize * 1.3
                }
                contentItem: ColumnLayout {
                    spacing: 5
                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight

                        text: qsTr("Установите период, по истечении которого Aborted документ автоматически будет delete.")
                        font.pixelSize: Qt.application.font.pixelSize * .9
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 44
                        spacing: 5
                        CheckBox {
                            id: setting_delete_enable
                            Layout.fillHeight: true
                            Layout.preferredWidth: 120
                            text: "Deleting"
                            onClicked: {
                                appSetting.setValue("delete_enable", setting_delete_enable.checked)
                                appSetting.setValue("delete_month", setting_delete_month.realValue)
                            }
                        }
                        FloatInput_DF {
                            id: setting_delete_month
                            enabled: setting_delete_enable.checked
                            Layout.fillHeight: true
                            Layout.preferredWidth: 80
                            decimals: 0
                            realFrom: 1
                            realTo: 48
                            realStepSize: 1
                            realValue: 1
                            onValueModified: {
                                appSetting.setValue("delete_month", setting_delete_month.realValue)
                            }
                        }
                        Label {
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth
                            text: qsTr("month")
                            horizontalAlignment: Qt.AlignLeft
                            verticalAlignment: Qt.AlignVCenter

                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 2
                        radius: 2
                        color: Const.CLR_YELLOW
                    }
                }
            }
            Item {
                Layout.fillHeight: true
                Layout.verticalStretchFactor: 1

            }
        }
    }


    FolderDialog {
        id: vaultDialog
        currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        onAccepted: {
            setting_vault.text = appSetting.toLocalDir(selectedFolder)
            appSetting.setValue("vault", setting_vault.text);
        }
    }
}
