#include "pm_partnerbank.h"

PartnerBankProxyModel::PartnerBankProxyModel(QObject *parent)
    : QSortFilterProxyModel{parent}
{}

void PartnerBankProxyModel::setFilter(const QString &filter)
{
    m_filter.clear();
    m_filter = filter;
    invalidateFilter();
}

void PartnerBankProxyModel::sortByRole(int role, Qt::SortOrder order)
{
    setSortRole(role);
    sort(0, order);
}

void PartnerBankProxyModel::setSortRole(int role)
{
    if (m_sortRole != role) {
        m_sortRole = role;
        QSortFilterProxyModel::setSortRole(m_sortRole);
    }
}


bool PartnerBankProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (m_filter.isEmpty()) return true;

    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    for (int i = 1; i <= 3; i++){
        if (index.data(i).toString().contains(m_filter, Qt::CaseInsensitive)) return true;
    }

    return false;
}
