#pragma once

#include <QObject>
#include <QApplication>
#include <QTranslator>
#include <QQmlEngine>
#include "tcd_settings.h"

class TranslateManager : public QObject
{
    Q_OBJECT
public:
    explicit TranslateManager(QQmlEngine *engine, TCD_Settings *st, QObject *parent = nullptr);

    Q_INVOKABLE void switchLang(const QString& code);
private:
    TCD_Settings *m_setting;
    QTranslator m_translator;
    QQmlEngine *m_engine;
    QString m_lang;

signals:
};
