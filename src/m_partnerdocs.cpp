#include "m_partnerdocs.h"

ModelPartnerDoc::ModelPartnerDoc(DatabaseWorker *dbw, FileManager *fm, NotificationManager *nm, QObject *parent)
    : dbWorker(dbw), m_fileManager(fm), m_notification(nm), QAbstractListModel{parent}
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
    QVariantMap res;
    // file
    QString origin_file;
    QString uuid;
    //тільки первісний док враховує файл, оновлення файлу тільки через updateFile()
    if (card.value("id").toInt() == 0) {
        origin_file = card.value("file").toString();
        QString ext = m_fileManager->getSuffix(origin_file);
        card.insert("file", ext);

        uuid = QUuid::createUuid().toString(QUuid::WithoutBraces);
        card.insert("uuid", uuid);
    }

    card.insert("created", QDateTime::currentSecsSinceEpoch());


    res = dbWorker->saveData(Tables::PARTNERS_DOC, card);

    if (res.value("r").toBool()) {
        if (card.value("id").toInt() == 0){

            // fileManager->createPartnerDoc(original_file, card.value("partner_id").toInt(), res.value("id").toInt());
            m_fileManager->createDoc(origin_file, card.value("uuid").toString());

            beginInsertRows(QModelIndex(), 0, 0);
            card.insert("id", res.value("id"));
            DATA.insert(0, card);
            endInsertRows();
        } else {
            int pos = getPosition(card.value("id").toInt());

            QVariantMap old_card = DATA[pos];
            card.insert("file", old_card.value("file"));
            card.insert("uuid", old_card.value("uuid"));

            DATA[pos] = card;
            emit dataChanged(index(pos), index(pos));
        }
        m_notification->makeNote("Saved success", Notes::SUCCESS);
    } else {
        m_notification->makeNote(res.value("err").toString(), Notes::ERROR);
    }
    return res;
}

QVariantMap ModelPartnerDoc::updateFile(QVariantMap card)
{
    int pos = getPosition(card.value("id").toInt());
    auto& old_card = DATA[pos];

    QString origin_file = card.value("file").toString();
    if (origin_file.isEmpty()) {
        m_fileManager->removeDoc(old_card.value("uuid").toString());
    }
    QString ext = m_fileManager->getSuffix(origin_file);
    card.insert("file", ext);
    card.insert("created", QDateTime::currentSecsSinceEpoch());
    QList<int> params = {Params::ONLY_FILE};
    QVariantMap res = dbWorker->saveData(Tables::PARTNERS_DOC, card, params);
    if (res.value("r").toBool()) {

        if (!origin_file.isEmpty()) {
            m_fileManager->createDoc(origin_file, old_card.value("uuid").toString());
        }

        old_card.insert("file", ext);
        old_card.insert("created", card.value("created"));
        emit dataChanged(index(pos), index(pos));

        m_notification->makeNote("File updated", Notes::SUCCESS);
    } else {
        m_notification->makeNote(res.value("err").toString(), Notes::ERROR);
    }
    return res;
}

bool ModelPartnerDoc::del(int id)
{
    int pos = getPosition(id);

    QVariantMap card = getCard(id);

    bool r = dbWorker->delData(Tables::PARTNERS_DOC, QVariantMap{{"id", id}});
    if (r) {
        // remove files
        m_fileManager->removeDoc(card.value("uuid").toString());

        //
        beginRemoveRows(QModelIndex(), pos, pos);
        DATA.removeAt(pos);
        endRemoveRows();


        m_notification->makeNote(tr("Delete completed"), Notes::NOTIFY);
    }  else {
        m_notification->makeNote("Unkown error while deleting, sorry", Notes::ERROR);
    }
    return r;
}

void ModelPartnerDoc::viewDoc(int id)
{
    QVariantMap card = DATA.at(getPosition(id));
    QString fileName = card.value("uuid").toString() + "." + card.value("file").toString();

    m_fileManager->openFile(fileName);

}


QString ModelPartnerDoc::toLocalFile(const QUrl &location)
{
    return m_fileManager->toLocalFile(location);
}
