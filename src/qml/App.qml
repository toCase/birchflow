import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts

import "const.js" as Const
Item {

    id: app

    states: [
        State {
            name: "DASH"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    dash.load();
                    app_stack.pop();
                    app_stack.push(dash);
                }
            }
        },
        State {
            name: "CLI"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    modelPartners.load();
                    app_stack.pop();
                    app_stack.push(partners);
                }
            }
        },
        State {
            name: "CONT"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    app_stack.pop();
                    app_stack.push(contracts);
                }
            }
        },
        State {
            name: "SETT"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    setting.load();
                    app_stack.pop();
                    app_stack.push(setting);
                }
            }
        },
        State {
            name: "ABO"
            PropertyChanges {}
            StateChangeScript {
                script: {
                    app_stack.pop();
                    app_stack.push(about);
                }
            }
        }
    ]

    state: "DASH"

    ColumnLayout {
        anchors.fill: parent

        spacing: 5

        TabBar {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            TabButton {
                text: qsTr("Dash")
                onClicked: app.state = "DASH"
            }
            TabButton {
                text: qsTr("Partners")
                onClicked: app.state = "CLI"
            }
            TabButton {
                text: qsTr("Contracts")
                onClicked: app.state = "CONT"
            }
            TabButton {
                text: qsTr("Settings")
                width: implicitWidth
                onClicked: app.state = "SETT"
            }
            TabButton {
                text: qsTr("BirchFlow")
                width: implicitWidth
                onClicked: app.state = "ABO"
            }
        }

        StackView {
            id: app_stack
            Layout.fillWidth: true
            Layout.fillHeight: true
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

    Dash {
        id: dash
        visible: false
    }

    Partners {
        id: partners
        visible: false
    }

    Contracts {
        id: contracts
        visible: false
    }

    Setting {
        id: setting
        visible: false
    }

    About {
        id: about
        visible: false
    }
}
