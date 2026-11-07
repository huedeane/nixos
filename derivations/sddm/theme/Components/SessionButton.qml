import QtQuick

Item {
  id: idSessionButtonComponent

  // Size
  implicitWidth:  idSessionPill.width
  implicitHeight: idSessionPill.height

  // Properties
  property real   propScale:            1
  property color  propTextColor:        config.ColorText
  property color  propDimTextColor:     config.ColorOverlay1
  property color  propAccentColor:      config.ColorGreen
  property color  propNameColor:        config.ColorYellow
  property color  propBackgroundColor:  config.ColorBase
  property string propFontFamily:       config.Font
  property int    propSessionIndex:     0
  property bool   propOpen:             false
  property Item   propNextFocusItem:    null

  // Icons (Nerd Font)
  readonly property string propIconSession: "\uf108"
  readonly property string propIconCaret:   "\uf0d8"

  // Tab Functionality
  activeFocusOnTab: true
  Keys.onReturnPressed: idSessionButtonComponent.clicked()
  Keys.onEnterPressed:  idSessionButtonComponent.clicked()
  Keys.onSpacePressed:  idSessionButtonComponent.clicked()
  KeyNavigation.tab:    propNextFocusItem

  // Signal
  signal clicked()

  function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

  // Helper
  ListView {
    id: sessionHelper
    model: typeof sessionModel !== "undefined" ? sessionModel : null
    currentIndex: propSessionIndex
    opacity: 0; width: 1; height: 1; z: -100
    delegate: Item { property string sName: model.name || "" }
  }

  // "Hyprland (uwsm-managed)" -> name + dimmed note
  readonly property string propSessionFull: sessionHelper.currentItem ? sessionHelper.currentItem.sName : "Default"
  readonly property int    propNoteStart:   propSessionFull.indexOf(" (")

  Rectangle {
    id: idSessionPill

    // Size
    width: idSessionRow.implicitWidth + 30 * propScale
    height: 34 * propScale

    // Modification
    color: withAlpha(propBackgroundColor, (idSessionMouseArea.containsMouse || propOpen) ? 0.85 : 0.6)

    // Animation
    Behavior on color { ColorAnimation { duration: 150 } }

    // Accent bar
    Rectangle {
      // Size
      width: 3 * propScale
      height: parent.height

      // Modification
      color: propAccentColor
    }

    Row {
      id: idSessionRow
      spacing: 10 * propScale

      // Position
      anchors {
        left: parent.left
        leftMargin: 15 * propScale
        verticalCenter: parent.verticalCenter
      }

      Text {
        text: propIconSession

        // Position
        anchors.verticalCenter: parent.verticalCenter

        // Modification
        font {
          family: propFontFamily
          pixelSize: 13 * propScale
        }
        color: propTextColor
      }

      Text {
        text: "SESSION"

        // Position
        anchors.verticalCenter: parent.verticalCenter

        // Modification
        font {
          family: propFontFamily
          pixelSize: 12 * propScale
          letterSpacing: 2 * propScale
        }
        color: propTextColor
      }

      Rectangle {
        // Size
        width: 1
        height: 14 * propScale

        // Position
        anchors.verticalCenter: parent.verticalCenter

        // Modification
        color: propTextColor
        opacity: 0.4
      }

      Text {
        text: propNoteStart >= 0 ? propSessionFull.substring(0, propNoteStart) : propSessionFull

        // Position
        anchors.verticalCenter: parent.verticalCenter

        // Modification
        font {
          family: propFontFamily
          pixelSize: 13 * propScale
          letterSpacing: 1 * propScale
          italic: true
          weight: Font.Bold
        }
        color: propNameColor
      }

      Text {
        text: propNoteStart >= 0 ? propSessionFull.substring(propNoteStart + 1) : ""

        // Position
        anchors.verticalCenter: parent.verticalCenter

        // Modification
        font {
          family: propFontFamily
          pixelSize: 12 * propScale
        }
        color: propDimTextColor
        visible: text !== ""
      }

      Text {
        text: propIconCaret

        // Position
        anchors.verticalCenter: parent.verticalCenter

        // Modification
        font {
          family: propFontFamily
          pixelSize: 11 * propScale
        }
        color: propDimTextColor
        visible: propOpen
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
      visible: idSessionButtonComponent.activeFocus
    }
  }

  MouseArea {
    id: idSessionMouseArea

    // Position
    anchors.fill: idSessionPill

    // Behavior
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    // Action
    onClicked: idSessionButtonComponent.clicked()
  }
}
