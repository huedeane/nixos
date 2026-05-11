import QtQuick
import Qt5Compat.GraphicalEffects

Item {
  id: idLoginFormComponent

  // Properties
  property real   propScale:            1
  property color  propErrorColor:       config.ColorRed
  property color  propBackgroundColor:  config.ColorBase
  property color  propAccentColor:      config.ColorGreen
  property color  propTextColor:        config.ColorText
  property string propFontFamily:       config.Font
  property int    propUserIndex:        0
  property int    propRoundCorners:    config.RoundCorners !== "" ? parseInt(config.RoundCorners) : 10

  // Signals
  signal loginSubmitted()
  signal userSwitched()

  // Public functions
  function showError(message) { idError.text = message }
  function clearPassword() { idPasswordInput.text = ""; idPasswordInput.forceActiveFocus() }
  function getPassword() { return idPasswordInput.text }
  function toTitleCase(str) {
    return str.replace(/\w\S*/g, function(word) {
      return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    })
  }
  // Callback
  Connections {
    target: typeof sddm !== "undefined" ? sddm : null
    
    function onLoginFailed() {
      root.propStateLoginError = true
      idError.text = "ACCESS DENIED"
      idPasswordInput.text = ""
      idPasswordInput.forceActiveFocus()
    }
  }

  // Helper
  ListView {
    id: idUserHelper
    model: typeof userModel !== "undefined" ? userModel : null
    currentIndex: propUserIndex
    opacity: 0; width: 1; height: 1; z: -100
    delegate: Item {
      property string uName:  model.realName || model.name || ""
      property string uLogin: model.name || ""
    }
  }
  
  Timer { interval: 300; running: true; onTriggered: idPasswordInput.forceActiveFocus() }

  Item {

    // Size
    width: 400 * propScale
    height: 120 * propScale

    // Position
    anchors {
      centerIn: parent
      verticalCenterOffset: 160 * propScale
    }

    Column {

      // Size
      width: 280 * propScale
      spacing: 20 * propScale
      
      // Position
      anchors {
        horizontalCenter: parent.horizontalCenter
        bottom: parent.bottom
      }

      // Username
      Item {

        // Size
        width: idUsername.implicitWidth
        height: idUsername.implicitHeight

        // Position
        anchors.horizontalCenter: parent.horizontalCenter
        
        Text {
          text: idUsername.text
          color: "#80000000"
          font: idUsername.font
          x: 2 * propScale
          y: 2 * propScale
        }

        Text {
          id: idUsername
          
          text: toTitleCase((idUserHelper.currentItem && idUserHelper.currentItem.uName)
            ? idUserHelper.currentItem.uName
            : (typeof userModel !== "undefined" ? userModel.lastUser : "User") || "User")
            
          // Modification
          color: propAccentColor
          style: Text.Normal
          font {
            italic: true
            family: propFontFamily
            pixelSize: 22 * propScale
            letterSpacing: 2 * propScale
            weight: Font.Bold;
          }
          
          // Effect
          layer {
            enabled: true
            effect: DropShadow {
              color: propBackgroundColor
              radius: 25 * propScale
              samples: 31
              verticalOffset: 6 * propScale
              transparentBorder: true
            }
          }
        }

        MouseArea {

          // Position
          anchors.fill: parent
          
          // Behavior
          cursorShape: Qt.PointingHandCursor
          
          // Action
          onClicked: idLoginFormComponent.userSwitched()
        }
      }

      // Password field
      Item {

        // Size
        width: parent.width
        height: 36 * propScale

        Rectangle {

          // Size
          width: parent.width
          height: 1 * propScale

          // Position
          anchors {
            bottom: parent.bottom
            left: parent.left
          }

          // Modification
          color: propTextColor
          opacity: idPasswordInput.activeFocus ? 1.0 : 0.3

          // Animation
          Behavior on opacity { NumberAnimation { duration: 300 } }
        }

        Rectangle {
          // Size
          width: idPasswordInput.activeFocus ? parent.width : 0
          height: 2 * propScale
          
          // Position
          anchors {
            bottom: parent.bottom
            left: parent.left
          }

          // Modification
          color: propAccentColor
          radius: 20 * propScale
          
          // Animation
          Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutExpo } }
          
          // Effect
          layer {
            enabled: true
            effect: Glow { color: propBackgroundColor; radius: 2; spread: 0.2 }
          }
        }

        TextInput {
          id: idPasswordInput
          
          // Position
          anchors.fill: parent
          
          // Modification
          color: propBackgroundColor
          font {
            family: propFontFamily
            pixelSize: 20 * propScale
            letterSpacing: 4 * propScale
          }
          selectionColor: propBackgroundColor

          // Password Setting
          echoMode: TextInput.Password
          passwordCharacter: "─"

          // Behavior
          focus: true
          clip: true
          horizontalAlignment: TextInput.AlignHCenter
          verticalAlignment: TextInput.AlignVCenter
          cursorVisible: false
          cursorDelegate: Item { width: 0; height: 0 }
          
          // Effect
          layer {
            enabled: true
            effect: Glow { color: propBackgroundColor; radius: 2; spread: 0.2 }
          }

          // State
          property bool wasClicked: false

          // Action
          onTextEdited: idError.text = ""
          onActiveFocusChanged: if (!activeFocus && text.length === 0) wasClicked = false
          Keys.onReturnPressed: idLoginFormComponent.loginSubmitted()
          Keys.onEnterPressed: idLoginFormComponent.loginSubmitted()
        }

        Text {
          
          text: "Password"
          
          // Position
          anchors.centerIn: parent
          
          
          // Modification
          color: propAccentColor
          font {
            family: propFontFamily
            pixelSize: 14 * propScale
            letterSpacing: 4 * propScale
          }
          opacity: idPasswordInput.text.length === 0 ? 0.8 : 0
          
          // Effect
          layer {
            enabled: true
            effect: DropShadow {
              color: "#000000"
              radius: 40  * propScale
              samples: 41
              spread: 0.4
              transparentBorder: true
            }
          }

          // Animation
          Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutSine } }
        }

        Rectangle {
          id: idCustomCursor
          
          // Size
          width: 5 * propScale
          height: 20 * propScale
          
          // Position
          anchors.verticalCenter: parent.verticalCenter
          x: idPasswordInput.cursorRectangle.x
          
          // Modification
          color: propBackgroundColor
          visible: idPasswordInput.focus && (idPasswordInput.text.length > 0 || idPasswordInput.wasClicked)
          
          // Animation
          SequentialAnimation {
            loops: Animation.Infinite
            running: idCustomCursor.visible
            NumberAnimation { target: idCustomCursor; property: "opacity"; from: 1;    to: 0.2; duration: 450 }
            NumberAnimation { target: idCustomCursor; property: "opacity"; from: 0.2;  to: 1;   duration: 450 }
          }
        }

        MouseArea {

          // Position
          anchors.fill: parent
          
          // Action
          onClicked: {
            idPasswordInput.forceActiveFocus()
            idPasswordInput.wasClicked = true
          }
        }
      }

      // Login button
      Item {

        // Size
        width: 140 * propScale
        height: 36 * propScale
        
        // Position
        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
          
          // Position
          anchors.fill: parent

          // Modification
          color: idLoginMouseArea.containsMouse ? propAccentColor : propBackgroundColor
          radius: propRoundCorners * propScale
          border {
            color: propAccentColor
            width: 2
          }
          opacity: idLoginMouseArea.containsMouse ? 1 : 0.8
          
          // Animation
          Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
          text: "LOGIN"
          
          // Position
          anchors.centerIn: parent
          
          // Modification
          color: idLoginMouseArea.containsMouse ? "#000" : propAccentColor
          font {
            family: propFontFamily
            pixelSize: 12 * propScale
            letterSpacing: 4 * propScale
          }

          // Animation
          Behavior on color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
          id: idLoginMouseArea
          
          // Position
          anchors.fill: parent
 
          // Behavior
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor

          // Action
          onClicked: idLoginFormComponent.loginSubmitted()
        }
      }

      // Error text
      Text {
        id: idError
        
        // Text
        text: ""
        
        // Position
        anchors.horizontalCenter: parent.horizontalCenter
        
        // Size
        height: 20 * propScale
        
        // Modification
        color: propErrorColor
        verticalAlignment: Text.AlignBottom
        font {
          family: propFontFamily
          pixelSize: 16 * propScale
        }

        // Effect
        layer {
          enabled: true
          effect: DropShadow {
            color: "#000000"
            radius: 40  * propScale
            samples: 41
            spread: 0.6
            transparentBorder: true
          }
        }
      }
    }
  }
}
