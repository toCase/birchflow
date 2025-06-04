#include "filemanager.h"

FileManager::FileManager(const QDir &appDir, TCD_Settings *st, QObject *parent)
    : m_setting(st), QObject{parent}
{
    // if (!appDir.exists("vault")) appDir.mkdir("vault");
    VAULT = QDir::toNativeSeparators(m_setting->getValue("vault").toString());
    connect(m_setting, &TCD_Settings::settingChange, this, &FileManager::setVault);
}

QString FileManager::toLocalFile(const QUrl &location)
{
    return location.toLocalFile();
}

QString FileManager::getSuffix(const QString &file)
{
    if (file.isEmpty()) return QString();
    return QFileInfo(file).suffix();
}

void FileManager::createPartnerDoc(const QString &original_file, int partner_id, int doc_id)
{
    QString ext = QFileInfo(original_file).suffix();
    QString vault_file = QDir::toNativeSeparators(VAULT + "/" + QString::number(partner_id) + "_" + QString::number(doc_id) + "." + ext);
    QFile orig_file(QDir::toNativeSeparators(original_file));
    orig_file.copy(vault_file);

}

void FileManager::removePartnerDoc(int partner_id, int doc_id, bool all)
{
    QString base_name = QString::number(partner_id) + "_" + QString::number(doc_id);

    QDir vault_dir(QDir::toNativeSeparators(VAULT));
    QFileInfoList fileList = vault_dir.entryInfoList(QDir::Files | QDir::NoSymLinks);
    for (const auto& fileInfo : fileList){
        if (fileInfo.completeBaseName() == base_name) {
            QFile::remove(fileInfo.absoluteFilePath());
        }
    }
}

void FileManager::createDoc(const QString &original_file, const QString &uuid)
{
    removeDoc(uuid);
    QString ext = QFileInfo(original_file).suffix();
    QString vault_file = QDir::toNativeSeparators(VAULT + "/" + uuid + "." + ext);
    QFile orig_file(QDir::toNativeSeparators(original_file));
    orig_file.copy(vault_file);
}

void FileManager::removeDoc(const QString &uuid, bool isArch)
{
    QDir vault_dir(QDir::toNativeSeparators(VAULT));
    QFileInfoList fileList = vault_dir.entryInfoList(QDir::Files | QDir::NoSymLinks);
    for (const auto& fileInfo : fileList){
        if (isArch) {
            if (fileInfo.completeBaseName() == "das" + uuid || fileInfo.completeBaseName() == "arch" + uuid) {
                QFile::remove(fileInfo.absoluteFilePath());
            }
        } else {
            if (fileInfo.completeBaseName() == uuid) {
                QFile::remove(fileInfo.absoluteFilePath());
            }
        }
    }
}

void FileManager::makeArchiveDir(int contract_id)
{
    QDir arch_dir = QDir::toNativeSeparators(VAULT+ "/arch");
    QDir vault_dir = QDir::toNativeSeparators(VAULT);
    arch_dir.removeRecursively();
    vault_dir.mkdir("arch");
}

void FileManager::copyAchiveFile(const QString &uuid, const QString &fname, int section)
{

    QDir vault_dir(QDir::toNativeSeparators(VAULT));

    QDir arch_dir = QDir::toNativeSeparators(VAULT+ "/arch");


    QString vault_file;
    QFileInfoList fileList = vault_dir.entryInfoList(QDir::Files | QDir::NoSymLinks);
    for (const auto& fileInfo : fileList){
        if (fileInfo.completeBaseName() == uuid) vault_file = fileInfo.absoluteFilePath();
    }
    QString ext_file = QFileInfo(vault_file).suffix();


    switch (section) {
    case -1:
        QFile(vault_file).copy(QDir::toNativeSeparators(VAULT+ "/arch/" + fname + "." + ext_file));
        break;
    case DocTypes::AMENDMENT:
        if (!arch_dir.exists("amendments")) arch_dir.mkdir("amendments");
        QFile(vault_file).copy(QDir::toNativeSeparators(VAULT+ "/arch/amendments/" + fname + "." + ext_file));
        break;
    case DocTypes::INVOICE:
        if (!arch_dir.exists("invoices")) arch_dir.mkdir("invoices");
        QFile(vault_file).copy(QDir::toNativeSeparators(VAULT+ "/arch/invoices/" + fname + "." + ext_file));
        break;
    case DocTypes::PAYMENT:
        if (!arch_dir.exists("payments")) arch_dir.mkdir("payments");
        QFile(vault_file).copy(QDir::toNativeSeparators(VAULT+ "/arch/payments/" + fname + "." + ext_file));
        break;
    case DocTypes::CORRESPONDENCE:
        if (!arch_dir.exists("correspondence")) arch_dir.mkdir("correspondence");
        QFile(vault_file).copy(QDir::toNativeSeparators(VAULT+ "/arch/correspondence/" + fname + "." + ext_file));
        break;
    case DocTypes::ESTIMATE:
        if (!arch_dir.exists("estimates")) arch_dir.mkdir("estimates");
        QFile(vault_file).copy(QDir::toNativeSeparators(VAULT+ "/arch/estimates/" + fname + "." + ext_file));
        break;
    case DocTypes::GOODS:
        if (!arch_dir.exists("goods")) arch_dir.mkdir("goods");
        QFile(vault_file).copy(QDir::toNativeSeparators(VAULT+ "/arch/goods/" + fname + "." + ext_file));
        break;
    case DocTypes::ACTS:
        if (!arch_dir.exists("acts")) arch_dir.mkdir("acts");
        QFile(vault_file).copy(QDir::toNativeSeparators(VAULT+ "/arch/acts/" + fname + "." + ext_file));
        break;
    case DocTypes::OTHER:
        if (!arch_dir.exists("docs")) arch_dir.mkdir("docs");
        QFile(vault_file).copy(QDir::toNativeSeparators(VAULT+ "/arch/docs/" + fname + "." + ext_file));
        break;
    default:
        break;
    }
}

