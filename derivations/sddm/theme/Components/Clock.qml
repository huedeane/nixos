import QtQuick
import Qt5Compat.GraphicalEffects

Column {
  id: idClockComponent

  // theme.conf helpers: value or fallback when unset/empty
  function conf(key, fallback) { return config[key] !== undefined && config[key] !== "" ? config[key] : fallback }
  function confNum(key, fallback) { return parseFloat(conf(key, fallback)) }
  function confBool(key, fallback) { return String(conf(key, fallback)) === "true" }

  property real   propScale:      1
  property color  propTextColor:  config.ColorText !== "" ? config.ColorText : "#ffffff"
  property color  propDateColor:  "#ffffff"
  property string propTimeFormat: config.TimeFormat !== "" ? config.TimeFormat : "HH:mm"
  property string propDateFormat: config.DateFormat !== "" ? config.DateFormat : "dddd, MMMM d"
  property string propFontFamily: config.Font !== "" ? config.Font : ""

  // Per-theme clock styling (theme.conf); defaults keep the original look
  property string propClockFont:   conf("ClockFont", propFontFamily)
  property int    propClockWeight: conf("ClockWeight", "thin") === "light" ? Font.Light : Font.Thin
  property real   propClockSize:   confNum("ClockSize", 180)
  property string propColonColor:  conf("ClockColonColor", "")
  property string propDateFont:    conf("DateFont", propFontFamily)
  property real   propDateSize:    confNum("DateSize", 22)
  property real   propDateSpacing: confNum("DateSpacing", 12)
  property bool   propShadow:      confBool("ClockShadow", "true")

  // Colon in its own colour (StyledText) when ClockColonColor is set
  function formatClock(d) {
    const t = Qt.formatTime(d, propTimeFormat)
    return propColonColor === "" ? t : t.split(":").join("<font color=\"" + propColonColor + "\">:</font>")
  }

  spacing: confNum("ClockDateGap", 15) * propScale

  Text {
    id: idClockTime
    text: formatClock(new Date())
    textFormat: propColonColor === "" ? Text.PlainText : Text.StyledText

    // Position
    anchors {
      horizontalCenter: parent.horizontalCenter
    }

    // Modification
    font {
      family: propClockFont
      pixelSize: propClockSize * propScale
      weight: propClockWeight
    }
    color: propTextColor
    style: propShadow ? Text.Outline : Text.Normal
    styleColor: "#000000"

    // Effect
    layer {
      enabled: propShadow
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
      onTriggered: idClockTime.text = formatClock(new Date())
    }
  }

  Text {
    id: idClockDateText
    text: Qt.formatDate(new Date(), propDateFormat).toUpperCase()

    // Position: letterSpacing also pads after the last letter, so shift right by half of it
    // to centre the visible text under the clock
    anchors {
      horizontalCenter: parent.horizontalCenter
      horizontalCenterOffset: propDateSpacing * propScale / 2
    }

    // Modification
    font {
      family: propDateFont
      pixelSize: propDateSize  * propScale
      letterSpacing: propDateSpacing  * propScale
      weight: Font.Normal
    }
    color: propDateColor
    style: propShadow ? Text.Outline : Text.Normal
    styleColor: "#000000"

    // Effect: small, crisp shadow so it reads over the background without a heavy glow
    layer {
      enabled: propShadow
      effect: DropShadow {
        color: "#b3000000"
        radius: 6  * propScale
        samples: 13
        spread: 0.2
        verticalOffset: 2  * propScale
        transparentBorder: true
      }
    }
  }
}
