import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../controls"
import "../const.js" as Const
import DocFlow.models 1.0

Dialog {
    id: dia_form
    z:5

    modal: true

    title: "Contract"
    property int contract_id: 0
    property bool is_file: false
    property alias c_type: dia_type.currentIndex
    property alias c_num: dia_num.text
    property alias c_date: dia_date.df_date
    property alias partner: dia_partner.currentIndex
    property alias valid_from: dia_valid_from.df_date
    property alias valid_to: dia_valid_to.df_date
    property alias amount: dia_amount.text
    property alias currency: dia_currency.currentIndex
    property alias desc: dia_desc.text
    property alias file: dia_file.text
    property alias status: dia_status.currentIndex


    function saveRequest() {

        if (dia_partner.currentIndex === -1) {
            dia_partner.focus = true
            return;
        }

        let card = {}
        card.id = dia_form.contract_id
        card.type_id = dia_type.currentValue
        card.num = dia_num.text
        card.c_date = dia_date.df_date
        card.partner_id = dia_partner.currentValue
        card.valid_from = dia_valid_from.df_date
        card.valid_to = dia_valid_to.df_date
        card.amount = dia_amount.text
        card.currency_id = dia_currency.currentValue
        card.description = dia_desc.text
        card.file = dia_file.text
        card.status = dia_status.currentValue

        card.currency = dia_currency.currentText
        card.partner = dia_partner.currentText


        let res = modelContracts.save(card);
        if (res.r) dia_form.close()
    }

    function updateFileRequest(){
        let card = {}
        card.id = dia_form.contract_id
        card.file = dia_file.text
        let res = modelContracts.updateFile(card);
    }

    function deleteFileRequest(){
        dia_form.is_file = false
        dia_file.clear()
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
                text: "Type: "
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }
            ComboBox {
                id: dia_type
                Layout.preferredWidth: 150
                Layout.fillHeight: true
                Layout.topMargin: 5
                model: TypeModel.getTypeList()
                valueRole: "value"
                textRole: "text"
            }
            Item {
                Layout.fillWidth: true
                Layout.horizontalStretchFactor: 1
            }
            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                text: "Status: "
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }
            ComboBox {
                id: dia_status
                Layout.preferredWidth: 150
                Layout.fillHeight: true
                Layout.topMargin: 5
                model: StatusModel.getStatusList()
                valueRole: "value"
                textRole: "text"
            }
        }
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
                text: "Partner: "
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }
            ComboBox {
                id: dia_partner
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 5
                model: modelPartnerCombo
                textRole: "c_name"
                valueRole: "c_id"
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            spacing: 10

            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                text: "Valid from:"

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }


            DateEdit_DF {
                id: dia_valid_from
                Layout.preferredWidth: 150
                Layout.fillHeight: true
            }

            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                text: "to:"

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }


            DateEdit_DF {
                id: dia_valid_to
                Layout.preferredWidth: 150
                Layout.fillHeight: true
            }

            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                text: "Amount:"

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }

            TextField {
                id: dia_amount
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                Layout.topMargin: 5

                validator: RegularExpressionValidator {
                    regularExpression: /(?:0|[1-9]\d*)(?:[.,]\d{1,5})?/
                }
            }

            ComboBox {
                id: dia_currency
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                Layout.topMargin: 5
                enabled: dia_form.contract_id === 0
                model: modelCurrency
                textRole: "code"
                valueRole: "cid"
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

            spacing: 10

            visible: !is_file

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
            Layout.preferredHeight: 46

            spacing: 10

            visible: is_file

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
                active: is_file && dia_file.text.length > 0
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
                onClicked: modelContracts.viewDoc(dia_form.contract_id)
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
                visible: dia_form.contract_id === 0 ? false : true
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Delete")
                onClicked: del_dialog.open()
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
                    dia_form.saveRequest()
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
            dia_file.text = modelPartnerDoc.toLocalFile(selectedFile);
            if (dia_form.contract_id > 0) {
                updateFileRequest();
            }
        }
    }

    Dialog {
        id: del_dialog
        width: 400
        height: 150
        title: qsTr("Delete contract")

        Label {
            text: qsTr("Are you sure?")
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
                    text: qsTr("Delete")
                    onClicked:{
                        modelContracts.del(dia_form.contract_id)
                        del_dialog.close()
                        dia_form.close()
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.horizontalStretchFactor: 1
                }
                Button_DF {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                    text: qsTr("Cancel")
                    onClicked: {
                        del_dialog.close()
                    }
                }
            }
        }
    }
}
