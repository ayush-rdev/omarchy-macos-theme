import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Services.Mpris
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "macos.nowplaying"

  readonly property var mprisPlayerList: Mpris.players ? Mpris.players.values : []
  property string selectedPlayerIdentity: ""

  readonly property var sourcePlayers: {
    var res = []
    for (var i = 0; i < mprisPlayerList.length; i++) {
      var p = mprisPlayerList[i]
      if (p && (p.trackTitle || p.trackArtist || p.identity || p.desktopEntry)) {
        res.push(p)
      }
    }
    return res
  }

  readonly property var activePlayer: {
    if (selectedPlayerIdentity) {
      for (var i = 0; i < sourcePlayers.length; i++) {
        var sp = sourcePlayers[i]
        if (sp && (sp.identity === selectedPlayerIdentity || sp.desktopEntry === selectedPlayerIdentity)) return sp
      }
    }
    for (var j = 0; j < sourcePlayers.length; j++) {
      if (sourcePlayers[j] && sourcePlayers[j].playbackState === MprisPlaybackState.Playing) return sourcePlayers[j]
    }
    return sourcePlayers.length > 0 ? sourcePlayers[0] : null
  }

  readonly property bool hasMedia: activePlayer !== null && (activePlayer.trackTitle || activePlayer.trackArtist)
  readonly property bool isPlaying: activePlayer !== null && activePlayer.playbackState === MprisPlaybackState.Playing

  property bool popupOpen: false
  function close() { popupOpen = false }

  function doPlayPause() {
    if (!activePlayer) return
    if (typeof activePlayer.playPause === "function") activePlayer.playPause()
    else if (isPlaying && typeof activePlayer.pause === "function") activePlayer.pause()
    else if (!isPlaying && typeof activePlayer.play === "function") activePlayer.play()
  }

  function doNext() {
    if (activePlayer && typeof activePlayer.next === "function") activePlayer.next()
  }

  function doPrevious() {
    if (activePlayer && typeof activePlayer.previous === "function") activePlayer.previous()
  }

  function formatTime(seconds) {
    if (!seconds || isNaN(seconds) || seconds < 0) return "0:00"
    var totalSec = Math.floor(seconds)
    var m = Math.floor(totalSec / 60)
    var s = totalSec % 60
    return m + ":" + (s < 10 ? "0" : "") + s
  }

  function cleanArtUrl(url) {
    if (!url) return ""
    var str = String(url)
    if (str.indexOf("googleusercontent.com") !== -1 || str.indexOf("ggpht.com") !== -1) {
      // 256px is 3x retina for our 84px container, downloads in milliseconds
      str = str.replace(/=w\d+-h\d+.*$/, "=w256-h256-l90-rj")
      str = str.replace(/=s\d+.*$/, "=s256")
    }
    return str
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  // Background image pre-loader so artwork is already cached in memory before popup is opened
  Image {
    id: backgroundPreloadArt
    visible: false
    width: Style.space(84)
    height: Style.space(84)
    sourceSize: Qt.size(Style.space(168), Style.space(168))
    source: root.cleanArtUrl(root.activePlayer && root.activePlayer.trackArtUrl ? root.activePlayer.trackArtUrl : "")
    asynchronous: true
    cache: true
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "󰝚"
    onPressed: function(b) {
      if (b === Qt.RightButton && root.activePlayer) {
        root.doPlayPause()
      } else {
        root.popupOpen = !root.popupOpen
      }
    }
    onWheelMoved: function(delta) {
      if (!root.activePlayer) return
      if (delta > 0) root.doPrevious()
      else if (delta < 0) root.doNext()
    }
  }

  Timer {
    id: positionTimer
    interval: 500
    repeat: true
    running: root.popupOpen && root.isPlaying
    onTriggered: {
      if (root.activePlayer && typeof root.activePlayer.positionChanged === "function") {
        root.activePlayer.positionChanged()
      }
    }
  }

  KeyboardPanel {
    id: popup
    anchorItem: button
    bar: root.bar
    owner: root
    open: root.popupOpen
    contentWidth: popup.fittedContentWidth(Style.space(340))
    contentHeight: popup.fittedContentHeight(mainColumn.implicitHeight)

    Column {
      id: mainColumn
      anchors.fill: parent
      spacing: Style.space(12)

      // Header row with source player tag & playback state
      Row {
        width: parent.width
        Item {
          width: parent.width
          height: sourceTag.implicitHeight

          Row {
            id: sourceTag
            anchors.left: parent.left
            spacing: Style.space(6)

            Text {
              textFormat: Text.PlainText
              text: "󰎆"
              color: Color.accent
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.bodySmall
              anchors.verticalCenter: parent.verticalCenter
            }

            Text {
              textFormat: Text.PlainText
              text: root.activePlayer ? (root.activePlayer.identity || root.activePlayer.desktopEntry || "Now Playing") : "Now Playing"
              color: Qt.darker(root.bar.foreground, 1.4)
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
            text: root.isPlaying ? "Playing" : (root.hasMedia ? "Paused" : "Idle")
            color: root.isPlaying ? Color.accent : Qt.darker(root.bar.foreground, 1.6)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }
      }

      // Track artwork + Title/Artist/Album Info
      Row {
        width: parent.width
        spacing: Style.space(12)

        BorderSurface {
          width: Style.space(84)
          height: Style.space(84)
          radius: Style.space(12)
          color: Style.normalFillFor(root.bar.foreground, Color.accent)
          borderSpec: Border.controlSpec("normal", root.bar.foreground, Color.accent)
          clip: true

          Image {
            id: albumArt
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: false
            cache: true
            smooth: true
            mipmap: true
            source: root.cleanArtUrl(root.activePlayer && root.activePlayer.trackArtUrl ? root.activePlayer.trackArtUrl : "")
            visible: source !== ""
            sourceSize: Qt.size(Style.space(168), Style.space(168))
          }

          Text {
            anchors.centerIn: parent
            visible: !albumArt.visible || albumArt.status !== Image.Ready
            text: "󰝚"
            color: root.bar.foreground
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.displayLarge
            opacity: 0.4
          }
        }

        Column {
          width: parent.width - Style.space(96)
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(4)

          Item {
            id: titleContainer
            width: parent.width
            height: titleText.implicitHeight
            clip: true

            Text {
              id: titleText
              textFormat: Text.PlainText
              text: root.activePlayer && root.activePlayer.trackTitle ? root.activePlayer.trackTitle : "No media playing"
              color: root.bar.foreground
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.subtitle
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter

              readonly property bool needsScroll: implicitWidth > titleContainer.width
              readonly property real overflowDistance: Math.max(0, implicitWidth - titleContainer.width)

              x: 0

              SequentialAnimation {
                id: titleAnim
                running: titleText.needsScroll && root.popupOpen
                loops: Animation.Infinite

                NumberAnimation { target: titleText; property: "x"; to: 0; duration: 0 }
                PauseAnimation { duration: 1800 }
                NumberAnimation {
                  target: titleText
                  property: "x"
                  to: -titleText.overflowDistance
                  duration: Math.max(2500, titleText.overflowDistance * 35)
                  easing.type: Easing.InOutQuad
                }
                PauseAnimation { duration: 1800 }
                NumberAnimation {
                  target: titleText
                  property: "x"
                  to: 0
                  duration: Math.max(2500, titleText.overflowDistance * 35)
                  easing.type: Easing.InOutQuad
                }
              }

              Connections {
                target: root
                function onPopupOpenChanged() {
                  if (root.popupOpen) {
                    titleText.x = 0
                    titleAnim.restart()
                  } else {
                    titleAnim.stop()
                    titleText.x = 0
                  }
                }
              }

              onTextChanged: {
                titleText.x = 0
                titleAnim.restart()
              }
            }
          }

          Item {
            id: artistContainer
            width: parent.width
            height: artistText.implicitHeight
            clip: true

            Text {
              id: artistText
              textFormat: Text.PlainText
              text: root.activePlayer && root.activePlayer.trackArtist ? root.activePlayer.trackArtist : "Play music or video to see info"
              color: Qt.darker(root.bar.foreground, 1.3)
              font.family: root.bar.fontFamily
              font.pixelSize: Style.font.bodySmall
              anchors.verticalCenter: parent.verticalCenter

              readonly property bool needsScroll: implicitWidth > artistContainer.width
              readonly property real overflowDistance: Math.max(0, implicitWidth - artistContainer.width)

              x: 0

              SequentialAnimation {
                id: artistAnim
                running: artistText.needsScroll && root.popupOpen
                loops: Animation.Infinite

                NumberAnimation { target: artistText; property: "x"; to: 0; duration: 0 }
                PauseAnimation { duration: 2000 }
                NumberAnimation {
                  target: artistText
                  property: "x"
                  to: -artistText.overflowDistance
                  duration: Math.max(2500, artistText.overflowDistance * 35)
                  easing.type: Easing.InOutQuad
                }
                PauseAnimation { duration: 2000 }
                NumberAnimation {
                  target: artistText
                  property: "x"
                  to: 0
                  duration: Math.max(2500, artistText.overflowDistance * 35)
                  easing.type: Easing.InOutQuad
                }
              }

              Connections {
                target: root
                function onPopupOpenChanged() {
                  if (root.popupOpen) {
                    artistText.x = 0
                    artistAnim.restart()
                  } else {
                    artistAnim.stop()
                    artistText.x = 0
                  }
                }
              }

              onTextChanged: {
                artistText.x = 0
                artistAnim.restart()
              }
            }
          }
        }
      }

      // Track progress bar with live position & total duration
      Column {
        width: parent.width
        spacing: Style.space(4)
        visible: root.hasMedia && root.activePlayer && root.activePlayer.length > 0

        PanelSlider {
          id: trackSlider
          width: parent.width
          bar: root.bar
          minimum: 0
          maximum: root.activePlayer && root.activePlayer.length > 0 ? root.activePlayer.length : 1
          value: root.activePlayer ? Math.max(0, Math.min(maximum, root.activePlayer.position || 0)) : 0
          fillColor: Color.accent

          onMoved: function(newVal) {
            if (root.activePlayer) {
              root.activePlayer.position = newVal
            }
          }
        }

        Row {
          width: parent.width
          Text {
            anchors.left: parent.left
            textFormat: Text.PlainText
            text: root.formatTime(trackSlider.liveValue)
            color: Qt.darker(root.bar.foreground, 1.5)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }

          Text {
            anchors.right: parent.right
            textFormat: Text.PlainText
            text: root.formatTime(root.activePlayer ? root.activePlayer.length : 0)
            color: Qt.darker(root.bar.foreground, 1.5)
            font.family: root.bar.fontFamily
            font.pixelSize: Style.font.caption
          }
        }
      }

      // Media controls row (Previous, Play/Pause, Next)
      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Style.space(14)

        Button {
          anchors.verticalCenter: parent.verticalCenter
          height: Style.space(42)
          iconText: "󰒮"
          foreground: root.bar.foreground
          iconSize: Style.font.iconLarge
          horizontalPadding: Style.space(16)
          enabled: root.activePlayer && (root.activePlayer.canGoPrevious !== false)
          opacity: enabled ? 1.0 : 0.4
          onClicked: root.doPrevious()
        }

        Button {
          anchors.verticalCenter: parent.verticalCenter
          height: Style.space(42)
          iconText: root.isPlaying ? "󰏤" : "󰐊"
          foreground: root.bar.foreground
          iconSize: Style.font.display
          horizontalPadding: Style.space(24)
          enabled: root.activePlayer !== null
          opacity: enabled ? 1.0 : 0.4
          onClicked: root.doPlayPause()
        }

        Button {
          anchors.verticalCenter: parent.verticalCenter
          height: Style.space(42)
          iconText: "󰒭"
          foreground: root.bar.foreground
          iconSize: Style.font.iconLarge
          horizontalPadding: Style.space(16)
          enabled: root.activePlayer && (root.activePlayer.canGoNext !== false)
          opacity: enabled ? 1.0 : 0.4
          onClicked: root.doNext()
        }
      }

      // Active Players list (when multiple apps are playing, e.g. Spotify + Browser)
      Column {
        id: playerSources
        width: parent.width
        spacing: Style.space(4)
        visible: root.sourcePlayers.length > 1

        PanelSeparator {
          width: parent.width
          foreground: root.bar.foreground
        }

        Text {
          textFormat: Text.PlainText
          text: "Media Sources"
          color: Qt.darker(root.bar.foreground, 1.6)
          font.family: root.bar.fontFamily
          font.pixelSize: Style.font.caption
          font.bold: true
        }

        Repeater {
          model: root.sourcePlayers

          BorderSurface {
            id: srcRow
            required property var modelData
            readonly property var p: modelData
            readonly property bool isCurrent: root.activePlayer && p && (root.activePlayer.identity === p.identity || root.activePlayer.desktopEntry === p.desktopEntry)

            width: parent.width
            height: Style.space(32)
            radius: Style.space(6)
            color: isCurrent ? Style.selectedFillFor(root.bar.foreground, Color.accent) : "transparent"
            borderSpec: isCurrent ? Border.controlSpec("normal", root.bar.foreground, Color.accent) : Border.none()

            Row {
              anchors.fill: parent
              anchors.leftMargin: Style.space(8)
              anchors.rightMargin: Style.space(8)
              spacing: Style.space(8)

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: p && p.playbackState === MprisPlaybackState.Playing ? "󰏤" : "󰐊"
                color: isCurrent ? Color.accent : root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.bodySmall
              }

              Text {
                anchors.verticalCenter: parent.verticalCenter
                text: p ? (p.identity || p.desktopEntry || "Player") : "Player"
                color: root.bar.foreground
                font.family: root.bar.fontFamily
                font.pixelSize: Style.font.caption
                font.bold: isCurrent
                elide: Text.ElideRight
                width: parent.width - Style.space(40)
              }
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (srcRow.p) {
                  root.selectedPlayerIdentity = srcRow.p.identity || srcRow.p.desktopEntry || ""
                }
              }
            }
          }
        }
      }
    }
  }
}
