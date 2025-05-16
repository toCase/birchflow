#include "tcd_settings.h"

TCD_Settings::TCD_Settings(const QString &filePath, QObject *parent)
    : m_filePath(filePath), QObject{parent}
{
    load();
}

void TCD_Settings::load()
{
    QFile file(m_filePath);
    if (file.open(QIODevice::ReadOnly)) {
        QJsonDocument doc = QJsonDocument::fromJson(file.readAll());
        if (doc.isObject()) m_settings = doc.object();
    }
}

void TCD_Settings::save()
{
    QFile file(m_filePath);
    if (file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        QJsonDocument doc(m_settings);
        file.write(doc.toJson(QJsonDocument::Indented));
    }
}

void TCD_Settings::setValue(const QString &key, const QVariant &value)
{
    if (m_settings.value(key).toVariant() != value) {
        m_settings.insert(key, QJsonValue::fromVariant(value));
        emit settingChange(key, value);
        save();
    }
}

QVariant TCD_Settings::getValue(const QString &key, const QVariant &defaultValue) const
{
    if (!m_settings.contains(key)) return defaultValue;
    return m_settings.value(key).toVariant();
}

QString TCD_Settings::toLocalDir(const QUrl &location)
{
    return location.toLocalFile();
}
