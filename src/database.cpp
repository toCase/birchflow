#include "database.h"

DatabaseManager::DatabaseManager(QObject *parent)
    : QObject{parent}
{
    /*
     * VERSION - main parameter
     *
     */

    VERSION = 1;

    QDir appDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    if (!appDir.exists()) QDir().mkdir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    QString db_file = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/birchflow.db3";


    db = QSqlDatabase::addDatabase("QSQLITE", "mng");
    db.setDatabaseName(db_file);
    db.open();

    // CREATE DB

    QStringList queryList;

    queryList.append("CREATE TABLE IF NOT EXISTS db_version (version INTEGER UNIQUE);");

    queryList.append("CREATE TABLE IF NOT EXISTS partners (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "name TEXT, full_name TEXT, off_address TEXT, real_address TEXT, code TEXT, "
                     "url TEXT, note TEXT, created INTEGER);");

    queryList.append("CREATE TABLE IF NOT EXISTS partnerbank (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "partner_id INTEGER, bank_name TEXT, bank_okpo TEXT, bank_mfo TEXT, bank_code TEXT, "
                     "bank_account TEXT, created INTEGER);");

    queryList.append("CREATE TABLE IF NOT EXISTS partnerperson (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "partner_id INTEGER, full_name TEXT, position TEXT, phone TEXT, mail TEXT, "
                     "messenger TEXT, note TEXT, created INTEGER);");

    queryList.append("CREATE TABLE IF NOT EXISTS partnerdocs (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "partner_id INTEGER, name TEXT, file TEXT, note TEXT, created INTEGER, "
                     "uuid TEXT UNIQUE);");

    queryList.append("CREATE TABLE IF NOT EXISTS contracts (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "num TEXT, c_date INTEGER, partner_id INTEGER, amount DOUBLE, currency_id INTEGER, "
                     "type_id INTEGER, valid_from INTEGER, valid_to INTEGER, status INTEGER, "
                     "description TEXT, file TEXT, created INTEGER, uuid TEXT UNIQUE);");

    queryList.append("CREATE TABLE IF NOT EXISTS amendments (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "contract_id INTEGER, num TEXT, doc_date INTEGER, description TEXT, change_date INTEGER, valid_from INTEGER, "
                     "valid_to INTEGER, change_amount INTEGER, amount DOUBLE, file TEXT, created INTEGER, "
                     "uuid TEXT UNIQUE);");

    queryList.append("CREATE TABLE IF NOT EXISTS documents (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "contract_id INTEGER, type_id INTEGER, num TEXT, doc_date INTEGER, title TEXT, description TEXT, "
                     "file TEXT, created INTEGER, uuid TEXT UNIQUE);");

    queryList.append("CREATE TABLE IF NOT EXISTS payments (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "contract_id INTEGER, type_id INTEGER, num TEXT, doc_date INTEGER, amount DOUBLE, currency_id INTEGER, "
                     "currency_rate DOUBLE, description TEXT, status INTEGER, file TEXT, created INTEGER, uuid TEXT UNIQUE);");

    queryList.append("CREATE TABLE IF NOT EXISTS currency (id INTEGER PRIMARY KEY AUTOINCREMENT, "
                     "code TEXT UNIQUE);");



    for (const auto& q : queryList){
        QSqlQuery query(q, db);
        query.exec();
        if (query.lastError().isValid()) qDebug() << query.lastError().text();
    }

    // Currency base

    const QStringList currencyList = {"ALL", "AMD", "AUD", "AZN", "BAM", "BGN", "BYN", "CAD", "CHF",
                                      "CNY", "CZK", "DKK", "EUR", "GBP", "GEL", "HUF", "ILS", "ISK",
                                      "JPY", "KRW", "MDL", "MKD", "NOK", "NZD", "PLN", "RON", "RSD",
                                      "SEK", "TRY", "UAH", "USD"};
    for (const auto& curr : currencyList) {
        QSqlQuery query(db);
        query.prepare(R"(INSERT OR IGNORE INTO currency (code) VALUES (?);)");
        query.bindValue(0, curr);
        query.exec();
    }

    // Check db version

    int DB_VERSION = 0;

    QSqlQuery v_query(db);
    v_query.prepare(R"(SELECT version FROM db_version)");
    v_query.exec();
    if (!v_query.first()) {
        QSqlQuery i_query(db);
        i_query.prepare(R"(INSERT OR REPLACE INTO db_version (version) VALUES (?))");
        i_query.bindValue(0, VERSION);
        i_query.exec();
        DB_VERSION = VERSION;
    } else {
        DB_VERSION = v_query.value(0).toInt();
    }

    // Change DB if change version
    if (DB_VERSION != VERSION) changeDB(DB_VERSION, VERSION);
    db.close();
}

