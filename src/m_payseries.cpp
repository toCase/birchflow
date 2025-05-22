#include "m_payseries.h"

ModelPaymentSeries::ModelPaymentSeries(DatabaseWorker *dbw, TCD_Settings *st, QObject *parent)
    : m_dbworker(dbw), m_setting(st), QAbstractTableModel{parent}
{
    connect(this, &ModelPaymentSeries::currencyChanged, this, &ModelPaymentSeries::updateModel);
    connect(this, &ModelPaymentSeries::contractChanged, this, &ModelPaymentSeries::updateModel);
}


int ModelPaymentSeries::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return 12;
}

int ModelPaymentSeries::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return 2;
}

QVariant ModelPaymentSeries::data(const QModelIndex &index, int role) const
{
    QVariant res;
    if (DATA.isEmpty()) return res;

    if (role == Qt::DisplayRole) {
        int col = index.column();
        if (col == 0) {
            res = index.row();
        } else {
            res = DATA.at(index.row());
        }
    }
    return res;
}

void ModelPaymentSeries::load()
{
    QDate from = QDate::currentDate().addMonths(-11);
    int doc_type = m_setting->getValue("calcPay").toString() == "payment" ? DocTypes::PAYMENT : DocTypes::INVOICE;
    CURR.clear();
    CURR = m_dbworker->getPaymentCurrency(from.toJulianDay(), doc_type);

    emit currencyListUpdated();

    if (m_currency == -1) setCurrency(0);
}

void ModelPaymentSeries::updateModel()
{
    beginResetModel();
    int doc_type = m_setting->getValue("calcPay").toString() == "payment" ? DocTypes::PAYMENT : DocTypes::INVOICE;

    monthList.clear();

    DATA.clear();
    for (int i = 11; i >= 0; i--){
        QDate x_date = QDate::currentDate().addMonths(-i);
        QDate from = QDate(x_date.year(), x_date.month(), 1);
        QDate to = QDate(x_date.year(), x_date.month(), x_date.daysInMonth());


        monthList.append(from.toString("MMM yy"));

        QVariantMap curr = CURR[m_currency];
        double value = m_dbworker->getPaymentSum(from.toJulianDay(), to.toJulianDay(), doc_type, curr.value("currency_id").toInt(), m_contract);

        DATA.append(value);
    }

    emit changeMonth(monthList);

    if (!DATA.isEmpty()) {
        auto[minIt, maxIt] = std::minmax_element(DATA.begin(),DATA.end());

        double minValue = *minIt;
        if (minValue > 0) minValue = minValue * 0.95;
        emit changeMin(minValue);

        double maxValue = *maxIt;
        if (maxValue > 0) maxValue = maxValue * 1.05;
        emit changeMax(maxValue);

    }

    endResetModel();
}

QStringList ModelPaymentSeries::currencyList()
{
    QStringList c;
    for (auto& card : CURR){ c.append(card.value("code").toString()); }
    return c;
}

int ModelPaymentSeries::currency() const
{
    return m_currency;
}

void ModelPaymentSeries::setCurrency(int newCurrency)
{
    if (m_currency == newCurrency)
        return;
    m_currency = newCurrency;
    emit currencyChanged();
}

void ModelPaymentSeries::setContract(int value)
{
    m_contract = value;
    emit contractChanged();
}

