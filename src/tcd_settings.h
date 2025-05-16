#pragma once

#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>
#include <QFile>
#include <QVariant>
#include <QTimer>

class TCD_Settings : public QObject
{
    Q_OBJECT
public:
    explicit TCD_Settings(const QString& filePath, QObject *parent = nullptr);

    void load();
    void save();

    Q_INVOKABLE void setValue(const QString& key, const QVariant& value);
    Q_INVOKABLE QVariant getValue(const QString& key, const QVariant& defaultValue = QVariant()) const;

    Q_INVOKABLE QString toLocalDir(const QUrl& location);
private:
    QString m_filePath;
    QJsonObject m_settings;

signals:
    void settingChange(const QString& key, const QVariant& value);
};
