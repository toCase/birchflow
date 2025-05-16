#include "m_contracts.h"

ModelContracts::ModelContracts(DatabaseWorker *dbw, FileManager *fm, NotificationManager *nm, TCD_Settings *st, QObject *parent)
    : dbWorker(dbw), m_fileManager(fm), m_noteManager(nm), m_setting(st), QAbstractListModel{parent}
{
    load();
}

int ModelContracts::getPosition(int id) const
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

QVariantMap ModelContracts::getValidAmount(int id) const
{
    QVariantMap data;
    QVariantMap contract_card = DATA.at(getPosition(id));

    QVariantMap filter;
    filter.insert("params", "valid_amount");
    filter.insert("contract_id", id);

    double amount = 0;
    double paid = 0;

    QList<QVariantMap> data_list = dbWorker->getData(Tables::AMENDMENTS, filter);
    if (!data_list.empty()) {
        QVariantMap a_card = data_list.at(0);
        amount = a_card.value("amount").toDouble();
    } else {
        amount = contract_card.value("amount").toDouble();
    }

    if (m_setting->getValue("calcPay").toString() == "payment") {
        paid = dbWorker->getSumPay(DocTypes::PAYMENT, id);
    } else {
        paid = dbWorker->getSumPay(DocTypes::INVOICE, id);
    }

    data.insert("amount", amount);
    data.insert("paid", paid);
    return data;

}

QVariantMap ModelContracts::getValidDate(int id) const
{
    QVariantMap data;
    QVariantMap contract_card = DATA.at(getPosition(id));

    QVariantMap filter;
    filter.insert("params", "valid_date");
    filter.insert("contract_id", id);

    QString valid_from;
    QString valid_to;


    QList<QVariantMap> data_list = dbWorker->getData(Tables::AMENDMENTS, filter);
    if (!data_list.empty()) {
        QVariantMap a_card = data_list.at(0);

        valid_from = QDate::fromJulianDay(a_card.value("valid_from").toInt()).toString(m_setting->getValue("dateFormat").toString());
        valid_to = QDate::fromJulianDay(a_card.value("valid_to").toInt()).toString(m_setting->getValue("dateFormat").toString());
    } else {
        valid_from = QDate::fromJulianDay(contract_card.value("valid_from").toInt()).toString(m_setting->getValue("dateFormat").toString());
        valid_to = QDate::fromJulianDay(contract_card.value("valid_to").toInt()).toString(m_setting->getValue("dateFormat").toString());
    }


    data.insert("valid_from", valid_from);
    data.insert("valid_to", valid_to);
    return data;
}

QString ModelContracts::getInfo(int id) const
{
    QVariantMap card = getCard(id);
    QString fname = QDir::toNativeSeparators(m_setting->getValue("vault").toString() + "/das" + card.value("uuid").toString() + ".md");
    qDebug() << fname;
    return m_fileManager->getArchiveMarkdown(fname);
}

void ModelContracts::requestSaveArchive(int id, const QString &dir_name) const
{
    QVariantMap card = getCard(id);
    m_fileManager->sendArchive(card.value("uuid").toString(), dir_name, id);
    QString note = QString("Files: arch-contract-%1.zip and index-contract-%1.md copied to %2").arg(id).arg(dir_name);
    m_noteManager->makeNote(note);
}

void ModelContracts::viewDoc(int id)
{
    int pos = getPosition(id);
    const auto& card = DATA.at(pos);
    m_fileManager->openFile(card.value("uuid").toString() + "." + card.value("file").toString());
}



void ModelContracts::load()
{
    beginResetModel();
    DATA.clear();
    DATA = dbWorker->getData(Tables::CONTRACTS);
    endResetModel();
}


int ModelContracts::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return DATA.count();
}

QVariant ModelContracts::data(const QModelIndex &index, int role) const
{
    QVariant res;
    if (DATA.isEmpty()) return res;

    QVariantMap CARD = DATA.at(index.row());

    QVariantMap VALID_DATE = getValidDate(CARD.value("id").toInt());
    QVariantMap VALID_AMOUNT = getValidAmount(CARD.value("id").toInt());

    switch (role) {
    case ID:
        res = CARD.value("id");
        break;
    case C_NUM:
        res = CARD.value("num");
        break;
    case C_DATE:
        res = QDate::fromJulianDay(CARD.value("c_date").toLongLong()).toString(m_setting->getValue("dateFormat").toString());
        break;
    case PARTNER:
        res = CARD.value("partner");
        break;
    case VALID_FROM:
        // res = QDate::fromJulianDay(VALID_DATE.value("valid_from").toLongLong()).toString(m_setting->getValue("dateFormat").toString());
        res = VALID_DATE.value("valid_from").toString();
        break;
    case VALID_TO:
        // res = QDate::fromJulianDay(VALID_DATE.value("valid_to").toLongLong()).toString(m_setting->getValue("dateFormat").toString());
        res = VALID_DATE.value("valid_to").toString();
        break;
    case AMOUNT:
        // res = CARD.value("amount");
        res = VALID_AMOUNT.value("amount");
        break;
    case CURRENCY:
        res = CARD.value("currency");
        break;
    case STATUS:
        res = CARD.value("status");
        break;
    case C_TYPE:
        res = CARD.value("type_id");
        break;
    case PAID:
        res = QString("%1%").arg(qCeil(100 * VALID_AMOUNT.value("paid").toDouble() / VALID_AMOUNT.value("amount").toDouble()));
        break;
    case DESC:
        res = CARD.value("description");
        break;
    default:
        break;
    }
    return res;
}

