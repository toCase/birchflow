#include "pm_dashcontracts.h"

ProxyModelDashContracts::ProxyModelDashContracts(TCD_Settings *st, QObject *parent)
    : m_setting(st), QSortFilterProxyModel{parent}
{
    invalidateFilter();
}


bool ProxyModelDashContracts::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const
{
    QModelIndex index = sourceModel()->index(source_row, 0, source_parent);
    int status = index.data(8).toInt();
    int valid_to = QDate::fromString(index.data(5).toString(), m_setting->getValue("dateFormat").toString()).toJulianDay();

    int today = QDate::currentDate().toJulianDay();

    if (status != 1) return false;
    if (today > valid_to) return true;

    return false;
}
