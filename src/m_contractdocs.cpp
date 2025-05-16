#include "m_contractdocs.h"

ModelContractDocs::ModelContractDocs(DatabaseWorker *dbw, FileManager *fm, NotificationManager *nm, TCD_Settings *st, QObject *parent)
    : dbWorker(dbw), m_fileManager(fm), m_noteManager(nm), m_setting(st), QAbstractItemModel{parent}
{}

int ModelContractDocs::getDocumentsPosition(const QList<QVariantMap> &documents, int id)
{
    int pos = -1;
    for (int i = 0; i < documents.count(); i++){
        QVariantMap card = documents.at(i);
        if (card.value("id").toInt() == id) {
            pos = i;
            break;
        }
    }
    return pos;
}


QModelIndex ModelContractDocs::index(int row, int column, const QModelIndex &parent) const
{
    if (!hasIndex(row, column, parent))
        return QModelIndex();

    if (!parent.isValid()) {
        // Разделы (уровень 0)
        return createIndex(row, column, -1); // -1 означает корень
    }

    if (!parent.parent().isValid()) {
        // Документы (уровень 1)
        return createIndex(row, column, parent.row());
    }

    return QModelIndex();
}

QModelIndex ModelContractDocs::parent(const QModelIndex &child) const
{
    if (!child.isValid()) return QModelIndex();

    int sectionRow = static_cast<int>(reinterpret_cast<qintptr>(child.internalPointer()));

    if (sectionRow == -1) {
        // Это раздел, у него нет родителя
        return QModelIndex();
    }

    // Это документ, его родитель — раздел
    return createIndex(sectionRow, 0, -1);
}

int ModelContractDocs::rowCount(const QModelIndex &parent) const
{
    if (!parent.isValid()) {
        // Корень → разделы
        return DATA.size();
    }

    if (!parent.parent().isValid()) {
        // Родитель — раздел → вернуть кол-во документов
        int sectionIndex = parent.row();
        if (sectionIndex >= 0 && sectionIndex < DATA.size())
            return DATA[sectionIndex].documents.size();
    }

    return 0;
}

int ModelContractDocs::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return 2;
}


QVariant ModelContractDocs::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    int sectionRow = static_cast<int>(reinterpret_cast<qintptr>(index.internalPointer()));
    // int col = index.column();

    if (sectionRow == -1) {
        // Это раздел
        const Section &section = DATA[index.row()];
        switch (role) {
        case TITLE:
            return section.name;
            break;
        case NUM:
            return section.id;
            break;
        case CREATED:
            return QString::number(section.documents.size());
            break;
        case IS_SECTION:
            return true;
            break;
        default:
            return QVariant();
            break;
        }

    } else {
        // Это документ
        const Section &section = DATA[sectionRow];
        const QVariantMap &doc = section.documents[index.row()];

        switch (role) {
        case FILE:
            return doc.value("file");
            break;
        case NUM:
            return doc.value("num");
            break;
        case DATE:
            return QDate::fromJulianDay(doc.value("doc_date").toInt()).toString(m_setting->getValue("dateFormat").toString());
            break;
        case TITLE:
            if (section.id == DocTypes::AMENDMENT) {
                return QString();
            } else if (section.id == DocTypes::INVOICE) {
                return "Invoice";
            } else if (section.id == DocTypes::PAYMENT) {
                return "Payment";
            } else {
                return doc.value("title");
            }
            break;
        case VF:
            if (section.id == DocTypes::AMENDMENT) {
                if (!doc.value("change_date").toBool()) return QString();
                return QDate::fromJulianDay(doc.value("valid_from").toInt()).toString(m_setting->getValue("dateFormat").toString());
            } else {
                return QString();
            }
            break;
        case VT:
            if (section.id == DocTypes::AMENDMENT) {
                if (!doc.value("change_date").toBool()) return QString();
                return QDate::fromJulianDay(doc.value("valid_to").toInt()).toString(m_setting->getValue("dateFormat").toString());
            } else {
                return QString();
            }
            break;
        case SUM:
            if (section.id == DocTypes::AMENDMENT) {
                if (!doc.value("change_amount").toBool()) return QString();
                return QString::number(doc.value("amount").toDouble(), 'f', 2) + " " + doc.value("currency").toString().toUpper();
            } else if (section.id == DocTypes::INVOICE || section.id == DocTypes::PAYMENT) {
                return QString::number(doc.value("amount").toDouble(), 'f', 2) + " " + doc.value("currency").toString().toUpper();
            } else {
                return QString();
            }
            break;
        case STATUS:
            if (section.id == DocTypes::INVOICE) {
                // switch (doc.value("status").toInt()) {
                // case PayStatus::NOT_PAID:
                //     return tr("Not paid");
                //     break;
                // case PayStatus::PARTIALLY_PAID:
                //     return tr("Partially paid");
                //     break;
                // case PayStatus::PAID:
                //     return tr("Paid");
                //     break;
                // default:
                //     break;
                // };
                return doc.value("status").toInt();
            } else {
                return 99;
            }
            break;
        case CREATED:
            return QDateTime::fromSecsSinceEpoch(doc.value("created").toInt()).toString(QString("hh:mm %1").arg(m_setting->getValue("dateFormat").toString()));
            break;
        case IS_SECTION:
            return false;
            break;
        case DOC_ID:
            return doc.value("id").toInt();
            break;
        case DOC_TYPE:
            return doc.value("type_id").toInt();
            break;
            return false;
        default:
            break;
        }
    }

    return QVariant();
}

