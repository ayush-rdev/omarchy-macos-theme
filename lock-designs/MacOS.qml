// macOS Sonoma & Sequoia Lock Screen for Omarchy
// Integrated with the macOS Sequoia theme: authentic Apple typography,
// frosted glass materials, circular user avatar, pill password field,
// upper-third clock & date, status indicators, and subtle system actions.

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import qs.Commons
import "../plugins/io.github.sirjul1337.lock-explorer/designs"

DesignBase {
  id: lock
  inputItem: passwordInput
  shakeOnFail: false

  // Wallpaper presentation: crisp Sonoma/Sequoia view with gentle depth
  Wallpaper {
    anchors.fill: parent
    lock: lock
    blur: 0.10
    dim: 0.06
    contrast: -0.02
    vignette: true
    vignetteTop: 0.38
    vignetteMiddle: 0.08
    vignetteBottom: 0.48
  }

  // Clicking anywhere wakes up the display and pulls focus to the password field
  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: { lock.wakeRequested(); lock.forcePasswordFocus() }
    onPositionChanged: lock.wakeRequested()
  }

  // System power management processes
  Process { id: sleepProc; command: ["systemctl", "suspend"] }
  Process { id: rebootProc; command: ["omarchy", "system", "reboot"] }
  Process { id: poweroffProc; command: ["omarchy", "system", "shutdown"] }

  // UPower battery integration
  readonly property var battery: UPower.displayDevice
  readonly property bool hasBattery: battery && battery.isPresent && battery.percentage > 0
  readonly property int batteryPct: hasBattery ? Math.round(battery.percentage * 100) : 0
  readonly property bool isCharging: hasBattery && !UPower.onBattery

  // Display user name formatted nicely
  readonly property string displayName: {
    var name = String(lock.userName || "")
    if (name.length === 0) return "User"
    return name.charAt(0).toUpperCase() + name.slice(1)
  }

  // =========================================================================
  // Top macOS Status Bar
  // =========================================================================
  Item {
    id: topBar
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 40

    // Left: Subtle Lock Status indicator
    Row {
      anchors.left: parent.left
      anchors.leftMargin: 24
      anchors.verticalCenter: parent.verticalCenter
      spacing: 7

      Text {
        text: "󰌾"
        color: Qt.rgba(1, 1, 1, 0.75)
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 15
        anchors.verticalCenter: parent.verticalCenter
      }

      Text {
        text: "Locked"
        color: Qt.rgba(1, 1, 1, 0.75)
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 13
        font.weight: Font.Medium
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    // Right: Wi-Fi, Battery, Keyboard Layout
    Row {
      anchors.right: parent.right
      anchors.rightMargin: 24
      anchors.verticalCenter: parent.verticalCenter
      spacing: 16

      // Battery status (if available)
      Row {
        visible: lock.hasBattery
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Text {
          text: lock.batteryPct + "%"
          color: Qt.rgba(1, 1, 1, 0.90)
          font.family: "SF Pro Display, SF Pro Text, sans-serif"
          font.pixelSize: 12
          font.weight: Font.Medium
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          text: lock.isCharging ? "󰂄"
                : (lock.batteryPct >= 90 ? "󰁹"
                : (lock.batteryPct >= 70 ? "󰂀"
                : (lock.batteryPct >= 50 ? "󰁾"
                : (lock.batteryPct >= 30 ? "󰁼" : "󰁺"))))
          color: lock.batteryPct <= 20 && !lock.isCharging ? Color.urgent : Qt.rgba(1, 1, 1, 0.90)
          font.family: "SF Pro Display, SF Pro Text, sans-serif"
          font.pixelSize: 17
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      // Wi-Fi icon
      Text {
        text: "󰤨"
        color: Qt.rgba(1, 1, 1, 0.90)
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 16
        anchors.verticalCenter: parent.verticalCenter
      }

      // Input source / Layout badge
      Rectangle {
        width: 28
        height: 19
        radius: 4
        color: Qt.rgba(1, 1, 1, 0.16)
        border.width: 1
        border.color: Qt.rgba(255, 255, 255, 0.20)
        anchors.verticalCenter: parent.verticalCenter

        Text {
          anchors.centerIn: parent
          text: "US"
          color: Qt.rgba(1, 1, 1, 0.90)
          font.family: "SF Pro Display, SF Pro Text, sans-serif"
          font.pixelSize: 10
          font.weight: Font.Bold
        }
      }
    }
  }

  // =========================================================================
  // Upper Region: Iconic macOS Sonoma / Sequoia Clock & Date
  // =========================================================================
  Column {
    id: clockSection
    anchors.top: parent.top
    anchors.topMargin: Math.round(parent.height * 0.13)
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 4

    // Date
    Item {
      width: dateLabel.implicitWidth
      height: dateLabel.implicitHeight
      anchors.horizontalCenter: parent.horizontalCenter

      // Shadow
      Text {
        text: Qt.formatDate(lock.now, "dddd, MMMM d")
        color: Qt.rgba(0, 0, 0, 0.55)
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 24
        font.weight: Font.Medium
        font.letterSpacing: 0.5
        x: 0; y: 2
      }
      // Main text
      Text {
        id: dateLabel
        text: Qt.formatDate(lock.now, "dddd, MMMM d")
        color: Qt.rgba(1, 1, 1, 0.96)
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 24
        font.weight: Font.Medium
        font.letterSpacing: 0.5
      }
    }

    // Large Clock
    Item {
      width: timeLabel.implicitWidth
      height: timeLabel.implicitHeight
      anchors.horizontalCenter: parent.horizontalCenter

      // Ambient shadow
      Text {
        text: lock.clock("HH:mm")
        color: Qt.rgba(0, 0, 0, 0.50)
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 102
        font.weight: Font.DemiBold
        font.letterSpacing: -2.5
        x: 0; y: 3
      }
      // Main clock
      Text {
        id: timeLabel
        text: lock.clock("HH:mm")
        color: "#ffffff"
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 102
        font.weight: Font.DemiBold
        font.letterSpacing: -2.5
      }
    }
  }

  // =========================================================================
  // Center / Lower-Center: User Profile Card & macOS Capsule Authentication Field
  // =========================================================================
  Column {
    id: userSection
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: clockSection.bottom
    anchors.topMargin: Math.round(parent.height * 0.14)
    spacing: 14

    // User Avatar with macOS frosted rim and soft drop shadow
    Item {
      anchors.horizontalCenter: parent.horizontalCenter
      width: 100
      height: 100

      // Layered drop shadow
      Rectangle {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: 6
        width: 94
        height: 94
        radius: 47
        color: Qt.rgba(0, 0, 0, 0.40)
      }

      // Outer macOS frosted rim
      Rectangle {
        anchors.fill: parent
        radius: 50
        color: Qt.rgba(255, 255, 255, 0.08)
        border.width: 2
        border.color: lock.errorState ? Color.lock.borderError : Qt.rgba(255, 255, 255, 0.35)
        antialiasing: true
      }

      // Avatar content: Custom picture or Apple-styled gradient monogram
      Item {
        anchors.centerIn: parent
        width: 90
        height: 90

        // Fallback gradient monogram
        Rectangle {
          id: monogramBg
          anchors.fill: parent
          radius: 45
          visible: !userAvatarImage.showsImage
          antialiasing: true
          gradient: Gradient {
            GradientStop { position: 0.0; color: "#0071e3" }
            GradientStop { position: 1.0; color: "#47a3ff" }
          }

          Text {
            anchors.centerIn: parent
            text: lock.userInitial
            color: "#ffffff"
            font.family: "SF Pro Display, SF Pro Text, sans-serif"
            font.pixelSize: 38
            font.weight: Font.Bold
          }
        }

        // Circular masked custom photo
        Item {
          id: userAvatarImage
          anchors.fill: parent
          readonly property bool showsImage: lock.hasAvatar && avatarImg.status === Image.Ready
          visible: showsImage
          layer.enabled: showsImage
          layer.smooth: true
          layer.effect: MultiEffect {
            maskEnabled: true
            maskSource: avatarMask
            maskThresholdMin: 0.5
            maskSpreadAtMin: 0.05
          }

          Image {
            id: avatarImg
            anchors.fill: parent
            source: lock.avatarUrl
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            smooth: true
            mipmap: true
            sourceSize.width: 180
            sourceSize.height: 180
          }
        }

        Item {
          id: avatarMask
          anchors.fill: parent
          visible: false
          layer.enabled: true
          Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "white"
            antialiasing: true
          }
        }
      }
    }

    // User display name
    Item {
      anchors.horizontalCenter: parent.horizontalCenter
      width: userNameLabel.implicitWidth
      height: userNameLabel.implicitHeight

      Text {
        text: lock.displayName
        color: Qt.rgba(0, 0, 0, 0.50)
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 19
        font.weight: Font.DemiBold
        x: 0; y: 2
      }
      Text {
        id: userNameLabel
        text: lock.displayName
        color: "#ffffff"
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 19
        font.weight: Font.DemiBold
      }
    }

    // Authentic macOS Capsule / Pill Password Field
    Item {
      id: fieldWrapper
      anchors.horizontalCenter: parent.horizontalCenter
      width: 264
      height: 42

      // Classic macOS Horizontal Shake Animation on authentication error
      transform: Translate { id: shakeTranslate; x: 0 }
      SequentialAnimation {
        id: shakeAnimation
        running: false
        NumberAnimation { target: shakeTranslate; property: "x"; from: 0; to: -14; duration: 40 }
        NumberAnimation { target: shakeTranslate; property: "x"; from: -14; to: 14; duration: 70 }
        NumberAnimation { target: shakeTranslate; property: "x"; from: 14; to: -10; duration: 60 }
        NumberAnimation { target: shakeTranslate; property: "x"; from: -10; to: 8; duration: 50 }
        NumberAnimation { target: shakeTranslate; property: "x"; from: 8; to: -4; duration: 40 }
        NumberAnimation { target: shakeTranslate; property: "x"; from: -4; to: 0; duration: 30 }
      }

      Connections {
        target: lock
        function onFailureMessageChanged() {
          if (lock.failureMessage.length > 0) shakeAnimation.restart()
        }
      }

      // Frosted Glass Pill Background
      Rectangle {
        id: pillBackground
        anchors.fill: parent
        radius: height / 2
        color: Qt.rgba(0.12, 0.12, 0.14, 0.72)
        border.width: 1.2
        border.color: lock.errorState ? Color.lock.borderError
                      : (passwordInput.activeFocus ? "#0a84ff" : Qt.rgba(255, 255, 255, 0.26))
        antialiasing: true

        Behavior on border.color { ColorAnimation { duration: 150 } }
      }

      // Password Text Input
      LockInput {
        id: passwordInput
        lock: lock
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 42
        anchors.topMargin: 2
        anchors.bottomMargin: 2
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignLeft
        echoMode: lock.passwordVisible && !lock.fido2Active ? TextInput.Normal : TextInput.Password
        passwordCharacter: "●"
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: text.length > 0 && !lock.passwordVisible ? 12 : 13
        font.letterSpacing: text.length > 0 && !lock.passwordVisible ? 3.5 : 0
        color: "#ffffff"
        cursorVisible: activeFocus && text.length > 0 && !lock.authenticatingPassword && !lock.errorState
        cursorDelegate: Rectangle {
          width: 2
          color: "#0a84ff"
          visible: passwordInput.cursorVisible
        }
      }

      // Placeholder or checking state
      Text {
        anchors.fill: passwordInput
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        visible: passwordInput.text.length === 0
        text: lock.authenticatingPassword ? "Checking…"
              : (lock.fido2Active ? (lock.fido2Status.length > 0 ? lock.fido2Status : "Touch security key…")
              : "Enter Password")
        color: lock.authenticatingPassword ? "#ffffff" : Qt.rgba(255, 255, 255, 0.48)
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 13
      }

      // Right-side macOS Submit Arrow Button (or Touch ID icon)
      Item {
        id: submitButton
        anchors.right: parent.right
        anchors.rightMargin: 6
        anchors.verticalCenter: parent.verticalCenter
        width: 30
        height: 30

        Rectangle {
          anchors.fill: parent
          radius: 15
          color: passwordInput.text.length > 0
                 ? (arrowMouse.pressed ? "#0062cc" : "#0a84ff")
                 : (arrowMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.20) : Qt.rgba(255, 255, 255, 0.10))
          antialiasing: true

          Behavior on color { ColorAnimation { duration: 120 } }

          Text {
            anchors.centerIn: parent
            text: lock.fingerprintConfigured && passwordInput.text.length === 0 ? "󰈷" : "➔"
            color: passwordInput.text.length > 0 ? "#ffffff" : Qt.rgba(255, 255, 255, 0.55)
            font.family: "SF Pro Display, SF Pro Text, sans-serif"
            font.pixelSize: 14
          }
        }

        MouseArea {
          id: arrowMouse
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          enabled: lock.inputEnabled && !lock.authenticatingPassword
          onClicked: {
            if (passwordInput.text.length > 0) {
              var submitted = passwordInput.text
              lock.passwordTextEdited("")
              lock.submitPassword(submitted)
            } else {
              passwordInput.forceActiveFocus()
            }
          }
        }
      }
    }

    // Status / Error hint below the input pill
    Item {
      anchors.horizontalCenter: parent.horizontalCenter
      width: statusText.implicitWidth
      height: 18

      Text {
        id: statusText
        anchors.centerIn: parent
        text: lock.errorState ? (lock.failureMessage.length > 0 ? lock.failureMessage : "Incorrect Password")
              : (lock.fingerprintConfigured ? "Touch ID or Enter Password" : "Press Return to unlock")
        color: lock.errorState ? Color.lock.borderError : Qt.rgba(255, 255, 255, 0.65)
        font.family: "SF Pro Display, SF Pro Text, sans-serif"
        font.pixelSize: 12
        font.weight: lock.errorState ? Font.Medium : Font.Normal
        font.letterSpacing: 0.2
      }
    }
  }

  // =========================================================================
  // Bottom macOS System Actions: Sleep, Restart, Shut Down
  // =========================================================================
  Row {
    id: bottomBar
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 32
    anchors.horizontalCenter: parent.horizontalCenter
    spacing: 16

    // Sleep Pill
    Rectangle {
      width: sleepRow.implicitWidth + 28
      height: 34
      radius: 17
      color: sleepMouse.pressed ? Qt.rgba(255, 255, 255, 0.24)
             : (sleepMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.18) : Qt.rgba(255, 255, 255, 0.12))
      border.width: 1
      border.color: Qt.rgba(255, 255, 255, 0.20)
      antialiasing: true

      Behavior on color { ColorAnimation { duration: 100 } }

      Row {
        id: sleepRow
        anchors.centerIn: parent
        spacing: 7
        Text {
          text: "󰒲"
          color: Qt.rgba(1, 1, 1, 0.90)
          font.family: "SF Pro Display, SF Pro Text, sans-serif"
          font.pixelSize: 14
          anchors.verticalCenter: parent.verticalCenter
        }
        Text {
          text: "Sleep"
          color: Qt.rgba(1, 1, 1, 0.90)
          font.family: "SF Pro Display, SF Pro Text, sans-serif"
          font.pixelSize: 12
          font.weight: Font.Medium
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      MouseArea {
        id: sleepMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          lock.wakeRequested()
          sleepProc.running = true
        }
      }
    }

    // Restart Pill
    Rectangle {
      width: restartRow.implicitWidth + 28
      height: 34
      radius: 17
      color: restartMouse.pressed ? Qt.rgba(255, 255, 255, 0.24)
             : (restartMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.18) : Qt.rgba(255, 255, 255, 0.12))
      border.width: 1
      border.color: Qt.rgba(255, 255, 255, 0.20)
      antialiasing: true

      Behavior on color { ColorAnimation { duration: 100 } }

      Row {
        id: restartRow
        anchors.centerIn: parent
        spacing: 7
        Text {
          text: "󰑐"
          color: Qt.rgba(1, 1, 1, 0.90)
          font.family: "SF Pro Display, SF Pro Text, sans-serif"
          font.pixelSize: 14
          anchors.verticalCenter: parent.verticalCenter
        }
        Text {
          text: "Restart"
          color: Qt.rgba(1, 1, 1, 0.90)
          font.family: "SF Pro Display, SF Pro Text, sans-serif"
          font.pixelSize: 12
          font.weight: Font.Medium
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      MouseArea {
        id: restartMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          lock.wakeRequested()
          rebootProc.running = true
        }
      }
    }

    // Shut Down Pill
    Rectangle {
      width: shutdownRow.implicitWidth + 28
      height: 34
      radius: 17
      color: shutdownMouse.pressed ? Qt.rgba(255, 255, 255, 0.24)
             : (shutdownMouse.containsMouse ? Qt.rgba(255, 255, 255, 0.18) : Qt.rgba(255, 255, 255, 0.12))
      border.width: 1
      border.color: Qt.rgba(255, 255, 255, 0.20)
      antialiasing: true

      Behavior on color { ColorAnimation { duration: 100 } }

      Row {
        id: shutdownRow
        anchors.centerIn: parent
        spacing: 7
        Text {
          text: "󰐥"
          color: Qt.rgba(1, 1, 1, 0.90)
          font.family: "SF Pro Display, SF Pro Text, sans-serif"
          font.pixelSize: 14
          anchors.verticalCenter: parent.verticalCenter
        }
        Text {
          text: "Shut Down"
          color: Qt.rgba(1, 1, 1, 0.90)
          font.family: "SF Pro Display, SF Pro Text, sans-serif"
          font.pixelSize: 12
          font.weight: Font.Medium
          anchors.verticalCenter: parent.verticalCenter
        }
      }

      MouseArea {
        id: shutdownMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
          lock.wakeRequested()
          poweroffProc.running = true
        }
      }
    }
  }
}
