import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: gameDetailsContainer

    property var game: null
    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property real fadeOpacity: 0
    property real cardOpacity: 0.95
    property int cardRadius: vpx(5)
    property int slideDuration: 550
    property real minCardWidth: parent ? parent.width * 0.58 : 400
    property real maxCardWidth: parent ? parent.width * 0.85 : 700
    property real cardHorizontalPadding: 80

    width: Math.min(maxCardWidth, Math.max(minCardWidth, developerYearMeasure.implicitWidth + cardHorizontalPadding))

    property real slideOffset: width

    opacity: fadeOpacity
    transform: Translate { x: gameDetailsContainer.slideOffset }

    Text {
        id: developerYearMeasure
        visible: false
        font.family: gameDetailsContainer.fontFamily
        font.pixelSize: gameDetailsContainer.parent ? gameDetailsContainer.parent.width * 0.028 * gameDetailsContainer.fontScale : 14
        text: game ? (game.developer + ", " + game.releaseYear).toUpperCase() : ""
    }

    function colorWithAlpha(colorValue, alpha) {
        var c = Qt.darker(colorValue, 1.0);
        return Qt.rgba(c.r, c.g, c.b, alpha);
    }

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

    function cleanAndSplitGenres(genreText) {
        if (!genreText) return [];
        var separators = [",", "/", "-", "&", "|", ";"];
        var allParts = [genreText];
        for (var i = 0; i < separators.length; i++) {
            var separator = separators[i];
            var newParts = [];
            for (var j = 0; j < allParts.length; j++) {
                var part = allParts[j];
                var splitParts = part.split(separator);
                for (var k = 0; k < splitParts.length; k++) {
                    newParts.push(splitParts[k]);
                }
            }
            allParts = newParts;
        }
        var cleanedParts = [];
        for (var l = 0; l < allParts.length; l++) {
            var cleaned = allParts[l].trim();
            if (cleaned.length > 0 &&
                cleaned.toLowerCase() !== "and" &&
                cleaned.toLowerCase() !== "or" &&
                cleaned.toLowerCase() !== "game" &&
                cleaned.length > 2) {
                cleanedParts.push(cleaned);
            }
        }
        return cleanedParts;
    }

    function getFirstGenre(gameData) {
        if (!gameData || !gameData.genre) return "Unknown";
        var cleanedGenres = cleanAndSplitGenres(gameData.genre);
        return cleanedGenres.length > 0 ? cleanedGenres[0] : "Unknown";
    }

    function getUniqueGenresFromGames(maxGenres) {
        var uniqueGenres = new Set();
        var genreCount = {};
        for (var i = 0; i < api.allGames.count; i++) {
            var game = api.allGames.get(i);
            if (game && game.genre) {
                var cleanedGenres = cleanAndSplitGenres(game.genre);
                cleanedGenres.forEach(function(genre) {
                    if (genre && genre.trim() !== "") {
                        var cleanGenre = genre.trim();
                        uniqueGenres.add(cleanGenre);
                        if (!genreCount[cleanGenre]) {
                            genreCount[cleanGenre] = 0;
                        }
                        genreCount[cleanGenre]++;
                    }
                });
            }
        }
        var genresArray = Array.from(uniqueGenres);
        genresArray.sort(function(a, b) {
            return (genreCount[b] || 0) - (genreCount[a] || 0);
        });
        if (maxGenres && maxGenres > 0) {
            return genresArray.slice(0, maxGenres);
        }
        return genresArray;
    }

    function formatGameGenre(genreText) {
        var cleaned = cleanAndSplitGenres(genreText);
        if (cleaned.length === 0) {
            return "Unknown genre";
        }
        return cleaned[0];
    }

    Rectangle {
        id: cardBackground
        anchors.fill: parent
        radius: gameDetailsContainer.cardRadius
        color: gameDetailsContainer.palette ? gameDetailsContainer.palette.surface : "#000000"
        opacity: gameDetailsContainer.cardOpacity
        border.width: vpx(2)
        border.color: gameDetailsContainer.palette
            ? gameDetailsContainer.colorWithAlpha(gameDetailsContainer.palette.accent, 0.35)
            : "transparent"
    }

    Column {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 4

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2

            Repeater {
                model: game ? gameDetailsContainer.displayRating(game.rating).split(" ") : []
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
            text: game ? gameDetailsContainer.formatGameGenre(game.genre) : ""
            color: gameDetailsContainer.palette ? gameDetailsContainer.palette.textPrimary : "white"
            font.family: gameDetailsContainer.fontFamily
            font.pixelSize: gameDetailsContainer.parent.width * 0.030 * gameDetailsContainer.fontScale
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideRight
            maximumLineCount: 2
        }

        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: {
                if (game) {
                    return (game.developer + ", " + game.releaseYear).toUpperCase()
                }
                return ""
            }
            color: gameDetailsContainer.palette ? gameDetailsContainer.palette.textSecondary : "#cccccc"
            font.family: gameDetailsContainer.fontFamily
            font.pixelSize: gameDetailsContainer.parent.width * 0.028 * gameDetailsContainer.fontScale
            elide: Text.ElideRight
            maximumLineCount: 2
        }
    }

    ParallelAnimation {
        id: cardAppearAnimation

        NumberAnimation {
            target: gameDetailsContainer
            property: "fadeOpacity"
            from: 0
            to: 1
            duration: gameDetailsContainer.slideDuration
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: gameDetailsContainer
            property: "slideOffset"
            from: gameDetailsContainer.width
            to: 0
            duration: gameDetailsContainer.slideDuration
            easing.type: Easing.OutCubic
        }
    }

    function startFadeIn() {
        cardAppearAnimation.stop();
        fadeOpacity = 0;
        slideOffset = gameDetailsContainer.width;
        cardAppearAnimation.start();
    }

    onGameChanged: startFadeIn()

    onVisibleChanged: {
        if (visible) {
            startFadeIn();
        }
    }

    Component.onCompleted: startFadeIn()
}
