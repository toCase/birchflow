#include "m_partnerbank.h"

ModelPartnerBank::ModelPartnerBank(DatabaseWorker *dbw, QObject *parent)
    : dbWorker(dbw), QAbstractListModel{parent}
{}

int ModelPartnerBank::getPosition(int id)
{
    int pos = -1;
    for (int i = 0; i < DATA.count(); i++) {
        if (DATA.at(i).value("id").toInt() == id) pos = i;
    }
    return pos;
}


int ModelPartnerBank::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return DATA.count();
}

QVariant ModelPartnerBank::data(const QModelIndex &index, int role) const
{
    QVariant res;
    if (DATA.isEmpty()) return res;

    QVariantMap CARD = DATA.at(index.row());

    switch (role) {
    case ID:
        res = CARD.value("id");
        break;
    case NAME:
        res = CARD.value("bank_name");
        break;
    case CODE:
        res = CARD.value("bank_code");
        break;
    case ACCOUNT:
        res = CARD.value("bank_account");
        break;
    case CREATED:
        res = CARD.value("created");
        break;
    default:
        break;
    }
    return res;

}

QHash<int, QByteArray> ModelPartnerBank::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ID] = "b_id";
    roles[NAME] = "b_name";
    roles[CODE] = "b_code";
    roles[ACCOUNT] = "b_account";
    roles[CREATED] = "b_created";

    return roles;
}

void ModelPartnerBank::setPartnerID(int id)
{
    PARTNER_ID = id;
    beginResetModel();
    QVariantMap filter;
    filter.insert("partner_id", PARTNER_ID);
    DATA = dbWorker->getData(Tables::PARTNERS_BANK, filter);
    endResetModel();
}

QVariantMap ModelPartnerBank::getCard(int id)
{
    return DATA.at(getPosition(id));
}

QVariantMap ModelPartnerBank::save(QVariantMap card)
{
    card.insert("created", QDateTime::currentSecsSinceEpoch());
    QVariantMap res = dbWorker->saveData(Tables::PARTNERS_BANK, card);
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

bool ModelPartnerBank::del(int id)
{
    int pos = getPosition(id);
    QVariantMap params;
    params.insert("id", id);

    bool res = dbWorker->delData(Tables::PARTNERS_BANK, params);

    if (res) {
        beginRemoveRows(QModelIndex(), pos, pos);
        DATA.removeOne(pos);
        endRemoveRows();
    }
    return res;
}
