import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: gameDetailsContainer

    property var game: null
    property string fontFamily: ""
    property real fadeOpacity: 1.0

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

    opacity: fadeOpacity

    NumberAnimation {
        id: fadeInAnimation
        target: gameDetailsContainer
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
                model: game ? displayRating(game.rating).split(" ") : []
                Image {
                    source: modelData
                    width: gameDetailsContainer.width * 0.08
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
            text: game ? formatGameGenre(game.genre) : ""
            color: "white"
            font.family: gameDetailsContainer.fontFamily
            font.pixelSize: gameDetailsContainer.parent.width * 0.020
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
            font.family: gameDetailsContainer.fontFamily
            font.pixelSize: gameDetailsContainer.parent.width * 0.018

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

    function startFadeIn() {
        fadeInAnimation.start();
    }
}
