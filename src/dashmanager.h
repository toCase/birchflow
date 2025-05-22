#pragma once

#include <QObject>
#include "database.h"
#include "tcd_settings.h"
// #include "app_namespaces.h"

using namespace App;

class DashManager : public QObject
{
    Q_OBJECT
public:
    explicit DashManager(DatabaseWorker *dbw, TCD_Settings *st, QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap dashTopData();
    Q_INVOKABLE QVariantMap dashContractData(int type = 0);

private:
    DatabaseWorker *m_dbworker;
    TCD_Settings *m_setting;

signals:
};
