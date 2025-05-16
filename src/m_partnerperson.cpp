#include "m_partnerperson.h"

ModelPartnerPerson::ModelPartnerPerson(DatabaseWorker *dbw, QObject *parent)
    : dbWorker(dbw), QAbstractListModel{parent}
{}

int ModelPartnerPerson::getPosition(int id)
{
    int pos = -1;
    for (int i = 0; i < DATA.count(); i++) {
        if (DATA.at(i).value("id").toInt() == id) pos = i;
    }
    return pos;
}


int ModelPartnerPerson::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return DATA.count();
}

QVariant ModelPartnerPerson::data(const QModelIndex &index, int role) const
{
    QVariant res;
    if (DATA.isEmpty()) return res;

    QVariantMap CARD = DATA.at(index.row());

    switch (role) {
    case ID:
        res = CARD.value("id");
        break;
    case NAME:
        res = CARD.value("full_name");
        break;
    case POSITION:
        res = CARD.value("position");
        break;
    case PHONE:
        res = CARD.value("phone");
        break;
    case MAIL:
        res = CARD.value("mail");
        break;
    case MESSENGER:
        res = CARD.value("messenger");
        break;
    default:
        break;
    }
    return res;
}

QHash<int, QByteArray> ModelPartnerPerson::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ID] = "p_id";
    roles[NAME] = "p_name";
    roles[POSITION] = "p_pos";
    roles[PHONE] = "p_phone";
    roles[MAIL] = "p_mail";
    roles[MESSENGER] = "p_messenger";

    return roles;
}

void ModelPartnerPerson::setPartnerID(int id)
{
    PARTNER_ID = id;
    beginResetModel();
    QVariantMap filter;
    filter.insert("partner_id", PARTNER_ID);
    DATA = dbWorker->getData(Tables::PARTNERS_PERSON, filter);
    endResetModel();
}

QVariantMap ModelPartnerPerson::getCard(int id)
{
    return DATA.at(getPosition(id));
}

QVariantMap ModelPartnerPerson::save(QVariantMap card)
{
    card.insert("created", QDateTime::currentSecsSinceEpoch());
    QVariantMap res = dbWorker->saveData(Tables::PARTNERS_PERSON, card);
    if (res.value("r").toBool()) {
        if (card.value("id").toInt() == 0){
            beginInsertRows(QModelIndex(), 0, 0);
            card.insert("id", res.value("id"));
            DATA.insert(0, card);
            endInsertRows();
        } else {
            int pos = getPosition(card.value("id").toInt());
            DATA[pos] = card;
            emit dataChanged(index(pos), index(pos));
        }
    } else {
        qDebug() << res.value("err").toString();
    }
    return res;
}

bool ModelPartnerPerson::del(int id)
{
    int pos = getPosition(id);
    QVariantMap params;
    params.insert("id", id);

    bool res = dbWorker->delData(Tables::PARTNERS_PERSON, params);

    if (res) {
        beginRemoveRows(QModelIndex(), pos, pos);
        DATA.removeOne(pos);
        endRemoveRows();
    }
    return res;
}