void DatabaseManager::changeDB(int db_version, int current_version)
{

}


DatabaseWorker::DatabaseWorker(QObject *parent)
{
    QDir appDir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    if (!appDir.exists()) QDir().mkdir(QStandardPaths::writableLocation(QStandardPaths::AppDataLocation));
    QString db_file = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation) + "/birchflow.db3";

    db = QSqlDatabase::addDatabase("QSQLITE", "app");
    db.setDatabaseName(db_file);
    db.open();
}

DatabaseWorker::~DatabaseWorker()
{
    db.close();
}

QList<QVariantMap> DatabaseWorker::getData(int table, const QVariantMap &filter)
{
    QList<QVariantMap> res;

    QSqlQuery query(db);
    switch (table) {
    case Tables::PARTNERS:
        if (filter.contains("dash")) {
            query.prepare(R"(SELECT Count(p.id) as "value" FROM partners p WHERE p.created >= ?)");
            query.bindValue(0, filter.value("d"));
        } else {
            query.prepare(R"(SELECT p.*, Count(c.id) as contracts FROM partners p
                LEFT JOIN contracts as c ON c.partner_id = p.id GROUP BY p.id)");
        }
        break;
    case Tables::PARTNERS_BANK:
        query.prepare(R"(SELECT * FROM partnerbank WHERE (partnerbank.partner_id = ?))");
        query.bindValue(0, filter.value("partner_id"));
        break;
    case Tables::PARTNERS_PERSON:
        query.prepare(R"(SELECT * FROM partnerperson WHERE partnerperson.partner_id = ?)");
        query.bindValue(0, filter.value("partner_id"));
        break;
    case Tables::PARTNERS_DOC:
        query.prepare(R"(SELECT * FROM partnerdocs WHERE partnerdocs.partner_id = ?)");
        query.bindValue(0, filter.value("partner_id"));
        break;
    case Tables::CONTRACTS:
        if (filter.contains("arch")) {
            query.prepare(R"(SELECT * FROM contracts WHERE contracts.status = ? AND contracts.created < ?)");
            query.bindValue(0, Status::COMPLETED);
            query.bindValue(1, filter.value("arch_date"));
        } else if (filter.contains("del")) {
            query.prepare(R"(SELECT * FROM contracts WHERE contracts.status = ? AND contracts.created < ?)");
            query.bindValue(0, Status::ABORTED);
            query.bindValue(1, filter.value("del_date"));
        } else if (filter.contains("contract_id")) {
            query.prepare(R"(SELECT c.*, c2.code currency, p.name partner,
                        (SELECT a.valid_from FROM amendments a WHERE a.contract_id = c.id AND a.change_date = 1 ORDER BY a.doc_date DESC LIMIT 1) as n_valid_from,
                        (SELECT a.valid_to FROM amendments a WHERE a.contract_id = c.id AND a.change_date = 1 ORDER BY a.doc_date DESC LIMIT 1) as n_valid_to,
                        (SELECT a.amount FROM amendments a WHERE a.contract_id = c.id AND a.change_amount = 1 ORDER BY a.doc_date DESC LIMIT 1) as n_amount
                        FROM contracts c
                        INNER JOIN currency c2 ON c2.id  = c.currency_id
                        INNER JOIN partners p ON p.id  = c.partner_id
                        WHERE c.id = ?)");
            query.bindValue(0, filter.value("contract_id").toInt());
        } else {
            query.prepare(R"(SELECT c.*, c2.code as currency, p.name as partner,
(SELECT a.valid_from FROM amendments a WHERE a.contract_id = c.id AND a.change_date = 1 ORDER BY a.doc_date DESC LIMIT 1) as n_valid_from,
(SELECT a.valid_to FROM amendments a WHERE a.contract_id = c.id AND a.change_date = 1 ORDER BY a.doc_date DESC LIMIT 1) as n_valid_to,
(SELECT a.amount FROM amendments a WHERE a.contract_id = c.id AND a.change_amount = 1 ORDER BY a.doc_date DESC LIMIT 1) as n_amount
                        FROM contracts c
                        INNER JOIN currency c2 ON c2.id  = c.currency_id
                        INNER JOIN partners p ON p.id  = c.partner_id)");
        }
        break;
    case Tables::CURRENCY:
        query.prepare(R"(SELECT * FROM currency)");
        break;

    case Tables::AMENDMENTS:
        if (filter.contains("params")) {
            if (filter.value("params").toString() == "valid_date") {
                query.prepare(R"(SELECT * FROM amendments WHERE amendments.contract_id = ? AND amendments.change_date > 0 ORDER BY amendments.doc_date DESC LIMIT 1)");
                query.bindValue(0, filter.value("contract_id"));
            } else if (filter.value("params").toString() == "valid_amount") {
                query.prepare(R"(SELECT * FROM amendments WHERE amendments.contract_id = ? AND amendments.change_amount > 0 ORDER BY amendments.doc_date DESC LIMIT 1)");
                query.bindValue(0, filter.value("contract_id"));
            }
        } else {
            query.prepare(R"(SELECT a.* FROM amendments a WHERE a.contract_id = ?)");
            query.bindValue(0, filter.value("contract_id"));
        }
        break;
    case Tables::PAYMENTS:
        query.prepare(R"(SELECT p.*, c.code as "currency" FROM payments p INNER JOIN currency c ON c.id = p.currency_id WHERE p.contract_id = ? AND p.type_id = ?)");
        query.bindValue(0, filter.value("contract_id"));
        query.bindValue(1, filter.value("type_id"));
        break;
    case Tables::DOCUMENTS:
        query.prepare(R"(SELECT * FROM documents WHERE documents.contract_id = ? AND documents.type_id = ?)");
        query.bindValue(0, filter.value("contract_id"));
        query.bindValue(1, filter.value("type_id"));
        break;
    default:
        break;
    }

    if (!query.exec()) qDebug() << query.lastError();

    while (query.next()) {
        QVariantMap card;
        QSqlRecord record = query.record();
        for (int i = 0; i < record.count(); i++){
            card.insert(record.fieldName(i), record.value(i));
        }
        res.append(card);
    }
    return res;
}

