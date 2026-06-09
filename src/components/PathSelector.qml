import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import SepKits as SepKits

Item {
    id: _root
    enum Mode { FileMode = 0, FolderMode = 1 }

    property int mode: PathSelector.FolderMode
    property alias selectedPath: _pathField.text
    property alias placeholderText: _placeholder.text
    signal pathSelected(string path)

    implicitHeight: 40; implicitWidth: 400

    Rectangle {
        anchors.fill: parent
        radius: SepKits.Theme.radius
        color: SepKits.Color.background
        border.width: 1
        border.color: SepKits.Color.border

        TextInput {
            id: _pathField
            anchors.left: parent.left; anchors.right: _separator.left; anchors.top: parent.top; anchors.bottom: parent.bottom
            anchors.leftMargin: SepKits.Theme.inputPaddingH; anchors.rightMargin: 8
            verticalAlignment: TextInput.AlignVCenter; color: SepKits.Color.foreground
            font.family: SepKits.Font.fontFamilyBody; font.pixelSize: SepKits.Font.sizeSmall
            clip: true; readOnly: true; selectByMouse: true
        }
        Text {
            id: _placeholder
            anchors.left: parent.left; anchors.right: _separator.left; anchors.top: parent.top; anchors.bottom: parent.bottom
            anchors.leftMargin: SepKits.Theme.inputPaddingH; verticalAlignment: Text.AlignVCenter
            color: SepKits.Color.mutedForeground; font.family: SepKits.Font.fontFamilyBody; font.pixelSize: SepKits.Font.sizeSmall
            visible: _pathField.text === ""
        }
        Rectangle {
            id: _separator
            anchors.right: _browseBtn.left; anchors.verticalCenter: parent.verticalCenter
            width: 1; height: parent.height - 8; color: SepKits.Color.border
        }
        Button {
            id: _browseBtn
            anchors.right: parent.right; anchors.rightMargin: 2; anchors.verticalCenter: parent.verticalCenter
            topPadding: 4; bottomPadding: 4; leftPadding: 10; rightPadding: 10
            contentItem: Text {
                text: qsTr("Browse")
                color: _browseBtn.hovered ? SepKits.Color.foreground : SepKits.Color.mutedForeground
                font.family: SepKits.Font.fontFamilyBody; font.pixelSize: SepKits.Font.sizeSmall; font.weight: SepKits.Font.weightMedium
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle { radius: 6; color: _browseBtn.pressed ? SepKits.Color.muted : SepKits.Color.transparent; Behavior on color { ColorAnimation { duration: SepKits.Theme.animFast } } }
            onClicked: _root.mode === PathSelector.FolderMode ? _folderDialog.open() : _fileDialog.open()
        }
    }
    FolderDialog {
        id: _folderDialog; title: qsTr("Select Output Folder")
        onAccepted: { var p = selectedFolder.toString(); if (p.startsWith("file:///")) p = p.substring(8); _root.selectedPath = p; _root.pathSelected(p) }
    }
    FileDialog {
        id: _fileDialog; title: qsTr("Select File"); fileMode: FileDialog.OpenFile
        onAccepted: { var p = selectedFile.toString(); if (p.startsWith("file:///")) p = p.substring(8); _root.selectedPath = p; _root.pathSelected(p) }
    }
}
