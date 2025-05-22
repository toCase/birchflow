import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../const.js" as Const
import "../controls"

Item {

    id: partner_main

    signal open(int partner_id)

    QtObject {
        id: internal

        function save() {
            let card = {}
            card.id = 0
            card.name = new_name.text

            let res = modelPartners.add(card);

            if (res.r) {
                partner_main.open(res.id)
            }
        }
    }




    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 15

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            Layout.leftMargin: 60
            Layout.rightMargin: 60

            TextField {
                id: cm_filter
                Layout.fillHeight: true
                Layout.preferredWidth: partner_main.width / 2
                Layout.topMargin: 5
                Layout.bottomMargin: 5

                placeholderText: qsTr("filter by title, reg code, address, description...")
                onTextEdited: modelProxyPartner.setFilter(text)
            }
            Item {
                Layout.fillWidth: true
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 80
                text: qsTr("ADD")
                onClicked: {
                    new_name.clear()
                    dia_new.open()
                }
            }
        }

        ListView {
            id: cm_table
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.verticalStretchFactor: 1
            Layout.leftMargin: 60
            Layout.rightMargin: 60
            model: modelProxyPartner
            spacing: 5
            clip: true

            delegate: Item {

                id: row
                width: cm_table.width
                height: 75

                required property int c_id;
                required property string c_code;
                required property string c_name;
                required property string real_address;
                required property string c_url;
                required property int c_contracts;
                required property int index;

                Rectangle {
                    id: row_bg
                    anchors.fill: parent
                    color: Const.CLR_ROW
                    radius: 5
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        row_bg.color = containsMouse ? Const.CLR_YELLOW : Const.CLR_ROW
                        row_bg.opacity = containsMouse ? .3 : 1
                    }
                    onClicked: partner_main.open(row.c_id)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 15
                    spacing: 20

                    Label {
                        Layout.preferredWidth: 120
                        Layout.fillHeight: true

                        text: c_code
                        elide: Text.ElideRight
                        font.pixelSize: Qt.application.font.pixelSize * 1.1
                        font.bold: true
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight
                            Layout.leftMargin: 15

                            text: c_name.toUpperCase()
                            font.pixelSize: Qt.application.font.pixelSize * 1.3
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: Const.CLR_YELLOW }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight

                            text: real_address
                            font.pixelSize: Qt.application.font.pixelSize * .8
                        }
                    }
                    Label {
                        Layout.preferredWidth: 150
                        Layout.fillHeight: true

                        text: c_contracts > 0 ? c_contracts : ""
                        font.pixelSize: Qt.application.font.pixelSize * 1.3
                        font.bold: true
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                    }
                    ToolButton {
                        Layout.preferredHeight: 44
                        Layout.preferredWidth: 44
                        icon.source: "qrc:/qt/qml/BirchFlow/img/info"
                        icon.width: 16
                        icon.height: 16
                        icon.color: Const.CLR_ICON
                        onClicked: {
                            partners_info.markdownText = modelPartners.getInfoDoc(c_id)
                            partners_info.open()
                        }
                    }
                }
            }
        }
    }


    PartnersInfo {
        id: partners_info
        x: partner_main.width * .2
        y: partner_main.width * .05
        width: partner_main.width - (2 * (partner_main.width * .2))
        height: partner_main.height - (2 * (partner_main.height * .05))
    }

    Dialog {
        id: dia_new
        x: partner_main.width * .2
        y: partner_main.width * .05
        width: partner_main.width - (2 * (partner_main.width * .2))
        height: 180

        title: qsTr("New partner")
        contentItem: ColumnLayout {
            TextField {
                id: new_name
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Layout.leftMargin: 30
                Layout.rightMargin: 30
                Layout.topMargin: 12
                Layout.bottomMargin: 12
                placeholderText: qsTr("Short title")
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

                Item {
                    Layout.fillWidth: true
                    Layout.horizontalStretchFactor: 1
                }
                Button_DF {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                    text: qsTr("Save")
                    onClicked:  {
                        if (new_name.text.trim().length === 0) {
                            new_name.focus = true
                        } else {
                            internal.save()
                            dia_new.accept()
                        }
                    }
                }
                Button_DF {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 100
                    text: qsTr("Close")
                    onClicked: dia_new.close()
                }
            }
        }
    }
}