QVariantMap DatabaseWorker::saveData(int table, const QVariantMap& card, const QList<int> &params)
{
    QVariantMap res;

    QSqlQuery query(db);
    int id = card.value("id").toInt();

    if (id == 0) {
        switch (table){
        case Tables::PARTNERS:
            query.prepare(R"(INSERT INTO partners (name, created) values (?, ?))");
            query.bindValue(0, card.value("name"));
            query.bindValue(1, QDateTime::currentSecsSinceEpoch());
            break;
        case Tables::PARTNERS_BANK:
            query.prepare(R"(INSERT INTO partnerbank (partner_id, bank_name, bank_code, bank_account, created) VALUES (?, ?, ?, ?, ?))");
            query.bindValue(0, card.value("partner_id"));
            query.bindValue(1, card.value("bank_name"));
            query.bindValue(2, card.value("bank_code"));
            query.bindValue(3, card.value("bank_account"));
            query.bindValue(4, card.value("created"));
            break;
        case Tables::PARTNERS_PERSON:
            query.prepare(R"(INSERT INTO partnerperson (partner_id, full_name, position, phone, mail, messenger, created) VALUES (?, ?, ?, ?, ?, ?, ?))");
            query.bindValue(0, card.value("partner_id"));
            query.bindValue(1, card.value("full_name"));
            query.bindValue(2, card.value("position"));
            query.bindValue(3, card.value("phone"));
            query.bindValue(4, card.value("mail"));
            query.bindValue(5, card.value("messenger"));
            query.bindValue(6, card.value("created"));
            break;
        case Tables::PARTNERS_DOC:
            query.prepare(R"(INSERT INTO partnerdocs (partner_id, name, file, note, uuid, created) VALUES (?, ?, ?, ?, ?, ?))");
            query.bindValue(0, card.value("partner_id"));
            query.bindValue(1, card.value("name"));
            query.bindValue(2, card.value("file"));
            query.bindValue(3, card.value("note"));
            query.bindValue(4, card.value("uuid"));
            query.bindValue(5, card.value("created"));
            break;
        case Tables::CONTRACTS:
            query.prepare(R"(INSERT INTO contracts (num, c_date, partner_id, amount, currency_id,
                    type_id, valid_from, valid_to, status, description, file, created, uuid)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?))");
            query.bindValue(0, card.value("num"));
            query.bindValue(1, card.value("c_date"));
            query.bindValue(2, card.value("partner_id"));
            query.bindValue(3, card.value("amount"));
            query.bindValue(4, card.value("currency_id"));
            query.bindValue(5, card.value("type_id"));
            query.bindValue(6, card.value("valid_from"));
            query.bindValue(7, card.value("valid_to"));
            query.bindValue(8, card.value("status"));
            query.bindValue(9, card.value("description"));
            query.bindValue(10, card.value("file"));
            query.bindValue(11, card.value("created"));
            query.bindValue(12, card.value("uuid"));
            break;
        case Tables::DOCUMENTS:
            query.prepare(R"(INSERT INTO documents (contract_id, type_id, num, doc_date, title, description, file, created, uuid)
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?))");
            query.bindValue(0, card.value("contract_id"));
            query.bindValue(1, card.value("type_id"));
            query.bindValue(2, card.value("num"));
            query.bindValue(3, card.value("doc_date"));
            query.bindValue(4, card.value("title"));
            query.bindValue(5, card.value("description"));
            query.bindValue(6, card.value("file"));
            query.bindValue(7, card.value("created"));
            query.bindValue(8, card.value("uuid"));
            break;
        case Tables::PAYMENTS:
            query.prepare(R"(INSERT INTO payments (contract_id, type_id, num, doc_date, amount, currency_id,
                        currency_rate, description, status, file, created, uuid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?))");
            query.bindValue(0, card.value("contract_id"));
            query.bindValue(1, card.value("type_id"));
            query.bindValue(2, card.value("num"));
            query.bindValue(3, card.value("doc_date"));
            query.bindValue(4, card.value("amount"));
            query.bindValue(5, card.value("currency_id"));
            query.bindValue(6, card.value("currency_rate"));
            query.bindValue(7, card.value("description"));
            query.bindValue(8, card.value("status"));
            query.bindValue(9, card.value("file"));
            query.bindValue(10, card.value("created"));
            query.bindValue(11, card.value("uuid"));
            break;
        case Tables::AMENDMENTS:
            query.prepare(R"(INSERT INTO amendments (contract_id, num, doc_date, description, change_date, valid_from, valid_to,
                    change_amount, amount, file, created, uuid) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?))");
            query.bindValue(0, card.value("contract_id"));
            query.bindValue(1, card.value("num"));
            query.bindValue(2, card.value("doc_date"));
            query.bindValue(3, card.value("description"));
            query.bindValue(4, card.value("change_date"));
            query.bindValue(5, card.value("valid_from"));
            query.bindValue(6, card.value("valid_to"));
            query.bindValue(7, card.value("change_amount"));
            query.bindValue(8, card.value("amount"));
            query.bindValue(9, card.value("file"));
            query.bindValue(10, card.value("created"));
            query.bindValue(11, card.value("uuid"));
            break;
        default:
            break;
        }
    } else {
        switch (table) {
        case Tables::PARTNERS:
            query.prepare(R"(UPDATE partners SET name = ?, full_name = ?, off_address = ?,
                        real_address = ?, code = ?, url = ?, note = ?
                        WHERE partners.id = ?)");
            query.bindValue(0, card.value("name").toString());
            query.bindValue(1, card.value("full_name").toString());
            query.bindValue(2, card.value("off_address").toString());
            query.bindValue(3, card.value("real_address").toString());
            query.bindValue(4, card.value("code").toString());
            query.bindValue(5, card.value("url").toString());
            query.bindValue(6, card.value("note").toString());
            query.bindValue(7, id);
            break;
        case Tables::PARTNERS_BANK:
            query.prepare(R"(UPDATE partnerbank SET bank_name = ?, bank_code = ?, bank_account = ?,
                            created = ? WHERE partnerbank.id = ?)");
            query.bindValue(0, card.value("bank_name"));
            query.bindValue(1, card.value("bank_code"));
            query.bindValue(2, card.value("bank_account"));
            query.bindValue(3, card.value("created"));
            query.bindValue(4, id);
            break;
        case Tables::PARTNERS_PERSON:
            query.prepare(R"(UPDATE partnerperson SET full_name = ?, position = ?, phone = ?,
                            mail = ?, messenger = ?, created = ? WHERE partnerperson.id = ?)");
            query.bindValue(0, card.value("full_name"));
            query.bindValue(1, card.value("position"));
            query.bindValue(2, card.value("phone"));
            query.bindValue(3, card.value("mail"));
            query.bindValue(4, card.value("messenger"));
            query.bindValue(5, card.value("created"));
            query.bindValue(6, id);
            break;
        case Tables::PARTNERS_DOC:
            if (params.contains(Params::ONLY_FILE)){
                query.prepare(R"(UPDATE partnerdocs SET file = ?, created = ? WHERE partnerdocs.id = ?)");
                query.bindValue(0, card.value("file"));
                query.bindValue(1, card.value("created"));
                query.bindValue(2, id);
            } else {
                query.prepare(R"(UPDATE partnerdocs SET name = ?, note = ?, created = ?
                            WHERE partnerdocs.id = ?)");
                query.bindValue(0, card.value("name"));
                query.bindValue(1, card.value("note"));
                query.bindValue(2, card.value("created"));
                query.bindValue(3, id);
            }
            break;
        case Tables::CONTRACTS:
            if (params.contains(Params::ONLY_FILE)) {
                query.prepare(R"(UPDATE contracts SET file = ?, created = ? WHERE contracts.id = ?)");
                query.bindValue(0, card.value("file"));
                query.bindValue(1, card.value("created"));
                query.bindValue(2, id);
            } else {
                query.prepare(R"(UPDATE contracts SET num = ?, c_date = ?, partner_id = ?, amount = ?,
                    currency_id  = ?, type_id = ?, valid_from = ?, valid_to = ?, status = ?, description = ?,
                    created = ?
                    WHERE contracts.id = ?)");
                query.bindValue(0, card.value("num"));
                query.bindValue(1, card.value("c_date"));
                query.bindValue(2, card.value("partner_id"));
                query.bindValue(3, card.value("amount"));
                query.bindValue(4, card.value("currency_id"));
                query.bindValue(5, card.value("type_id"));
                query.bindValue(6, card.value("valid_from"));
                query.bindValue(7, card.value("valid_to"));
                query.bindValue(8, card.value("status"));
                query.bindValue(9, card.value("description"));
                query.bindValue(10, card.value("created"));
                query.bindValue(11, id);
            }
            break;
        case Tables::DOCUMENTS:
            if (params.contains(Params::ONLY_FILE)){
                query.prepare(R"(UPDATE documents SET file = ?, created = ? WHERE documents.id = ?)");
                query.bindValue(0, card.value("file"));
                query.bindValue(1, card.value("created"));
                query.bindValue(2, id);
            } else {
                query.prepare(R"(UPDATE documents SET num = ?, doc_date = ?, title = ?, description = ?, created = ?
                    WHERE documents.id = ?)");
                query.bindValue(0, card.value("num"));
                query.bindValue(1, card.value("doc_date"));
                query.bindValue(2, card.value("title"));
                query.bindValue(3, card.value("description"));
                query.bindValue(4, card.value("created"));
                query.bindValue(5, id);
            }
            break;
        case Tables::PAYMENTS:
            if (params.contains(Params::ONLY_FILE)){
                query.prepare(R"(UPDATE payments SET file = ?, created = ? WHERE payments.id = ?)");
                query.bindValue(0, card.value("file"));
                query.bindValue(1, card.value("created"));
                query.bindValue(2, id);
            } else {
                query.prepare(R"(UPDATE payments SET num = ?, doc_date = ?, amount = ?, currency_id = ?,
                    currency_rate = ?, description = ?, status = ?, created = ? WHERE payments.id = ?)");
                query.bindValue(0, card.value("num"));
                query.bindValue(1, card.value("doc_date"));
                query.bindValue(2, card.value("amount"));
                query.bindValue(3, card.value("currency_id"));
                query.bindValue(4, card.value("currency_rate"));
                query.bindValue(5, card.value("description"));
                query.bindValue(6, card.value("status"));
                query.bindValue(7, card.value("created"));
                query.bindValue(8, id);
            }
            break;
        case Tables::AMENDMENTS:
            if (params.contains(Params::ONLY_FILE)){
                query.prepare(R"(UPDATE amendments SET file = ?, created = ? WHERE amendments.id = ?)");
                query.bindValue(0, card.value("file"));
                query.bindValue(1, card.value("created"));
                query.bindValue(2, id);
            } else {
                query.prepare(R"(UPDATE amendments SET num = ?, doc_date = ?, description = ?, change_date = ?, valid_from = ?, valid_to = ?,
                    change_amount = ?, amount = ?, created = ? WHERE amendments.id = ?)");
                query.bindValue(0, card.value("num"));
                query.bindValue(1, card.value("doc_date"));
                query.bindValue(2, card.value("description"));
                query.bindValue(3, card.value("change_date"));
                query.bindValue(4, card.value("valid_from"));
                query.bindValue(5, card.value("valid_to"));
                query.bindValue(6, card.value("change_amount"));
                query.bindValue(7, card.value("amount"));
                query.bindValue(8, card.value("created"));
                query.bindValue(9, id);
            }
            break;
        default:
            break;
        }
    }

    if (query.exec()){
        res.insert("id", query.lastInsertId());
        res.insert("r", true);
    } else {
        res.insert("err", query.lastError().text());
        res.insert("r", false);
    }

    return res;
}

