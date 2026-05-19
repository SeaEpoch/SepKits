#pragma once
#include <QObject>
#include <QVariant>
#include <QSettings>

class SettingsStore : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool launchAsAdmin READ launchAsAdmin WRITE setLaunchAsAdmin NOTIFY launchAsAdminChanged)

public:
    static QString iniFilePath();

    explicit SettingsStore(QObject *parent = nullptr);
    ~SettingsStore() override;

    Q_INVOKABLE QVariant value(const QString &key, const QVariant &defaultValue = QVariant()) const;
    Q_INVOKABLE void setValue(const QString &key, const QVariant &value);

    bool launchAsAdmin() const;
    void setLaunchAsAdmin(bool value);

    Q_INVOKABLE void copyToClipboard(const QString &text) const;

signals:
    void launchAsAdminChanged();

private:
    QSettings *m_settings = nullptr;
};