QHash<int, QByteArray> ModelContracts::roleNames() const
{

    QHash<int, QByteArray> roles;
    roles[ID] = "c_id";
    roles[C_NUM] = "c_num";
    roles[C_DATE] = "c_date";
    roles[PARTNER] = "partner";
    roles[VALID_FROM] = "valid_from";
    roles[VALID_TO] = "valid_to";
    roles[AMOUNT] = "amount";
    roles[CURRENCY] = "currency";
    roles[STATUS] = "status";
    roles[C_TYPE] = "c_type";
    roles[PAID] = "c_paid";

    return roles;
}

QVariantMap ModelContracts::save(QVariantMap card)
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

    // c_date
    QDate c_date = QDate::fromString(card.value("c_date").toString(), m_setting->getValue("dateFormat").toString());
    card.insert("c_date", c_date.toJulianDay());

    //valid_from
    QDate valid_from = QDate::fromString(card.value("valid_from").toString(), m_setting->getValue("dateFormat").toString());
    card.insert("valid_from", valid_from.toJulianDay());

    //valid_to
    QDate valid_to = QDate::fromString(card.value("valid_to").toString(), m_setting->getValue("dateFormat").toString());
    card.insert("valid_to", valid_to.toJulianDay());

    card.insert("created", QDateTime::currentSecsSinceEpoch());

    if (valid_to.toJulianDay() < valid_from.toJulianDay()) {
        res.insert("r", false);
        m_noteManager->makeNote(tr("Incorrect date ratio"), Notes::ERROR);
        return res;
    }


    res = dbWorker->saveData(Tables::CONTRACTS, card);

    if (res.value("r").toBool()) {
        if (card.value("id").toInt() == 0){

            m_fileManager->createDoc(origin_file, uuid);

            beginInsertRows(QModelIndex(), 0, 0);
            card.insert("id", res.value("id"));
            DATA.insert(0, card);
            endInsertRows();
        } else {
            int pos = getPosition(card.value("id").toInt());
            auto& old_card = DATA[pos];
            card.insert("file", old_card.value("file"));
            card.insert("uuid", old_card.value("uuid"));
            DATA[pos] = card;
            emit dataChanged(index(pos), index(pos));
        }

        m_noteManager->makeNote("Saved success", Notes::SUCCESS);
    } else {
        m_noteManager->makeNote(res.value("err").toString(), Notes::ERROR);
    }
    return res;
}

QVariantMap ModelContracts::updateFile(QVariantMap card)
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
    QVariantMap res = dbWorker->saveData(Tables::CONTRACTS, card, params);
    if (res.value("r").toBool()) {

        if (!origin_file.isEmpty()) {
            m_fileManager->createDoc(origin_file, old_card.value("uuid").toString());
        }

        old_card.insert("file", ext);
        old_card.insert("created", card.value("created"));
        emit dataChanged(index(pos), index(pos));

        m_noteManager->makeNote("File updated successfull", Notes::SUCCESS);
    } else {
        m_noteManager->makeNote(res.value("err").toString(), Notes::ERROR);
    }
    return res;
}

bool ModelContracts::del(int id)
{
    int pos = getPosition(id);

    QVariantMap card = getCard(id);
    QStringList uuids = dbWorker->getContractUuids(id);

    bool r = dbWorker->delData(Tables::CONTRACTS, QVariantMap{{"id", id}});
    if (r) {
        // remove files
        if (card.value("status").toInt() == Status::ARCHIVE) {
            m_fileManager->removeDoc(card.value("uuid").toString(), true);
        }
        for (auto& uuid : uuids){
            m_fileManager->removeDoc(uuid);
        }

        //
        beginRemoveRows(QModelIndex(), pos, pos);
        DATA.removeAt(pos);
        endRemoveRows();


        m_noteManager->makeNote(tr("Contract delete successfull"), Notes::NOTIFY);
    }  else {
        m_noteManager->makeNote("Unkown document delete error, sorry", Notes::ERROR);
    }
    return r;
}

QVariantMap ModelContracts::getCard(int id) const
{
    QVariantMap card = DATA.at(getPosition(id));

    QString c_date = QDate::fromJulianDay(card.value("c_date").toInt()).toString(m_setting->getValue("dateFormat").toString());
    QString valid_from = QDate::fromJulianDay(card.value("valid_from").toInt()).toString(m_setting->getValue("dateFormat").toString());
    QString valid_to = QDate::fromJulianDay(card.value("valid_to").toInt()).toString(m_setting->getValue("dateFormat").toString());
    QString created = QDateTime::fromSecsSinceEpoch(card.value("created").toLongLong()).toString(QString("hh:mm %1").arg(m_setting->getValue("dateFormat").toString()));

    card.insert("c_date", c_date);
    card.insert("valid_from", valid_from);
    card.insert("valid_to", valid_to);
    card.insert("created", created);

    return card;
}
