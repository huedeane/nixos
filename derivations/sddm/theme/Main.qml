import QtQuick
import Qt5Compat.GraphicalEffects
import QtMultimedia
import Qt.labs.folderlistmodel
import "Components"

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
  property bool propStateSessionMenuOpen:  false
  
  // Visual
  readonly property string  propBackground:              Qt.resolvedUrl(config.Background)
  readonly property string  propBackgroundPlaceholder:   Qt.resolvedUrl(config.BackgroundPlaceholder)

  // Font
  readonly property string  propFontFamily:   config.Font
  readonly property int     propFontSize:     config.FontSize !== "" ? parseInt(config.FontSize) : parseInt(height / 80) || 13

  // --- Layer ---
  // Fallback -1000
  Rectangle { 
    anchors.fill: parent; 
    color: config.ColorCrust; 
    z: -1000 
  }

  // Background -500
  Background {
    anchors.fill: parent
    z: -500

    // Properties
    propSource: propBackground
    propPlaceholder: propBackgroundPlaceholder
    // propCrop:
  }

  // Overlay -300
  Rectangle {
    anchors.fill: parent
    z: -300
    gradient: Gradient {
      GradientStop { position: 0.0; color: "#00000000" }
      GradientStop { position: 0.5; color: "#00000000" }
      GradientStop { position: 1.0; color: "#aa05080c" }
    }
  }

  // Session Popup Dismisser -10
  MouseArea {
    anchors.fill: parent
    z: -10
    onClicked: { root.propStateSessionMenuOpen = false }
    visible: root.propStateSessionMenuOpen
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

      // Properties
      propScale: root.s
      // propFontFamily:
      // propTextColor:
      // propTimeFormat:
      // propDateFormat:
    }

    LoginForm {
      id: idLoginForm

      // Position
      anchors.fill: parent
      propScale:     s
      propUserIndex: root.propStateUserIndex
      propSessionIndex: root.propStateSessionIndex
      propNextFocusItem: idSessionButton
      propLoginDelay: 3000
      // propErrorColor:
      // propBackgroundColor:
      // propAccentColor:
      // propTextColor:
      // propFontFamily:
      // propRoundedCorner:

      // Action
      onUserSwitched: {
        if (typeof userModel !== "undefined" && userModel.rowCount() > 0)
          root.propStateUserIndex = (root.propStateUserIndex + 1) % userModel.rowCount()
      }
    }

    // Actions bar
    Item {
      // Size
      height: 80 * s

      // Position
      anchors {
        margins: 50 * s
        left: parent.left
        right: parent.right
        bottom: parent.bottom
      }

      SessionButton {
        id: idSessionButton
        
        // Position
        anchors {
          left: parent.left
          bottom: parent.bottom
        }

        // Properties
        propScale:       s 
        propSessionIndex: root.propStateSessionIndex
        propOpen:        root.propStateSessionMenuOpen
        // propTextColor:
        // propAccentColor:
        // propFontFamily:
 
        // Action
        onClicked: root.propStateSessionMenuOpen = !root.propStateSessionMenuOpen

        // Focus
        propNextFocusItem: idPowerButton.propFirstFocusItem
      }
      
      PowerButton {
        id: idPowerButton
        
        // Position
        anchors {
          right: parent.right
          bottom: parent.bottom
        }

        // Properties
        propScale:      s
        // propTextColor:
        // propRebootTextColor:
        // propPowerTextColor:
        // propFontFamily:

        // Focus
        propNextFocusItem: idLoginForm.propFirstFocusItem
      }
    }
    
    SessionPopup {
      // Position
      anchors.fill: parent

      // Properties
      propScale:        s
      propOpen:         root.propStateSessionMenuOpen
      propCurrentIndex: root.propStateSessionIndex
      propReturnFocusItem: idSessionButton

      // Override Prop
      // propAccentColor:
      // propTextColor:
      // propFontFamily:
      // propRoundedCorner:

      // Action
      onSessionSelected: (index) => {
        root.propStateSessionIndex   = index
        root.propStateSessionMenuOpen = false
      }
      onClosed: root.propStateSessionMenuOpen = false
    }
  }

  // Login Fade 1000
  Rectangle {
    anchors.fill: parent
    z: 1000
    color: "black"
    opacity: 0
    visible: opacity > 0

    // Slow fade out on login, quick fade back if login fails
    NumberAnimation on opacity { id: idLoginFadeOut; running: false; to: 1; duration: 3000; easing.type: Easing.InOutQuad }
    NumberAnimation on opacity { id: idLoginFadeIn;  running: false; to: 0; duration: 400;  easing.type: Easing.InOutQuad }
    Connections {
      target: idLoginForm
      function onPropStateLoggingInChanged() {
        idLoginFadeOut.stop(); idLoginFadeIn.stop()
        if (idLoginForm.propStateLoggingIn) idLoginFadeOut.start()
        else idLoginFadeIn.start()
      }
    }

    // Swallow input while fading
    MouseArea { anchors.fill: parent }
  }

  // Boot Fade 1001
  Rectangle {
    anchors.fill: parent
    z: 1001
    color: "black"
    opacity: 1
    visible: opacity > 0

    NumberAnimation on opacity { from: 1; to: 0; duration: 1500; easing.type: Easing.InOutQuad }
  }
}
