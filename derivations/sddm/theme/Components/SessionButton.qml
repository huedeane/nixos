import QtQuick

Item {
  id: idSessionButtonComponent

  // Properties
  property real   propScale:        1
  property color  propTextColor:    config.ColorText
  property color  propAccentColor:  config.ColorGreen
  property string propFontFamily:   config.Font
  property int    propSessionIndex: 0
  
  // Signal
  signal clicked()

  // Helper
  ListView {
    id: sessionHelper
    model: typeof sessionModel !== "undefined" ? sessionModel : null
    currentIndex: propSessionIndex
    opacity: 0; width: 1; height: 1; z: -100
    delegate: Item { property string sName: model.name || "" }
  }

  Row {
    id: idSessionButton
    spacing: 12 * propScale

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
      width: 2
      height: 14 * propScale

      // Position
      anchors {
        verticalCenter: parent.verticalCenter 
      }

      // Modification
      color: propTextColor
      opacity: 0.5
    }

    Text {
      text: sessionHelper.currentItem ? sessionHelper.currentItem.sName : "DEFAULT"

      // Position
      anchors {
        verticalCenter: parent.verticalCenter
      }

      // Modification
      font {
        family: propFontFamily
        pixelSize: 14 * propScale
        letterSpacing: 2 * propScale
        weight: Font.Bold
      }
      color: idSessionMouseArea.containsMouse ? propTextColor : propAccentColor
      scale: idSessionMouseArea.containsMouse ? 1.02 : 1.0

      // Animation
      Behavior on color { ColorAnimation { duration: 200 } }
      Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }
    }
  }

  MouseArea {
    id: idSessionMouseArea

    // Position
    anchors.fill: idSessionButton 

    //Behavior
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    // Action
    onClicked: idSessionButtonComponent.clicked()
  }
}
