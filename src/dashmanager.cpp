#include "dashmanager.h"

DashManager::DashManager(DatabaseWorker *dbw, TCD_Settings *st, QObject *parent)
    : m_dbworker(dbw), m_setting(st), QObject{parent}
{}

QVariantMap DashManager::dashTopData()
{
    int d = QDateTime::currentDateTime().addMonths(-1).toSecsSinceEpoch();
    auto dash_data = m_dbworker->getDashData("top", QVariantMap{{"d", d}});

    int doc_count = dash_data.value("doc_count").toInt();
    int pay_count = dash_data.value("pay_count").toInt();
    double pay_percent = 0;
    if (pay_count > 0) {
        pay_percent = 100 * pay_count / doc_count;
    }

    dash_data.insert("pay_doc", QString::number(pay_percent, 'f', 0));
    return dash_data;
}

QVariantMap DashManager::dashContractData(int type)
{
    QVariantMap data;
    if (type == 0) {
        data = m_dbworker->getDashData("contracts");
    } else {
        data = m_dbworker->getDashData("contracts", QVariantMap{{"type", type}});
    }

    double c_count = data.value("contracts_count").toDouble();
    double c_active = data.value("active").toDouble();
    double c_completed = data.value("completed").toDouble();
    double c_aborted = data.value("aborted").toDouble();
    double c_archive = data.value("archive").toDouble();

    double m_active = 0;
    double m_completed = 0;
    double m_aborted = 0;
    double m_archive = 0;

    if (c_count > 0) {
        m_active = c_active / c_count;
        m_completed = c_completed / c_count;
        m_aborted = c_aborted / c_count;
        m_archive = c_archive / c_count;
    }

    data.insert("m_active", m_active);
    data.insert("m_completed", m_completed);
    data.insert("m_aborted", m_aborted);
    data.insert("m_archive", m_archive);

    return data;
}
