#pragma once


#include <QObject>
#include <QDate>
#include <QSortFilterProxyModel>
#include "tcd_settings.h"

class ProxyModelDashContracts : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit ProxyModelDashContracts(TCD_Settings *st, QObject *parent = nullptr);

private:
    TCD_Settings *m_setting;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;
};
