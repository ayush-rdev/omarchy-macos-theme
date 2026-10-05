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
  property real cpuPercent: 0
  property int cpuTemp: 0
  property real ramUsedGb: 0
  property real ramTotalGb: 0
  property int ramPercent: 0
  property int gpuBusy: 0
  property int gpuTemp: 0
  property real diskFreeGb: 0
  property real diskTotalGb: 0
  property int diskPercent: 0

  Process {
    id: statsProc
    command: ["python3", "-c", "
import json, glob, os
res = {'cpu_percent': 0, 'cpu_temp': 0, 'ram_used_gb': 0, 'ram_total_gb': 0, 'ram_percent': 0, 'gpu_busy': 0, 'gpu_temp': 0, 'disk_free_gb': 0, 'disk_total_gb': 0, 'disk_percent': 0}
try:
    with open('/proc/loadavg') as f:
        load = float(f.read().split()[0])
        cores = os.cpu_count() or 1
        res['cpu_percent'] = min(100.0, round((load / cores) * 100, 1))
except: pass

try:
    mem = {}
    with open('/proc/meminfo') as f:
        for line in f:
            p = line.split(':')
            if len(p) == 2: mem[p[0].strip()] = int(p[1].strip().split()[0])
    tot = mem.get('MemTotal', 1)
    avail = mem.get('MemAvailable', 1)
    used = tot - avail
    res['ram_total_gb'] = round(tot / 1048576, 1)
    res['ram_used_gb'] = round(used / 1048576, 1)
    res['ram_percent'] = int(round((used / tot) * 100))
except: pass

try:
    for p in sorted(glob.glob('/sys/class/hwmon/hwmon*/temp*_input')):
        nf = os.path.join(os.path.dirname(p), 'name')
        n = open(nf).read().strip() if os.path.exists(nf) else ''
        if n in ['k10temp', 'coretemp', 'acpitz']:
            v = int(open(p).read().strip()) // 1000
            if v > 0 and (res['cpu_temp'] == 0 or n in ['k10temp', 'coretemp']):
                res['cpu_temp'] = v
except: pass

try:
    for p in glob.glob('/sys/class/drm/card*/device/gpu_busy_percent'):
        res['gpu_busy'] = int(open(p).read().strip())
    for p in glob.glob('/sys/class/drm/card*/device/hwmon/hwmon*/temp1_input'):
        res['gpu_temp'] = int(open(p).read().strip()) // 1000
except: pass

try:
    st = os.statvfs('/')
    tot = st.f_blocks * st.f_frsize
    free = st.f_bavail * st.f_frsize
    used = tot - free
    res['disk_total_gb'] = round(tot / (1024**3), 1)
    res['disk_free_gb'] = round(free / (1024**3), 1)
    res['disk_percent'] = int(round((used / tot) * 100))
except: pass

print(json.dumps(res))
"]
    stdout: SplitParser {
      onRead: function(data) {
        try {
          var s = JSON.parse(data.trim())
          root.cpuPercent = s.cpu_percent || 0
          root.cpuTemp = s.cpu_temp || 0
          root.ramUsedGb = s.ram_used_gb || 0
          root.ramTotalGb = s.ram_total_gb || 0
          root.ramPercent = s.ram_percent || 0
          root.gpuBusy = s.gpu_busy || 0
          root.gpuTemp = s.gpu_temp || 0
          root.diskFreeGb = s.disk_free_gb || 0
          root.diskTotalGb = s.disk_total_gb || 0
          root.diskPercent = s.disk_percent || 0
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

  // Minimalist bar icon (Option A: Clean single chip icon)
  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰍛"
    onPressed: function(b) {
      if (b === Qt.RightButton) {
        Quickshell.execDetached(["omarchy-launch-terminal", "btop"])
      } else {
        root.popupOpen = !root.popupOpen
      }
    }
  }

  PopupCard {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(310))
    contentHeight: popup.fittedContentHeight(mainColumn.implicitHeight)

    Column {
      id: mainColumn
      anchors.fill: parent
      spacing: Style.space(12)

      // Header row
      Row {
        width: parent.width
        Item {
          width: parent.width
          height: titleTag.implicitHeight

          Row {
            id: titleTag
            anchors.left: parent.left
            spacing: Style.space(6)

            Text {
              textFormat: Text.PlainText
              text: "󰍛"
              color: Color.accent
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.bodySmall
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              textFormat: Text.PlainText
              text: "Activity Monitor"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            textFormat: Text.PlainText
            text: root.cpuTemp > 0 ? (root.cpuTemp + "°C") : "Active"
            color: root.cpuTemp > 80 ? "#ff5555" : (root.cpuTemp > 70 ? "#ffb86c" : Color.accent)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
            font.bold: true
          }
        }
      }

      // 1. CPU Usage Meter
      Column {
        width: parent.width
        spacing: Style.space(4)

        Row {
          width: parent.width
          Text {
            anchors.left: parent.left
            textFormat: Text.PlainText
            text: "CPU"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
          Text {
            anchors.right: parent.right
            textFormat: Text.PlainText
            text: root.cpuPercent + "%"
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        Rectangle {
          width: parent.width
          height: Style.space(6)
          radius: height / 2
          color: Style.selectedFillFor(root.bar.foreground, Color.accent)

          Rectangle {
            width: Math.max(0, Math.min(parent.width, parent.width * (root.cpuPercent / 100)))
            height: parent.height
            radius: height / 2
            color: root.cpuPercent > 85 ? "#ff5555" : (root.cpuPercent > 60 ? "#ffb86c" : Color.accent)
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
          }
        }
      }

      // 2. RAM Memory Meter
      Column {
        width: parent.width
        spacing: Style.space(4)

        Row {
          width: parent.width
          Text {
            anchors.left: parent.left
            textFormat: Text.PlainText
            text: "Memory"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
          Text {
            anchors.right: parent.right
            textFormat: Text.PlainText
            text: root.ramUsedGb + " GB / " + root.ramTotalGb + " GB (" + root.ramPercent + "%)"
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        Rectangle {
          width: parent.width
          height: Style.space(6)
          radius: height / 2
          color: Style.selectedFillFor(root.bar.foreground, Color.accent)

          Rectangle {
            width: Math.max(0, Math.min(parent.width, parent.width * (root.ramPercent / 100)))
            height: parent.height
            radius: height / 2
            color: root.ramPercent > 85 ? "#ff5555" : (root.ramPercent > 65 ? "#ffb86c" : Color.accent)
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
          }
        }
      }

      // 3. GPU Section (if GPU or GPU temp present)
      Column {
        width: parent.width
        spacing: Style.space(4)

        Row {
          width: parent.width
          Text {
            anchors.left: parent.left
            textFormat: Text.PlainText
            text: "GPU"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
          Text {
            anchors.right: parent.right
            textFormat: Text.PlainText
            text: (root.gpuTemp > 0 ? (root.gpuTemp + "°C  •  ") : "") + root.gpuBusy + "%"
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        Rectangle {
          width: parent.width
          height: Style.space(6)
          radius: height / 2
          color: Style.selectedFillFor(root.bar.foreground, Color.accent)

          Rectangle {
            width: Math.max(0, Math.min(parent.width, parent.width * (root.gpuBusy / 100)))
            height: parent.height
            radius: height / 2
            color: Color.accent
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
          }
        }
      }

      // 4. Storage Disk Meter
      Column {
        width: parent.width
        spacing: Style.space(4)

        Row {
          width: parent.width
          Text {
            anchors.left: parent.left
            textFormat: Text.PlainText
            text: "Disk"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
          Text {
            anchors.right: parent.right
            textFormat: Text.PlainText
            text: root.diskFreeGb + " GB free / " + root.diskTotalGb + " GB"
            color: Qt.darker(root.bar.foreground, 1.3)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        Rectangle {
          width: parent.width
          height: Style.space(6)
          radius: height / 2
          color: Style.selectedFillFor(root.bar.foreground, Color.accent)

          Rectangle {
            width: Math.max(0, Math.min(parent.width, parent.width * (root.diskPercent / 100)))
            height: parent.height
            radius: height / 2
            color: root.diskPercent > 90 ? "#ff5555" : Color.accent
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
          }
        }
      }

      PanelSeparator {
        foreground: root.bar.foreground
      }

      // Quick launcher button to open Activity Monitor (btop)
      Button {
        width: parent.width
        text: "Open Activity Monitor"
        iconText: "󰆍"
        foreground: root.bar.foreground
        horizontalPadding: Style.space(12)
        verticalPadding: Style.space(8)
        onClicked: {
          root.close()
          Quickshell.execDetached(["omarchy-launch-terminal", "btop"])
        }
      }
    }
  }
}
