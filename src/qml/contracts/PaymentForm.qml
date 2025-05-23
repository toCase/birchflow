import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../controls"
import "../const.js" as Const
import DocFlow.models 1.0

Dialog {
    id: dia_doc
    z: 5

    modal: true

    signal paymentChanged(bool a, int type_id);

    property int doc_id: 0
    property int type_id: -1
    property bool has_file: false
    property alias base_currency: contract_currency.text

    property alias doc_num: dia_num.text
    property alias doc_date: dia_date.df_date
    property alias status: dia_status.currentIndex
    property alias amount: dia_amount.realValue
    property alias currency: dia_currency.currentIndex
    property alias currency_rate: dia_currency_rate.realValue
    property alias desc: dia_desc.text
    property alias file: dia_file.text

    property bool currency_equality: true

    function saveRequest() {
        let card = {}
        card.id = dia_doc.doc_id
        card.type_id = dia_doc.type_id
        card.num = dia_num.text
        card.doc_date = dia_date.df_date
        card.status = dia_doc.type_id === 1 ? dia_status.currentIndex : 2;
        card.amount = dia_amount.realValue
        card.currency = dia_currency.currentText
        card.currency_id = dia_currency.currentValue
        card.currency_rate = dia_currency_rate.realValue
        card.description = dia_desc.text
        card.file = dia_file.text

        let res = modelContractDocs.saveDoc(card);
        if (res.r) {
            dia_doc.close()
            dia_doc.paymentChanged(true, dia_doc.type_id)
        }
    }

    function deleteRequest() {
        let res = modelContractDocs.deleteDoc(dia_doc.type_id, dia_doc.doc_id);
        if (res) {
            dia_doc.close()
            dia_doc.paymentChanged(true, dia_doc.type_id)
        }
    }

    function updateFileRequest(){
        let card = {}
        card.id = dia_doc.doc_id
        card.type_id = dia_doc.type_id
        card.file = dia_file.text
        let res = modelContractDocs.updateFile(card)
    }

    function deleteFileRequest(){
        dia_doc.has_file = false
        dia_file.clear();
        updateFileRequest();
    }

    function changeCurrency(){
        dia_doc.currency_equality = dia_currency.currentText === dia_doc.base_currency
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
                text: qsTr("Number:")
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
                text: qsTr("Date:")
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
            Label {
                visible: dia_doc.type_id === 1
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                text: qsTr("Status:")
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }
            ComboBox {
                id: dia_status
                visible: dia_doc.type_id === 1
                Layout.preferredWidth: 150
                Layout.fillHeight: true
                Layout.topMargin: 5
                model: PaymentStatusModel.getList()
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

                text: qsTr("Amount:")

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }

            FloatInput_DF {
                id: dia_amount
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                Layout.topMargin: 5
                decimals: 2
                from: 0

            }

            ComboBox {
                id: dia_currency
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                Layout.topMargin: 5
                model: modelCurrency
                textRole: "code"
                valueRole: "cid"
                onActivated: dia_doc.changeCurrency()
            }

            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                visible: !dia_doc.currency_equality

                text: qsTr("Currency rate:")

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }
            FloatInput_DF {
                id: dia_currency_rate
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                visible: !dia_doc.currency_equality
                decimals: 2
                from: 0

            }

            Label {
                id: contract_currency
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                visible: !dia_doc.currency_equality

                text: qsTr("Currency rate:")

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }


            Item {
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44

            spacing: 10

            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                text: qsTr("Description:")

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

            visible: !dia_doc.has_file
            spacing: 10
            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                text: qsTr("File:")

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
            Layout.preferredHeight: 44

            visible: dia_doc.has_file
            spacing: 10
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: implicitWidth

                icon.source: "qrc:/qt/qml/BirchFlow/img/del_doc"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON

                flat: true

                text: qsTr("Delete file")
                onClicked: deleteFileRequest()

            }

            Item {
                Layout.fillWidth: true
            }

            Loader {
                id: iconLoader
                Layout.preferredHeight: 32
                Layout.preferredWidth: 32
                active: has_file && dia_file.text.length > 0
                sourceComponent: Image {
                    id: file_icon
                    source: "qrc:/qt/qml/BirchFlow/img/" + dia_file.text
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    cache: false
                }
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 120

                icon.source: "qrc:/qt/qml/BirchFlow/img/open"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON

                flat: true

                text: qsTr("Open")
                onClicked: modelContractDocs.viewDoc(doc_form.type_id, doc_form.doc_id)
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
                visible: dia_doc.doc_id === 0 ? false : true
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Delete")
                onClicked: dia_doc.deleteRequest()
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
                    dia_doc.saveRequest()
                }
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Close")
                onClicked: {

                    dia_doc.close()
                    dia_doc.paymentChanged(false, -1)
                }
            }
        }
    }

    FileDialog_DF {
        id: dialog_file
        onAccepted: {
            dia_file.text = modelContractDocs.toLocalFile(currentFile);
            if (dia_doc.doc_id > 0) {
                updateFileRequest();
            }
        }
    }

}
