#include "TrayMenuHelper.h"

#ifdef Q_OS_WINDOWS

static constexpr UINT IDM_RESTORE = 1;
static constexpr UINT IDM_EXIT = 2;

TrayMenuHelper::TrayMenuHelper(QObject *parent)
    : QObject(parent)
{
    m_ownerHwnd = CreateWindowExW(0, L"STATIC", L"", WS_POPUP,
                                   0, 0, 0, 0, HWND_MESSAGE, nullptr,
                                   GetModuleHandleW(nullptr), nullptr);
}

TrayMenuHelper::~TrayMenuHelper()
{
    if (m_ownerHwnd)
        DestroyWindow(m_ownerHwnd);
}

void TrayMenuHelper::showContextMenu()
{
    HMENU hMenu = CreatePopupMenu();
    AppendMenuW(hMenu, MF_STRING, IDM_RESTORE, L"Show Window");
    AppendMenuW(hMenu, MF_STRING, IDM_EXIT, L"Exit");

    POINT pt;
    GetCursorPos(&pt);

    SetForegroundWindow(m_ownerHwnd);
    const UINT cmd = TrackPopupMenu(hMenu,
                                    TPM_RETURNCMD | TPM_NONOTIFY | TPM_BOTTOMALIGN | TPM_LEFTALIGN,
                                    pt.x, pt.y, 0, m_ownerHwnd, nullptr);
    PostMessageW(m_ownerHwnd, WM_NULL, 0, 0);
    DestroyMenu(hMenu);

    if (cmd == IDM_RESTORE)
        emit restoreRequested();
    else if (cmd == IDM_EXIT)
        emit exitRequested();
}

#else

TrayMenuHelper::TrayMenuHelper(QObject *parent) : QObject(parent) {}
TrayMenuHelper::~TrayMenuHelper() = default;
void TrayMenuHelper::showContextMenu() {}

#endif
