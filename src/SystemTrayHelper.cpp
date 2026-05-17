#include "SystemTrayHelper.h"
#include <QApplication>
#include <QAction>

SystemTrayHelper::SystemTrayHelper(QObject *parent)
    : QObject(parent)
{
    m_trayIcon = new QSystemTrayIcon(this);
    m_trayIcon->setIcon(QIcon(QStringLiteral(":/assets/images/sepwinkits-logo-modern.png")));
    m_trayIcon->setToolTip(QStringLiteral("SepKits"));

    m_menu = new QMenu();
    m_menu->setStyleSheet(QStringLiteral(
        "QMenu {"
        "  background-color: #1E293B;"
        "  color: #FAFAFA;"
        "  border: 1px solid #334155;"
        "  border-radius: 8px;"
        "  padding: 4px 0;"
        "}"
        "QMenu::item {"
        "  padding: 6px 32px;"
        "}"
        "QMenu::item:selected {"
        "  background-color: #0052FF;"
        "  color: #FFFFFF;"
        "}"
    ));
    QAction *showAction = m_menu->addAction(QStringLiteral("Show Window"));
    QObject::connect(showAction, &QAction::triggered, this, &SystemTrayHelper::restoreRequested);

    QAction *exitAction = m_menu->addAction(QStringLiteral("Exit"));
    QObject::connect(exitAction, &QAction::triggered, this, &SystemTrayHelper::exitRequested);

    m_trayIcon->setContextMenu(m_menu);

    QObject::connect(m_trayIcon, &QSystemTrayIcon::activated, this, [this](QSystemTrayIcon::ActivationReason reason) {
        if (reason == QSystemTrayIcon::DoubleClick || reason == QSystemTrayIcon::Trigger) {
            emit restoreRequested();
        }
    });
}

void SystemTrayHelper::show()
{
    if (m_trayIcon)
        m_trayIcon->show();
    emit visibleChanged();
}

void SystemTrayHelper::hide()
{
    if (m_trayIcon)
        m_trayIcon->hide();
    emit visibleChanged();
}
