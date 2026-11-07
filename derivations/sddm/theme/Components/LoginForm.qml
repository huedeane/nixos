import QtQuick
import Qt5Compat.GraphicalEffects

Item {
  id: idLoginFormComponent

  // Properties
  property real   propScale:            1
  property color  propErrorColor:       config.ColorRed
  property color  propBackgroundColor:  config.ColorBase
  property color  propAccentColor:      config.ColorGreen
  property color  propTitleColor:       config.ColorYellow
  property color  propTextColor:        config.ColorText
  property color  propDimTextColor:     config.ColorOverlay1
  property string propFontFamily:       config.Font
  property int    propUserIndex:        0
  property int    propSessionIndex:     0
  property int    propRoundCorners:     config.RoundCorners !== "" ? parseInt(config.RoundCorners) : 10
  property Item   propNextFocusItem:    null
  property alias  propFirstFocusItem:   idPasswordInput
  property int    propLoginDelay:       0

  // State
  property bool   propStateShowPassword: false
  property bool   propStateLoggingIn:    false
  property bool   propStateFailed:       false
  readonly property bool propStateCapsLock: typeof keyboard !== "undefined" && keyboard.capsLock

  // Icons (Nerd Font)
  readonly property string propIconEye:      "\uf06e"
  readonly property string propIconEyeOff:   "\uf070"
  readonly property string propIconCaps:     String.fromCodePoint(0xf0632)
  readonly property string propIconReturn:   String.fromCodePoint(0xf0311)
  readonly property string propIconDot:      "\uf111"

  // Signals
  signal userSwitched()

  // Public functions
  function showError(message) { idError.text = message }
  function clearPassword() { idPasswordInput.text = ""; idPasswordInput.forceActiveFocus() }
  function getPassword() { return idPasswordInput.text }
  function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
  function login() {
    if (propStateLoggingIn) return
    var n = (idUserHelper.currentItem && idUserHelper.currentItem.uLogin !== "")
      ? idUserHelper.currentItem.uLogin
      : (typeof userModel !== "undefined" ? userModel.lastUser : "")
    propStateFailed = false
    propStateLoggingIn = true
    idLoginTimer.propUser = n
    idLoginTimer.start()
  }

  // Delay login so the fade-out can finish before the greeter is torn down
  Timer {
    id: idLoginTimer
    property string propUser: ""
    interval: Math.max(1, propLoginDelay)
    onTriggered: if (typeof sddm !== "undefined") sddm.login(propUser, idPasswordInput.text, propSessionIndex)
  }

  // Callback
  Connections {
    target: typeof sddm !== "undefined" ? sddm : null

    function onLoginFailed() {
      propStateLoggingIn = false
      propStateFailed = true
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

  // Card
  Rectangle {
    id: idCard

    // Size
    width: 330 * propScale
    height: idCardColumn.implicitHeight + 28 * propScale

    // Position
    anchors {
      centerIn: parent
      verticalCenterOffset: 150 * propScale
    }

    // Modification
    color: withAlpha(propBackgroundColor, 0.72)

    // Accent bar
    Rectangle {
      // Size
      width: 3 * propScale
      height: parent.height

      // Modification
      color: propStateFailed ? propErrorColor : propAccentColor

      // Animation
      Behavior on color { ColorAnimation { duration: 200 } }
    }

    Column {
      id: idCardColumn

      // Size
      spacing: 12 * propScale

      // Position
      anchors {
        top: parent.top
        topMargin: 14 * propScale
        left: parent.left
        leftMargin: 20 * propScale
        right: parent.right
        rightMargin: 14 * propScale
      }

      // Header: title + username
      Item {

        // Size
        width: parent.width
        height: idTitle.implicitHeight

        Text {
          id: idTitle
          text: "Login"

          // Position
          anchors.left: parent.left

          // Modification
          color: propTitleColor
          font {
            family: propFontFamily
            pixelSize: 13 * propScale
          }
        }

        Text {
          id: idUsername
          text: (idUserHelper.currentItem && idUserHelper.currentItem.uLogin)
            ? idUserHelper.currentItem.uLogin
            : (typeof userModel !== "undefined" ? userModel.lastUser : "user") || "user"

          // Position
          anchors.right: parent.right

          // Modification
          color: propAccentColor
          font {
            italic: true
            family: propFontFamily
            pixelSize: 13 * propScale
            weight: Font.Bold
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
      }

      // Password field
      Item {
        id: idPasswordField

        // Size
        width: parent.width
        height: 34 * propScale

        // Underline
        Rectangle {

          // Size
          width: parent.width
          height: (idPasswordInput.activeFocus || propStateFailed) ? 2 * propScale : 1 * propScale

          // Position
          anchors {
            bottom: parent.bottom
            left: parent.left
          }

          // Modification
          color: propStateFailed ? propErrorColor
            : idPasswordInput.activeFocus ? propAccentColor
            : propTextColor
          opacity: (idPasswordInput.activeFocus || propStateFailed) ? 1.0 : 0.35

          // Animation
          Behavior on color { ColorAnimation { duration: 200 } }
          Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        TextInput {
          id: idPasswordInput

          // Position
          anchors {
            left: parent.left
            right: idEyeButton.left
            rightMargin: 8 * propScale
            top: parent.top
            bottom: parent.bottom
          }

          // Modification
          color: propTextColor
          font {
            family: propFontFamily
            pixelSize: (propStateShowPassword ? 15 : 12) * propScale
            letterSpacing: (propStateShowPassword ? 1 : 5) * propScale
          }
          selectionColor: propAccentColor
          selectedTextColor: propBackgroundColor

          // Password Setting
          echoMode: propStateShowPassword ? TextInput.Normal : TextInput.Password
          passwordCharacter: propIconDot

          // Behavior
          focus: true
          clip: true
          readOnly: propStateLoggingIn
          verticalAlignment: TextInput.AlignVCenter
          cursorDelegate: Rectangle {
            width: 2 * propScale
            color: propTextColor
            visible: idPasswordInput.activeFocus && !propStateLoggingIn

            // Animation
            SequentialAnimation on opacity {
              loops: Animation.Infinite
              NumberAnimation { from: 1;   to: 0.2; duration: 450 }
              NumberAnimation { from: 0.2; to: 1;   duration: 450 }
            }
          }

          // Action
          onTextEdited: propStateFailed = false
          activeFocusOnTab: true
          KeyNavigation.tab: idLoginButton
          Keys.onReturnPressed: login()
          Keys.onEnterPressed: login()
        }

        // Placeholder
        Text {
          text: "password"

          // Position
          anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
          }

          // Modification
          color: propDimTextColor
          font {
            family: propFontFamily
            pixelSize: 14 * propScale
          }
          visible: idPasswordInput.text.length === 0 && !propStateLoggingIn
        }

        // Eye (show password) / spinner while logging in
        Item {
          id: idEyeButton

          // Size
          width: 26 * propScale
          height: 26 * propScale

          // Position
          anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
          }

          Rectangle {

            // Position
            anchors.fill: parent

            // Modification
            radius: width / 2
            color: withAlpha(propBackgroundColor, 0.85)
            opacity: idEyeArea.containsMouse && !propStateLoggingIn ? 1 : 0

            // Animation
            Behavior on opacity { NumberAnimation { duration: 150 } }
          }

          Text {
            text: propStateShowPassword ? propIconEyeOff : propIconEye

            // Position
            anchors.centerIn: parent

            // Modification
            color: propStateShowPassword ? propAccentColor : propTextColor
            opacity: propStateShowPassword || idEyeArea.containsMouse ? 1 : 0.7
            font {
              family: propFontFamily
              pixelSize: 14 * propScale
            }
            visible: !propStateLoggingIn
          }

          // Spinner
          Canvas {
            id: idSpinner

            // Size
            width: 14 * propScale
            height: 14 * propScale

            // Position
            anchors.centerIn: parent

            // Modification
            visible: propStateLoggingIn
            onPaint: {
              var ctx = getContext("2d")
              ctx.reset()
              ctx.lineWidth = 2 * propScale
              ctx.strokeStyle = propAccentColor
              ctx.beginPath()
              ctx.arc(width / 2, height / 2, width / 2 - ctx.lineWidth, 0, Math.PI * 1.5)
              ctx.stroke()
            }

            // Animation
            RotationAnimation on rotation {
              running: idSpinner.visible
              loops: Animation.Infinite
              from: 0; to: 360; duration: 800
            }
          }

          MouseArea {
            id: idEyeArea

            // Position
            anchors.fill: parent

            // Behavior
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            enabled: !propStateLoggingIn

            // Action
            onClicked: {
              propStateShowPassword = !propStateShowPassword
              idPasswordInput.forceActiveFocus()
            }
          }
        }

        MouseArea {

          // Position
          anchors {
            fill: parent
            rightMargin: idEyeButton.width
          }

          // Behavior
          cursorShape: Qt.IBeamCursor

          // Action
          onClicked: idPasswordInput.forceActiveFocus()
        }
      }

      // Caps lock / error / login button
      Item {

        // Size
        width: parent.width
        height: 24 * propScale

        // Caps lock badge
        Rectangle {

          // Size
          width: idCapsRow.implicitWidth + 12 * propScale
          height: 18 * propScale

          // Position
          anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
          }

          // Modification
          color: "transparent"
          border {
            color: propTitleColor
            width: 1
          }
          visible: propStateCapsLock && !propStateFailed

          Row {
            id: idCapsRow
            spacing: 5 * propScale

            // Position
            anchors.centerIn: parent

            Text {
              text: propIconCaps
              color: propTitleColor
              font { family: propFontFamily; pixelSize: 11 * propScale }
            }
            Text {
              text: "caps on"
              color: propTitleColor
              font { family: propFontFamily; pixelSize: 11 * propScale }
            }
          }
        }

        // Error text
        Text {
          id: idError
          text: "wrong password, try again"

          // Position
          anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
          }

          // Modification
          color: propErrorColor
          font {
            family: propFontFamily
            pixelSize: 11 * propScale
          }
          visible: propStateFailed
        }

        // Login button
        Rectangle {
          id: idLoginButton

          // Size
          width: idLoginRow.implicitWidth + 16 * propScale
          height: 24 * propScale

          // Position
          anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
          }

          // Modification
          color: idLoginMouseArea.pressed ? withAlpha(propAccentColor, 0.25)
            : idLoginMouseArea.containsMouse ? withAlpha(propBackgroundColor, 0.9)
            : "transparent"
          border {
            color: propAccentColor
            width: idLoginMouseArea.containsMouse ? 2 : 1
          }
          opacity: propStateLoggingIn ? 0.5 : 1

          // Animation
          Behavior on color { ColorAnimation { duration: 150 } }

          // Focus
          activeFocusOnTab: true
          KeyNavigation.tab: propNextFocusItem
          Keys.onReturnPressed: login()
          Keys.onEnterPressed:  login()
          Keys.onSpacePressed:  login()

          Row {
            id: idLoginRow
            spacing: 8 * propScale

            // Position
            anchors.centerIn: parent

            Text {
              text: "Login"

              // Position
              anchors.verticalCenter: parent.verticalCenter

              // Modification
              color: idLoginMouseArea.containsMouse ? propTextColor : propAccentColor
              font {
                family: propFontFamily
                pixelSize: 12 * propScale
              }
            }

            // Return key
            Rectangle {

              // Size
              width: 16 * propScale
              height: 14 * propScale

              // Position
              anchors.verticalCenter: parent.verticalCenter

              // Modification
              color: withAlpha(propAccentColor, 0.35)
              radius: 2 * propScale

              Text {
                text: propIconReturn

                // Position
                anchors.centerIn: parent

                // Modification
                color: propTextColor
                font {
                  family: propFontFamily
                  pixelSize: 10 * propScale
                }
              }
            }
          }

          // Focus ring: offset outside the control, rounded
          Rectangle {
            // Position
            anchors {
              fill: parent
              margins: -6 * propScale
            }

            // Modification
            color: "transparent"
            radius: 6 * propScale
            border {
              color: propAccentColor
              width: 2 * propScale
            }
            visible: idLoginButton.activeFocus
          }

          MouseArea {
            id: idLoginMouseArea

            // Position
            anchors.fill: parent

            // Behavior
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            // Action
            onClicked: login()
          }
        }
      }
    }

    // Shadow
    layer {
      enabled: true
      effect: DropShadow {
        color: "#80000000"
        radius: 24 * propScale
        samples: 33
        verticalOffset: 6 * propScale
        transparentBorder: true
      }
    }
  }
}
