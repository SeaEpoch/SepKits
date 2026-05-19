#include "CacheCleanerModel.h"

#include <QCoreApplication>

CacheCleanerModel::CacheCleanerModel(QObject *parent) : QAbstractListModel(parent)
{
    m_categories = {
        {QStringLiteral("userTemp"),        tr("User Temp")},
        {QStringLiteral("legacyTemp"),      tr("Legacy Temp")},
        {QStringLiteral("windowsTemp"),     tr("Windows Temp")},
        {QStringLiteral("prefetch"),        tr("Prefetch")},
        {QStringLiteral("systemDriveJunk"), tr("System Drive Junk")},
        {QStringLiteral("windowsBak"),      tr("Windows *.bak")},
        {QStringLiteral("recycleBin"),      tr("Recycle Bin")},
        {QStringLiteral("cookies"),         tr("Cookies")},
        {QStringLiteral("recentFiles"),     tr("Recent Files")},
        {QStringLiteral("ieTemp"),          tr("Temporary Internet Files")},
    };
}

int CacheCleanerModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_categories.size();
}

QVariant CacheCleanerModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_categories.size())
        return {};

    const auto &c = m_categories.at(index.row());
    const bool scanned = c.fileCount >= 0;

    switch (role) {
    case KeyRole:       return c.key;
    case LabelRole:     return c.label;
    case FileCountRole: return c.fileCount;
    case TotalSizeRole: return c.totalSize;
    case CheckedRole:   return c.checked;
    case ScannedRole:   return scanned;
    case SizeTextRole:  return scanned ? formatSize(c.totalSize) : QStringLiteral("—");
    default:            return {};
    }
}

bool CacheCleanerModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_categories.size())
        return false;

    if (role == CheckedRole) {
        auto &c = m_categories[index.row()];
        if (c.fileCount < 0) return false; // not scanned yet
        c.checked = value.toBool();
        emit dataChanged(index, index, {CheckedRole});
        emit anyCheckedChanged();
        emit checkedCountChanged();
        return true;
    }
    return false;
}

Qt::ItemFlags CacheCleanerModel::flags(const QModelIndex &index) const
{
    if (!index.isValid()) return Qt::NoItemFlags;
    return QAbstractListModel::flags(index) | Qt::ItemIsEditable;
}

QHash<int, QByteArray> CacheCleanerModel::roleNames() const
{
    return {
        {KeyRole,       "key"},
        {LabelRole,     "label"},
        {FileCountRole, "fileCount"},
        {TotalSizeRole, "totalSize"},
        {CheckedRole,   "checked"},
        {ScannedRole,   "scanned"},
        {SizeTextRole,  "sizeText"},
    };
}

void CacheCleanerModel::resetAll()
{
    for (int i = 0; i < m_categories.size(); ++i) {
        m_categories[i].fileCount = -1;
        m_categories[i].totalSize = -1;
        m_categories[i].checked = false;
    }
    emit dataChanged(index(0), index(m_categories.size() - 1));
    emit allScannedChanged();
    emit anyCheckedChanged();
    emit checkedCountChanged();
}

void CacheCleanerModel::setScanResult(int row, int fileCount, qint64 totalSize)
{
    if (row < 0 || row >= m_categories.size()) return;
    m_categories[row].fileCount = fileCount;
    m_categories[row].totalSize = totalSize;
    m_categories[row].checked = fileCount > 0;
    emit dataChanged(index(row), index(row));
    emit allScannedChanged();
    emit anyCheckedChanged();
    emit checkedCountChanged();
}

void CacheCleanerModel::setAllChecked(bool checked)
{
    for (int i = 0; i < m_categories.size(); ++i) {
        if (m_categories[i].fileCount >= 0)
            m_categories[i].checked = checked;
    }
    emit dataChanged(index(0), index(m_categories.size() - 1), {CheckedRole});
    emit anyCheckedChanged();
    emit checkedCountChanged();
}

QStringList CacheCleanerModel::checkedKeys() const
{
    QStringList keys;
    for (const auto &c : m_categories) {
        if (c.checked && c.fileCount >= 0)
            keys.append(c.key);
    }
    return keys;
}

bool CacheCleanerModel::allScanned() const
{
    for (const auto &c : m_categories) {
        if (c.fileCount < 0) return false;
    }
    return true;
}

bool CacheCleanerModel::anyChecked() const
{
    for (const auto &c : m_categories) {
        if (c.checked && c.fileCount >= 0) return true;
    }
    return false;
}

int CacheCleanerModel::checkedCount() const
{
    int count = 0;
    for (const auto &c : m_categories) {
        if (c.checked && c.fileCount >= 0)
            ++count;
    }
    return count;
}

void CacheCleanerModel::retranslate()
{
    m_categories[0].label = tr("User Temp");
    m_categories[1].label = tr("Legacy Temp");
    m_categories[2].label = tr("Windows Temp");
    m_categories[3].label = tr("Prefetch");
    m_categories[4].label = tr("System Drive Junk");
    m_categories[5].label = tr("Windows *.bak");
    m_categories[6].label = tr("Recycle Bin");
    m_categories[7].label = tr("Cookies");
    m_categories[8].label = tr("Recent Files");
    m_categories[9].label = tr("Temporary Internet Files");

    emit dataChanged(index(0), index(m_categories.size() - 1), {LabelRole});
}

QString CacheCleanerModel::formatSize(qint64 bytes)
{
    if (bytes < 1024) return QString::number(bytes) + QStringLiteral(" B");
    if (bytes < 1048576) return QString::number(bytes / 1024.0, 'f', 1) + QStringLiteral(" KB");
    if (bytes < 1073741824LL) return QString::number(bytes / 1048576.0, 'f', 1) + QStringLiteral(" MB");
    return QString::number(bytes / 1073741824.0, 'f', 2) + QStringLiteral(" GB");
}
