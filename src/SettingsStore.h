#pragma once
#include <QObject>
#include <QVariant>
#include <QSettings>

class SettingsStore : public QObject {
    Q_OBJECT

public:
    static QString iniFilePath();

    explicit SettingsStore(QObject *parent = nullptr);
    ~SettingsStore() override;

    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);

private:
    QSettings *m_settings = nullptr;
};
