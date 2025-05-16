#include "pm_partner.h"

PartnerProxyModel::PartnerProxyModel(QObject *parent)
    : QSortFilterProxyModel{parent}
{

}

int PartnerProxyModel::getRow(int id)
{
    auto* partnersModel = qobject_cast<ModelPartners*>(sourceModel());
    if (!partnersModel)
        return -1;

    int sourceRowCount = partnersModel->rowCount(QModelIndex());
    for (int row = 0; row < sourceRowCount; ++row) {
        QModelIndex sourceIndex = partnersModel->index(row, 0);
        QVariant idValue = partnersModel->data(sourceIndex, ModelPartners::ID);
        if (idValue == id) {
            QModelIndex proxyIndex = mapFromSource(sourceIndex);
            if (proxyIndex.isValid())
                return proxyIndex.row(); // Возвращаем позицию в прокси
            else
                return -1; // Может быть отфильтровано
        }
    }

    return -1; // Не найдено
}

void PartnerProxyModel::setFilter(const QString &filter)
{
    m_filter.clear();
    m_filter = filter;
    invalidateFilter();
}

void PartnerProxyModel::sortByRole(int role, Qt::SortOrder order)
{
    setSortRole(role);
    sort(0, order);
}


bool PartnerProxyModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    if (m_filter.isEmpty()) return true;

    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);

    for (int i = 1; i <= 7; i++){
        if (index.data(i).toString().contains(m_filter, Qt::CaseInsensitive)) return true;
    }

    return false;
}

void PartnerProxyModel::setSortRole(int role)
{
    if (m_sortRole != role) {
        m_sortRole = role;
        QSortFilterProxyModel::setSortRole(m_sortRole);
    }
}
