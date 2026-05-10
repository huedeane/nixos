import QtQuick
import QtMultimedia

Item {
  id: idBackgroundComponent

  property string propSource:      Qt.resolvedUrl(config.background)
  property string propPlaceholder: Qt.resolvedUrl(config.backgroundplaceholder)  
  property bool   propCrop:        true

  // Placeholder shown while video loads
  Image {
    id: idPlaceholderImage
    anchors.fill: parent
    source: idBackgroundComponent.propPlaceholder
    fillMode: propCrop ? Image.PreserveAspectCrop : Image.PreserveAspectFit
    visible: false
  }

  MediaPlayer {
    id: idPlayer
    videoOutput: idVideoOutput
    loops: MediaPlayer.Infinite
    onPlayingChanged: idPlaceholderImage.visible = false
  }

  VideoOutput {
    id: idVideoOutput
    anchors.fill: parent
    fillMode: propCrop ? VideoOutput.PreserveAspectCrop : VideoOutput.PreserveAspectFit
  }

  Component.onCompleted: {
    var fileType = idBackgroundComponent.propSource.substring(idBackgroundComponent.propSource.lastIndexOf(".") + 1)
    const videoTypes = ["avi", "mp4", "mov", "mkv", "m4v", "webm"]
    if (videoTypes.includes(fileType)) {
      idPlaceholderImage.visible = true
      idPlayer.source = idBackgroundComponent.propSource
      idPlayer.play()
    } else {
      idPlaceholderImage.source = idBackgroundComponent.propSource
      idPlaceholderImage.visible = true
    }
  }
}
