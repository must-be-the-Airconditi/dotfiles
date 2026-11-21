// WallpaperPicker.qml — 缩略图网格选壁纸（Mod+Shift+W 打开）。
// 选中后交给 wallpaper-next 做转场，然后关闭。
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Scope {
    id: root

    property bool shown: false
    property var files: []
    property int current: 0
    readonly property string dir: (Quickshell.env("HOME") || "") + "/Pictures/wallpapers"

    function openPicker() {
        quitTimer.stop()
        root.current = 0
        root.shown = true
        grid.forceActiveFocus()
        lister.files = []
        lister.running = true
    }
    function closePicker() { root.shown = false; quitTimer.restart() }
    function choose(path) {
        quitTimer.stop()
        root.shown = false
        Quickshell.execDetached(["sh", "-c", "sleep 0.15; exec \"$HOME/.local/bin/wallpaper-next\" " + JSON.stringify(path)])
    }

    // 选完/关掉后没人用 quickshell 就自动退出，别常驻内存
    Timer {
        id: quitTimer
        interval: 12000
        onTriggered: Quickshell.execDetached(["pkill", "-x", "qs"])
    }

    IpcHandler {
        target: "wallpick"
        function open(): string { root.openPicker(); return "ok" }
        function close(): string { root.closePicker(); return "ok" }
        function choose(path: string): string { root.choose(path); return "ok" }
        function state(): string { return root.shown ? "open" : "closed" }
        function focus(): string { return (grid.activeFocus ? "grid" : "none") + " idx=" + grid.currentIndex }
    }

    // 文件列表：目录里的图片，按名字排序
    Process {
        id: lister
        property var files: []
        command: ["sh", "-c", "find " + JSON.stringify(root.dir) + " -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) | sort"]
        stdout: SplitParser {
            onRead: line => lister.files = lister.files.concat([line])
        }
        onRunningChanged: if (!running) { root.files = lister.files.slice(0); grid.forceActiveFocus() }
    }

    PanelWindow {
        id: win
        visible: root.shown
        screen: Quickshell.screens[0]
        color: "#ee101014"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; bottom: true; left: true; right: true }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "quickshell:wallpick"

        FocusScope {
            anchors.fill: parent
            focus: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 44
                spacing: 18

                RowLayout {
                    Text {
                        text: "选择壁纸"
                        color: "#f5f5f5"
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                    }
                    Text {
                        Layout.leftMargin: 12
                        text: root.files.length + " 张 · 方向键选择，Enter 确认，Esc 退出"
                        color: "#9aa0a6"
                        font.pixelSize: 14
                    }
                    Item { Layout.fillWidth: true }
                }

                GridView {
                    id: grid
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    cellWidth: 300
                    cellHeight: 212
                    model: root.files
                    currentIndex: root.current
                    onCurrentIndexChanged: root.current = currentIndex
                    boundsBehavior: Flickable.StopAtBounds
                    focus: true
                    Component.onCompleted: forceActiveFocus()
                    Keys.onEscapePressed: root.closePicker()
                    readonly property int cols: Math.max(1, Math.floor(width / cellWidth))
                    Keys.onLeftPressed: currentIndex = Math.max(0, currentIndex - 1)
                    Keys.onRightPressed: currentIndex = Math.min(count - 1, currentIndex + 1)
                    Keys.onUpPressed: currentIndex = Math.max(0, currentIndex - cols)
                    Keys.onDownPressed: currentIndex = Math.min(count - 1, currentIndex + cols)
                    Keys.onReturnPressed: if (count > 0) root.choose(root.files[currentIndex])
                    Keys.onEnterPressed: if (count > 0) root.choose(root.files[currentIndex])

                    delegate: Item {
                        width: grid.cellWidth
                        height: grid.cellHeight

                        Rectangle {
                            id: card
                            anchors.fill: parent
                            anchors.margins: 8
                            radius: 16
                            color: index === grid.currentIndex ? "#33404a5e" : "#1a202833"
                            border.width: index === grid.currentIndex ? 2 : 1
                            border.color: index === grid.currentIndex ? "#a6e3a1" : "#334155"

                            Image {
                                anchors.fill: parent
                                anchors.margins: 8
                                anchors.bottomMargin: 34
                                source: "file://" + modelData
                                sourceSize: Qt.size(280, 150)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                            }
                            Text {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.margins: 12
                                text: modelData.split("/").pop()
                                color: "#d7dbe0"
                                font.pixelSize: 12
                                elide: Text.ElideMiddle
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: root.choose(modelData)
                            }
                        }
                    }
                }
            }
        }
    }
}
