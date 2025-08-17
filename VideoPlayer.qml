import QtQuick 2.15
import QtMultimedia 5.15

Video {
    id: gameVideo

    property bool videoEnded: false
    property string fallbackImage: ""

    signal videoFinished()
    signal videoError()

    fillMode: VideoOutput.PreserveAspectFit
    autoPlay: true
    loops: 1
    visible: !videoEnded

    onSourceChanged: {
        if (source !== "") {
            videoEnded = false;
            gameVideo.play();
        }
    }

    onStopped: {
        if (gameVideo.position === gameVideo.duration) {
            videoEnded = true;
            gameVideo.videoFinished();
        }
    }

    onErrorChanged: {
        if (error !== MediaPlayer.NoError) {
            videoEnded = true;
            gameVideo.videoError();
        }
    }

    function resetVideo() {
        videoEnded = false;
        if (source !== "") {
            play();
        }
    }
}
