#pragma once

#include <QObject>
#include <QSortFilterProxyModel>

class PartnerDocProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit PartnerDocProxyModel(QObject *parent = nullptr);

    Q_INVOKABLE void setFilter(const QString& filter);

    Q_INVOKABLE void sortByRole(int role, Qt::SortOrder order = Qt::AscendingOrder);
    void setSortRole(int role);

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const;

private:
    QString m_filter;
    int m_sortRole = 0;
};
