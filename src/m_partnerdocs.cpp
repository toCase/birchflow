#include "m_partnerdocs.h"

ModelPartnerDoc::ModelPartnerDoc(DatabaseWorker *dbw, FileManager *fm, QObject *parent)
    : dbWorker(dbw), fileManager(fm), QAbstractListModel{parent}
{}

int ModelPartnerDoc::getPosition(int id)
{
    int pos = -1;
    for (int i = 0; i < DATA.count(); i++) {
        if (DATA.at(i).value("id").toInt() == id) pos = i;
    }
    return pos;
}


int ModelPartnerDoc::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return DATA.count();
}

QVariant ModelPartnerDoc::data(const QModelIndex &index, int role) const
{
    QVariant res;
    if (DATA.isEmpty()) return res;

    QVariantMap CARD = DATA.at(index.row());

    switch (role) {
    case ID:
        res = CARD.value("id");
        break;
    case NAME:
        res = CARD.value("name");
        break;
    case FILE:
        res = CARD.value("file");
        break;
    case NOTE:
        res = CARD.value("note");
        break;
    default:
        break;
    }
    return res;
}

QHash<int, QByteArray> ModelPartnerDoc::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ID] = "d_id";
    roles[NAME] = "d_name";
    roles[FILE] = "d_file";
    roles[NOTE] = "d_note";
    return roles;
}

void ModelPartnerDoc::setPartnerID(int id)
{
    PARTNER_ID = id;
    beginResetModel();
    QVariantMap filter;
    filter.insert("partner_id", PARTNER_ID);
    DATA = dbWorker->getData(Tables::PARTNERS_DOC, filter);
    endResetModel();
}

QVariantMap ModelPartnerDoc::getCard(int id)
{
    return DATA.at(getPosition(id));
}

QVariantMap ModelPartnerDoc::save(QVariantMap card)
{
    QString original_file = card.value("file").toString();
    QString ext = fileManager->getSuffix(original_file);
    card.insert("file", ext);

    card.insert("created", QDateTime::currentSecsSinceEpoch());
    QVariantMap res = dbWorker->saveData(Tables::PARTNERS_DOC, card);
    if (res.value("r").toBool()) {
        if (card.value("id").toInt() == 0){

            fileManager->createPartnerDoc(original_file, card.value("partner_id").toInt(), res.value("id").toInt());

            beginInsertRows(QModelIndex(), 0, 0);
            card.insert("id", res.value("id"));
            DATA.insert(0, card);
            endInsertRows();
        } else {
            int pos = getPosition(card.value("id").toInt());

            QVariantMap old_card = DATA[pos];
            card.insert("file", old_card.value("file"));

            DATA[pos] = card;
            emit dataChanged(index(pos), index(pos));
        }
    } else {
        qDebug() << res.value("err").toString();
    }
    return res;
}

bool ModelPartnerDoc::del(int id)
{
    fileManager->removePartnerDoc(PARTNER_ID, id);

    int pos = getPosition(id);
    QVariantMap params;
    params.insert("id", id);

    bool res = dbWorker->delData(Tables::PARTNERS_DOC, params);

    if (res) {
        beginRemoveRows(QModelIndex(), pos, pos);
        DATA.removeOne(pos);
        endRemoveRows();
    }
    return res;
}

void ModelPartnerDoc::viewDoc(int id)
{
    QVariantMap card = DATA.at(getPosition(id));
    QString fileName = QString::number(PARTNER_ID) + "_" + QString::number(id) + "." + card.value("file").toString();

    fileManager->openFile(fileName);
}


QString ModelPartnerDoc::toLocalFile(const QUrl &location)
{
    return fileManager->toLocalFile(location);
}