Qt::ItemFlags ModelContractDocs::flags(const QModelIndex &index) const
{
    if (!index.isValid()) return Qt::NoItemFlags;
    return Qt::ItemIsEnabled | Qt::ItemIsSelectable;
}

QHash<int, QByteArray> ModelContractDocs::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Qt::DisplayRole] = "display";
    roles[FILE] = "file";
    roles[NUM] = "num";
    roles[DATE] = "doc_date";
    roles[TITLE] = "doc_title";
    roles[VF] = "validFrom";
    roles[VT] = "validTo";
    roles[SUM] = "sum";
    roles[STATUS] = "status";
    roles[CREATED] = "created";
    roles[IS_SECTION] = "is_section";
    roles[DOC_ID] = "doc_id";
    roles[DOC_TYPE] = "doc_type";
    return roles;
}

void ModelContractDocs::setContract(int id)
{
    CONTRACT_ID = id;
    beginResetModel();

    DATA.clear();

    for (int i = 0; i < sections.count(); i++){
        QList<QVariantMap> documents;
        switch (i) {
        case DocTypes::AMENDMENT:
            documents = dbWorker->getData(Tables::AMENDMENTS, QVariantMap{{"contract_id", CONTRACT_ID}});
            break;
        case DocTypes::INVOICE:
            documents = dbWorker->getData(Tables::PAYMENTS, QVariantMap{{"contract_id", CONTRACT_ID}, {"type_id", DocTypes::INVOICE}});
            break;
        case DocTypes::PAYMENT:
            documents = dbWorker->getData(Tables::PAYMENTS, QVariantMap{{"contract_id", CONTRACT_ID}, {"type_id", DocTypes::PAYMENT}});
            break;
        case DocTypes::CORRESPONDENCE:
            documents = dbWorker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", CONTRACT_ID}, {"type_id", DocTypes::CORRESPONDENCE}});
            break;
        case DocTypes::ESTIMATE:
            documents = dbWorker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", CONTRACT_ID}, {"type_id", DocTypes::ESTIMATE}});
            break;
        case DocTypes::GOODS:
            documents = dbWorker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", CONTRACT_ID}, {"type_id", DocTypes::GOODS}});
            break;
        case DocTypes::ACTS:
            documents = dbWorker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", CONTRACT_ID}, {"type_id", DocTypes::ACTS}});
            break;
        case DocTypes::OTHER:
            documents = dbWorker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", CONTRACT_ID}, {"type_id", DocTypes::OTHER}});
            break;
        default:
            break;
        }

        // qDebug() << documents;

        Section section;
        section.id = i;
        section.name = sections.at(i);
        section.documents = documents;
        DATA.append(section);
    }
    endResetModel();
}

