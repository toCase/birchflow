import QtQuick
import QtCharts
import QtQuick.Controls.Material
import QtQuick.Layouts

import "../const.js" as Const
import "../controls"


Item {
    id: root

    property list<string> m_currency: []
    property int m_currencyIndex: 0
    property real m_min: 0
    property real m_max: 10000

    property list<string> m_dates: []

    readonly property font titleFont: ({
                                           pointSize: Qt.application.font.pixelSize,
                                           weight: Font.Black,
                                           bold: true
                                       })

    readonly property font labelFont: ({
                                           pointSize: Qt.application.font.pixelSize * .8,
                                           weight: Font.Black,

                                       })



    function load() {
        modelPaySeries.load();
        modelPaySeries.updateModel();
        root.m_currency = modelPaySeries.currencyList();

    }

    Connections {
        target: modelPaySeries
        function onChangeMin(value){
            root.m_min = value
        }
        function onChangeMax(value) {
            root.m_max = value
        }
        function onChangeMonth(value) {
            root.m_dates = value
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 10

        ChartView {
            id: chart
            Layout.fillHeight: true
            Layout.fillWidth: true
            Layout.horizontalStretchFactor: 1

            title: " "

            backgroundColor: "transparent"
            legend.visible: false
            antialiasing: true

            animationOptions: ChartView.SeriesAnimations

            BarCategoryAxis {
                id: monthAxis
                titleText: qsTr("Month/Year")
                gridVisible: false
                categories: root.m_dates
                titleVisible: false
                labelsColor: Const.CLR_TEXT
                labelsFont: root.labelFont

            }

            ValuesAxis {
                id: amountAxis
                titleText: qsTr("Amount")
                gridVisible: false
                min: root.m_min
                max: root.m_max
                titleVisible: false
                labelsColor: Const.CLR_TEXT
                labelsFont: root.labelFont
            }

            BarSeries {
                id: series
                axisX: monthAxis
                axisY: amountAxis

                VBarModelMapper {
                    model: modelPaySeries
                    firstBarSetColumn: 1
                    lastBarSetColumn: 1
                    firstRow: 0
                }
                onHovered: (status, index, barset) => {
                               if (status) {
                                   tooltip.visible = true
                                   tooltip.text = root.m_dates[index] + " - " + barset.at(index) + " " + root.m_currency[root.m_currencyIndex]
                               } else {
                                   tooltip.visible = false
                               }
                           }
                onBarsetsAdded: {
                        for (let i = 0; i < count; i++) {
                            at(i).color = but_prof.checked ? Const.CLR_GREEN : Const.CLR_ORANGE
                            at(i).borderWidth = 0
                        }
                    }
            }
        }

        ColumnLayout {
            Layout.fillHeight: true
            Layout.preferredWidth: 80

            ButtonGroup {id: bgType}

            Button_DF {
                id: but_prof
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: qsTr("Profitable")
                font.pixelSize: Qt.application.font.pixelSize * .8
                checkable: true
                checked: true
                ButtonGroup.group: bgType
                onClicked: modelPaySeries.setContract(1)
            }
            Button_DF {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                text: qsTr("Consumable")
                font.pixelSize: Qt.application.font.pixelSize * .8
                checkable: true
                checked: false
                ButtonGroup.group: bgType
                onClicked: modelPaySeries.setContract(2)
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 3

                color: Const.CLR_YELLOW
                radius: 3
            }
            ButtonGroup {id: bgCurrency}

            Repeater {
                model: root.m_currency.length

                Button_DF {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30

                    text: root.m_currency[index]
                    font.pixelSize: Qt.application.font.pixelSize * .8
                    checkable: true
                    checked: false
                    ButtonGroup.group: bgCurrency

                    onClicked: {
                        modelPaySeries.setCurrency(index)
                        series.name = root.m_currency[index]
                        root.m_currencyIndex = index
                    }

                    Component.onCompleted: checked = index === 0 ? true : false
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.verticalStretchFactor: 1
            }
        }
    }

    Item {
        id: tooltip
        visible: false
        x: chart.width - width
        y: 20
        z: 20
        width: 180
        height: 30
        Label {
            anchors.centerIn: parent
            text: tooltip.text
            font.pixelSize: Qt.application.font.pixelSize * 1.1
        }
        property string text: ""
    }

    Label {
        id: title
        x: 100
        y: 20
        width: implicitWidth
        height: implicitHeight

        text: qsTr("Payment dynamics")
        font.pixelSize: Qt.application.font.pixelSize
        font.bold: true
    }
}


