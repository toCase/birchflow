#include "translatemanager.h"

TranslateManager::TranslateManager(QQmlEngine *engine, TCD_Settings *st, QObject *parent)
    : m_engine(engine), m_setting(st), QObject{parent}
{
    QString code = m_setting->getValue("lang").toString();
    if (code != "English") switchLang(code);
}

void TranslateManager::switchLang(const QString &code)
{
    qApp->removeTranslator(&m_translator);

    QString qm_file;

    if (code == "English") {
        m_lang = code;
        m_engine->retranslate();
        return;
    } else if (code == "Українська") {
        qm_file = ":/qt/qml/BirchFlow/tr/app_ua.qm";
    } else {
        return;
    }

    if (m_translator.load(qm_file)){
        qApp->installTranslator(&m_translator);
        m_lang = code;
        m_engine->retranslate();
    }
}