QVariantMap ModelContractDocs::saveDoc(QVariantMap card)
{
    QString origin_file;
    QString uuid;

    int type_id = card.value("type_id").toInt();
    Section section = DATA.at(type_id);

    if (card.value("id").toInt() == 0) {
        origin_file = card.value("file").toString();
        QString ext = m_fileManager->getSuffix(origin_file);
        card.insert("file", ext);

        uuid = QUuid::createUuid().toString(QUuid::WithoutBraces);
        card.insert("uuid", uuid);
    }

    QDate doc_date = QDate::fromString(card.value("doc_date").toString(), m_setting->getValue("dateFormat").toString());
    card.insert("doc_date", doc_date.toJulianDay());

    card.insert("contract_id", CONTRACT_ID);
    card.insert("created", QDateTime::currentSecsSinceEpoch());

    QVariantMap res;
    if (type_id == DocTypes::AMENDMENT) {
        QDate valid_from = QDate::fromString(card.value("valid_from").toString(), m_setting->getValue("dateFormat").toString());
        QDate valid_to = QDate::fromString(card.value("valid_to").toString(), m_setting->getValue("dateFormat").toString());

        card.insert("valid_from", valid_from.toJulianDay());
        card.insert("valid_to", valid_to.toJulianDay());

        // test correct date ratio
        if (valid_to.toJulianDay() < valid_from.toJulianDay()) {
            res.insert("r", false);
            m_noteManager->makeNote(tr("Incorrect date ratio"), Notes::ERROR);
            return res;
        }


        res = dbWorker->saveData(Tables::AMENDMENTS, card);
    } else if (type_id == DocTypes::INVOICE || type_id == DocTypes::PAYMENT) {
        res = dbWorker->saveData(Tables::PAYMENTS, card);
    } else if (type_id >= 3) {
        res = dbWorker->saveData(Tables::DOCUMENTS, card);
    }

    if (res.value("r").toBool()) {
        if (card.value("id").toInt() == 0) {

            if (!origin_file.isEmpty()){
                m_fileManager->createDoc(origin_file, uuid);
            }

            card.insert("id", res.value("id").toInt());
            auto& documents = section.documents;

            int newRow = documents.size();
            QModelIndex sectionIndex = this->index(type_id, 0, QModelIndex());
            beginInsertRows(sectionIndex, newRow, newRow);
            documents.append(card);
            DATA[type_id] = section;
            endInsertRows();

        } else {
            auto& documents = section.documents;
            int pos = getDocumentsPosition(documents, card.value("id").toInt());
            QVariantMap old_card = documents.at(pos);
            card.insert("file", old_card.value("file"));
            card.insert("uuid", old_card.value("uuid"));
            documents[pos] = card;
            section.documents = documents;
            DATA[type_id] = section;
            QModelIndex sectionIndex = this->index(type_id, 0, QModelIndex());
            QModelIndex docIndex = this->index(pos, 1, sectionIndex);
            emit dataChanged(docIndex, docIndex);
        }
        m_noteManager->makeNote("Saved success", Notes::SUCCESS);
    } else {
        m_noteManager->makeNote(res.value("err").toString(), Notes::ERROR);
    }
    return res;
}

bool ModelContractDocs::deleteDoc(int type_id, int doc_id)
{
    bool res = false;
    switch (type_id) {
    case DocTypes::AMENDMENT:
        res = dbWorker->delData(Tables::AMENDMENTS, QVariantMap{{"id", doc_id}, {"type_id", DocTypes::AMENDMENT}});
        break;
    case DocTypes::INVOICE:
        res = dbWorker->delData(Tables::PAYMENTS, QVariantMap{{"id", doc_id}, {"type_id", DocTypes::INVOICE}});
        break;
    case DocTypes::PAYMENT:
        res = dbWorker->delData(Tables::PAYMENTS, QVariantMap{{"id", doc_id}, {"type_id", DocTypes::PAYMENT}});
        break;
    case DocTypes::CORRESPONDENCE:
        res = dbWorker->delData(Tables::DOCUMENTS, QVariantMap{{"id", doc_id}, {"type_id", DocTypes::CORRESPONDENCE}});
        break;
    case DocTypes::ESTIMATE:
        res = dbWorker->delData(Tables::DOCUMENTS, QVariantMap{{"id", doc_id}, {"type_id", DocTypes::ESTIMATE}});
        break;
    case DocTypes::GOODS:
        res = dbWorker->delData(Tables::DOCUMENTS, QVariantMap{{"id", doc_id}, {"type_id", DocTypes::GOODS}});
        break;
    case DocTypes::ACTS:
        res = dbWorker->delData(Tables::DOCUMENTS, QVariantMap{{"id", doc_id}, {"type_id", DocTypes::ACTS}});
        break;
    case DocTypes::OTHER:
        res = dbWorker->delData(Tables::DOCUMENTS, QVariantMap{{"id", doc_id}, {"type_id", DocTypes::OTHER}});
        break;
    default:
        break;
    }
    if (res) {
        Section section = DATA.at(type_id);
        auto& documents = section.documents;
        int pos = getDocumentsPosition(documents, doc_id);

        QVariantMap card = documents.at(pos);

        if (!card.value("file").toString().isEmpty()) {
            m_fileManager->removeDoc(card.value("uuid").toString());
        }

        QModelIndex sectionIndex = this->index(type_id, 0, QModelIndex());
        beginRemoveRows(sectionIndex, pos, pos);
        documents.removeAt(pos);
        section.documents = documents;
        DATA[type_id] = section;
        endRemoveRows();

        m_noteManager->makeNote(tr("Document delete successfull"), Notes::NOTIFY);
    } else {
        m_noteManager->makeNote("Unkown document delete error, sorry", Notes::ERROR);
    }
    return res;
}

