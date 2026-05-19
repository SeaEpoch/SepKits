#pragma once
#include <QObject>
#include <QSystemTrayIcon>
#include <QMenu>

class SystemTrayHelper : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool visible READ isVisible NOTIFY visibleChanged)

public:
    explicit SystemTrayHelper(QObject *parent = nullptr);

    bool isVisible() const { return m_trayIcon != nullptr && m_trayIcon->isVisible(); }

    Q_INVOKABLE void show();
    Q_INVOKABLE void hide();

signals:
    void visibleChanged();
    void restoreRequested();
    void exitRequested();

private:
    QSystemTrayIcon *m_trayIcon = nullptr;
    QMenu *m_menu = nullptr;
};
