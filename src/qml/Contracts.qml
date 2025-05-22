import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts

import "contracts"

Item {

    id: contracts

    states: [
        State {
            name: "LIST"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    modelContracts.load();
                    stack.pop();
                    stack.push(contracts_list);
                }
            }
        },
        State {
            name: "DET"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    stack.pop();
                    stack.push(contracts_detail);
                }
            }
        }
    ]

    state: "LIST"

    StackView {
        id: stack
        anchors.fill: parent
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

    ContractsList {
        id: contracts_list
        visible: false
    }

    Connections {
        target: contracts_list
        function onOpen(contract_id){
            contracts.state = "DET"
            contracts_detail.load(contract_id);
        }
    }

    ContractsDetail {
        id: contracts_detail
        visible: false
    }

    Connections {
        target: contracts_detail
        function onClose() {
            contracts.state = "LIST"
        }
    }

}
