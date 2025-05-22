import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../const.js" as Const
import "../controls"

Item {
    id: root

    property string title: qsTr("Partners")
    property int main_value: 0
    property string add_value: qsTr("+2 partner added")
    property string icon_title: "qrc:/qt/qml/BirchFlow/img/partner"

    property color clr_title: Const.CLR_GREEN


    Rectangle {
        anchors.fill: parent

        border.width: 2
        border.color: Const.CLR_YELLOW
        color: "transparent"

        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 5

            RowLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true
                spacing: 15

                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 5
                    radius: 5
                    color: root.clr_title
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Label {
                        Layout.fillWidth: true
                        Layout.preferredHeight: implicitHeight

                        text: root.title
                        font.pixelSize: Qt.application.font.pixelSize
                        font.bold: true
                        horizontalAlignment: Qt.AlignLeft
                        verticalAlignment: Qt.AlignVCenter
                    }

                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        text: String(root.main_value)
                        font.pixelSize: Qt.application.font.pixelSize * 4
                        font.bold: true
                        horizontalAlignment: Qt.AlignHCenter
                        verticalAlignment: Qt.AlignVCenter
                    }
                }
            }

            Label {
                Layout.fillWidth: true
                Layout.preferredHeight: implicitHeight
                text: root.add_value
                font.italic: true
                color: Const.CLR_GREEN
            }
        }
    }
    Loader {
        x: root.width - 40
        y: 16
        width: 24
        height: 24
        sourceComponent:  Image {
            width: 24
            height: 24
            source: root.icon_title
            fillMode: Image.PreserveAspectFit
            mipmap: true
            cache: false
        }
    }

    Behavior on main_value {
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }
}
