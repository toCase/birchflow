#include "pm_contracts.h"

ContractsProxyModel::ContractsProxyModel(TCD_Settings *st, QObject *parent)
    : m_setting(st), QSortFilterProxyModel{parent}
{}

void ContractsProxyModel::setFilter(const QVariantMap &filter)
{
    m_filter.clear();
    m_filter = filter;
    invalidateFilter();
}

void ContractsProxyModel::setQuickFilter(const QString &filter)
{
    m_quickFilter.clear();
    m_quickFilter = filter;
    invalidateFilter();
}


bool ContractsProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (m_filter.isEmpty() && m_quickFilter.isEmpty()) return true;

    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    if (!m_quickFilter.isEmpty()){
        if (index.data(1).toString().contains(m_quickFilter, Qt::CaseInsensitive)) return true;
        if (index.data(12).toString().contains(m_quickFilter, Qt::CaseInsensitive)) return true;
    }

    if (!m_filter.isEmpty()){
        if (m_filter.contains("status")){
            if (index.data(8).toInt() == m_filter.value("status").toInt()) return true;
        }
        if (m_filter.contains("partner")){
            if (index.data(3).toString() == m_filter.value("partner").toString()) return true;
        }
        if (m_filter.contains("from")){
            int doc_date = QDate::fromString(index.data(2).toString(),m_setting->getValue("dateFormat").toString()).toJulianDay();
            int f_from = QDate::fromString(m_filter.value("from").toString(), m_setting->getValue("dateFormat").toString()).toJulianDay();
            int f_to = QDate::fromString(m_filter.value("to").toString(), m_setting->getValue("dateFormat").toString()).toJulianDay();

            if (doc_date >= f_from && doc_date <= f_to) return true;
        }
    }
    return false;
}
