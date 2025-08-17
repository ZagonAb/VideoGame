import QtQuick 2.15
import QtGraphicalEffects 1.12
import QtMultimedia 5.15

Item {
    id: videoContent

    property var game: null
    property string fontFamily: ""
    property bool videoEnded: false
    property alias videoSource: gameVideo.source

    signal videoFinished()
    signal videoError()

    function getFallbackImage(originalSource, fallbackSource) {
        return originalSource && originalSource !== "" ? originalSource : fallbackSource;
    }

    function resetVideo() {
        videoEnded = false;
        boxFrontImage.source = "";
        gameVideo.resetVideo();
        updateDisplayLogic();
    }

    function updateDisplayLogic() {
        if (!game) {
            return;
        }

        const hasVideo = game.assets && game.assets.video && game.assets.video !== "";
        const hasBoxFront = game.assets && game.assets.boxFront && game.assets.boxFront !== "";

        if (hasVideo) {
            gameVideo.source = game.assets.video;
            videoEnded = false;
        } else if (hasBoxFront) {
            boxFrontImage.source = game.assets.boxFront;
            videoEnded = true;
            gameDetails.startFadeIn();
        } else {
            boxFrontImage.source = "assets/no-image/default.png";
            videoEnded = true;
            gameDetails.startFadeIn();
        }
    }

    onGameChanged: {
        updateDisplayLogic();
    }

    FastBlur {
        anchors.fill: parent
        source: boxFrontImage
        radius: 30
        cached: true
        transparentBorder: true
    }

    FastBlur {
        anchors.fill: parent
        source: gameVideo
        cached: true
        radius: 60
        transparentBorder: true
    }

    VideoPlayer {
        id: gameVideo
        width: parent.width * 0.90
        height: parent.height * 0.9
        anchors.centerIn: parent
        source: ""
        videoEnded: videoContent.videoEnded

        onVideoFinished: {
            const hasBoxFront = game && game.assets && game.assets.boxFront && game.assets.boxFront !== "";
            boxFrontImage.source = hasBoxFront ? game.assets.boxFront : "assets/no-image/default.png";
            videoContent.videoEnded = true;
            gameDetails.startFadeIn();
            videoContent.videoFinished();
        }

        onVideoError: {
            const hasBoxFront = game && game.assets && game.assets.boxFront && game.assets.boxFront !== "";
            boxFrontImage.source = hasBoxFront ? game.assets.boxFront : "assets/no-image/default.png";
            videoContent.videoEnded = true;
            gameDetails.startFadeIn();
            videoContent.videoError();
        }
    }

    Image {
        id: boxFrontImage
        width: gameVideo.width
        height: gameVideo.height
        anchors.centerIn: parent
        source: ""
        fillMode: Image.PreserveAspectFit
        visible: videoContent.videoEnded

        onStatusChanged: {
            if (status === Image.Error) {
                source = "assets/no-image/default.png";
            }
        }
    }

    Item {
        id: gameDetails
        width: parent.width * 0.4
        height: parent.height * 0.15
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.05
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.05
        visible: videoContent.videoEnded

        property real fadeOpacity: 1.0
        opacity: fadeOpacity

        function displayRating(rating) {
            const fullStars = Math.floor(rating * 10);
            const hasHalfStar = (rating * 10) % 2 !== 0;

            let ratingDisplay = "";
            for (let i = 0; i < fullStars; i++) {
                ratingDisplay += "assets/icons/star1.png ";
            }
            if (hasHalfStar) {
                ratingDisplay += "assets/icons/star05.png ";
            }
            for (let i = 0; i < 10 - fullStars - (hasHalfStar ? 1 : 0); i++) {
                ratingDisplay += "assets/icons/star0.png ";
            }

            return ratingDisplay.trim();
        }

        function formatGameGenre(genre) {
            if (!genre || genre.trim() === "") {
                return "Unknown genre"
            }

            const maxLength = 40
            if (genre.length <= maxLength) {
                return genre
            } else {
                return genre.substring(0, maxLength - 3) + "..."
            }
        }

        function startFadeIn() {
            fadeInAnimation.start();
        }

        NumberAnimation {
            id: fadeInAnimation
            target: gameDetails
            property: "fadeOpacity"
            from: 0
            to: 1
            duration: 800
            easing.type: Easing.InOutQuad
        }

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 2

                Repeater {
                    model: game ? gameDetails.displayRating(game.rating).split(" ") : []
                    Image {
                        source: modelData
                        width: gameDetails.width * 0.08
                        height: width
                        mipmap: true

                        onStatusChanged: {
                            if (status === Image.Error) {
                                source = "assets/icons/star0.png";
                            }
                        }
                    }
                }
            }

            Text {
                text: game ? gameDetails.formatGameGenre(game.genre) : ""
                color: "white"
                font.family: videoContent.fontFamily
                font.pixelSize: videoContent.parent.width * 0.020
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                elide: Text.ElideMiddle

                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 20
                    samples: 50
                    color: "black"
                    horizontalOffset: 5
                    verticalOffset: 0
                    spread: 0.35
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    if (game) {
                        return (game.developer + ", " + game.releaseYear).toUpperCase()
                    }
                    return ""
                }
                color: "#cccccc"
                font.family: videoContent.fontFamily
                font.pixelSize: videoContent.parent.width * 0.018

                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 20
                    samples: 50
                    color: "black"
                    horizontalOffset: 5
                    verticalOffset: 0
                    spread: 0.35
                }
            }
        }
    }

    Item {
        id: itemNoGames
        anchors.fill: parent
        visible: !game || gameVideo.status === MediaPlayer.Loading

        Column {
            anchors.centerIn: parent
            spacing: 20

            Image {
                id: loadingSpinner
                source: "assets/icons/spinner.svg"
                width: videoContent.parent.width * 0.08
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                visible: game && gameVideo.status === MediaPlayer.Loading
                mipmap: true

                RotationAnimation {
                    target: loadingSpinner
                    property: "rotation"
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: loadingSpinner.visible
                }

                onStatusChanged: {
                    if (status === Image.Error) {
                        loadingText.visible = true;
                        loadingSpinner.visible = false;
                    }
                }
            }

            Text {
                id: loadingText
                text: "Loading..."
                color: "#ffffff"
                font.pixelSize: videoContent.parent.width * 0.04
                font.family: videoContent.fontFamily
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                visible: false

                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 10
                    samples: 10
                    color: "white"
                    horizontalOffset: -2
                    verticalOffset: - 2
                    spread: 0.10
                }
            }
        }
    }
}
