import QtQuick
import QtQuick.Controls

Item {
    id: notificator
    property var messages: []
    property int m_spacing: 15
    property int m_startY: notificator.height - m_heightNote - 15
    property int m_heightNote: 60

    function createMessage(textNote, typeNote) {
        let popup = Qt.createComponent("qrc:/qt/qml/BirchFlow/qml/controls/Notify_DF.qml").createObject(Overlay.overlay, {textNote:textNote, typeNote:typeNote});

        messages.push(popup)

        popup.closed.connect(function(){
            let idx = messages.indexOf(popup)
            if (idx !== -1) {
                messages.splice(idx, 1)
                updatePositions()
            }
            popup.destroy(200)
        })

        updatePositions()
    }

    function updatePositions() {
        let currentY = m_startY
        for (let i = 0; i < messages.length; i++) {
            let popup = messages[i]

            let anim = popupAnimComponent.createObject(popup, {
                        "target": popup,
                        "property": "y",
                        "to": currentY,
                        "duration": 200,
                        "easing.type": Easing.OutQuad
                    })
            anim.start()

            currentY -= m_heightNote + m_spacing
        }
    }

    Component {
        id: popupAnimComponent
        NumberAnimation {}
    }

    Connections {
        target: noteManager
        function onNotify(textNote, typeNote){
            createMessage(textNote, typeNote)
        }
    }
}
