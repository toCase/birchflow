#pragma once

#include <QObject>

#include "app_namespaces.h"
using namespace App;

class NotificationManager : public QObject
{
    Q_OBJECT
public:
    explicit NotificationManager(QObject *parent = nullptr);

    Q_INVOKABLE void makeNote(const QString& textNote, int typeNote = Notes::NOTIFY);

signals:
    void notify(const QString& textNote, int typeNote);
};
