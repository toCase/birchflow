#pragma once

#include <QObject>
#include <QDate>
#include <QSortFilterProxyModel>
#include "tcd_settings.h"

class ContractsProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit ContractsProxyModel(TCD_Settings *st, QObject *parent = nullptr);

    Q_INVOKABLE void setFilter(const QVariantMap& filter);
    Q_INVOKABLE void setQuickFilter(const QString& filter);

private:
    QVariantMap m_filter;
    QString m_quickFilter;

    TCD_Settings *m_setting;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;
};

