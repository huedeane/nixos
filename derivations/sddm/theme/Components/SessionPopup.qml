import QtQuick

Item {
  id: idSessionPopupComponent

  // Properties
  property real   propScale:            1
  property bool   propOpen:             false
  property int    propCurrentIndex:     0
  property color  propBackgroundColor:  config.ColorBase
  property color  propAccentColor:      config.ColorGreen
  property color  propTextColor:        config.ColorText
  property color  propDimTextColor:     config.ColorOverlay1
  property string propFontFamily:       config.Font
  property int    propRoundCorners:     config.RoundCorners !== "" ? parseInt(config.RoundCorners) : 10
  property Item   propReturnFocusItem:  null

  // Signals
  signal sessionSelected(int index)
  signal closed()

  enabled: propOpen

  function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a) }

  onPropOpenChanged: {
    if (propOpen) {
      idSessionList.currentIndex = propCurrentIndex
      idSessionList.forceActiveFocus()
    } else if (propReturnFocusItem) {
      propReturnFocusItem.forceActiveFocus()
    }
  }

  Rectangle {
    // Position
    anchors {
      left: parent.left
      leftMargin: 50 * propScale
      bottom: parent.bottom
      bottomMargin: 92 * propScale
    }

    // Size
    width: 300 * propScale
    height: (typeof sessionModel !== "undefined" ? sessionModel.count : 0) * 34 * propScale + 12 * propScale

    // Modification
    color: withAlpha(propBackgroundColor, 0.85)

    // Visibility
    opacity: propOpen ? 1.0 : 0.0
    scale: propOpen ? 1.0 : 0.96
    transformOrigin: Item.BottomLeft
    visible: opacity > 0

    // Animation
    Behavior on opacity { NumberAnimation { duration: 200 } }
    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    ListView {
      id: idSessionList

      // Position
      anchors {
        fill: parent
        topMargin: 6 * propScale
        bottomMargin: 6 * propScale
      }

      // Data
      model: typeof sessionModel !== "undefined" ? sessionModel : null

      // Other
      clip: true

      // Keyboard
      focus: true
      keyNavigationEnabled: true
      keyNavigationWraps: true
      highlightMoveDuration: 150

      Keys.onReturnPressed: idSessionPopupComponent.sessionSelected(currentIndex)
      Keys.onEnterPressed:  idSessionPopupComponent.sessionSelected(currentIndex)
      Keys.onEscapePressed: idSessionPopupComponent.closed()
      Keys.onTabPressed:    incrementCurrentIndex()
      Keys.onBacktabPressed: decrementCurrentIndex()

      // List Item
      delegate: Item {
        id: idDelegate

        // Size
        width: ListView.view.width
        height: 34 * propScale

        readonly property bool isHighlighted: ListView.isCurrentItem
        readonly property bool isCurrent:     index === propCurrentIndex
        readonly property string fullName:    model.name || "Unnamed"
        readonly property int    noteStart:   fullName.indexOf(" (")

        // Hover / keyboard highlight
        Rectangle {
          // Position
          anchors.fill: parent

          // Modification
          color: withAlpha(propTextColor, 0.08)
          visible: idDelegate.isHighlighted
        }

        // Current session bar
        Rectangle {
          // Size
          width: 3 * propScale
          height: parent.height

          // Modification
          color: propAccentColor
          visible: idDelegate.isCurrent
        }

        Row {
          spacing: 8 * propScale

          // Position
          anchors {
            left: parent.left
            leftMargin: 15 * propScale
            verticalCenter: parent.verticalCenter
          }

          Text {
            text: idDelegate.noteStart >= 0 ? idDelegate.fullName.substring(0, idDelegate.noteStart) : idDelegate.fullName

            // Modification
            font {
              family: propFontFamily
              pixelSize: 13 * propScale
              letterSpacing: 1 * propScale
            }
            color: idDelegate.isCurrent ? propAccentColor : propTextColor
          }

          Text {
            text: idDelegate.noteStart >= 0 ? idDelegate.fullName.substring(idDelegate.noteStart + 1) : ""

            // Modification
            font {
              family: propFontFamily
              pixelSize: 12 * propScale
            }
            color: propDimTextColor
            visible: text !== ""
          }
        }

        // Focus ring
        Rectangle {
          // Position
          anchors.fill: parent

          // Modification
          color: "transparent"
          border {
            color: propAccentColor
            width: 1
          }
          visible: idDelegate.isHighlighted && idSessionList.activeFocus && !idDelegateArea.containsMouse
        }

        MouseArea {
          id: idDelegateArea

          // Position
          anchors.fill: parent

          // Behavior
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor

          // Action
          onEntered: idSessionList.currentIndex = index
          onClicked: idSessionPopupComponent.sessionSelected(index)
        }
      }
    }
  }
}
