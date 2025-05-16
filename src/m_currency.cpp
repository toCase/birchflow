#include "m_currency.h"

ModelCurrency::ModelCurrency(DatabaseWorker *dbw, QObject *parent)
    : dbWorker(dbw), QAbstractListModel{parent}
{
    beginResetModel();
    DATA = dbWorker->getData(Tables::CURRENCY);
    endResetModel();
}


int ModelCurrency::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return DATA.count();
}

QVariant ModelCurrency::data(const QModelIndex &index, int role) const
{
    QVariant res;
    if (DATA.isEmpty()) return res;

    QVariantMap CARD = DATA.at(index.row());

    switch (role) {
    case ID:
        res = CARD.value("id");
        break;
    case CODE:
        res = CARD.value("code");
        break;
    default:
        break;
    }
    return res;
}

QHash<int, QByteArray> ModelCurrency::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ID] = "cid";
    roles[CODE] = "code";

    return roles;
}

int ModelCurrency::getRow(int id)
{
    for (int i = 0; i < DATA.count(); i++) {
        QVariantMap map = DATA.at(i);
        if (map.value("id").toInt() == id) return i;
    }
    return -1;
}

int ModelCurrency::getRowCode(const QString &code)
{
    for (int i = 0; i < DATA.count(); i++) {
        QVariantMap map = DATA.at(i);
        if (map.value("code").toString() == code) return i;
    }
    return -1;
}
