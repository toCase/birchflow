import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "controls"
import "const.js" as Const
import DocFlow.models 1.0

Dialog {
    id: root
    z:5

    modal: true

    header: Item {
        width: root.width
        height: 50

        RowLayout {
            anchors.fill: parent
            anchors.margins: 3
            spacing: 5

            Item {
                Layout.fillWidth: true
            }
            Button_DF {
                Layout.fillHeight: true
                Layout.preferredWidth: 44
                flat: true
                text: "X"
                onClicked: close()
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        spacing: 5

        Loader {
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            active: true
            sourceComponent: Image {
                anchors.centerIn: parent
                width: 95
                height: 95
                source: "qrc:/qt/qml/BirchFlow/img/app_icon"
                fillMode: Image.PreserveAspectFit
                mipmap: true
                cache: false
            }
        }
        Label {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            text: "DocFlow"

            font.pixelSize: Qt.application.font.pixelSize * 3
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }
        Label {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            text: "version 1.0.2"

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
        }
        Item {
            Layout.preferredHeight: 20
        }

        Row {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            spacing: 30

            Loader {
                Layout.fillHeight: true
                Layout.preferredWidth: 70
                active: true
                sourceComponent: Image {
                    anchors.centerIn: parent
                    width: 35
                    height: 35
                    source: "qrc:/qt/qml/BirchFlow/img/site-alt"
                    fillMode: Image.PreserveAspectFit
                    mipmap: true
                    cache: false
                }
            }
            Label {
                Layout.fillWidth: true
                Layout.fillHeight: true

                font.pixelSize: Qt.application.font.pixelSize * .9
                horizontalAlignment: Qt.AlignLeft
                verticalAlignment: Qt.AlignVCenter
                wrapMode: Text.WordWrap

                text: qsTr("Read the official documentation of DocFlow on the official website.")
            }

            Button_DF {
                Layout.preferredHeight: 44
                Layout.preferredWidth: 80

                text: "Visit"
            }

        }


        Item {
            Layout.fillHeight: true
            Layout.verticalStretchFactor: 1
        }
        Label {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            text: "toCaseDev 2025"

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: Qt.application.font.pixelSize * .8
        }
    }

}
