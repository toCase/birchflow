import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
import QtCore

Dialog {
    id: dia_info

    title: "Summary information"
    standardButtons: Dialog.Ok
    property string markdownText: ""
    contentItem: ScrollView {
        ScrollBar.horizontal.interactive: true
        ScrollBar.vertical.interactive: true
        TextArea {
            id: ta
            readOnly: true
            wrapMode: TextEdit.WordWrap
            textFormat: TextEdit.MarkdownText
            text: markdownText
        }
    }
}