bool DatabaseWorker::delData(int table, const QVariantMap &params)
{
    bool res = false;
    QSqlQuery query(db);
    if (table == Tables::CONTRACTS) {
        QStringList qlist;
        qlist.append(QString("DELETE FROM amendments WHERE amendments.contract_id = \"%1\";").arg(params.value("id").toInt()));
        qlist.append(QString("DELETE FROM payments WHERE payments.contract_id = \"%1\";").arg(params.value("id").toInt()));
        qlist.append(QString("DELETE FROM documents WHERE documents.contract_id = \"%1\";").arg(params.value("id").toInt()));
        qlist.append(QString("DELETE FROM contracts WHERE contracts.id = \"%1\";").arg(params.value("id").toInt()));
        for (auto& q : qlist) {
            QSqlQuery query(q, db);
            res = query.exec();
            if (!res) qDebug() <<"del err: "<< query.lastError().text();
        }
    } else {
        switch (table) {
        case Tables::PARTNERS:
            query.prepare(R"(DELETE FROM partners WHERE partners.id = ?)");
            query.bindValue(0, params.value("id"));
            break;
        case Tables::PARTNERS_BANK:
            if (params.contains("partner_id")) {
                query.prepare(R"(DELETE FROM partnerbank WHERE partnerbank.partner_id = ?)");
                query.bindValue(0, params.value("partner_id"));
            } else {
                query.prepare(R"(DELETE FROM partnerbank WHERE partnerbank.id = ?)");
                query.bindValue(0, params.value("id"));
            }
            break;
        case Tables::PARTNERS_PERSON:
            if (params.contains("partner_id")) {
                query.prepare(R"(DELETE FROM partnerperson WHERE partnerperson.partner_id = ?)");
                query.bindValue(0, params.value("partner_id"));
            } else {
                query.prepare(R"(DELETE FROM partnerperson WHERE partnerperson.id = ?)");
                query.bindValue(0, params.value("id"));
            }
            break;
        case Tables::PARTNERS_DOC:
            if (params.contains("partner_id")) {
                query.prepare(R"(DELETE FROM partnerdocs WHERE partnerdocs.partner_id = ?)");
                query.bindValue(0, params.value("partner_id"));
            } else {
                query.prepare(R"(DELETE FROM partnerdocs WHERE partnerdocs.id = ?)");
                query.bindValue(0, params.value("id"));
            }
            break;
        case Tables::DOCUMENTS:
            query.prepare(R"(DELETE FROM documents WHERE documents.id = ?)");
            query.bindValue(0, params.value("id"));
            break;
        case Tables::PAYMENTS:
            query.prepare(R"(DELETE FROM payments WHERE payments.id = ?)");
            query.bindValue(0, params.value("id"));
            break;
        case Tables::AMENDMENTS:
            query.prepare(R"(DELETE FROM amendments WHERE amendments.id = ?)");
            query.bindValue(0, params.value("id"));
            break;
        default:
            break;
        }
        res = query.exec();
        if (!res) qDebug() <<"del err: "<< query.lastError().text();
    }
    return res;
}

