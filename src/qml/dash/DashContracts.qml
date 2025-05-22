import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../const.js" as Const
import "../controls"

Item {
    id: root

    property real m_active: .35
    property real m_completed: .45
    property real m_aborted: .05
    property real m_archive: .15

    property real c_active: 0
    property real c_completed: 0
    property real c_aborted: 0
    property real c_archive: 0

    property int m_contracts: 0

    function updateData() {
        let data = {}
        if (but_all.checked) {
            data = dashManager.dashContractData(0);
        } else if (but_prof.checked) {
            data = dashManager.dashContractData(1);
        } else if (but_cons.checked) {
            data = dashManager.dashContractData(2);
        }
        root.m_active = data.m_active
        root.m_completed = data.m_completed
        root.m_aborted = data.m_aborted
        root.m_archive = data.m_archive

        root.m_contracts = data.contracts_count
        root.c_active = data.active
        root.c_completed = data.completed
        root.c_aborted = data.aborted
        root.c_archive = data.archive

        canvas.requestPaint()
    }

    onM_activeChanged: canvas.requestPaint()
    onM_completedChanged: canvas.requestPaint()
    onM_abortedChanged: canvas.requestPaint()
    onM_archiveChanged: canvas.requestPaint()


    Rectangle {
        anchors.fill: parent

        // border.width: 2
        // border.color: Const.CLR_YELLOW
        color: "transparent"

        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            spacing: 15

            Label {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight

                text: qsTr("Contracts")
                font.pixelSize: Qt.application.font.pixelSize
                font.bold: true
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 35
                spacing: 5

                ButtonGroup{id: selector}

                Button {
                    id: but_all
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("ALL")
                    checkable: true
                    checked: true
                    ButtonGroup.group: selector
                    onClicked: root.updateData()
                }
                Button {
                    id: but_prof
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("PROFITABLE")
                    checkable: true
                    checked: false
                    ButtonGroup.group: selector
                    onClicked: root.updateData()
                }
                Button {
                    id: but_cons
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("CONSUMABLE")
                    checkable: true
                    checked: false
                    ButtonGroup.group: selector
                    onClicked: root.updateData()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.verticalStretchFactor: 1


                Canvas {
                    id: canvas
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.horizontalStretchFactor: 1

                    onPaint: {
                        var ctx = getContext("2d");
                        var centerX = canvas.width / 2;
                        var centerY = canvas.height / 2;
                        var radius = 100;
                        var line_width = 20;
                        var startAngle = 0;
                        var angleA = startAngle + 2 * Math.PI * root.m_active;
                        var angleB = angleA + 2 * Math.PI * root.m_completed;
                        var angleC = angleB + 2 * Math.PI * root.m_aborted;
                        var angleD = angleC + 2 * Math.PI * root.m_archive;



                        ctx.clearRect(0, 0, width, height);
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                        ctx.strokeStyle = "#FFFFFF";
                        ctx.lineWidth = line_width;
                        ctx.lineCap = "round";
                        ctx.stroke();

                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, startAngle, angleA);
                        ctx.strokeStyle = Const.CLR_GREEN;
                        ctx.lineWidth = line_width;
                        ctx.lineCap = "round";
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, angleA, angleB);
                        ctx.strokeStyle = Const.CLR_ORANGE;
                        ctx.lineWidth = line_width;
                        ctx.lineCap = "round";
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, angleB, angleC);
                        ctx.strokeStyle = Const.CLR_RED;
                        ctx.lineWidth = line_width;
                        ctx.lineCap = "round";
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(centerX, centerY, radius, angleC, angleD);
                        ctx.strokeStyle = Const.CLR_YELLOW;
                        ctx.lineWidth = line_width;
                        ctx.lineCap = "round";
                        ctx.stroke();
                    }

                    Label {
                        anchors.centerIn: parent
                        text: root.m_contracts
                        font.pixelSize: Qt.application.font.pixelSize * 6
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100

                    spacing: 5
                    Item{
                        Layout.fillHeight: true
                        Layout.verticalStretchFactor: 1
                    }
                    RowLayout {
                        Layout.preferredHeight: 20
                        Layout.fillWidth: true
                        spacing: 5

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 40
                            radius: 20
                            color: Const.CLR_GREEN
                            Label {
                                anchors.centerIn: parent
                                text: root.c_active
                                font.pixelSize: Qt.application.font.pixelSize * .8
                            }
                        }
                        Label {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: qsTr("ACTIVE")
                            font.pixelSize: Qt.application.font.pixelSize * .9
                            verticalAlignment: Qt.AlignVCenter
                        }
                    }
                    RowLayout {
                        Layout.preferredHeight: 20
                        Layout.fillWidth: true
                        spacing: 5

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 40
                            radius: 20
                            color: Const.CLR_ORANGE
                            Label {
                                anchors.centerIn: parent
                                text: root.c_completed
                                font.pixelSize: Qt.application.font.pixelSize * .8
                            }
                        }
                        Label {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: qsTr("COMPLETED")
                            font.pixelSize: Qt.application.font.pixelSize * .9
                            verticalAlignment: Qt.AlignVCenter
                        }
                    }
                    RowLayout {
                        Layout.preferredHeight: 20
                        Layout.fillWidth: true
                        spacing: 5

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 40
                            radius: 20
                            color: Const.CLR_RED
                            Label {
                                anchors.centerIn: parent
                                text: root.c_aborted
                                font.pixelSize: Qt.application.font.pixelSize * .8
                            }
                        }
                        Label {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: qsTr("ABORTED")
                            font.pixelSize: Qt.application.font.pixelSize * .9
                            verticalAlignment: Qt.AlignVCenter
                        }
                    }
                    RowLayout {
                        Layout.preferredHeight: 20
                        Layout.fillWidth: true
                        spacing: 5

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 40
                            radius: 20
                            color: Const.CLR_YELLOW
                            Label {
                                anchors.centerIn: parent
                                text: root.c_archive
                                font.pixelSize: Qt.application.font.pixelSize * .8
                            }
                        }
                        Label {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            text: qsTr("ARCHIVE")
                            font.pixelSize: Qt.application.font.pixelSize * .9
                            verticalAlignment: Qt.AlignVCenter
                        }
                    }
                }
            }
        }
    }



    Behavior on m_contracts {
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on m_active {
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on m_completed {
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on m_aborted {
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on m_archive {
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    Component.onCompleted: update()
}
