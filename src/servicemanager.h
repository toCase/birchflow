#pragma once

#include <QObject>
#include "filemanager.h"
#include "database.h"
#include "tcd_settings.h"
#include "notificationmanager.h"
#include "app_namespaces.h"

using namespace App;

class ServiceManager : public QObject
{
    Q_OBJECT
public:
    explicit ServiceManager(DatabaseWorker *dbw, FileManager *fm, NotificationManager *nm, TCD_Settings *sm, QObject *parent = nullptr);


private:
    DatabaseWorker *m_dbworker;
    FileManager *m_filemanager;
    NotificationManager *m_notification;
    TCD_Settings *m_setting;

    QStringList prefix_list = {"AMD", "IVC", "PAY", "COR", "EST", "GD", "ACT", "DOC"};
    QStringList type_list = {tr("Amendment"), tr("Invoice"), tr("Payment"), tr("Correspondence"),
                             tr("Estymate"), tr("Goods"), tr("Acts"), tr("Documents")};

public:
    void archiveService();
    QList<QVariantMap> generateArchive(const QVariantMap &card);
    void generateDocumentArchiveSummary(const QVariantMap &card, const QList<QVariantMap>& documents);

    void deleteService();
};