QString FileManager::getMD5(const QString &fileName)
{
    QString res;
    QFile file(fileName);

    if (!file.open(QIODevice::ReadOnly)) {
        qDebug() << "Failed to open archive for hashing!";
    } else {
        QCryptographicHash hash(QCryptographicHash::Md5);
        if (!hash.addData(&file)) {
            qDebug() << "Failed to compute hash!";
        } else {
            res = hash.result().toHex();
        }
        file.close();
    }
    return res;
}

void FileManager::saveArchiveDir(const QString &zip_file)
{

    /*
    QDir vault_dir(QDir::toNativeSeparators(VAULT));
    QStringList args;
    args << "-r" << zip_file << "arch";

    QProcess proc;
    proc.setWorkingDirectory(vault_dir.absolutePath());
    proc.start("zip", args);
    proc.waitForFinished();



    QDir arch_dir = QDir::toNativeSeparators(VAULT+ "/arch");
    arch_dir.removeRecursively();
    */
    QDir vault_dir(VAULT);
    QString arch_path = vault_dir.filePath("arch");

    if (!QDir(arch_path).exists()){
        qDebug() << "arch folder is not exists";
        return;
    }

    bool ok = JlCompress::compressDir(zip_file, arch_path);
    if (!ok) { qWarning() << "Error during making arch: " << zip_file; }

    QDir arch_dir(arch_path);
    if (!arch_dir.removeRecursively()) {
        qWarning() << "Error can't remove dir " << arch_path;
    }
}

QString FileManager::getArchiveMarkdown(const QString &arch_file)
{
    QString res;
    QFile file(arch_file);
    if (file.open(QIODevice::ReadOnly)) {
        QTextStream in(&file);
        res = in.readAll();
    }
    return res;
}

void FileManager::sendArchive(const QString &uuid, const QString &dir, int contract_id)
{
    QString arch_zip = QDir::toNativeSeparators(VAULT + "/arch" + uuid + ".zip");
    QString new_zip = QDir::toNativeSeparators(dir + "/arch-contract-" + QString::number(contract_id) + ".zip");

    QFile zip_file(arch_zip);
    zip_file.copy(new_zip);

    QString arch_md = QDir::toNativeSeparators(VAULT + "/das" + uuid + ".md");
    QString new_md = QDir::toNativeSeparators(dir + "/index-contract-" + QString::number(contract_id) + ".md");

    QFile md_file(arch_md);
    md_file.copy(new_md);
}






void FileManager::openFile(const QString &fileName)
{
    QString filePath = QDir::toNativeSeparators(VAULT + "/" + fileName);
    QFileInfo fileInfo(filePath);
    if (!fileInfo.exists()) {
        qWarning("Файл не найден: %s", qUtf8Printable(filePath));
        return;
    }

    QUrl fileUrl = QUrl::fromLocalFile(filePath);
    QDesktopServices::openUrl(fileUrl);
}

void FileManager::setVault(const QString &key, const QVariant &value)
{
    if (key == "vault" && VAULT != value.toString()) VAULT = value.toString();
}
