import QtQuick
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../const.js" as Const
import "../controls"
import DocFlow.models 1.0

Item {
    id: contract_detail

    signal close()

    property string currency: "UAH"
    property int currency_id: 0
    property int contract_type: 1
    property int contract_id: 0

    property string c_valid_from: ""
    property string c_valid_to: ""
    property double c_amount: 0

    function load(contract_id) {
        contract_detail.contract_id = contract_id
        modelContractDocs.setContract(contract_id)

        let card = modelContracts.getCard(contract_id)
        contract_data.text = String("#%1  %2").arg(card.num).arg(card.c_date)
        contract_description.text = card.description
        contract_partner.text = card.partner
        contract_detail.contract_type = card.type_id
        contract_detail.currency = card.currency
        contract_detail.currency_id = card.currency_id
        //-- info valid date
        internal.updateValidDate();
        internal.updateAmountPaid();

        let expand = appSetting.getValue("doc_expand", false);
        expandTree(expand)

        console.log(card.valid_from)

    }

    function expandTree(e) {
        if (e) { content.expandRecursively(); } else { content.collapseRecursively(); }
    }



    QtObject {
        id: internal

        function add(doc) {
            if (doc === 0) {
                addAmendment(doc);
            } else if (doc === 1 || doc === 2) {
                addPayment(doc);
            } else if (doc > 2) {
                addDocument(doc);
            }
        }

        function open(doc, doc_id){
            if (doc === 0) {
                openAmendment(doc, doc_id)
            } else if (doc === 1 || doc === 2) {
                openPayment(doc, doc_id);
            } else if (doc > 2){
                openDocument(doc, doc_id);
            }
        }

        function addAmendment(doc) {
            amen_form.type_id = doc
            amen_form.doc_id = 0
            amen_form.doc_num = ""
            amen_form.change_date = false
            amen_form.doc_date = new Date().toLocaleString(Qt.locale(), String(appSetting.getValue("dateFormat")));
            amen_form.valid_from = contract_detail.c_valid_from
            amen_form.valid_to = contract_detail.c_valid_to
            amen_form.change_amount = false
            amen_form.amount = contract_detail.c_amount
            amen_form.currency = contract_detail.currency
            amen_form.desc = ""
            amen_form.file = ""
            amen_form.has_file = false;

            amen_form.open();
        }

        function openAmendment(doc, doc_id){
            let card = modelContractDocs.getCard(doc, doc_id)

            amen_form.type_id = doc
            amen_form.doc_id = doc_id
            amen_form.doc_num = card.num
            amen_form.doc_date = card.doc_date
            amen_form.change_date = card.change_date
            amen_form.valid_from = card.valid_from
            amen_form.valid_to = card.valid_to
            amen_form.change_amount = card.change_amount
            amen_form.amount = card.amount
            amen_form.currency = contract_detail.currency
            amen_form.desc = card.description
            amen_form.file = card.file
            amen_form.has_file = card.file === "" ? false : true;

            amen_form.open();
        }

        function addDocument(doc){
            doc_form.type_id = doc
            doc_form.doc_id = 0
            switch (Number(doc)) {
            case 3:
                doc_form.title = qsTr("Correspondence")
                break;
            case 4:
                doc_form.title = qsTr("Estimate")
                break;
            case 5:
                doc_form.title = qsTr("Goods")
                break;
            case 6:
                doc_form.title = qsTr("Acts")
                break;
            case 7:
                doc_form.title = qsTr("Document")
                break;
            default:
                doc_form.title = "Document"
                break;
            }
            doc_form.doc_num = ""
            doc_form.doc_date = new Date().toLocaleString(Qt.locale(), String(appSetting.getValue("dateFormat")));
            doc_form.doc_title = ""
            doc_form.desc = ""
            doc_form.file = ""
            doc_form.has_file = false;

            doc_form.open();
        }

        function openDocument(doc, doc_id) {
            switch (Number(doc)) {
            case 3:
                doc_form.title = qsTr("Correspondence")
                break;
            case 4:
                doc_form.title = qsTr("Estimate")
                break;
            case 5:
                doc_form.title = qsTr("Goods")
                break;
            case 6:
                doc_form.title = qsTr("Acts")
                break;
            case 7:
                doc_form.title = qsTr("Document")
                break;
            default:
                doc_form.title = "Document"
                break;
            }
            let card = modelContractDocs.getCard(doc, doc_id)

            doc_form.type_id = doc
            doc_form.doc_id = doc_id
            doc_form.doc_num = card.num
            doc_form.doc_date = card.doc_date
            doc_form.doc_title = card.title
            doc_form.desc = card.description
            doc_form.file = card.file
            doc_form.has_file = card.file === "" ? false : true;

            doc_form.open();
        }

        function addPayment(doc){
            pay_form.type_id = doc
            pay_form.doc_id = 0
            switch (Number(doc)) {
            case 1:
                pay_form.title = qsTr("Invoice")
                break;
            case 2:
                pay_form.title = qsTr("Payment")
                break;
            default:
                pay_form.title = "Document"
                break;
            }
            pay_form.doc_num = "";
            pay_form.doc_date = new Date().toLocaleString(Qt.locale(), String(appSetting.getValue("dateFormat")));
            pay_form.amount = 1.00;
            pay_form.base_currency = contract_detail.currency;
            pay_form.currency = modelCurrency.getRow(contract_detail.currency_id);
            pay_form.currency_rate = 1;
            pay_form.status = 0;
            pay_form.desc = "";
            pay_form.file = "";
            pay_form.has_file = false;

            pay_form.open();
        }

        function openPayment(doc, doc_id){
            if (doc === 1) {
                pay_form.title = qsTr("Invoice")
            } else if (doc === 2) {
                pay_form.title = qsTr("Payment")
            }

            let card = modelContractDocs.getCard(doc, doc_id)

            pay_form.type_id = doc
            pay_form.doc_id = doc_id
            pay_form.doc_num = card.num
            pay_form.doc_date = card.doc_date
            pay_form.amount = card.amount;
            pay_form.base_currency = contract_detail.currency;
            pay_form.currency = modelCurrency.getRow(card.currency_id);
            pay_form.currency_rate = card.currency_rate;
            pay_form.status = PaymentStatusModel.getRow(card.status);
            pay_form.desc = card.description;
            pay_form.file = card.file;
            pay_form.has_file = card.file === "" ? false : true;

            pay_form.open();
        }

        function updateValidDate(){
            let data_valid = modelContracts.getValidDate(contract_id)

            contract_progress.dateFrom = data_valid.valid_from
            contract_progress.dateTo = data_valid.valid_to

            contract_detail.c_valid_from = data_valid.valid_from
            contract_detail.c_valid_to = data_valid.valid_to
        }

        function updateAmountPaid(){
            let data_amount = modelContracts.getValidAmount(contract_id);

            c_amount = data_amount.amount

            contract_amount.amount = data_amount.amount
            contract_amount.currency = contract_detail.currency
            contract_amount.paid = data_amount.paid
        }
    }


    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 10
        anchors.leftMargin: 70
        anchors.rightMargin: 15

        spacing: 10

        Item {
            id: header
            Layout.fillWidth: true
            Layout.minimumHeight: 170
            Layout.maximumHeight: 170
            RowLayout {
                anchors.fill: parent
                spacing: 30

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.fillWidth: true
                    Layout.horizontalStretchFactor: 1

                    spacing: 30

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 60

                        Button_DF {
                            Layout.preferredHeight: 60
                            Layout.preferredWidth: 60
                            Layout.alignment: Layout.Center

                            flat: true

                            icon.source: "qrc:/qt/qml/DocFlow/img/prev"
                            icon.width: 24
                            icon.height: 24
                            icon.color: Const.CLR_ICON
                            onClicked: contract_detail.close()

                        }

                        Label {
                            id: contract_partner
                            Layout.fillHeight: true
                            Layout.preferredWidth: implicitWidth

                            font.pixelSize: Qt.application.font.pixelSize * 3
                            font.italic: true
                            verticalAlignment: Qt.AlignVCenter
                        }
                        Item {
                            Layout.fillWidth: true
                            Layout.horizontalStretchFactor: 1
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70

                        spacing: 25

                        Loader {
                            Layout.preferredHeight: 32
                            Layout.preferredWidth: 32
                            Layout.alignment: Layout.Center
                            active: contract_detail.contract_type > 0;
                            sourceComponent: Image {
                                source: contract_detail.contract_type === 1 ? "qrc:/qt/qml/DocFlow/img/trend-up" : "qrc:/qt/qml/DocFlow/img/trend-down"
                                fillMode: Image.PreserveAspectFit
                                mipmap: true
                                cache: false
                            }
                        }

                        Column {
                            Layout.preferredHeight: implicitHeight
                            Layout.fillWidth: true
                            Layout.alignment: Layout.Center

                            Label {
                                id: contract_data
                                font.pixelSize: Qt.application.font.pixelSize * 1.3
                            }
                            Label {
                                id: contract_description
                                font.pixelSize: Qt.application.font.pixelSize
                                font.italic: true
                            }
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                    }
                }

                DateProgress_DF {
                    id: contract_progress
                    Layout.fillHeight: true
                    Layout.preferredWidth: 220
                }

                PaidProgress_DF {
                    id: contract_amount
                    Layout.fillHeight: true
                    Layout.preferredWidth: 220
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 3
            radius: 3
            color: Const.CLR_YELLOW
        }

        TreeView {
            id: content

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.verticalStretchFactor: 1

            model: modelContractDocs
            selectionModel: ItemSelectionModel {}
            rowSpacing: 5
            columnSpacing: 0
            clip: true

            columnWidthProvider: function (column) {
                if (column === 0) return 40;
                return content.width - 40;
            }
            rowHeightProvider: function (row) {return 50;}



            delegate: TreeViewDelegate {
                id: cell
                required property int column

                required property string file
                required property string num
                required property string doc_date
                required property string doc_title
                required property string validFrom
                required property string validTo
                required property string sum
                required property int status
                required property string created
                required property bool is_section
                required property int doc_id
                required property int doc_type

                contentItem: Item {
                    anchors.fill: parent

                    Loader {
                        anchors.fill: parent
                        active: cell.column === 1 && cell.is_section
                        sourceComponent: RowLayout {
                            spacing: 5

                            Label {
                                Layout.fillHeight: true
                                Layout.preferredWidth: implicitWidth

                                text: cell.doc_title
                                verticalAlignment: Qt.AlignVCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.5
                            }

                            Rectangle {
                                Layout.preferredHeight: 15
                                Layout.preferredWidth: 30
                                Layout.topMargin: -10
                                radius: 15
                                visible: cell.created !== "0"

                                color: Const.CLR_ORANGE
                                Text {
                                    anchors.centerIn: parent
                                    color: "#000000"
                                    text: cell.created
                                    font.pixelSize: Qt.application.font.pixelSize * .8
                                    font.bold: true
                                }
                            }

                            Item {
                                Layout.fillWidth: true
                            }
                            Button_DF {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 50
                                flat: true

                                icon.source: "qrc:/qt/qml/DocFlow/img/plus"
                                icon.width: 16
                                icon.height: 16
                                icon.color: Const.CLR_ICON
                                onClicked: internal.add(Number(cell.num))
                            }
                        }
                    }

                    Loader {
                        anchors.fill: parent
                        active: cell.column === 1 && !cell.is_section
                        sourceComponent:  RowLayout {
                            spacing: 5
                            Loader {
                                Layout.preferredHeight: 36
                                Layout.preferredWidth: 36
                                Layout.leftMargin: 20
                                Layout.rightMargin: 20
                                active: cell.file.length > 0
                                sourceComponent: Image {
                                    source: "qrc:/qt/qml/DocFlow/img/" + cell.file
                                    fillMode: Image.PreserveAspectFit
                                    mipmap: true
                                }
                            }

                            Label {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 80
                                text: cell.num
                                horizontalAlignment: Qt.AlignLeft
                                verticalAlignment: Qt.AlignVCenter
                                font.pixelSize: Qt.application.font.pixelSize * .9
                            }
                            Label {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 100
                                text: cell.doc_date
                                horizontalAlignment: Qt.AlignLeft
                                verticalAlignment: Qt.AlignVCenter
                                font.pixelSize: Qt.application.font.pixelSize * .9
                            }
                            Label {
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                text: cell.doc_title
                                horizontalAlignment: Qt.AlignLeft
                                verticalAlignment: Qt.AlignVCenter
                                font.pixelSize: Qt.application.font.pixelSize * 1.3
                            }
                            Label {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 80
                                text: cell.validFrom
                                horizontalAlignment: Qt.AlignLeft
                                verticalAlignment: Qt.AlignVCenter
                                font.pixelSize: Qt.application.font.pixelSize * .9
                            }
                            Label {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 80
                                text: cell.validTo
                                horizontalAlignment: Qt.AlignLeft
                                verticalAlignment: Qt.AlignVCenter
                                font.pixelSize: Qt.application.font.pixelSize * .9
                            }
                            Label {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 80
                                text: cell.sum
                                horizontalAlignment: Qt.AlignLeft
                                verticalAlignment: Qt.AlignVCenter
                                font.pixelSize: Qt.application.font.pixelSize * .9
                            }
                            Item {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 100

                                Rectangle {
                                    anchors.centerIn: parent
                                    visible: cell.status === 99 ? false : true
                                    width: 25
                                    height: 25
                                    radius: 25
                                    color:{
                                        switch (cell.status) {
                                        case 0:
                                            "#FFFFFF"
                                            break;
                                        case 1:
                                            Const.CLR_ORANGE
                                            break;
                                        case 2:
                                            Const.CLR_GREEN
                                            break;
                                        default:
                                            "transparent"
                                            break;
                                        }
                                    }
                                }
                            }
                            Button_DF {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 44
                                flat: true
                                enabled: cell.file.length > 0

                                icon.source: "qrc:/qt/qml/DocFlow/img/open"
                                icon.width: 16
                                icon.height: 16
                                icon.color: cell.file.length > 0 ? Const.CLR_ICON : "gray"
                                onClicked: modelContractDocs.viewDoc(cell.doc_type, cell.doc_id)
                            }

                            Label {
                                Layout.fillHeight: true
                                Layout.preferredWidth: 120
                                text: cell.created
                                horizontalAlignment: Qt.AlignLeft
                                verticalAlignment: Qt.AlignVCenter
                                font.pixelSize: Qt.application.font.pixelSize * .9
                                font.italic: true
                            }
                        }
                    }
                }

                background: Rectangle {
                    color: is_section ? "transparent"  : ma.containsMouse && column === 1 ? Const.CLR_YELLOW : "transparent"
                    // topRightRadius: is_section ? (column === 2 ? 7 : 0) : 0
                    // bottomRightRadius: is_section ? (column === 2 ? 7 : 0) : 0
                    // topLeftRadius: is_section ? (column === 0 ? 7 : 0) : 0
                    // bottomLeftRadius: is_section ? (column === 0 ? 7 : 0) : 0
                    radius: 5
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        if (!is_section && column === 1) {
                            internal.open(cell.doc_type, cell.doc_id);
                        }
                    }
                }
            }
        }
    }

    DocumentForm {
        id: doc_form
        x: contract_detail.width * .15
        y: contract_detail.width * .05
        width: contract_detail.width - (2 * (contract_detail.width * .15))
        height: 370
    }
    Connections {
        target: doc_form
        function onSetOpen(a, type_id) {
            if (a) content.expand(type_id)
        }
    }

    PaymentForm {
        id: pay_form
        x: contract_detail.width * .15
        y: contract_detail.width * .05
        width: contract_detail.width - (2 * (contract_detail.width * .15))
        height: 370
    }
    Connections {
        target: pay_form
        function onPaymentChanged(a, type_id) {
            if (a) {
                content.expand(type_id)
                internal.updateAmountPaid()
            }
        }
    }

    AmendmentForm {
        id: amen_form
        x: contract_detail.width * .15
        y: contract_detail.width * .05
        width: contract_detail.width - (2 * (contract_detail.width * .15))
        height: 420
    }
    Connections {
        target: amen_form
        function onChangeAmendment() {
            content.expand(0)
            internal.updateValidDate()
            internal.updateAmountPaid()
        }
    }

    HiddenMenu_DF {
        id: menu
        x: 0
        y: content.y + 10
    }
    Connections {
        target: menu
        function onChangeExpand(e) {
            console.log("change expand", e)
            contract_detail.expandTree(e)
        }
        function onMakeZip() {            
            dialog_file.open()
        }
    }

    FileDialog {
        id: dialog_file
        currentFolder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
        fileMode: FileDialog.SaveFile
        defaultSuffix: "zip"
        nameFilters: ["Zip file (*.zip)"]
        onAccepted: {
            let zip_file = modelContractDocs.toLocalFile(selectedFile);
            modelContractDocs.makeArchive(zip_file);
        }
    }
}
