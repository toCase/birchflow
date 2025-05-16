import QtQuick
import QtQuick.Controls 2.15

import "const.js" as Const

Popup {
    id: note

    // Свойства из вашего оригинального компонента
    property int n_type: 0
    property string n_messa: ""
    property string objectIdentifier: ""

    // Координаты позиционирования
    x: n_x
    y: n_y

    // Размеры
    width: 500
    height: 50

    // Важные свойства для Popup
    z: 9999
    modal: false  // Не модальный, чтобы не блокировать интерфейс
    closePolicy: Popup.NoAutoClose  // Не закрывать автоматически
    padding: 0  // Убираем внутренние отступы, чтобы контент занимал все пространство

    // Фон
    background: Rectangle {
        radius: 5
        opacity: 0.8
        color: {
            if (note.n_type === 3) {
                return Const.CLR_GREEN
            } else if (note.n_type === 1) {
                return Const.CLR_RED
            } else if (note.n_type === 2) {
                return Const.CLR_YELLOW
            }
            return "gray"  // Значение по умолчанию
        }
    }

    // Контент
    contentItem: Label {
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        horizontalAlignment: Qt.AlignLeft
        verticalAlignment: Qt.AlignVCenter
        // font.pointSize: 13
        text: note.n_messa
        wrapMode: Text.WordWrap
    }

    // Открываем нотификацию при создании
    Component.onCompleted: {
        open()  // Важно вызвать open() для отображения Popup
    }

    // Можно добавить анимации появления и исчезновения
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
    }
}
