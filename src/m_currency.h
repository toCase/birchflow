#pragma once

#include <QAbstractListModel>
#include <QObject>

#include "database.h"

using namespace App;

class ModelCurrency : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ModelCurrency(DatabaseWorker *dbw, QObject *parent = nullptr);

    enum RoleNames : int {
        ID = 0,
        CODE = 1
    };

private:
    DatabaseWorker *dbWorker;
    QList<QVariantMap> DATA;

public:
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE int getRow(int id);
    Q_INVOKABLE int getRowCode(const QString& code);
};
