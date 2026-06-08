#pragma once
#include <QObject>

#ifdef Q_OS_WINDOWS
#  include <windows.h>
#endif

class TrayMenuHelper : public QObject {
    Q_OBJECT

public:
    explicit TrayMenuHelper(QObject *parent = nullptr);
    ~TrayMenuHelper() override;

    Q_INVOKABLE void showContextMenu();

signals:
    void restoreRequested();
    void exitRequested();

private:
#ifdef Q_OS_WINDOWS
    HWND m_ownerHwnd = nullptr;
#endif
};
