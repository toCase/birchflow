import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts

import "partners"

Item {

    id: partners

    states: [
        State {
            name: "TAB"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    stack.pop();
                    stack.push(partners_main);
                }
            }
        },
        State {
            name: "FORM"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    stack.pop();
                    stack.push(partners_form);
                }
            }
        }
    ]

    state: "TAB"

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

    PartnersMain {
        id: partners_main
        visible: false
    }
    Connections {
        target: partners_main
        function onOpen(idx) {
            partners_form.load(idx)
            partners.state = "FORM"
        }
    }

    PartnersForm {
        id: partners_form
        visible: false
    }
    Connections {
        target: partners_form
        function onClose() {
            partners.state = "TAB"
        }
    }
}
