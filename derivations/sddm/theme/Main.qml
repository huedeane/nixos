import QtQuick
import Qt5Compat.GraphicalEffects
import QtMultimedia
import Qt.labs.folderlistmodel
import "Component"


// MediaPlayer {
//   id: player
//   source: "bg.mp4"
//   videoOutput: bgVideo
//   loops: MediaPlayer.Infinite
//   Component.onCompleted: player.play()
// }
//
// VideoOutput {
//   id: bgVideo
//   anchors.fill: parent
//   fillMode: VideoOutput.PreserveAspectCrop
//   z: -500
// }

Item {
  id: root

  // Size
  width: config.ScreenWidth || Screen.width 
  height: config.ScreenHeight || Screen.height
  
  // --- Property ---

  // Scale
  readonly property real s: width / 1920

  // Colors
  readonly property color propTextPrimaryColor:  config.ColorText

  // State
  property int  propStateUserIndex:        (typeof userModel !== "undefined" && userModel.lastIndex >= 0) ? userModel.lastIndex : 0
  property int  propStateSessionIndex:     (typeof sessionModel !== "undefined" && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
  property bool propStateLoginError:       false
  property bool propStateSessionMenuOpen:  false

  // Font
  readonly property string  propFontFamily:   config.Font
  readonly property int     propFontSize:     config.FontSize !== "" ? parseInt(config.FontSize) : parseInt(height / 80) || 13

  // Visual
  readonly property string  propBackground:              Qt.resolvedUrl(config.Background)
  readonly property string  propBackgroundPlaceholder:   Qt.resolvedUrl(config.BackgroundPlaceholder)

  // --- Helper ---
  ListView {
    id: sessionHelper
    model: typeof sessionModel !== "undefined" ? sessionModel : null
    currentIndex: root.propStateSessionIndex
    opacity: 0; width: 1; height: 1; z: -100
    delegate: Item { property string sName: model.name || "" }
  }

  ListView {
    id: userHelper
    model: typeof userModel !== "undefined" ? userModel : null
    currentIndex: root.propStateUserIndex
    opacity: 0; width: 1; height: 1; z: -100
    delegate: Item {
      property string uName:  model.realName || model.name || ""
      property string uLogin: model.name || ""
    }
  }
  
  // --- Function ---
  function login() {
    var n = (userHelper.currentItem && userHelper.currentItem.uLogin !== "")
      ? userHelper.currentItem.uLogin
      : (typeof userModel !== "undefined" ? userModel.lastUser : "")
    if (typeof sddm !== "undefined") sddm.login(n, pwd.text, root.propStateSessionIndex)
  }
  
  // Callback
  Connections {
    target: typeof sddm !== "undefined" ? sddm : null
    
    function onLoginFailed() {
      root.propStateLoginError = true
      err.text = "ACCESS DENIED"
      pwd.text = ""
      errorShake.start()
      pwd.forceActiveFocus()
    }
  }

  Timer { interval: 300; running: true; onTriggered: pwd.forceActiveFocus() }

  // --- Layer ---
  // Fallback - 1000
  Rectangle { 
    anchors.fill: parent; 
    color: "#05080c"; 
    z: -1000 
  }

  // Background - 500
  Background {
    anchors.fill: parent
    z: -500
    propSource: propBackground
    propPlaceholder: propBackgroundPlaceholder
    propCrop: true
  }

  // Overlay - 300
  Rectangle {
    anchors.fill: parent
    z: -300
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#00000000" }
      GradientStop { position: 0.5; color: "#00000000" }
      GradientStop { position: 1.0; color: "#aa05080c" }
    }
  }

  // UI - 0
  Item {
    anchors.fill: parent

    Clock {
      anchors {
        top: parent.top
        topMargin: 120 * s
        horizontalCenter: parent.horizontalCenter
      }

      propScale: root.s

      // Override Prop
      // propFontFamily:
      // propTextColor:
      // propTimeFormat:
      // propDateFormat:
    }

    // Login area
    Item {
      anchors.centerIn: parent
      anchors.verticalCenterOffset: 160 * s
      width: 400 * s
      height: 120 * s

      Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        spacing: 20 * s
        width: 280 * s

        // Username
        Item {
          anchors.horizontalCenter: parent.horizontalCenter
          width: un.implicitWidth
          height: un.implicitHeight

          Text { text: un.text; color: "#80000000"; font: un.font; x: 2 * s; y: 2 * s }

          Text {
            id: un
            text: ((userHelper.currentItem && userHelper.currentItem.uName)
              ? userHelper.currentItem.uName
              : (userModel.lastUser || "User")).toUpperCase()
            color: root.propTextPrimaryColor
            style: Text.Normal
            layer.enabled: true
            layer.effect: DropShadow { color: "#50000000"; radius: 25 * s; samples: 31; verticalOffset: 6 * s; transparentBorder: true }
            font.family: root.propFontFamily
            font.pixelSize: 22 * s
            font.letterSpacing: 4 * s
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (typeof userModel !== "undefined" && userModel.rowCount() > 0)
                root.propStateUserIndex = (root.propStateUserIndex + 1) % userModel.rowCount()
            }
          }
        }

        // Password field
        Item {
          width: parent.width
          height: 36 * s

          Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: parent.width
            height: 1 * s
            color: root.propTextPrimaryColor
            opacity: pwd.activeFocus ? 1.0 : 0.3
            Behavior on opacity { NumberAnimation { duration: 300 } }
          }

          Rectangle {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: pwd.activeFocus ? parent.width : 0
            height: 2 * s
            color: root.propTextPrimaryColor
            Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
            layer.enabled: true
            layer.effect: Glow { color: root.propTextPrimaryColor; radius: 6; spread: 0.4 }
          }

          TextInput {
            id: pwd
            anchors.fill: parent
            color: root.propTextPrimaryColor
            font.family: root.propFontFamily  
            font.pixelSize: 18 * s
            font.letterSpacing: 4 * s
            echoMode: TextInput.Password
            passwordCharacter: "─"
            focus: true
            clip: true
            horizontalAlignment: TextInput.AlignHCenter
            verticalAlignment: TextInput.AlignVCenter
            cursorVisible: false
            cursorDelegate: Item { width: 0; height: 0 }
            selectionColor: root.propTextPrimaryColor
            onTextEdited: err.text = ""
            property bool wasClicked: false
            onActiveFocusChanged: if (!activeFocus && text.length === 0) wasClicked = false
            Keys.onReturnPressed: login()
            Keys.onEnterPressed: login()
          }

          Text {
            anchors.centerIn: parent
            text: "Password"
            color: root.propTextPrimaryColor
            font.family: root.propFontFamily
            font.pixelSize: 14 * s
            font.letterSpacing: 4 * s
            opacity: pwd.text.length === 0 ? 0.4 : 0
            Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutSine } }
          }

          Rectangle {
            id: customCursor
            width: 2 * s
            height: 20 * s
            color: root.propTextPrimaryColor
            anchors.verticalCenter: parent.verticalCenter
            x: pwd.cursorRectangle.x
            visible: pwd.focus && (pwd.text.length > 0 || pwd.wasClicked)
            SequentialAnimation {
              loops: Animation.Infinite
              running: customCursor.visible
              NumberAnimation { target: customCursor; property: "opacity"; from: 1;    to: 0.05; duration: 450 }
              NumberAnimation { target: customCursor; property: "opacity"; from: 0.05; to: 1;    duration: 450 }
            }
          }

          MouseArea {
            anchors.fill: parent
            onClicked: {
              pwd.forceActiveFocus()
              pwd.wasClicked = true
            }
          }
        }

        // Login button
        Item {
          anchors.horizontalCenter: parent.horizontalCenter
          width: 140 * s
          height: 36 * s

          Rectangle {
            anchors.fill: parent
            color: sbm.containsMouse ? root.propTextPrimaryColor : "transparent"
            border.color: root.propTextPrimaryColor
            border.width: 2
            radius: 4 * s
            Behavior on color { ColorAnimation { duration: 150 } }
          }

          Text {
            anchors.centerIn: parent
            text: "LOGIN"
            color: sbm.containsMouse ? "#000" : root.propTextPrimaryColor
            font.family: root.propFontFamily
            font.pixelSize: 12 * s
            font.letterSpacing: 4 * s
            Behavior on color { ColorAnimation { duration: 150 } }
          }

          MouseArea {
            id: sbm
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: login()
          }
        }

        // Error text
        Text {
          id: err
          text: ""
          height: 12 * s
          verticalAlignment: Text.AlignBottom
          color: "#ff4444"
          anchors.horizontalCenter: parent.horizontalCenter
          font.family: root.propFontFamily
          font.pixelSize: 12 * s
        }
      }
    }

    // Actions bar
    Item {
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 50 * s
      height: 80 * s

      // Session selector
      Row {
        id: sessionRow
        visible: !root.isQuickshell
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        spacing: 12 * s

        Text {
          text: "SESSION"
          font.family: root.propFontFamily
          font.pixelSize: 12 * s
          font.letterSpacing: 2 * s
          color: root.propTextPrimaryColor
          anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
          width: 1; height: 14 * s
          color: root.propTextPrimaryColor
          opacity: 0.5
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          text: (sessionHelper.currentItem && sessionHelper.currentItem.sName
            ? sessionHelper.currentItem.sName : "DEFAULT").toUpperCase()
          font.family: root.propFontFamily
          font.pixelSize: 14 * s
          font.weight: Font.Bold
          font.letterSpacing: 1 * s
          color: sessionMa.containsMouse ? root.propTextPrimaryColor : root.accent
          scale: sessionMa.containsMouse ? 1.08 : 1.0
          anchors.verticalCenter: parent.verticalCenter
          Behavior on color { ColorAnimation { duration: 200 } }
          Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
        }
      }

      MouseArea {
        id: sessionMa
        visible: !root.isQuickshell
        anchors.fill: sessionRow
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.propStateSessionMenuOpen = !root.propStateSessionMenuOpen
      }

      // Power buttons
      Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        spacing: 25 * s

        Text {
          text: "REBOOT"
          font.family: root.propFontFamily
          font.pixelSize: 12 * s
          font.letterSpacing: 2 * s
          color: reboot2Ma.containsMouse ? root.propTextPrimaryColor : root.propTextPrimaryColor
          scale: reboot2Ma.containsMouse ? 1.12 : 1.0
          Behavior on color { ColorAnimation { duration: 200 } }
          Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
          MouseArea {
            id: reboot2Ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { if (typeof sddm !== "undefined") sddm.reboot() }
          }
        }

        Text {
          text: "SHUTDOWN"
          font.family: root.propFontFamily
          font.pixelSize: 12 * s
          font.letterSpacing: 2 * s
          color: power2Ma.containsMouse ? "#ff6b6b" : root.propTextPrimaryColor
          scale: power2Ma.containsMouse ? 1.12 : 1.0
          Behavior on color { ColorAnimation { duration: 200 } }
          Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
          MouseArea {
            id: power2Ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { if (typeof sddm !== "undefined") sddm.powerOff() }
          }
        }
      }
    }

    // Session popup
    Rectangle {
      anchors.left: parent.left
      anchors.leftMargin: 50 * s
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 100 * s
      width: 250 * s
      height: (typeof sessionModel !== "undefined" ? sessionModel.count : 0) * 45 * s + 20 * s
      color: "#d005080c"
      border.color: "#33cde4ef"
      border.width: 1
      radius: 4 * s
      opacity: root.propStateSessionMenuOpen && !root.isQuickshell ? 1.0 : 0.0
      scale: root.propStateSessionMenuOpen && !root.isQuickshell ? 1.0 : 0.96
      transformOrigin: Item.BottomLeft
      visible: opacity > 0
      Behavior on opacity { NumberAnimation { duration: 250 } }
      Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

      ListView {
        anchors.fill: parent
        anchors.margins: 10 * s
        model: typeof sessionModel !== "undefined" ? sessionModel : null
        clip: true
        delegate: Item {
          width: parent.width
          height: 45 * s
          Text {
            anchors.centerIn: parent
            text: (model.name || "UNNAMED").toUpperCase()
            font.family: root.propFontFamily
            font.pixelSize: 12 * s
            font.letterSpacing: 2 * s
            color: index === root.propStateSessionIndex ? root.accent : (sDelMa.containsMouse ? root.propTextPrimaryColor : root.propTextPrimaryColor)
            font.weight: index === root.propStateSessionIndex ? Font.Bold : Font.Normal
          }
          MouseArea {
            id: sDelMa
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { root.propStateSessionIndex = index; root.propStateSessionMenuOpen = false }
          }
        }
      }
    }
  }

  // Dismiss session menu
  MouseArea {
    anchors.fill: parent
    z: -10
    onClicked: { root.propStateSessionMenuOpen = false }
    visible: root.propStateSessionMenuOpen
  }
}
