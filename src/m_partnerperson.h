#pragma once

#include <QAbstractListModel>
#include <QObject>

#include "database.h"

class ModelPartnerPerson : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ModelPartnerPerson(DatabaseWorker *dbw, QObject *parent = nullptr);


    enum RoleNames : int {
        ID = 0,
        NAME = 1,
        POSITION = 2,
        PHONE = 3,
        MAIL = 4,
        MESSENGER = 5
    };

private:
    DatabaseWorker *dbWorker;
    QList<QVariantMap> DATA;
    int PARTNER_ID = -1;

    int getPosition(int id);
public:
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE void setPartnerID(int id);
    Q_INVOKABLE QVariantMap getCard(int id);
    Q_INVOKABLE QVariantMap save(QVariantMap card);
    Q_INVOKABLE bool del(int id);
};
