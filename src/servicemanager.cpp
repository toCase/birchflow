#include "servicemanager.h"

ServiceManager::ServiceManager(DatabaseWorker *dbw, FileManager *fm, NotificationManager *nm, TCD_Settings *sm, QObject *parent)
    : m_dbworker(dbw), m_filemanager(fm), m_notification(nm), m_setting(sm), QObject{parent}
{
    archiveService();
    deleteService();
}

void ServiceManager::archiveService()
{
    bool arch_enable = m_setting->getValue("archive_enable", true).toBool();
    if (!arch_enable) return;

    int arch_month = m_setting->getValue("archive_month", 3).toInt();

    QVariantMap filter;
    filter.insert("arch", true);
    filter.insert("arch_date", QDateTime::currentDateTime().addMonths(-arch_month).toSecsSinceEpoch());


    QList<QVariantMap> data = m_dbworker->getData(Tables::CONTRACTS, filter);

    for (int i = 0; i < data.count(); i++) {
        QVariantMap card = data.at(i);

        card.insert("status", Status::ARCHIVE);
        m_dbworker->saveData(Tables::CONTRACTS, card);

        QList<QVariantMap> res = generateArchive(card);
        generateDocumentArchiveSummary(card, res);
    }
}

QList<QVariantMap> ServiceManager::generateArchive(const QVariantMap &card)
{
    QList<QVariantMap> res;

    int c_id = card.value("id").toInt();
    m_filemanager->makeArchiveDir(0);

    //contract_file
    m_filemanager->copyAchiveFile(card.value("uuid").toString(), "contract");

    QVariantMap report;
    report.insert("doc", -1);
    report.insert("file", "contract." + card.value("file").toString());
    report.insert("date", QDate::fromJulianDay(card.value("c_date").toInt()).toString(m_setting->getValue("dateFormat").toString()));
    report.insert("desc", card.value("description").toString());
    res.append(report);

    // all docs

    for (int type_id = 0; type_id < 8; type_id++){
        QList<QVariantMap> documents;
        switch (type_id) {
        case DocTypes::AMENDMENT:
            documents = m_dbworker->getData(Tables::AMENDMENTS, QVariantMap{{"contract_id", c_id}});
            break;
        case DocTypes::INVOICE:
            documents = m_dbworker->getData(Tables::PAYMENTS, QVariantMap{{"contract_id", c_id}, {"type_id", type_id}});
            break;
        case DocTypes::PAYMENT:
            documents = m_dbworker->getData(Tables::PAYMENTS, QVariantMap{{"contract_id", c_id}, {"type_id", type_id}});
            break;
        case DocTypes::CORRESPONDENCE:
            documents = m_dbworker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", c_id}, {"type_id", type_id}});
            break;
        case DocTypes::ESTIMATE:
            documents = m_dbworker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", c_id}, {"type_id", type_id}});
            break;
        case DocTypes::GOODS:
            documents = m_dbworker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", c_id}, {"type_id", type_id}});
            break;
        case DocTypes::ACTS:
            documents = m_dbworker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", c_id}, {"type_id", type_id}});
            break;
        case DocTypes::OTHER:
            documents = m_dbworker->getData(Tables::DOCUMENTS, QVariantMap{{"contract_id", c_id}, {"type_id", type_id}});
            break;
        default:
            break;
        }
        for (int i = 0; i < documents.count(); i++) {
            QVariantMap doc_card = documents.at(i);

            QString f_name;
            if (doc_card.value("file").toString().isEmpty()) {
                f_name = "NOT FILE";
            } else {
                f_name = QString("%1-%2").arg(prefix_list.at(type_id)).arg(doc_card.value("id").toInt());
                m_filemanager->copyAchiveFile(doc_card.value("uuid").toString(), f_name, type_id);
                f_name.append(QString(".%1").arg(doc_card.value("file").toString()));
            }

            QVariantMap report;
            report.insert("doc", type_id);
            report.insert("file", f_name);
            report.insert("num", doc_card.value("num").toString());
            report.insert("date", QDate::fromJulianDay(doc_card.value("doc_date").toInt()).toString(m_setting->getValue("dateFormat").toString()));
            report.insert("desc", doc_card.value("description").toString());
            res.append(report);
        }
    }

    // make zip
    m_filemanager->saveArchiveDir(QDir::toNativeSeparators(m_setting->getValue("vault").toString() + "/arch" + card.value("uuid").toString() + ".zip"));
    return res;
}

void ServiceManager::generateDocumentArchiveSummary(const QVariantMap& card, const QList<QVariantMap>& documents)
{
    QString das;
    das.append("# Document Archive Summary\n\n");
    das.append(QString("Contract ID: %1  \n").arg(card.value("id").toInt()));
    das.append(QString("Number: %1  \n").arg(card.value("num").toString()));
    das.append(QString("Date: %1  \n").arg(QDate::fromJulianDay(card.value("c_date").toInt()).toString(m_setting->getValue("dateFormat").toString())));
    das.append(QString("Partner: %1  \n").arg(card.value("partner").toString()));
    das.append(QString("Archived: %1  \n").arg(QDate::currentDate().toString(m_setting->getValue("dateFormat").toString())));
    das.append(QString("MD5: %1  \n\n").arg(m_filemanager->getMD5(QDir::toNativeSeparators(m_setting->getValue("vault").toString() + "/arch" + card.value("uuid").toString() + ".zip"))));
    // das.append("----\n\n");

    das.append("## Attached Documents\n\n");
    das.append("| # | Document Type | Num  | Date | Notes | File  |\n");
    das.append("|---|---------------|------|------|-------|-------|\n");


    int row = 1;
    for (const auto& doc : documents) {
        QString doc_type = doc.value("doc").toInt() == -1 ? tr("Contract") : type_list.at(doc.value("doc").toInt());

        das.append(QString("| %1 | %2 | %3 | %4 | %5 | %6 |\n")
                       .arg(row++).arg(doc_type)
                       .arg(doc.value("num").toString())
                       .arg(doc.value("date").toString())
                       .arg(doc.value("desc").toString())
                       .arg(doc.value("file").toString()));
    }
    das.append("\n");
    das.append("----\n\n");

    QFile das_file(QDir::toNativeSeparators(m_setting->getValue("vault").toString() + "/das" + card.value("uuid").toString() + ".md"));
    if (das_file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        QTextStream out(&das_file);
        out << das;
        das_file.close();
    }
}

void ServiceManager::deleteService()
{
    bool del_enable = m_setting->getValue("delete_enable", true).toBool();
    if (!del_enable) return;

    int del_month = m_setting->getValue("delete_month", 3).toInt();

    QVariantMap filter;
    filter.insert("del", true);
    filter.insert("del_date", QDateTime::currentDateTime().addMonths(-del_month).toSecsSinceEpoch());

    QList<QVariantMap> data = m_dbworker->getData(Tables::CONTRACTS, filter);

    for (int i = 0; i < data.count(); i++) {
        QVariantMap card = data.at(i);
        int c_id = card.value("id").toInt();

        // remove files
        QStringList uuids = m_dbworker->getContractUuids(c_id);
        for (auto& uuid : uuids) {
            m_filemanager->removeDoc(uuid);
        }

        // delete from db
        QVariantMap params;
        params.insert("id", c_id);
        m_dbworker->delData(Tables::CONTRACTS, params);
    }
}
