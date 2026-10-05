import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "macos.stats"

  property bool popupOpen: false
  function close() { popupOpen = false }

  // System stats state
  property string hostname: "Parikshit"
  property string osName: "Omarchy"
  property string uptime: "—"
  property real cpuPercent: 0
  property real ramUsedGb: 0
  property real ramTotalGb: 0
  property int ramPercent: 0
  property int swapPercent: 0
  property int batteryPercent: 0
  property string batteryStatus: ""
  property real diskUsedGb: 0
  property real diskTotalGb: 0
  property int diskPercent: 0
  property int cpuTemp: 0
  property int gpuBusy: 0
  property int gpuTemp: 0

  Process {
    id: statsProc
    command: ["omarchy-macos-stats"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var s = JSON.parse(text.trim())
          root.hostname = s.hostname || "Parikshit"
          root.osName = s.os_name || "Omarchy"
          root.uptime = s.uptime || "—"
          root.cpuPercent = s.cpu_percent || 0
          root.ramUsedGb = s.ram_used_gb || 0
          root.ramTotalGb = s.ram_total_gb || 0
          root.ramPercent = s.ram_percent || 0
          root.swapPercent = s.swap_percent || 0
          root.batteryPercent = s.battery_percent || 0
          root.batteryStatus = s.battery_status || ""
          root.diskUsedGb = s.disk_used_gb || 0
          root.diskTotalGb = s.disk_total_gb || 0
          root.diskPercent = s.disk_percent || 0
          root.cpuTemp = s.cpu_temp || 0
          root.gpuBusy = s.gpu_busy || 0
          root.gpuTemp = s.gpu_temp || 0
        } catch(e) {}
      }
    }
  }

  Timer {
    interval: root.popupOpen ? 1500 : 5000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: {
      if (!statsProc.running) statsProc.running = true
    }
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Minimalist bar icon (Sleek Microchip)
  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ""
    onPressed: function(b) {
      if (b === Qt.RightButton) {
        Quickshell.execDetached(["omarchy-launch-terminal", "btop"])
      } else {
        root.popupOpen = !root.popupOpen
      }
    }
  }

  KeyboardPanel {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(320))
    contentHeight: popup.fittedContentHeight(mainColumn.implicitHeight)

    Column {
      id: mainColumn
      anchors.fill: parent
      spacing: Style.space(14)

      // ================= Header Section (Laptop Icon + Parikshit Laptop) =================
      Row {
        width: parent.width
        spacing: Style.space(12)

        Text {
          text: "󰌢"
          color: root.cpuPercent > 80 ? "#ff5555" : Color.accent
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.displayLarge
          anchors.verticalCenter: parent.verticalCenter
        }

        Column {
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(2)

          Text {
            text: root.hostname + " Laptop"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.title
            font.bold: true
          }

          Text {
            text: root.osName + "  •  " + (root.uptime !== "—" ? ("󱑂 " + root.uptime) : "Online")
            color: Qt.darker(root.bar.foreground, 1.5)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }
      }

      Text {
        text: "HARDWARE VITALS"
        color: Qt.darker(root.bar.foreground, 1.4)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
        font.letterSpacing: 1.2
      }

      // ================= Pure Clean Typography (2-Column Grid) =================
      Grid {
        width: parent.width
        columns: 2
        rowSpacing: Style.space(12)
        columnSpacing: Style.space(24)

        // CPU
        Item {
          width: (parent.width - parent.columnSpacing) / 2
          height: childrenRect.height
          Text {
            anchors.left: parent.left
            text: "CPU"
            color: root.bar.foreground
            opacity: 0.6
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
          Text {
            anchors.right: parent.right
            text: root.cpuPercent + "%"
            color: root.cpuPercent > 80 ? "#ff5555" : (root.cpuPercent > 50 ? "#ffb86c" : root.bar.foreground)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
        }

        // Memory
        Item {
          width: (parent.width - parent.columnSpacing) / 2
          height: childrenRect.height
          Text {
            anchors.left: parent.left
            text: "Memory"
            color: root.bar.foreground
            opacity: 0.6
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
          Text {
            anchors.right: parent.right
            text: root.ramPercent + "%"
            color: root.ramPercent > 80 ? "#ff5555" : (root.ramPercent > 50 ? "#ffb86c" : root.bar.foreground)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
        }

        // GPU Temp
        Item {
          width: (parent.width - parent.columnSpacing) / 2
          height: childrenRect.height
          Text {
            anchors.left: parent.left
            text: "GPU Temp"
            color: root.bar.foreground
            opacity: 0.6
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
          Text {
            anchors.right: parent.right
            text: root.gpuTemp > 0 ? (root.gpuTemp + "°C") : "—"
            color: root.gpuTemp > 80 ? "#ff5555" : (root.gpuTemp > 70 ? "#ffb86c" : root.bar.foreground)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
        }

        // Storage
        Item {
          width: (parent.width - parent.columnSpacing) / 2
          height: childrenRect.height
          Text {
            anchors.left: parent.left
            text: "Storage"
            color: root.bar.foreground
            opacity: 0.6
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
          Text {
            anchors.right: parent.right
            text: root.diskPercent + "%"
            color: root.diskPercent > 90 ? "#ff5555" : (root.diskPercent > 70 ? "#ffb86c" : root.bar.foreground)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
        }

        // CPU Temp
        Item {
          width: (parent.width - parent.columnSpacing) / 2
          height: childrenRect.height
          Text {
            anchors.left: parent.left
            text: "CPU Temp"
            color: root.bar.foreground
            opacity: 0.6
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
          Text {
            anchors.right: parent.right
            text: root.cpuTemp > 0 ? (root.cpuTemp + "°C") : "—"
            color: root.cpuTemp > 80 ? "#ff5555" : (root.cpuTemp > 70 ? "#ffb86c" : root.bar.foreground)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
        }

        // Swap
        Item {
          width: (parent.width - parent.columnSpacing) / 2
          height: childrenRect.height
          Text {
            anchors.left: parent.left
            text: "Swap"
            color: root.bar.foreground
            opacity: 0.6
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
          }
          Text {
            anchors.right: parent.right
            text: root.swapPercent + "%"
            color: root.swapPercent > 80 ? "#ff5555" : (root.swapPercent > 50 ? "#ffb86c" : root.bar.foreground)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
        }
      }

      PanelSeparator {
        foreground: root.bar.foreground
      }

      Text {
        text: "CONTROLS & SHORTCUTS"
        color: Qt.darker(root.bar.foreground, 1.4)
        font.family: root.bar.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
        font.letterSpacing: 1.2
      }

      // Shortcut Grid
      Grid {
        width: parent.width
        columns: 2
        rowSpacing: Style.space(8)
        columnSpacing: Style.space(8)

        Button {
          width: (parent.width - parent.columnSpacing) / 2
          text: "Files"
          iconText: "󰉋"
          foreground: root.bar.foreground
          horizontalPadding: Style.space(8)
          verticalPadding: Style.space(8)
          onClicked: {
            root.close()
            Quickshell.execDetached(["nautilus"])
          }
        }
        Button {
          width: (parent.width - parent.columnSpacing) / 2
          text: "Terminal"
          iconText: "󰆍"
          foreground: root.bar.foreground
          horizontalPadding: Style.space(8)
          verticalPadding: Style.space(8)
          onClicked: {
            root.close()
            Quickshell.execDetached(["omarchy-launch-terminal"])
          }
        }
        Button {
          width: (parent.width - parent.columnSpacing) / 2
          text: "Monitor"
          iconText: "󰡣"
          foreground: root.bar.foreground
          horizontalPadding: Style.space(8)
          verticalPadding: Style.space(8)
          onClicked: {
            root.close()
            Quickshell.execDetached(["omarchy-launch-terminal", "btop"])
          }
        }
        Button {
          width: (parent.width - parent.columnSpacing) / 2
          text: "Lock"
          iconText: "󰌾"
          foreground: root.bar.foreground
          horizontalPadding: Style.space(8)
          verticalPadding: Style.space(8)
          onClicked: { root.close(); Quickshell.execDetached(["hyprlock"]) }
        }
        Button {
          width: (parent.width - parent.columnSpacing) / 2
          text: "Reboot"
          iconText: "󰑓"
          foreground: root.bar.foreground
          horizontalPadding: Style.space(8)
          verticalPadding: Style.space(8)
          onClicked: { root.close(); Quickshell.execDetached(["systemctl", "reboot"]) }
        }
        Button {
          width: (parent.width - parent.columnSpacing) / 2
          text: "Power"
          iconText: "󰐥"
          foreground: "#ff5555"
          horizontalPadding: Style.space(8)
          verticalPadding: Style.space(8)
          onClicked: { root.close(); Quickshell.execDetached(["systemctl", "poweroff"]) }
        }
      }
    }
  }
}
