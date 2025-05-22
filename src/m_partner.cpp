#include "m_partner.h"

ModelPartners::ModelPartners(DatabaseWorker *dbw, NotificationManager *nm, FileManager *fm, QObject *parent)
    : dbWorker(dbw), m_notification(nm), m_fileManager(fm), QAbstractListModel{parent}
{
    load();
}

int ModelPartners::getPosition(int id)
{
    int pos = -1;
    for (int i = 0; i < DATA.count(); i++){
        QVariantMap card = DATA.at(i);
        if (card.value("id").toInt() == id) {
            pos = i;
            break;
        }
    }
    return pos;
}


int ModelPartners::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return DATA.count();
}

QVariant ModelPartners::data(const QModelIndex &index, int role) const
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
    case FULL_NAME:
        res = CARD.value("full_name");
        break;
    case OFF_ADDRESS:
        res = CARD.value("off_address");
        break;
    case REAL_ADDRESS:
        res = CARD.value("real_address");
        break;
    case CODE:
        res = CARD.value("code");
        break;
    case URL:
        res = CARD.value("url");
        break;
    case NOTE:
        res = CARD.value("note");
        break;

    case CONTRACTS:
        res = CARD.value("contracts");
        break;
    default:
        break;
    }
    return res;
}

QHash<int, QByteArray> ModelPartners::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ID] = "c_id";
    roles[NAME] = "c_name";
    roles[FULL_NAME] = "full_name";
    roles[OFF_ADDRESS] = "off_address";
    roles[REAL_ADDRESS] = "real_address";
    roles[CODE] = "c_code";
    roles[URL] = "c_url";
    roles[NOTE] = "c_note";
    roles[CONTRACTS] = "c_contracts";

    return roles;
}

void ModelPartners::load()
{
    beginResetModel();
    DATA = dbWorker->getData(Tables::PARTNERS);
    endResetModel();
}

QVariantMap ModelPartners::add(QVariantMap card)
{
    QVariantMap res = dbWorker->saveData(Tables::PARTNERS, card);
    if (res.value("r").toBool()){
        card.insert("id", res.value("id"));
        card.insert("code", QString());
        card.insert("full_name", QString());
        card.insert("off_address", QString());
        card.insert("real_address", QString());
        card.insert("url", QString());
        card.insert("note", QString());
        card.insert("contracts", 0);

        beginInsertRows(QModelIndex(), 0, 0);
        DATA.insert(0, card);
        endInsertRows();
    } else {
        m_notification->notify(res.value("error").toString(), Notes::ERROR);
    }
    return res;
}

QVariantMap ModelPartners::save(QVariantMap card)
{
    QVariantMap res = dbWorker->saveData(Tables::PARTNERS, card);
    if (res.value("r").toBool()){
        int pos = getPosition(card.value("id").toInt());
        auto& old_card = DATA[pos];
        card.insert("contracts", old_card.value("contracts"));
        DATA[pos] = card;
        emit dataChanged(index(pos), index(pos));
        m_notification->makeNote("Saved success", Notes::SUCCESS);
    } else {
        m_notification->notify(res.value("error").toString(), Notes::ERROR);
    }
    return res;
}

QVariantMap ModelPartners::getCard(int id)
{
    return DATA.at(getPosition(id));
}

bool ModelPartners::del(int id)
{
    int pos = getPosition(id);
    QStringList doc_uuid = dbWorker->getPartnerUuids(id);

    dbWorker->delData(Tables::PARTNERS_DOC, QVariantMap{{"partner_id", id}});
    dbWorker->delData(Tables::PARTNERS_BANK, QVariantMap{{"partner_id", id}});
    dbWorker->delData(Tables::PARTNERS_PERSON, QVariantMap{{"partner_id", id}});
    bool r = dbWorker->delData(Tables::PARTNERS, QVariantMap{{"id", id}});
    if (r) {
        for (auto& uuid: doc_uuid) {
            m_fileManager->removeDoc(uuid);
        }

        beginRemoveRows(QModelIndex(), pos, pos);
        DATA.removeAt(pos);
        endRemoveRows();

        m_notification->makeNote(tr("Delete completed"), Notes::NOTIFY);
    } else {
        m_notification->makeNote("Unkown document delete error, sorry", Notes::ERROR);
    }
    return r;
}

QString ModelPartners::getInfoDoc(int id)
{
    QVariantMap card = getCard(id);

    QString text;

    text.append(QString("\n"
                        "# %1\n\n\n"
                        "---\n"
                        "## %2 \n\n"
                        ">*%3* \n\n"
                        ">*Юридична адреса*: %4 \n\n"
                        ">*Фактична адреса*: %5 \n\n"
                        ">*URL:*: %6 \n\n\n "
                        "---\n")
                    .arg(card.value("name").toString(),
                         card.value("full_name").toString(),
                         card.value("code").toString(),
                         card.value("off_address").toString(),
                         card.value("real_address").toString(),
                         card.value("url").toString()));

    QVariantMap filter;
    filter.insert("partner_id", id);


    QList<QVariantMap> persons = dbWorker->getData(Tables::PARTNERS_PERSON, filter);

    if (!persons.isEmpty()){
        text.append("## Контактні особи:\n\n");


        for (int i = 0; i < persons.count(); i++){
            auto pers = persons.at(i);
            text.append(QString("### %1 - %2 \n\n"
                                ">*phone*: **%3**\n\n"
                                ">*mail*: **%4**  \n"
                                ">*messengers*: **%5**\n\n")
                            .arg(pers.value("position").toString(),
                                 pers.value("full_name").toString(),
                                 pers.value("phone").toString(),
                                 pers.value("mail").toString(),
                                 pers.value("messenger").toString()));
        }
        text.append("---\n");
    }

    QList<QVariantMap> banks = dbWorker->getData(Tables::PARTNERS_BANK, filter);

    if (!banks.isEmpty()){
        text.append("## Інформація про банки:\n\n");

        for (int i = 0; i < banks.count(); i++){
            auto bank = banks.at(i);
            text.append(QString("### %1 \n\n"
                                ">*SWIFT/BIC*: **%2**\n\n"
                                ">*IBAN*: **%3**\n\n")
                            .arg(bank.value("bank_name").toString(),
                                 bank.value("bank_code").toString(),
                                 bank.value("bank_account").toString()));
        }

        text.append("---\n");
    }

    QList<QVariantMap> docs = dbWorker->getData(Tables::PARTNERS_DOC, filter);

    if (!docs.isEmpty()){
        text.append("## Перелік наявних копій документів:\n\n");

        for (int i = 0; i < docs.count(); i++){
            auto doc = docs.at(i);
            text.append(QString("- %1 \n\n")
                            .arg(doc.value("name").toString()));
        }

        text.append("---\n");
    }


    return text;
}
