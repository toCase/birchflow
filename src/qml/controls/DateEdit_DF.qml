// DateTimePicker.qml
import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../const.js" as Const

Item {
    id: root
    width: 156
    height: 44

    property alias df_date: dtp_text.text

    function setDate(dateString){
        let d = Date.fromLocaleDateString(Qt.locale(), dateString, String(appSetting.getValue("dateFormat")))
        grid.month = d.getMonth()
        grid.year = d.getFullYear()
        dtp_text.text = dateString
    }

    RowLayout {
        anchors.fill: root
        spacing: 0

        TextField {
            id: dtp_text
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.topMargin: 5
            Layout.bottomMargin: 5

            readOnly: true

            horizontalAlignment: Qt.AlignHCenter
        }
        ToolButton {
            Layout.preferredHeight: 44
            Layout.preferredWidth: 44

            icon.source: "qrc:/qt/qml/BirchFlow/img/calendar"
            icon.width: 16
            icon.height: 16
            icon.color: Const.CLR_ICON

            onClicked: {
                let d = Date.fromLocaleDateString(Qt.locale(), root.df_date, String(appSetting.getValue("dateFormat")))
                grid.month = d.getMonth()
                grid.year = d.getFullYear()

                dtp_calender.open()
            }
        }
    }

    Popup {
        id: dtp_calender
        width: 300
        height: 250
        x: 0
        y: 50
        modal: false

        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        // === Анимации при открытии и закрытии ===
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 150 }
            NumberAnimation { property: "scale"; from: 0.95; to: 1.0; duration: 150 }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 150 }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.95; duration: 150 }
        }

        // Начальные состояния
        opacity: 0
        scale: 0.95

        ColumnLayout{
            anchors.fill: parent
            spacing: 3

            RowLayout {
                Layout.preferredHeight: 44
                Layout.fillWidth: true

                Button_DF {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 44
                    Layout.topMargin: -5
                    Layout.bottomMargin: -7

                    icon.source: "qrc:/qt/qml/BirchFlow/img/prev"
                    icon.width: 16
                    icon.height: 16
                    icon.color: Const.CLR_ICON

                    flat: true

                    onClicked: {
                        if (grid.month > 0) {
                            grid.month -= 1
                        } else {
                            grid.month = 11
                            grid.year -= 1
                        }
                    }
                }

                Label {
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    text: grid.title.toUpperCase()

                    horizontalAlignment: Qt.AlignHCenter
                    verticalAlignment: Qt.AlignVCenter

                    color: Const.CLR_YELLOW
                }

                Button_DF {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 44
                    Layout.topMargin: -5
                    Layout.bottomMargin: -7

                    icon.source: "qrc:/qt/qml/BirchFlow/img/next"
                    icon.width: 16
                    icon.height: 16
                    icon.color: Const.CLR_ICON

                    flat: true

                    onClicked: {
                        if (grid.month < 11) {
                            grid.month += 1
                        } else {
                            grid.month = 0
                            grid.year += 1
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillHeight: true
                Layout.fillWidth: true

                columns: 2


                DayOfWeekRow {
                    locale: grid.locale

                    Layout.column: 1
                    Layout.fillWidth: true

                    delegate: Label {
                        text: shortName.toUpperCase()
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Const.CLR_YELLOW

                        required property string shortName
                    }
                }

                WeekNumberColumn {
                    month: grid.month
                    year: grid.year
                    locale: grid.locale

                    Layout.fillHeight: true

                    delegate: Label {
                        text: weekNumber
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        color: Const.CLR_YELLOW

                        required property int weekNumber
                    }
                }

                MonthGrid {
                    id: grid
                    month: new Date().getMonth()
                    year: new Date().getFullYear()
                    locale: Qt.locale()

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    delegate: Rectangle {
                        required property var model

                        color: "transparent"
                        radius: 3
                        Label {
                            id: label
                            anchors.centerIn: parent
                            opacity: model.month === grid.month ? 1 : 0
                            text: grid.locale.toString(model.date, "d")
                            font: grid.font
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onHoveredChanged: {

                                parent.color = containsMouse ? Const.CLR_YELLOW : "transparent"
                                label.color = containsMouse ? "#000000" : "#FFFFFF"
                            }
                            onClicked: {

                                dtp_text.text = grid.locale.toString(model.date, String(appSetting.getValue("dateFormat")))
                                dtp_calender.close()
                            }
                        }
                    }
                }
            }
        }
    }
}
