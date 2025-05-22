#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QUuid>

#include "database.h"
#include "filemanager.h"
#include "notificationmanager.h"

using namespace App;

class ModelPartnerDoc : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ModelPartnerDoc(DatabaseWorker *dbw, FileManager *fm, NotificationManager *nm, QObject *parent = nullptr);


    enum RoleNames : int {
        ID = 0,
        NAME = 1,
        FILE = 2,
        NOTE = 3
    };

private:
    DatabaseWorker *dbWorker;
    FileManager *m_fileManager;
    NotificationManager *m_notification;
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
    Q_INVOKABLE QVariantMap updateFile(QVariantMap card);
    Q_INVOKABLE bool del(int id);

    Q_INVOKABLE void viewDoc(int id);

    Q_INVOKABLE QString toLocalFile(const QUrl& location);
};
