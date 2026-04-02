pragma Singleton
import QtQuick

QtObject {
    id: _fontAwesomeIcon

    readonly property url xmark: "qrc:/assets/icons/fontawesome-free-7.2.0-desktop/svgs-full/solid/xmark.svg"
    readonly property url windowMaximize: "qrc:/assets/icons/fontawesome-free-7.2.0-desktop/svgs-full/solid/window-maximize.svg"
    readonly property url windowRestore: "qrc:/assets/icons/fontawesome-free-7.2.0-desktop/svgs-full/solid/window-restore.svg"
    readonly property url windowMinimize: "qrc:/assets/icons/fontawesome-free-7.2.0-desktop/svgs-full/solid/window-minimize.svg"
}
