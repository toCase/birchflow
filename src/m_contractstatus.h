#pragma once

#include <QObject>
#include <QQmlEngine>

class ModelContractStatus : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    Q_INVOKABLE QVariantList getStatusList() const {
        return QVariantList {
            QVariantMap{{"value", 1}, {"text", tr("Active")}},
            QVariantMap{{"value", 2}, {"text", tr("Aborted")}},
            QVariantMap{{"value", 3}, {"text", tr("Completed")}},
            QVariantMap{{"value", 4}, {"text", tr("Archived")}}
        };
    }
    Q_INVOKABLE int getRow(int id) {
        QVariantList list = getStatusList();
        for (int i = 0; i < list.count(); i++){
            QVariantMap map = list.at(i).toMap();
            if (map.value("value").toInt() == id) return i;
        }
        return -1;
    }
};

class ModelContractType : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    Q_INVOKABLE QVariantList getTypeList() const {
        return QVariantList {
            QVariantMap{{"value", 1}, {"text", tr("Profitable")}},
            QVariantMap{{"value", 2}, {"text", tr("Expense")}},
        };
    }

    Q_INVOKABLE int getRow(int id) {
        QVariantList list = getTypeList();
        for (int i = 0; i < list.count(); i++){
            QVariantMap map = list.at(i).toMap();
            if (map.value("value").toInt() == id) return i;
        }
        return -1;
    }

};

class ModelPaymentStatus : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    Q_INVOKABLE QVariantList getList() const {
        return QVariantList {
                            QVariantMap{{"value", 0}, {"text", tr("Not paid")}},
                            QVariantMap{{"value", 1}, {"text", tr("Partially paid")}},
                            QVariantMap{{"value", 2}, {"text", tr("Paid")}},
                            };
    }

    Q_INVOKABLE int getRow(int id) {
        QVariantList list = getList();
        for (int i = 0; i < list.count(); i++){
            QVariantMap map = list.at(i).toMap();
            if (map.value("value").toInt() == id) return i;
        }
        return -1;
    }

};
