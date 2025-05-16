#pragma once

#include <QObject>
#include <QSortFilterProxyModel>

class PartnerBankProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit PartnerBankProxyModel(QObject *parent = nullptr);

    Q_INVOKABLE void setFilter(const QString& filter);
    Q_INVOKABLE void sortByRole(int role, Qt::SortOrder order = Qt::AscendingOrder);
    void setSortRole(int role);

private:
    QString m_filter;
    int m_sortRole = 0;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

};
