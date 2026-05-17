#include "SettingsStore.h"
#include <QCoreApplication>
#include <QDir>
#include <QStandardPaths>

QString SettingsStore::iniFilePath()
{
    QString dir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir().mkpath(dir);
    return dir + QStringLiteral("/SepKits.ini");
}

SettingsStore::SettingsStore(QObject *parent)
    : QObject(parent)
{
    m_settings = new QSettings(iniFilePath(), QSettings::IniFormat, this);
}

SettingsStore::~SettingsStore()
{
    if (m_settings)
        m_settings->sync();
}

QVariant SettingsStore::value(const QString &key, const QVariant &defaultValue) const
{
    return m_settings->value(key, defaultValue);
}

void SettingsStore::setValue(const QString &key, const QVariant &value)
{
    m_settings->setValue(key, value);
    m_settings->sync();
}
