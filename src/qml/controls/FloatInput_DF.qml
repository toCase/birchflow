import QtQuick
import QtQuick.Controls

import "../const.js" as Const

SpinBox {
    id: root

    property int decimals: 5
    property real realValue: value / factor
    property real realFrom: from / factor
    property real realTo: to / factor
    property real realStepSize: stepSize / factor
    property real factor: Math.pow(10, decimals)
    property bool isEditing: false
    property bool showButtons: true
    property bool isInternalUpdate: false

    editable: true

    // Ограничиваем диапазон для положительных чисел
    from: 1 // Минимальное значение для положительных чисел
    to: 2147483647   // Максимальное значение для 32-битного целого числа
    stepSize: {
        // Убеждаемся, что stepSize корректно сконвертирован в целое число
        const step = Math.round(realStepSize * factor)
        return step > 0 ? step : 1
    }

    signal realValueModified(real newValue)
    signal realValueUpdated(real newValue)

    // Инициализация с корректным диапазоном
    // Component.onCompleted: {
    //     const minValue = 0.0000001
    //     const maxValue = 10000000

    //     from = Math.max(1, Math.round(minValue * factor))
    //     to = Math.round(maxValue * factor)
    // }

    // Проверяем, находится ли значение в допустимом диапазоне
    function isValueInRange(val) {
        return val >= realFrom && val <= realTo
    }

    // Безопасное обновление значения с проверкой диапазона
    function safeSetValue(newValue) {
        if (isValueInRange(newValue) && newValue > 0) {
            if (!isInternalUpdate) {
                isInternalUpdate = true
                realValue = newValue
                value = Math.round(newValue * factor)
                isInternalUpdate = false
            }
        }
    }

    onRealValueChanged: {
        if (!isInternalUpdate) {
            isInternalUpdate = true
            if (isValueInRange(realValue) && realValue > 0) {
                value = Math.round(realValue * factor)
                realValueUpdated(realValue)
            }
            isInternalUpdate = false
        }
    }

    onValueChanged: {
        if (!isInternalUpdate) {
            isInternalUpdate = true
            const newRealValue = value / factor
            if (Math.abs(newRealValue - realValue) > 1e-10 && isValueInRange(newRealValue) && newRealValue > 0) {
                realValue = newRealValue
            }
            isInternalUpdate = false
        }
    }

    onValueModified: {
        realValueModified(realValue)
    }

    // Обновляем параметры при изменении decimals
    onDecimalsChanged: {
        isInternalUpdate = true
        const oldRealValue = realValue
        factor = Math.pow(10, decimals)

        // Обновляем границы с учетом нового factor
        const minValue = 0.0000001
        const maxValue = 10000000

        from = Math.max(1, Math.round(minValue * factor))
        to = Math.round(maxValue * factor)

        // Обновляем значение с учетом нового factor
        value = Math.round(oldRealValue * factor)
        isInternalUpdate = false
    }

    // Обновляем stepSize при изменении realStepSize
    onRealStepSizeChanged: {
        const step = Math.round(realStepSize * factor)
        stepSize = step > 0 ? step : 1
    }

    validator: RegularExpressionValidator {
        regularExpression: /^[0-9]*\.?[0-9]{0,5}$/
    }

    textFromValue: function(value, locale) {
        return (value / factor).toFixed(decimals)
    }

    valueFromText: function(text, locale) {
        if (text === "" || text === ".") return 0
        const val = parseFloat(text)
        if (val <= 0) return from
        if (isValueInRange(val)) {
            return Math.round(val * factor)
        }
        return value // Возвращаем текущее значение если новое вне диапазона
    }

    inputMethodHints: Qt.ImhFormattedNumbersOnly

    contentItem: TextInput {
        text: root.textFromValue(root.value, root.locale)
        font: root.font
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !root.enabled
        color: root.enabled ? root.palette.text : Const.CLR_ROW
        selectionColor: root.palette.highlight
        selectedTextColor: root.palette.highlightedText
        validator: root.validator
        inputMethodHints: root.inputMethodHints

        onFocusChanged: {
            if (focus) {
                isEditing = true
                selectAll()
            } else {
                if (isEditing) {
                    isEditing = false
                    root.value = root.valueFromText(text)
                }
            }
        }

        onTextEdited: {
            isEditing = true
        }
    }

    up.indicator: showButtons ? up.indicator : null
    down.indicator: showButtons ? down.indicator : null

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        propagateComposedEvents: true

        onWheel: function(wheel) {
            if (root.enabled) {
                const delta = wheel.angleDelta.y > 0 ? realStepSize : -realStepSize
                const newValue = realValue + delta

                if (isValueInRange(newValue) && newValue > 0) {
                    safeSetValue(newValue)
                    root.valueModified()
                } else {
                    if (newValue > realTo) {
                        safeSetValue(realTo)
                        root.valueModified()
                    }
                    if (newValue < realFrom) {
                        safeSetValue(realFrom)
                        root.valueModified()
                    }

                }
            }
        }
    }

    Keys.onPressed: function(event) {
        if (!root.enabled) return
        if (event.text === ",") {
            event.accepted = true
            contentItem.insert(contentItem.cursorPosition, ".")
        }
    }

    Keys.onEnterPressed: focus = false
    Keys.onReturnPressed: focus = false
}
