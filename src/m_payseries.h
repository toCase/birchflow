#pragma once

#include <QAbstractTableModel>
#include <QObject>
#include "algorithm"

#include "database.h"
#include "tcd_settings.h"

class ModelPaymentSeries : public QAbstractTableModel
{
    Q_OBJECT
    Q_PROPERTY(int currency READ currency WRITE setCurrency NOTIFY currencyChanged FINAL);
public:
    explicit ModelPaymentSeries(DatabaseWorker *dbw, TCD_Settings *st, QObject *parent = nullptr);


private:
    DatabaseWorker *m_dbworker;
    TCD_Settings *m_setting;

    QList<double> DATA;
    QList<QVariantMap> CURR;

    QStringList monthList;
    int currentCurrency = -1;

    int m_currency;
    int m_contract = 1;

public:
    int rowCount(const QModelIndex &parent) const;
    int columnCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;


    Q_INVOKABLE void load();
    Q_INVOKABLE void updateModel();

    Q_INVOKABLE QStringList currencyList();

    Q_INVOKABLE int currency() const;
    Q_INVOKABLE void setCurrency(int newCurrency);

    Q_INVOKABLE void setContract(int value);

signals:
    void currencyListUpdated();
    void currencyChanged();
    void contractChanged();

    void changeMin(double value);
    void changeMax(double value);
    void changeMonth(QStringList month);
};
