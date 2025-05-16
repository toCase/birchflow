import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../const.js" as Const
import "../controls"

Item {

    id: partner_form

    signal close()

    function load(idx) {
        pf_edit.partner_id = idx
        pf_edit.load(idx)
        pf_banks.partner_id = idx
        pf_banks.load()
        pf_persons.partner_id = idx
        pf_persons.load()
        pf_docs.partner_id = idx
        pf_docs.load()
        partner_form.state = "EDIT"
    }

    states: [
        State {
            name: "EDIT"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    form_stack.pop();
                    form_stack.push(pf_edit);
                }
            }
        },
        State {
            name: "BANK"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    form_stack.pop();
                    form_stack.push(pf_banks);
                }
            }
        },
        State {
            name: "PERS"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    form_stack.pop();
                    form_stack.push(pf_persons);
                }
            }
        },
        State {
            name: "DOCS"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    form_stack.pop();
                    form_stack.push(pf_docs);
                }
            }
        }
    ]


    ColumnLayout {
        anchors.fill: parent

        spacing: 5

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            spacing: 0

            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 44
                Layout.topMargin: -5
                Layout.bottomMargin: -7

                icon.source: "qrc:/qt/qml/DocFlow/img/prev"
                icon.width: 16
                icon.height: 16
                icon.color: Const.CLR_ICON

                flat: true

                onClicked: {
                    partner_form.state = "EDIT"
                    form_tabbar.currentIndex = 0
                    partner_form.close()
                }
            }

            TabBar {
                id: form_tabbar
                Layout.fillWidth: true
                Layout.fillHeight: true

                TabButton {
                    text: qsTr("FORM")
                    onClicked: partner_form.state = "EDIT"
                }
                TabButton {
                    text: qsTr("BANK")
                    onClicked: partner_form.state = "BANK"
                }
                TabButton {
                    text: qsTr("PERSONS")
                    onClicked: partner_form.state = "PERS"
                }
                TabButton {
                    text: qsTr("DOCUMENTS")
                    onClicked: partner_form.state = "DOCS"
                }
            }
        }

        StackView {
            id: form_stack
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.verticalStretchFactor: 1
            initialItem: Item{}

            pushEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to:1
                    duration: 200
                }
            }
            pushExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to:0
                    duration: 200
                }
            }
            popEnter: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to:1
                    duration: 200
                }
            }
            popExit: Transition {
                PropertyAnimation {
                    property: "opacity"
                    from: 1
                    to:0
                    duration: 200
                }
            }
        }
    }

    PartnersEdit {
        id: pf_edit
        visible: false
    }

    PartnersPersons {
        id: pf_persons
        visible: false
    }

    PartnersBanks {
        id: pf_banks
        visible: false
    }

    PartnersDocs {
        id: pf_docs
        visible: false
    }

}
