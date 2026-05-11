import QtQuick
import Qt5Compat.GraphicalEffects

Column {
  id: idClockComponent

  property real   propScale:      1
  property color  propTextColor:  config.ColorText !== "" ? config.ColorText : "#ffffff"
  property string propTimeFormat: config.TimeFormat !== "" ? config.TimeFormat : "HH:mm"
  property string propDateFormat: config.DateFormat !== "" ? config.DateFormat : "dddd, MMMM d"
  property string propFontFamily: config.Font !== "" ? config.Font : ""


  spacing: 15 * propScale

  Text {
    id: idClockTime
    text: Qt.formatTime(new Date(), propTimeFormat)
    
    // Position
    anchors {
      horizontalCenter: parent.horizontalCenter
    }
    
    // Modification
    font {
      family: propFontFamily
      pixelSize: 180  * propScale
      weight: Font.Thin
    }
    color: propTextColor
    style: Text.Outline
    styleColor: "#000000"
    
    // Effect
    layer {
      enabled: true
      effect: DropShadow {
        color: "#000000"
        radius: 25  * propScale
        samples: 31
        verticalOffset: 6  * propScale
        transparentBorder: true
      }
    }
    
    // Action: Update time
    Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: idClockTime.text = Qt.formatTime(new Date(), propTimeFormat)
    }
  }

  Text {
    id: idClockDateText
    text: Qt.formatDate(new Date(), propDateFormat).toUpperCase()
    
    // Position
    anchors {
      horizontalCenter: parent.horizontalCenter
    }
    
    // Modification
    font {
      family: propFontFamily
      pixelSize: 22  * propScale
      letterSpacing: 12  * propScale
      weight: Font.DemiBold
    }
    color: propTextColor
    opacity: 0.95
    style: Text.Outline
    styleColor: "#000000"
    
    // Effect
    layer {
      enabled: true
      effect: DropShadow {
        color: "#000000"
        radius: 40  * propScale
        samples: 41
        spread: 0.3
        verticalOffset: 6  * propScale
        transparentBorder: true
      }
    }
  }
}