double DatabaseWorker::getSumPay(int type_id, int contract_id)
{
    double res = 0;
    QSqlQuery query(db);
    query.prepare(R"(SELECT SUM(p.amount * p.currency_rate) FROM payments AS p WHERE p.type_id = ? AND p.contract_id = ? AND p.status = ?)");
    query.bindValue(0, type_id);
    query.bindValue(1, contract_id);
    query.bindValue(2, PayStatus::PAID);
    if (query.exec()) {
        query.first();
        res = query.value(0).toDouble();
    }
    return res;
}

QStringList DatabaseWorker::getContractUuids(int contract_id)
{
    QStringList res;
    QSqlQuery query(db);
    query.prepare(R"(SELECT c.uuid as uuid FROM contracts c WHERE c.id = ?
        UNION SELECT a.uuid as uuid FROM amendments a WHERE a.contract_id = ?
        UNION SELECT p.uuid as uuid FROM payments p WHERE p.contract_id = ?
        UNION SELECT d.uuid as uuid FROM documents d WHERE d.contract_id = ? )");
    query.bindValue(0, contract_id);
    query.bindValue(1, contract_id);
    query.bindValue(2, contract_id);
    query.bindValue(3, contract_id);
    query.exec();
    while (query.next()) {
        res.append(query.value(0).toString());
    }
    return res;
}

