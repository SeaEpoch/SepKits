#include "LanguageManager.h"
#include "SettingsStore.h"
#include <QCoreApplication>
#include <QGuiApplication>
#include <QQmlEngine>

LanguageManager::LanguageManager(QQmlEngine *engine, QObject *parent)
    : QObject(parent)
    , m_engine(engine)
{
    QSettings settings(SettingsStore::iniFilePath(), QSettings::IniFormat);
    int savedIndex = settings.value(QStringLiteral("languageIndex"), 0).toInt();
    if (savedIndex > 0)
        loadTranslator(savedIndex);
    m_currentIndex = savedIndex;
}

QStringList LanguageManager::model() const
{
    return {
        QStringLiteral("English"),
        QStringLiteral("简体中文"),
        QStringLiteral("繁體中文")
    };
}

void LanguageManager::loadTranslator(int index)
{
    if (m_translator) {
        QCoreApplication::removeTranslator(m_translator);
        delete m_translator;
        m_translator = nullptr;
    }

    if (index > 0) {
        QString qmFile;
        switch (index) {
        case 1: qmFile = QStringLiteral("SepKits_zh_CN"); break;
        case 2: qmFile = QStringLiteral("SepKits_zh_TW"); break;
        default: return;
        }

        m_translator = new QTranslator(this);
        if (!m_translator->load(QStringLiteral(":/i18n/%1").arg(qmFile))) {
            delete m_translator;
            m_translator = nullptr;
        } else {
            QCoreApplication::installTranslator(m_translator);
        }
    }
}

void LanguageManager::switchLanguage(int index)
{
    if (index == m_currentIndex)
        return;

    loadTranslator(index);
    m_currentIndex = index;

    QSettings settings(SettingsStore::iniFilePath(), QSettings::IniFormat);
    settings.setValue(QStringLiteral("languageIndex"), index);
    settings.sync();

    emit languageChanged();
    if (m_engine)
        m_engine->retranslate();
}
