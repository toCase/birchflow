import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "../const.js" as Const
import "../controls"

Item {

    id: partner_main

    signal open(int i)

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

                placeholderText: "filter..."
                onTextEdited: modelProxyPartner.setFilter(text)
            }
            Item {
                Layout.fillWidth: true
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 80
                text: "ADD"
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

            delegate: Rectangle {

                id: row
                width: cm_table.width
                height: 135
                color: Const.CLR_ROW
                radius: 5

                required property int c_id;
                required property string c_name;
                required property string real_address;
                required property string c_url;
                required property int index;

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onHoveredChanged: {
                        row.color = containsMouse ? "#4b5159" : Const.CLR_ROW
                    }
                    onClicked: partner_main.open(c_id)
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 35
                    spacing: 5

                    ColumnLayout {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        spacing: 2

                        Label {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight

                            text: c_name.toUpperCase()
                            font.pixelSize: Qt.application.font.pixelSize * 1.7
                            font.bold: true
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1
                            color: "#1f2630"
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight

                            text: real_address
                            font.pixelSize: Qt.application.font.pixelSize * .8
                        }
                        Label {
                            Layout.fillWidth: true
                            Layout.preferredHeight: implicitHeight

                            text: c_url
                            font.pixelSize: Qt.application.font.pixelSize * .8
                        }
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 200
                    }
                    ToolButton {
                        Layout.preferredHeight: 44
                        Layout.preferredWidth: 44
                        icon.source: "qrc:/qt/qml/DocFlow/img/info"
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
                placeholderText: "Shot name"
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
