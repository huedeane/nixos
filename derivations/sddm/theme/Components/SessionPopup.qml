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

  // Signals
  signal sessionSelected(int index)

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

      // Position
      anchors {
        fill: parent
        margins: 10 * propScale
      }

      // Data
      model: typeof sessionModel !== "undefined" ? sessionModel : null

      // Other
      clip: true

      // List Item
      delegate: Item {
        
        // Size
        width: parent.width
        height: 45 * propScale

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
          onClicked: idSessionPopupComponent.sessionSelected(index)
        }
      }
    }
  }
}
