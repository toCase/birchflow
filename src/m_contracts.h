#pragma once

#include <QAbstractListModel>
#include <QObject>
#include <QUuid>

#include "database.h"
#include "filemanager.h"
#include "notificationmanager.h"
#include "tcd_settings.h"

using namespace App;

class ModelContracts : public QAbstractListModel
{
    Q_OBJECT
public:
    explicit ModelContracts(DatabaseWorker *dbw, FileManager *fm, NotificationManager *nm, TCD_Settings *st, QObject *parent = nullptr);


    enum RoleNames : int {
        ID = 0,
        C_NUM = 1,
        C_DATE = 2,
        PARTNER = 3,
        VALID_FROM = 4,
        VALID_TO = 5,
        AMOUNT = 6,
        CURRENCY = 7,
        STATUS = 8,
        CREATED = 9,
        C_TYPE = 10,
        PAID = 11,
        DESC = 12,
    };

private:
    DatabaseWorker *dbWorker;
    FileManager *m_fileManager;
    NotificationManager *m_noteManager;
    TCD_Settings *m_setting;
    QList<QVariantMap> DATA;


    void load();

public:
    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE QVariantMap save(QVariantMap card);
    Q_INVOKABLE QVariantMap updateFile(QVariantMap card);
    Q_INVOKABLE bool del(int id);
    Q_INVOKABLE QVariantMap getCard(int id) const;
    Q_INVOKABLE int getPosition(int id) const;

    Q_INVOKABLE QVariantMap getValidAmount(int id) const;
    Q_INVOKABLE QVariantMap getValidDate(int id) const;

    Q_INVOKABLE QString getInfo(int id) const;
    Q_INVOKABLE void requestSaveArchive(int id, const QString& dir_name) const;

    Q_INVOKABLE void viewDoc(int id);
};
