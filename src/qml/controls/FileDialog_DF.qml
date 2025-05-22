import QtQuick
import Qt.labs.platform

FileDialog {
    id: dia_file
    folder: StandardPaths.standardLocations(StandardPaths.DocumentsLocation)[0]
    fileMode: FileDialog.OpenFile
    nameFilters: [
        "All supported files (*.txt *.md *.nfo *.asc *.log *.ini *.doc *.docx *.odt *.rtf
                                *.pages *.wps *.sxw *.pdf *.ps *.djvu *.tex *.rtfd *.xml
            *.json *.yaml *.yml *.csv *.xls *.xlsx *.ppt *.pptx *.epub *.fb2 *.msg *.eml)",
        "Text (*.txt *.md *.nfo *.asc *.log *.ini)",
        "Office (*.doc *.docx *.odt *.rtf *.pages *.wps *.sxw)",
        "Formatted (*.pdf *.ps *.djvu *.tex *.rtfd)",
        "Structured (*.xml *.json *.yaml *.yml *.csv)",
        "Tables/Presentations (*.xls *.xlsx *.ppt *.pptx)",
        "E-books/Other (*.epub *.fb2 *.msg *.eml)"
    ]

}
