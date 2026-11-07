import QtQuick

Item {
  id: idPowerButtonsComponent

  // Size
  implicitWidth:  idPowerRow.implicitWidth
  implicitHeight: idPowerRow.implicitHeight

  // Properties
  property real   propScale:            1
  property color  propRebootTextColor:  config.ColorGreen
  property color  propPowerTextColor:   config.ColorRed
  property color  propTextColor:        config.ColorText
  property color  propBackgroundColor:  config.ColorBase
  property string propFontFamily:       config.Font

  // Focus chain
  property alias propFirstFocusItem: idRebootButton
  property Item  propNextFocusItem:  null

  function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }
  function reboot()   { if (typeof sddm !== "undefined") sddm.reboot() }
  function powerOff() { if (typeof sddm !== "undefined") sddm.powerOff() }

  // Pill with an accent bar, icon and label (shared by reboot and shutdown)
  component PowerPill: Rectangle {
    id: idPill

    // Properties
    property string propIcon:        ""
    property string propLabel:       ""
    property color  propAccent:      propTextColor
    property bool   propTintOnHover: false

    // Signal
    signal activated()

    readonly property bool hovered: idPillArea.containsMouse

    // Size
    width: idPillRow.implicitWidth + 30 * propScale
    height: 34 * propScale

    // Modification
    color: idPillArea.pressed ? withAlpha(propBackgroundColor, 0.95)
      : hovered ? withAlpha(propBackgroundColor, 0.85)
      : withAlpha(propBackgroundColor, 0.6)

    // Animation
    Behavior on color { ColorAnimation { duration: 150 } }

    // Focus
    activeFocusOnTab: true
    Keys.onReturnPressed: activated()
    Keys.onEnterPressed:  activated()
    Keys.onSpacePressed:  activated()

    // Accent bar
    Rectangle {
      // Size
      width: 3 * propScale
      height: parent.height

      // Modification
      color: idPill.propAccent
    }

    Row {
      id: idPillRow
      spacing: 10 * propScale

      // Position
      anchors {
        left: parent.left
        leftMargin: 15 * propScale
        verticalCenter: parent.verticalCenter
      }

      Text {
        text: idPill.propIcon

        // Position
        anchors.verticalCenter: parent.verticalCenter

        // Modification
        font {
          family: propFontFamily
          pixelSize: 13 * propScale
        }
        color: idPill.propTintOnHover ? idPill.propAccent : propTextColor
      }

      Text {
        text: idPill.propLabel

        // Position
        anchors.verticalCenter: parent.verticalCenter

        // Modification
        font {
          family: propFontFamily
          pixelSize: 12 * propScale
          letterSpacing: 2 * propScale
        }
        color: idPill.propTintOnHover && idPill.hovered && !idPillArea.pressed ? idPill.propAccent : propTextColor

        // Animation
        Behavior on color { ColorAnimation { duration: 150 } }
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
        color: config.ColorGreen
        width: 2 * propScale
      }
      visible: idPill.activeFocus
    }

    MouseArea {
      id: idPillArea

      // Position
      anchors.fill: parent

      // Behavior
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor

      // Action
      onClicked: idPill.activated()
    }
  }

  Row {
    id: idPowerRow
    spacing: 10 * propScale

    PowerPill {
      id: idRebootButton

      // Properties
      propIcon:   "\uf01e"
      propLabel:  "REBOOT"
      propAccent: propRebootTextColor

      // Focus
      KeyNavigation.tab: idShutdownButton

      // Action
      onActivated: reboot()
    }

    PowerPill {
      id: idShutdownButton

      // Properties
      propIcon:        "\uf011"
      propLabel:       "SHUTDOWN"
      propAccent:      propPowerTextColor
      propTintOnHover: true

      // Focus
      KeyNavigation.tab: propNextFocusItem

      // Action
      onActivated: powerOff()
    }
  }
}
