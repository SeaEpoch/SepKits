#pragma once
#include <QObject>
#include <QTranslator>
#include <QStringList>

class QQmlEngine;

class LanguageManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY languageChanged)
    Q_PROPERTY(QStringList model READ model CONSTANT)

public:
    explicit LanguageManager(QQmlEngine *engine, QObject *parent = nullptr);

    int currentIndex() const { return m_currentIndex; }
    QStringList model() const;

    Q_INVOKABLE void switchLanguage(int index);

signals:
    void languageChanged();

private:
    void loadTranslator(int index);

    int m_currentIndex = 0;
    QTranslator *m_translator = nullptr;
    QQmlEngine *m_engine = nullptr;
};
