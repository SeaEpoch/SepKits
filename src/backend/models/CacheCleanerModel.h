#pragma once
#include <QAbstractListModel>
#include <QStringList>

class CacheCleanerModel : public QAbstractListModel {
    Q_OBJECT
    Q_PROPERTY(bool allScanned READ allScanned NOTIFY allScannedChanged)
    Q_PROPERTY(bool anyChecked READ anyChecked NOTIFY anyCheckedChanged)
    Q_PROPERTY(int checkedCount READ checkedCount NOTIFY checkedCountChanged)

public:
    enum Roles {
        KeyRole = Qt::UserRole + 1,
        LabelRole,
        FileCountRole,
        TotalSizeRole,
        CheckedRole,
        ScannedRole,
        SizeTextRole
    };
    Q_ENUM(Roles)

    explicit CacheCleanerModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex &index, const QVariant &value, int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex &index) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void resetAll();
    Q_INVOKABLE void setScanResult(int index, int fileCount, qint64 totalSize);
    Q_INVOKABLE void setAllChecked(bool checked);
    Q_INVOKABLE QStringList checkedKeys() const;
    Q_INVOKABLE bool allScanned() const;
    Q_INVOKABLE bool anyChecked() const;
    int checkedCount() const;

    void retranslate();

signals:
    void allScannedChanged();
    void anyCheckedChanged();
    void checkedCountChanged();

private:
    struct Category {
        QString key;
        QString label;
        int fileCount = -1;
        qint64 totalSize = -1;
        bool checked = false;
    };

    static QString formatSize(qint64 bytes);

    QList<Category> m_categories;
};
