#pragma once

#include <QObject>
#include <QUrl>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QProcess>
#include <QDesktopServices>
#include <QCryptographicHash>
#include "tcd_settings.h"
#include "app_namespaces.h"

using namespace App;

class FileManager : public QObject
{
    Q_OBJECT
public:
    explicit FileManager(const QDir& appDir, TCD_Settings *st, QObject *parent = nullptr);

private:
    QString VAULT;

    TCD_Settings* m_setting;

public:
    Q_INVOKABLE QString toLocalFile(const QUrl& location);

    QString getSuffix(const QString& file);

    void createPartnerDoc(const QString& original_file, int partner_id, int doc_id);
    void removePartnerDoc(int partner_id, int doc_id, bool all = false);


    void createDoc(const QString& original_file, const QString& uuid);
    void removeDoc(const QString& uuid, bool isArch = false);

    void makeArchiveDir(int contract_id);
    void copyAchiveFile(const QString& uuid, const QString &fname, int section = -1);
    void saveArchiveDir(const QString& zip_file);
    QString getArchiveMarkdown(const QString& arch_file);

    void sendArchive(const QString& uuid, const QString& dir, int contract_id);

    QString getMD5(const QString& fileName);

    void openFile(const QString& fileName);


public slots:
    void setVault(const QString& key, const QVariant& value);
};