QStringList DatabaseWorker::getPartnerUuids(int partner_id)
{
    QStringList res;
    QSqlQuery query(db);
    query.prepare(R"(SELECT pd.uuid as uuid FROM partnerdocs pd WHERE pd.partner_id = ? )");
    query.bindValue(0, partner_id);
    query.exec();
    while (query.next()) {
        res.append(query.value(0).toString());
    }
    return res;
}

QVariantMap DatabaseWorker::getDashData(const QString &ids, const QVariantMap &filter)
{
    QVariantMap result;

    QSqlQuery query(db);
    if (ids.contains("top")) {
        query.prepare(R"(SELECT
            (SELECT Count(p.id) FROM partners p) AS partners_count,
            (SELECT Count(p.id) FROM partners p WHERE p.created > ?) AS partner_new,
            (SELECT COUNT(c.id) FROM contracts c) AS contracts_count,
            (SELECT Count(c.id) FROM contracts c WHERE  c.created > ?) AS contract_new,
            (SELECT (SELECT Count(d.id) FROM documents d) + (SELECT Count(p.id) FROM payments p) + (SELECT Count(a.id) FROM amendments a)) AS doc_count,
            (SELECT Count(p.id) FROM payments p) AS pay_count,
            (SELECT
(SELECT Count(c.id) FROM contracts c WHERE c.status != 4 AND c.file IS NULL) +
(SELECT Count(d.id) FROM documents d INNER JOIN contracts c ON d.contract_id  = c.id WHERE c.status != 4 AND d.file IS NULL) +
(SELECT Count(p.id) FROM payments p INNER JOIN contracts c ON p.contract_id  = c.id WHERE c.status != 4 AND p.file IS NULL) +
(SELECT Count(a.id) FROM amendments a INNER JOIN contracts c ON a.contract_id  = c.id WHERE c.status != 4 AND a.file IS NULL)) AS file_fail)");
        query.bindValue(0, filter.value("d"));
        query.bindValue(1, filter.value("d"));
    } else if (ids.contains("contracts")) {
        if (filter.contains("type")){
            query.prepare(R"(SELECT
                (SELECT COUNT(c.id) FROM contracts c WHERE c.type_id = ?) AS contracts_count,
                (SELECT Count(c.id) FROM contracts c WHERE c.type_id = ? AND c.status = 1) AS active,
                (SELECT Count(c.id) FROM contracts c WHERE c.type_id = ? AND c.status = 3) AS completed,
                (SELECT Count(c.id) FROM contracts c WHERE c.type_id = ? AND c.status = 2) AS aborted,
                (SELECT Count(c.id) FROM contracts c WHERE c.type_id = ? AND c.status = 4) AS archive)");
            query.bindValue(0, filter.value("type"));
            query.bindValue(1, filter.value("type"));
            query.bindValue(2, filter.value("type"));
            query.bindValue(3, filter.value("type"));
            query.bindValue(4, filter.value("type"));
        } else {
            query.prepare(R"(SELECT
                (SELECT COUNT(c.id) FROM contracts c) AS contracts_count,
                (SELECT Count(c.id) FROM contracts c WHERE  c.status = 1) AS active,
                (SELECT Count(c.id) FROM contracts c WHERE  c.status = 3) AS completed,
                (SELECT Count(c.id) FROM contracts c WHERE  c.status = 2) AS aborted,
                (SELECT Count(c.id) FROM contracts c WHERE  c.status = 4) AS archive)");
        }
    }
    query.exec();
    while (query.next()) {
        QSqlRecord record = query.record();
        for (int i = 0; i < record.count(); i++){
            result.insert(record.fieldName(i), record.value(i));
        }
    }
    return result;
}

