import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material

import "../const.js" as Const

Item {
    id: root
    width: 220
    height: 170

    property real amount: 1000
    property real paid: 600
    property real progress: Math.min(1.0, paid / amount)
    property string currency: "USD"

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
            ctx.strokeStyle = Const.CLR_YELLOW;
            ctx.lineWidth = 13;
            ctx.lineCap = "round";
            ctx.stroke();
        }
        Connections {
            target: root
            function onProgressChanged() { canvas.requestPaint() }
            function onPaidChanged(){ canvas.requestPaint() }
            function onAmountChanged(){ canvas.requestPaint() }
        }
    }

    // Текст по центру (можно поднять выше, чтобы не наезжал)
    Label {
        id: perc
        anchors.horizontalCenter: root.horizontalCenter
        y: 70
        text: Math.round(root.progress * 100) + "%"
        font.pointSize: 24
        // color: "#333"
    }
    Row {
        anchors.top: perc.bottom
        anchors.horizontalCenter: root.horizontalCenter
        height: children.implicitHeight
        // width: children.implicitWidth
        Label {
            text: root.paid + " " + root.currency + " / "
            font.pointSize: 11
            font.bold: true
            font.italic: true
            verticalAlignment: Qt.AlignBottom
        }
        Label {
            height: parent.height
            text: root.amount + " " + root.currency
            font.pointSize: 8
            font.italic: true
            verticalAlignment: Qt.AlignBottom
        }
    }

    Behavior on progress {
        NumberAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }
}
