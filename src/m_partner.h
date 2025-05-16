#pragma once

#include <QAbstractListModel>
#include <QObject>

#include "database.h"

using namespace App;

class ModelPartners : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ModelPartners(DatabaseWorker *dbw, QObject *parent = nullptr);

    enum RoleNames : int {
        ID = 0,
        NAME = 1,
        FULL_NAME = 2,
        OFF_ADDRESS = 3,
        REAL_ADDRESS = 4,
        CODE = 5,
        URL = 6,
        NOTE = 7,
        CREATED = 8
    };

private:

    DatabaseWorker *dbWorker;
    QList<QVariantMap> DATA;


public:
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE QVariantMap add(QVariantMap card);
    Q_INVOKABLE QVariantMap save(QVariantMap card);
    Q_INVOKABLE QVariantMap getCard(int id);

    Q_INVOKABLE QString getInfoDoc(int id);
    Q_INVOKABLE int getPosition(int id);


};
