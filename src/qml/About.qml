import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

import "controls"
import "const.js" as Const
import DocFlow.models 1.0

Item {
    id: root
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

            text: "BirchFlow"

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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.verticalStretchFactor: 1

            Layout.leftMargin: Math.max(0, (parent.width - 600) / 2)
            Layout.rightMargin: Math.max(0, (parent.width - 600) / 2)

            ColumnLayout {
                anchors.fill: parent
                spacing: 30

                RowLayout {
                    Layout.preferredWidth: 600
                    Layout.preferredHeight: 44
                    Layout.alignment: Layout.Center
                    spacing: 20

                    Loader {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 44
                        active: true
                        sourceComponent: Image {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            source: "qrc:/qt/qml/BirchFlow/img/site-alt"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            cache: false
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        font.pixelSize: Qt.application.font.pixelSize * 1.2
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter

                        text: qsTr("Read the official documentation ")
                    }

                    Button_DF {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100

                        text: "VISIT"
                    }

                }

                RowLayout {
                    Layout.preferredWidth: 600
                    Layout.preferredHeight: 44
                    Layout.alignment: Layout.Center
                    spacing: 20

                    Loader {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 44
                        active: true
                        sourceComponent: Image {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            source: "qrc:/qt/qml/BirchFlow/img/bug"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            cache: false
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        font.pixelSize: Qt.application.font.pixelSize * 1.2
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter

                        text: qsTr("If you have a suggestion or found a bug")
                    }

                    Button_DF {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100

                        text: "ISSUE"
                    }

                }

                RowLayout {
                    Layout.preferredWidth: 600
                    Layout.preferredHeight: 44
                    Layout.alignment: Layout.Center
                    spacing: 20

                    Loader {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 44
                        active: true
                        sourceComponent: Image {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            source: "qrc:/qt/qml/BirchFlow/img/support"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
                            cache: false
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        font.pixelSize: Qt.application.font.pixelSize * 1.2
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter

                        text: qsTr("Thanks for support ")
                    }

                    Button_DF {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 100

                        text: "SUPPORT"
                    }
                }
                Item {
                    Layout.fillHeight: true
                    Layout.verticalStretchFactor: 1
                }
            }
        }

        Label {
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight

            text: "MADE IN UKRAINE"

            color: Const.CLR_YELLOW_TRUE

            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: Qt.application.font.pixelSize * .8
        }
    }

}
