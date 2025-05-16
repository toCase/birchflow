#include "notificationmanager.h"

NotificationManager::NotificationManager(QObject *parent)
    : QObject{parent}
{}

void NotificationManager::makeNote(const QString &textNote, int typeNote)
{
    emit notify(textNote, typeNote);
}