QVariantMap ModelContractDocs::updateFile(QVariantMap card)
{
    int type_id = card.value("type_id").toInt();
    Section section = DATA.at(type_id);
    auto& documents = section.documents;

    int pos = getDocumentsPosition(documents, card.value("id").toInt());

    QVariantMap old_card = documents.at(pos);

    const QString& uuid = old_card.value("uuid").toString();

    QString origin_file = card.value("file").toString();
    if (origin_file.isEmpty()) {
        m_fileManager->removeDoc(uuid);
    }

    QString ext = m_fileManager->getSuffix(origin_file);
    card.insert("file", ext);
    card.insert("created", QDateTime::currentSecsSinceEpoch());

    QVariantMap res;
    if (type_id == DocTypes::AMENDMENT) {
        res = dbWorker->saveData(Tables::AMENDMENTS, card, {Params::ONLY_FILE});
    } else if (type_id == DocTypes::INVOICE || type_id == DocTypes::PAYMENT) {
        res = dbWorker->saveData(Tables::PAYMENTS, card, {Params::ONLY_FILE});
    } else {
        res = dbWorker->saveData(Tables::DOCUMENTS, card, {Params::ONLY_FILE});
    }

    if (res.value("r").toBool()) {
        if (!origin_file.isEmpty()) {
            m_fileManager->createDoc(origin_file, uuid);
        }

        old_card.insert("file", ext);
        old_card.insert("created", card.value("created"));
        documents[pos] = old_card;
        section.documents = documents;
        DATA[type_id] = section;

        QModelIndex sectionIndex = this->index(type_id, 0, QModelIndex());
        QModelIndex docIndex = this->index(pos, 1, sectionIndex);
        emit dataChanged(docIndex, docIndex);

        m_noteManager->makeNote("File updated successfull", Notes::SUCCESS);
    } else {
        m_noteManager->makeNote(res.value("err").toString(), Notes::ERROR);
    }
    return res;
}

QVariantMap ModelContractDocs::getCard(int type_id, int doc_id)
{
    Section section = DATA.at(type_id);
    auto& documents = section.documents;

    QVariantMap card = documents.at(getDocumentsPosition(documents, doc_id));
    QString doc_date = QDate::fromJulianDay(card.value("doc_date").toInt()).toString(m_setting->getValue("dateFormat").toString());
    card.insert("doc_date", doc_date);
    if (type_id == DocTypes::AMENDMENT) {
        QString valid_from = QDate::fromJulianDay(card.value("valid_from").toInt()).toString(m_setting->getValue("dateFormat").toString());
        card.insert("valid_from", valid_from);
        QString valid_to = QDate::fromJulianDay(card.value("valid_to").toInt()).toString(m_setting->getValue("dateFormat").toString());
        card.insert("valid_to", valid_to);
    }
    return card;
}

void ModelContractDocs::viewDoc(int type_id, int doc_id)
{
    const QVariantMap& card = getCard(type_id, doc_id);
    m_fileManager->openFile(card.value("uuid").toString() + "." + card.value("file").toString());
}

void ModelContractDocs::makeArchive(const QString& zip_name)
{
    m_fileManager->makeArchiveDir(CONTRACT_ID);

    // saving contract
    QVariantMap filter;
    filter.insert("contract_id", CONTRACT_ID);
    QList<QVariantMap> data = dbWorker->getData(Tables::CONTRACTS, filter);
    auto card = data[0];
    QString fname = QString("%1-%2-%3").arg("contract",
                                            card.value("id").toString(),
                                            card.value("num").toString());
    m_fileManager->copyAchiveFile(card.value("uuid").toString(), fname, -1);

    // saving documents
    for (int i = 0; i < DATA.count(); i++) {
        Section section = DATA.at(i);
        for (int j = 0; j < section.documents.count(); j++){
            auto& card = section.documents.at(j);
            if (card.value("file").toString().isEmpty()) continue;

            QString fname = QString("%1-%2-%3").arg(section.name,
                                                    card.value("id").toString(),
                                                    card.value("num").toString());
            m_fileManager->copyAchiveFile(card.value("uuid").toString(), fname, section.id);
        }
    }
    m_fileManager->saveArchiveDir(zip_name);
}

QString ModelContractDocs::toLocalFile(const QUrl &location)
{
    return m_fileManager->toLocalFile(location);
}