double DatabaseWorker::getPaymentSum(int from, int to, int doc_type, int currency, int contract_type)
{
    double result;
    QSqlQuery query(db);
    query.prepare(R"(SELECT SUM(p.amount) FROM payments p
            INNER JOIN contracts c ON p.contract_id = c.id
            WHERE p.type_id = ? AND p.status = ? AND p.currency_id = ? AND (p.doc_date BETWEEN ? AND ?) AND c.type_id = ?)");
    query.bindValue(0, doc_type);
    query.bindValue(1, PayStatus::PAID);
    query.bindValue(2, currency);
    query.bindValue(3, from);
    query.bindValue(4, to);
    query.bindValue(5, contract_type);
    query.exec();
    query.first();
    result = query.value(0).toDouble();
    return result;
}

QList<QVariantMap> DatabaseWorker::getPaymentCurrency(int c_date, int doc_type)
{
    QList<QVariantMap> result;
    QSqlQuery query(db);
    query.prepare(R"(SELECT p.currency_id, c.code FROM payments p
            INNER JOIN currency c ON p.currency_id = c.id            
            WHERE p.type_id = ? AND p.status = ? AND p.doc_date > ? GROUP BY p.currency_id)");
    query.bindValue(0, doc_type);
    query.bindValue(1, PayStatus::PAID);
    query.bindValue(2, c_date);

    bool r = query.exec();
    if (r) {
        while (query.next()) {
            QVariantMap card;
            QSqlRecord record = query.record();
            for (int i = 0; i < record.count(); i++){
                card.insert(record.fieldName(i), record.value(i));
            }
            result.append(card);
        }
    }
    return result;
}

