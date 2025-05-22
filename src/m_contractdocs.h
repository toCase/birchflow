#pragma once

#include <QAbstractItemModel>
#include <QObject>
#include <QUuid>

#include "database.h"
#include "filemanager.h"
#include "notificationmanager.h"
#include "tcd_settings.h"

using namespace App;

struct Section {
    int id;
    QString name;
    QList<QVariantMap> documents;
};

class ModelContractDocs : public QAbstractItemModel
{
    Q_OBJECT
public:
    explicit ModelContractDocs(DatabaseWorker *dbw,
                               FileManager *fm,
                               NotificationManager *nm,
                               TCD_Settings *st, QObject *parent = nullptr);

private:

    enum RoleColumn : int {        
        FILE = 1,
        NUM = 2,
        DATE = 3,
        TITLE = 4,
        VF = 5,
        VT = 6,
        SUM = 7,
        STATUS = 8,
        CREATED = 9,
        IS_SECTION = 10,
        DOC_ID = 11,
        DOC_TYPE = 12,
    };

    DatabaseWorker *dbWorker;
    FileManager *m_fileManager;
    NotificationManager *m_noteManager;
    TCD_Settings *m_setting;

    QList<Section> DATA;
    int CONTRACT_ID = 0;

    QStringList sections = {tr("Amendments"), tr("Invoices"), tr("Payments"), tr("Correspondence"), tr("Estimates"), tr("Goods"), tr("Acts"), tr("Others")};

    int getDocumentsPosition(const QList<QVariantMap>& documents, int id);

public:
    QModelIndex index(int row, int column, const QModelIndex &parent) const;
    QModelIndex parent(const QModelIndex &child) const;
    int rowCount(const QModelIndex &parent) const;
    int columnCount(const QModelIndex &parent) const;
    // bool hasChildren(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;
    Qt::ItemFlags flags(const QModelIndex &index) const;
    QHash<int, QByteArray> roleNames() const;

    Q_INVOKABLE void setContract(int id);
    Q_INVOKABLE QVariantMap saveDoc(QVariantMap card);
    Q_INVOKABLE bool deleteDoc(int type_id, int doc_id);
    Q_INVOKABLE QVariantMap updateFile(QVariantMap card);

    Q_INVOKABLE QVariantMap getCard(int type_id, int doc_id);
    Q_INVOKABLE void viewDoc(int type_id, int doc_id);

    Q_INVOKABLE void makeArchive(const QString& zip_name);

    Q_INVOKABLE QString toLocalFile(const QUrl& location);

};
