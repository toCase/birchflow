#include <QGuiApplication>
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>

// managers
#include "database.h"
#include "filemanager.h"
#include "notificationmanager.h"
#include "tcd_settings.h"
#include "servicemanager.h"
#include "dashmanager.h"
#include "translatemanager.h"

// models
#include "m_partner.h"
#include "m_partnerbank.h"
#include "m_partnerperson.h"
#include "m_partnerdocs.h"
#include "m_contracts.h"
#include "m_currency.h"
#include "m_contractstatus.h"
#include "m_contractdocs.h"
#include "m_payseries.h"

// sort filter proxy models
#include "pm_partner.h"
#include "pm_partnercombo.h"
#include "pm_partnerbank.h"
#include "pm_partnerperson.h"
#include "pm_partnerdoc.h"
#include "pm_contracts.h"
#include "pm_dashcontracts.h"


int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    QQuickStyle::setStyle("Material");
    qputenv("QT_QUICK_CONTROLS_MATERIAL_VARIANT", "Dense");

    // Включаем отладочные сообщения
    qSetMessagePattern("[%{time h:mm:ss.zzz}] [%{type}] %{message}");

    QQmlApplicationEngine engine;

    QDir appDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    if (!appDir.exists()) QDir().mkdir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    QString setting_file = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/config.json";

    TCD_Settings *setting = new TCD_Settings(setting_file);
    engine.rootContext()->setContextProperty("appSetting", setting);

    DatabaseManager manager;
    DatabaseWorker *db_worker = new DatabaseWorker();

    FileManager *fileManager = new FileManager(QCoreApplication::applicationDirPath(), setting);

    NotificationManager *noteManager = new NotificationManager();
    engine.rootContext()->setContextProperty("noteManager", noteManager);

    ServiceManager serviceManager = ServiceManager(db_worker, fileManager, noteManager, setting);

    ModelCurrency *modelCurrency = new ModelCurrency(db_worker);
    engine.rootContext()->setContextProperty("modelCurrency", modelCurrency);

    ModelPartners *modelPartners = new ModelPartners(db_worker, noteManager, fileManager);
    engine.rootContext()->setContextProperty("modelPartners", modelPartners);

    PartnerProxyModel *modelProxyPartner = new PartnerProxyModel();
    modelProxyPartner->setSourceModel(modelPartners);
    modelProxyPartner->sortByRole(ModelPartners::NAME);
    engine.rootContext()->setContextProperty("modelProxyPartner", modelProxyPartner);

    PartnerComboModel *modelPartnerCombo = new PartnerComboModel();
    modelPartnerCombo->setSourceModel(modelPartners);
    modelPartnerCombo->sortByRole(ModelPartners::NAME);
    engine.rootContext()->setContextProperty("modelPartnerCombo", modelPartnerCombo);

    ModelPartnerBank *modelPartnerBank = new ModelPartnerBank(db_worker, noteManager);
    engine.rootContext()->setContextProperty("modelPartnerBank", modelPartnerBank);

    PartnerBankProxyModel *modelProxyPartnerBank = new PartnerBankProxyModel();
    modelProxyPartnerBank->setSourceModel(modelPartnerBank);
    modelProxyPartnerBank->sortByRole(ModelPartnerBank::NAME);
    engine.rootContext()->setContextProperty("modelProxyPartnerBank", modelProxyPartnerBank);

    ModelPartnerPerson *modelPartnerPerson = new ModelPartnerPerson(db_worker, noteManager);
    engine.rootContext()->setContextProperty("modelPartnerPerson", modelPartnerPerson);

    PartnerPersonProxyModel *modelProxyPartnerPerson = new PartnerPersonProxyModel();
    modelProxyPartnerPerson->setSourceModel(modelPartnerPerson);
    modelProxyPartnerPerson->sortByRole(ModelPartnerPerson::NAME);
    engine.rootContext()->setContextProperty("modelProxyPartnerPerson", modelProxyPartnerPerson);

    ModelPartnerDoc *modelPartnerDoc = new ModelPartnerDoc(db_worker, fileManager, noteManager);
    engine.rootContext()->setContextProperty("modelPartnerDoc", modelPartnerDoc);

    PartnerDocProxyModel *modelProxyPartnerDoc = new PartnerDocProxyModel();
    modelProxyPartnerDoc->setSourceModel(modelPartnerDoc);
    modelProxyPartnerDoc->sortByRole(ModelPartnerDoc::NAME);
    engine.rootContext()->setContextProperty("modelProxyPartnerDoc", modelProxyPartnerDoc);

    ModelContracts *modelContracts = new ModelContracts(db_worker, fileManager, noteManager, setting);
    engine.rootContext()->setContextProperty("modelContracts", modelContracts);

    ContractsProxyModel *modelProxyContracts = new ContractsProxyModel(setting);
    modelProxyContracts->setSourceModel(modelContracts);
    engine.rootContext()->setContextProperty("modelProxyContracts", modelProxyContracts);

    ModelContractDocs *modelContractDocs = new ModelContractDocs(db_worker, fileManager, noteManager, setting);
    engine.rootContext()->setContextProperty("modelContractDocs", modelContractDocs);

    DashManager *dashManager = new DashManager(db_worker, setting);
    engine.rootContext()->setContextProperty("dashManager", dashManager);

    ModelPaymentSeries *modelPaySeries = new ModelPaymentSeries(db_worker, setting);
    modelPaySeries->load();
    engine.rootContext()->setContextProperty("modelPaySeries", modelPaySeries);

    ProxyModelDashContracts *proxyDashContracts = new ProxyModelDashContracts(setting);
    proxyDashContracts->setSourceModel(modelContracts);
    engine.rootContext()->setContextProperty("proxyDashContracts", proxyDashContracts);

    qmlRegisterSingletonInstance("DocFlow.models", 1, 0, "StatusModel", new ModelContractStatus);
    qmlRegisterSingletonInstance("DocFlow.models", 1, 0, "TypeModel", new ModelContractType);
    qmlRegisterSingletonInstance("DocFlow.models", 1, 0, "PaymentStatusModel", new ModelPaymentStatus);

    TranslateManager *trManager = new TranslateManager(&engine, setting);
    engine.rootContext()->setContextProperty("trManager", trManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("BirchFlow", "Main");

    return app.exec();
}
