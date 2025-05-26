#pragma once

#include <QObject>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>
#include <QDir>
#include <QCoreApplication>
#include <QDateTime>
#include <QStandardPaths>

#include "app_namespaces.h"

using namespace App;

class DatabaseManager : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseManager(QObject *parent = nullptr);

private:
    int VERSION;
    QSqlDatabase db;

    void changeDB(int db_version, int current_version);
};


class DatabaseWorker : public QObject
{
    Q_OBJECT
public:
    explicit DatabaseWorker(QObject *parent = nullptr);
    ~DatabaseWorker();

private:
    QSqlDatabase db;




public:
    QList<QVariantMap> getData(int table,const QVariantMap& filter = QVariantMap());
    QVariantMap saveData(int table, const QVariantMap& card, const QList<int>& params = QList<int>());
    bool delData(int table, const QVariantMap& params);

    double getSumPay(int type_id, int contract_id);

    QStringList getContractUuids(int contract_id);
    QStringList getPartnerUuids(int partner_id);

    QVariantMap getDashData(const QString& ids, const QVariantMap& filter = QVariantMap());
    double getPaymentSum(int from, int to, int doc_type, int currency, int contract_type);
    QList<QVariantMap> getPaymentCurrency(int c_date, int doc_type);

};
