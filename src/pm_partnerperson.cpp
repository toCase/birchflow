#include "pm_partnerperson.h"

PartnerPersonProxyModel::PartnerPersonProxyModel(QObject *parent)
    : QSortFilterProxyModel{parent}
{}

void PartnerPersonProxyModel::setFilter(const QString &filter)
{
    m_filter.clear();
    m_filter = filter;
    invalidateFilter();
}

void PartnerPersonProxyModel::sortByRole(int role, Qt::SortOrder order)
{
    setSortRole(role);
    sort(0, order);
}

void PartnerPersonProxyModel::setSortRole(int role)
{
    if (m_sortRole != role) {
        m_sortRole = role;
        QSortFilterProxyModel::setSortRole(m_sortRole);
    }
}


bool PartnerPersonProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (m_filter.isEmpty()) return true;

    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    for (int i = 1; i <= 5; i++) {
        if (index.data(i).toString().contains(m_filter, Qt::CaseInsensitive)) return true;
    }

    return false;
}
