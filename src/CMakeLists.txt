cmake_minimum_required(VERSION 3.16)

project(BirchFlow VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Sql Charts)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appBirchFlow
    main.cpp
)

qt_add_qml_module(appBirchFlow
    URI BirchFlow
    VERSION 1.0
    QML_FILES
    QML_FILES qml/App.qml
    QML_FILES qml/Main.qml
    QML_FILES qml/Dash.qml
    QML_FILES qml/Partners.qml
    QML_FILES qml/Contracts.qml
    QML_FILES qml/About.qml
    QML_FILES qml/partners/PartnersMain.qml
    QML_FILES qml/partners/PartnersForm.qml
    QML_FILES qml/partners/PartnersInfo.qml
    QML_FILES qml/partners/PartnersBanks.qml
    QML_FILES qml/partners/PartnersPersons.qml
    QML_FILES qml/partners/PartnersDocs.qml
    QML_FILES qml/partners/PartnersEdit.qml
    QML_FILES qml/const.js
    SOURCES app_namespaces.h
    SOURCES database.h database.cpp
    SOURCES m_partner.h m_partner.cpp
    RESOURCES
    SOURCES m_partnerbank.h m_partnerbank.cpp
    SOURCES m_partnerperson.h m_partnerperson.cpp
    SOURCES m_partnerdocs.h m_partnerdocs.cpp
    SOURCES filemanager.h filemanager.cpp
    RESOURCES img/asc.png img/csv.png img/djvu.png img/doc.png img/docx.png img/eml.png img/epub.png img/fb2.png
    RESOURCES img/ini.png img/json.png img/log.png img/md.png img/msg.png img/nfo.png img/odt.png img/pages.png img/pdf.png
    RESOURCES img/ppt.png img/pptx.png img/ps.png img/rtf.png img/rtfd.png img/sxw.png img/tex.png img/txt.png img/wps.png
    RESOURCES img/xls.png img/xlsx.png img/xml.png img/yaml.png img/yml.png img/trash.png img/open.png img/info.png
    RESOURCES img/prev.png img/next.png img/calendar.png img/edit.png img/del_doc.png img/change.png img/plus.png
    RESOURCES img/trend-up.png img/trend-down.png img/exp-up.png img/exp-down.png img/report.png img/zip-file.png
    RESOURCES img/app_icon.png img/settings.png img/help.png img/site-alt.png img/partner.png img/folder.png
    RESOURCES img/document.png img/exclamation.png img/icon-ok.png img/bug.png img/support.png
    QML_FILES qml/controls/Button_DF.qml
    SOURCES pm_partner.h pm_partner.cpp
    SOURCES pm_partnerbank.h pm_partnerbank.cpp
    SOURCES pm_partnerperson.h pm_partnerperson.cpp
    SOURCES pm_partnerdoc.h pm_partnerdoc.cpp
    QML_FILES qml/contracts/ContractsForm.qml
    QML_FILES qml/contracts/ContractsList.qml
    QML_FILES qml/contracts/ContractsDetail.qml
    SOURCES m_contracts.h m_contracts.cpp
    QML_FILES qml/controls/DateEdit_DF.qml
    SOURCES pm_partnercombo.h pm_partnercombo.cpp
    SOURCES m_currency.h m_currency.cpp
    QML_FILES
    SOURCES m_contractstatus.h
    SOURCES notificationmanager.h notificationmanager.cpp
    QML_FILES qml/AppNote.qml
    SOURCES
    QML_FILES
    QML_FILES qml/Notification.qml
    QML_FILES qml/controls/Notify_DF.qml
    SOURCES m_contractdocs.h m_contractdocs.cpp
    QML_FILES qml/contracts/DocumentForm.qml
    QML_FILES qml/contracts/PaymentForm.qml
    QML_FILES qml/controls/FloatInput_DF.qml
    QML_FILES qml/controls/PaidProgress_DF.qml
    QML_FILES qml/controls/DateProgress_DF.qml
    SOURCES tcd_settings.h tcd_settings.cpp
    QML_FILES qml/Setting.qml
    QML_FILES qml/controls/HiddenMenu_DF.qml
    QML_FILES qml/contracts/AmendmentForm.qml
    SOURCES servicemanager.h servicemanager.cpp
    QML_FILES qml/contracts/ContractsArchive.qml
    QML_FILES qml/contracts/ContractsListFilter.qml
    SOURCES pm_contracts.h pm_contracts.cpp
    QML_FILES qml/partners/PartnersDocDialog.qml
    QML_FILES qml/controls/AcceptDeleteDialog.qml
    QML_FILES qml/dash/DashNumberValue.qml
    SOURCES dashmanager.h dashmanager.cpp
    QML_FILES qml/dash/DashContracts.qml
    SOURCES m_payseries.h m_payseries.cpp
    QML_FILES qml/dash/DashPaymentChart.qml
    SOURCES pm_dashcontracts.h pm_dashcontracts.cpp
    QML_FILES qml/dash/DashTroubleContracts.qml
    QML_FILES qml/controls/FileDialog_DF.qml
    RESOURCES tr/app_ua.qm
    SOURCES translatemanager.h translatemanager.cpp
)

qt_add_resources(appBirchFlow "configuration"
    PREFIX "/"
    FILES
    qtquickcontrols2.conf
)

target_link_libraries(appBirchFlow
    PRIVATE Qt6::Quick
    PRIVATE Qt6::QuickControls2
    PRIVATE Qt6::Sql
    PRIVATE Qt6::Charts
)

include(GNUInstallDirs)
install(TARGETS appBirchFlow
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

set(REPO_ROOT_DIR ${CMAKE_SOURCE_DIR}/..)
install(FILES ${REPO_ROOT_DIR}/flatpak/io.github.toCase.Birchflow.svg
    DESTINATION ${CMAKE_INSTALL_DATADIR}/icons/hicolor/scalable/apps)
install(FILES ${REPO_ROOT_DIR}/flatpak/io.github.toCase.Birchflow.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
install(FILES ${REPO_ROOT_DIR}/flatpak/io.github.toCase.Birchflow.metainfo.xml
    DESTINATION ${CMAKE_INSTALL_DATADIR}/metainfo)
