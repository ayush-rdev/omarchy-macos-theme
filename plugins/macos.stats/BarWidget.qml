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
    interval: 1500
    repeat: true
    running: root.popupOpen
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



      // ================= Hardware Vitals (Bars Aesthetic) =================
      Column {
        width: parent.width
        spacing: Style.space(14)

        // CPU
        Item {
          width: parent.width
          height: Math.max(cpuLabel.implicitHeight, Style.space(10))
          
          Text {
            id: cpuLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "CPU"
            color: root.bar.foreground
            opacity: 0.8
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            width: Style.space(48)
          }

          Item {
            anchors.left: cpuLabel.right
            anchors.right: cpuVal.left
            anchors.leftMargin: Style.space(20)
            anchors.rightMargin: Style.space(20)
            anchors.verticalCenter: parent.verticalCenter
            height: Style.space(10)
            
            Rectangle {
              anchors.fill: parent
              color: Util.alpha(root.bar.foreground, 0.1)
              radius: 0
            }
            Rectangle {
              width: (parent.width * Math.max(0, Math.min(root.cpuPercent, 100))) / 100
              height: parent.height
              color: Color.accent
              radius: 0
            }
          }

          Text {
            id: cpuVal
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.cpuPercent + "%"
            color: Color.accent
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            width: Style.space(36)
            horizontalAlignment: Text.AlignRight
          }
        }

        // Memory
        Item {
          width: parent.width
          height: Math.max(memLabel.implicitHeight, Style.space(10))
          
          Text {
            id: memLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "RAM"
            color: root.bar.foreground
            opacity: 0.8
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            width: Style.space(48)
          }

          Item {
            anchors.left: memLabel.right
            anchors.right: memVal.left
            anchors.leftMargin: Style.space(20)
            anchors.rightMargin: Style.space(20)
            anchors.verticalCenter: parent.verticalCenter
            height: Style.space(10)
            
            Rectangle {
              anchors.fill: parent
              color: Util.alpha(root.bar.foreground, 0.1)
              radius: 0
            }
            Rectangle {
              width: (parent.width * Math.max(0, Math.min(root.ramPercent, 100))) / 100
              height: parent.height
              color: Color.accent
              radius: 0
            }
          }

          Text {
            id: memVal
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.ramPercent + "%"
            color: Color.accent
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            width: Style.space(36)
            horizontalAlignment: Text.AlignRight
          }
        }

        // Storage
        Item {
          width: parent.width
          height: Math.max(storageLabel.implicitHeight, Style.space(10))
          
          Text {
            id: storageLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Disk"
            color: root.bar.foreground
            opacity: 0.8
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            width: Style.space(48)
          }

          Item {
            anchors.left: storageLabel.right
            anchors.right: storageVal.left
            anchors.leftMargin: Style.space(20)
            anchors.rightMargin: Style.space(20)
            anchors.verticalCenter: parent.verticalCenter
            height: Style.space(10)
            
            Rectangle {
              anchors.fill: parent
              color: Util.alpha(root.bar.foreground, 0.1)
              radius: 0
            }
            Rectangle {
              width: (parent.width * Math.max(0, Math.min(root.diskPercent, 100))) / 100
              height: parent.height
              color: Color.accent
              radius: 0
            }
          }

          Text {
            id: storageVal
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: root.diskPercent + "%"
            color: Color.accent
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            width: Style.space(36)
            horizontalAlignment: Text.AlignRight
          }
        }

        // Temperatures (Mapped to average temp for bar)
        Item {
          width: parent.width
          height: Math.max(tempsLabel.implicitHeight, Style.space(10))
          
          Text {
            id: tempsLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Temp"
            color: root.bar.foreground
            opacity: 0.8
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            width: Style.space(48)
          }

          Item {
            anchors.left: tempsLabel.right
            anchors.right: tempsVal.left
            anchors.leftMargin: Style.space(20)
            anchors.rightMargin: Style.space(20)
            anchors.verticalCenter: parent.verticalCenter
            height: Style.space(10)
            
            Rectangle {
              anchors.fill: parent
              color: Util.alpha(root.bar.foreground, 0.1)
              radius: 0
            }
            Rectangle {
              width: (parent.width * Math.max(0, Math.min(root.cpuTemp > 0 ? root.cpuTemp : 0, 100))) / 100
              height: parent.height
              color: Color.accent
              radius: 0
            }
          }

          Text {
            id: tempsVal
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: (root.cpuTemp > 0 ? root.cpuTemp : 0) + "°C"
            color: Color.accent
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            width: Style.space(36)
            horizontalAlignment: Text.AlignRight
          }
        }
      }

      PanelSeparator {
        foreground: root.bar.foreground
      }

      Text {
        text: "SHORTCUTS"
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
            Quickshell.execDetached(["sh", "-c", "gtk-launch $(xdg-mime query default inode/directory)"])
          }
        }
        Button {
          width: (parent.width - parent.columnSpacing) / 2
          text: "Browser"
          iconText: "󰖟"
          foreground: root.bar.foreground
          horizontalPadding: Style.space(8)
          verticalPadding: Style.space(8)
          onClicked: {
            root.close()
            Quickshell.execDetached(["sh", "-c", "gtk-launch $(xdg-settings get default-web-browser)"])
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
          onClicked: { root.close(); Quickshell.execDetached(["omarchy-system-lock"]) }
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
