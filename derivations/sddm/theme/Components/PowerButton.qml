import QtQuick

Item {
  id: idPowerButtonsComponent

  // Size
  implicitWidth:  idPowerRow.implicitWidth
  implicitHeight: idPowerRow.implicitHeight

  // Properties
  property real   propScale:            1
  property color  propRebootTextColor:  config.ColorYellow
  property color  propPowerTextColor:   config.ColorRed
  property color  propTextColor:        config.ColorText
  property string propFontFamily:       config.Font

  // Focus chain
  property alias propFirstFocusItem: idRebootText
  property Item  propNextFocusItem: null

  Row {
    id: idPowerRow
    spacing: 25 * propScale

    Text {
      id: idRebootText
      text: "REBOOT"

      // Position
      anchors.verticalCenter: parent.verticalCenter

      // Modification
      font {
        family: propFontFamily
        pixelSize: 14 * propScale
        // letterSpacing: 2 * propScale
      }
      color: idRebootArea.containsMouse ? propRebootTextColor : propTextColor
      scale: idRebootArea.containsMouse ? 1.12 : 1.0

      // Animation
      Behavior on color { ColorAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

      // Focus
      activeFocusOnTab: true
      KeyNavigation.tab: idShutdownText
      Keys.onReturnPressed: { if (typeof sddm !== "undefined") sddm.reboot() }
      Keys.onEnterPressed:  { if (typeof sddm !== "undefined") sddm.reboot() }

      Rectangle {
        // Position
        anchors.fill: parent
        anchors.margins: -6 * propScale

        // Modification
        color: "transparent"
        border {
          color: propRebootTextColor
          width: 1
        }
        visible: idRebootText.activeFocus
      }

      // Action
      MouseArea {
        id: idRebootArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { if (typeof sddm !== "undefined") sddm.reboot() }
      }
    }

    Text {
      id: idShutdownText
      text: "SHUTDOWN"

      // Position
      anchors.verticalCenter: parent.verticalCenter

      // Modification
      font {
        family: propFontFamily
        pixelSize: 14 * propScale
        // letterSpacing: 2 * propScale
      }
      color: idShutdownArea.containsMouse ? propPowerTextColor : propTextColor
      scale: idShutdownArea.containsMouse ? 1.12 : 1.0

      // Animation
      Behavior on color { ColorAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

      // Focus
      activeFocusOnTab: true
      KeyNavigation.tab: propNextFocusItem
      Keys.onReturnPressed: { if (typeof sddm !== "undefined") sddm.powerOff() }
      Keys.onEnterPressed:  { if (typeof sddm !== "undefined") sddm.powerOff() }

      Rectangle {
        // Position
        anchors.fill: parent
        anchors.margins: -6 * propScale

        // Modification
        color: "transparent"
        border {
          color: propPowerTextColor
          width: 1
        }
        visible: idShutdownText.activeFocus
      }

      // Action
      MouseArea {
        id: idShutdownArea

        // Position
        anchors.fill: parent

        // Behavior
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        // Action
        onClicked: { if (typeof sddm !== "undefined") sddm.powerOff() }
      }
    }
  }
}
