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
  property string propFontFamily:       config.Font
  property int    propRoundCorners:    config.RoundCorners !== "" ? parseInt(config.RoundCorners) : 10
  property Item   propReturnFocusItem: null

  // Signals
  signal sessionSelected(int index)
  signal closed()

  enabled: propOpen

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
      bottomMargin: 100 * propScale
    }

    // Size
    width: 250 * propScale
    height: (typeof sessionModel !== "undefined" ? sessionModel.count : 0) * 45 * propScale + 20 * propScale

    // Modification
    color: propBackgroundColor
    radius: propRoundCorners * propScale
    border {
      color: propAccentColor
      width: 2
    }

    // Visibility
    opacity: propOpen ? .8 : 0.0
    scale: propOpen ? 1.0 : 0.96
    transformOrigin: Item.BottomLeft
    visible: opacity > 0

    // Animation
    Behavior on opacity { NumberAnimation { duration: 250 } }
    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

    ListView {
      id: idSessionList

      // Position
      anchors {
        fill: parent
        margins: 10 * propScale
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
        height: 45 * propScale

        readonly property bool isHighlighted: ListView.isCurrentItem

        // Focus border
        Rectangle {
          anchors.fill: parent
          anchors.margins: 2 * propScale
          color: "transparent"
          border {
            color: propAccentColor
            width: 1
          }
          visible: idDelegate.isHighlighted && idSessionList.activeFocus
        }

        Text {
          text: (model.name || "UNNAMED").toUpperCase()
          
          // Position
          anchors.centerIn: parent
          
          // Modification
          font {
            family: propFontFamily
            pixelSize: 12 * propScale
            letterSpacing: 2 * propScale
            weight: index === propCurrentIndex ? Font.Bold : Font.Normal
          }
          color: index === propCurrentIndex ? propAccentColor : propTextColor
        }

        MouseArea {
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
