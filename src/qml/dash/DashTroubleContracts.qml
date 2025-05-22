import QtQuick
import QtCharts
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../const.js" as Const
import "../controls"

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 8

        Label {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight
            text: qsTr("Expired contracts")
            font.pixelSize: Qt.application.font.pixelSize
            font.bold: true
            horizontalAlignment: Qt.AlignLeft
            verticalAlignment: Qt.AlignVCenter
        }

        ListView {
            id: table
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: proxyDashContracts
            spacing: 5
            clip: true

            delegate: Rectangle {

                id: row
                width: table.width
                height: 40
                color: Const.CLR_ROW
                radius: 5

                required property int c_id;
                required property string c_num;
                required property string c_date;
                required property string partner;
                required property string valid_from;
                required property string valid_to;
                required property string amount;
                required property string currency;
                required property int status;
                required property int c_type;
                required property string c_paid
                required property int index;

                /*MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        row.color = containsMouse ? "#4b5159" : Const.CLR_ROW
                    }
                onClicked: {
                    if (row.status === 4) {
                        internal.view_arch(c_id)
                    } else {
                        contract_list.open(c_id)
                    }
                }
                }*/

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 3
                    spacing: 8

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 3
                        color: {
                            if (c_type === 1) {
                                Const.CLR_GREEN
                            } else if (c_type === 2) {
                                Const.CLR_ORANGE
                            }
                        }
                        radius: 3
                    }

                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 70
                        text: row.c_num
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9

                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 60
                        text: row.c_date
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.fillWidth:  true
                        text: row.partner
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 1.1
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 200
                        text: row.valid_from + " - " + row.valid_to
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        text: row.amount + " " + row.currency
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 80
                        text: row.c_paid
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                    }
                    Label {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100
                        color:  {
                            if (row.status === 1) {
                                Const.CLR_GREEN
                            } else if (row.status === 2) {
                                Const.CLR_RED
                            } else if (row.status === 3) {
                                Const.CLR_ORANGE
                            } else if (row.status === 4) {
                                Const.CLR_YELLOW
                            }
                        }
                        text: {
                            if (row.status === 1) {
                                qsTr("ACTIVE")
                            } else if (row.status === 2) {
                                qsTr("ABORTED")
                            } else if (row.status === 3) {
                                qsTr("COMPLETED")
                            } else if (row.status === 4) {
                                qsTr("ARCHIVED")
                            }
                        }
                        font.pixelSize: Qt.application.font.pixelSize * 0.9
                        font.bold: true
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter

                    }
                }
            }
        }
    }
}
