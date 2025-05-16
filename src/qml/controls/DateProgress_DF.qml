import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import "../const.js" as Const

Item {
    id: root
    width: 220
    height: 170

    property string dateFrom: ""
    property string dateTo: ""

    property date m_dateFrom: new Date()
    property date m_dateTo: new Date()
    property date m_today: new Date()

    property real progress: 0

    function parseDatesAndCalcProgress() {
        if (root.dateFrom !== "" && root.dateTo !== "") {
            root.m_dateFrom = Date.fromLocaleDateString(Qt.locale(), root.dateFrom, String(appSetting.getValue("dateFormat")))
            root.m_dateTo = Date.fromLocaleDateString(Qt.locale(), root.dateTo, String(appSetting.getValue("dateFormat")))

            var total = root.m_dateTo - root.m_dateFrom
            var done = root.m_today - root.m_dateFrom
            root.progress = Math.max(0, Math.min(1, done / total))
        }
    }

    onDateFromChanged: parseDatesAndCalcProgress()
    onDateToChanged: parseDatesAndCalcProgress()

    Component.onCompleted: {
        parseDatesAndCalcProgress()
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            var centerX = width / 2;
            var centerY = 110;
            var radius = 100;
            var startAngle = Math.PI;
            var endAngle = startAngle + Math.PI * root.progress;

            ctx.clearRect(0, 0, width, height);

            // фон
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, startAngle, 2 * Math.PI);
            ctx.strokeStyle = "#e0e0e0";
            ctx.lineWidth = 13;
            ctx.lineCap = "round";
            ctx.stroke();

            // прогресс
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, startAngle, endAngle);
            ctx.strokeStyle = root.progress < 0.8 ? Const.CLR_GREEN : Const.CLR_RED
            ctx.lineWidth = 13;
            ctx.lineCap = "round";
            ctx.stroke();
        }
        Connections {
            target: root
            function onProgressChanged() { canvas.requestPaint() }
        }
    }

    Label {
        id: perc
        anchors.horizontalCenter: root.horizontalCenter
        y: 70
        text: Math.round(root.progress * 100) + "%"
        font.pointSize: 24
    }
    Label {
        anchors.top: perc.bottom
        anchors.horizontalCenter: root.horizontalCenter
        height: implicitHeight
        text: root.dateFrom + " - " + root.dateTo
        font.pointSize: 11
        font.bold: true
        font.italic: true
        verticalAlignment: Qt.AlignBottom
    }

    Behavior on progress {
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }
}
