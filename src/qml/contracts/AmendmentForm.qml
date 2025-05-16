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

    signal changeAmendment();

    title: qsTr("Amendment")

    property int doc_id: 0
    property int type_id: 0

    property bool has_file: false

    property alias doc_num: dia_num.text
    property alias doc_date: dia_date.df_date

    property alias change_date: dia_change_date.checked
    property alias valid_from: dia_valid_from.df_date
    property alias valid_to: dia_valid_to.df_date

    property alias change_amount: dia_change_amount.checked
    property alias amount: dia_amount.realValue
    property alias currency: dia_currency.text

    property alias desc: dia_desc.text
    property alias file: dia_file.text

    function saveRequest() {
        let card = {}
        card.id = root.doc_id
        card.type_id = root.type_id
        card.num = dia_num.text
        card.doc_date = dia_date.df_date
        card.change_date = dia_change_date.checked
        card.valid_from = dia_valid_from.df_date
        card.valid_to = dia_valid_to.df_date
        card.change_amount = dia_change_amount.checked
        card.amount = dia_amount.realValue
        card.description = dia_desc.text
        card.file = dia_file.text

        let res = modelContractDocs.saveDoc(card);
        if (res.r) {
            root.close();
            root.changeAmendment();
        }
    }

    function deleteRequest() {
        let res = modelContractDocs.deleteDoc(root.type_id, root.doc_id);
        if (res) {
            root.close();
            root.changeAmendment();
        }
    }

    function updateFileRequest(){
        let card = {}
        card.id = root.doc_id
        card.type_id = root.type_id
        card.file = dia_file.text
        let res = modelContractDocs.updateFile(card)
    }

    function deleteFileRequest(){
        root.has_file = false
        dia_file.clear();
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
            CheckBox {
                id: dia_change_date
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                text: qsTr("Change valid date")
            }

            Label {
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true

                text: "from:"

                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }


            DateEdit_DF {
                id: dia_valid_from
                enabled: dia_change_date.checked
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
                enabled: dia_change_date.checked
                Layout.preferredWidth: 150
                Layout.fillHeight: true
            }
            Item {
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            spacing: 10

            CheckBox {
                id: dia_change_amount
                Layout.preferredWidth: implicitWidth
                Layout.fillHeight: true
                text: qsTr("Change amount")
            }
            FloatInput_DF {
                id: dia_amount
                Layout.preferredWidth: 100
                Layout.fillHeight: true
                enabled: dia_change_amount.checked
                decimals: 2
                realStepSize: 10

            }

            Label {
                id: dia_currency
                Layout.preferredWidth: 80
                Layout.fillHeight: true
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

            visible: !root.has_file
            spacing: 10
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
            Layout.preferredHeight: 44

            visible: root.has_file
            spacing: 10
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
                active: root.has_file && dia_file.text.length > 0
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
                visible: root.doc_id === 0 ? false : true
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Delete")
                onClicked: root.deleteRequest()
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
                    root.saveRequest()
                }
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 100
                text: qsTr("Close")
                onClicked: {

                    root.close()
                }
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
            dia_file.text = modelContractDocs.toLocalFile(selectedFile);
            if (root.doc_id > 0) {
                updateFileRequest();
            }
        }
    }
}
