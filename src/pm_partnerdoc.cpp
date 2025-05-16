#include "pm_partnerdoc.h"

PartnerDocProxyModel::PartnerDocProxyModel(QObject *parent)
    : QSortFilterProxyModel{parent}
{}

void PartnerDocProxyModel::setFilter(const QString &filter)
{
    m_filter.clear();
    m_filter = filter;
    invalidateFilter();
}

void PartnerDocProxyModel::sortByRole(int role, Qt::SortOrder order)
{
    setSortRole(role);
    sort(0, order);
}

void PartnerDocProxyModel::setSortRole(int role)
{
    if (m_sortRole != role) {
        m_sortRole = role;
        QSortFilterProxyModel::setSortRole(m_sortRole);
    }
}


bool PartnerDocProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (m_filter.isEmpty()) return true;

    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    for (int i = 1; i <= 3; i++){
        if (index.data(i).toString().contains(m_filter, Qt::CaseInsensitive)) return true;
    }

    return false;
}
