import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import SortFilterProxyModel 0.2
import QtMultimedia 5.15
import QtQuick.Window 2.15

FocusScope {
    id: root
    focus: true
    property var game: null
    property string currentFilter: "All"
    property bool videoEnded: false
    width: parent.width
    height: parent.height

    function getFallbackImage(originalSource, fallbackSource) {
        return originalSource && originalSource !== "" ? originalSource : fallbackSource;
    }

    function findCollectionForGame(gameObject) {
        for (var i = 0; i < api.collections.count; i++) {
            var collection = api.collections.get(i);
            for (var j = 0; j < collection.games.count; j++) {
                var game = collection.games.get(j);
                if (game.title === gameObject.title &&
                    game.assets.video === gameObject.assets.video &&
                    game.assets.boxFront === gameObject.assets.boxFront) {
                    return collection.name;
                    }
            }
        }
        return "Unknown Collection";
    }

    SortFilterProxyModel {
        id: filteredGames
        sourceModel: api.allGames
        sorters: RoleSorter { roleName: "title" }
        filterRoleName: "title"
        filterRegExp: /^.*/

        function updateFilter() {
            if (currentFilter === "All") {
                filterRegExp = /^.*/;
            } else {
                filterRegExp = new RegExp("^" + currentFilter, "i");
            }
            root.updateSelectedGame();
        }
    }

    function updateSelectedGame() {
        if (filteredGames.count > 0) {
            gameListView.currentIndex = 0;
            game = gameListView.model.get(0);
            gameVideo.source = game.assets.video;
            boxFrontImage.source = "";
            videoEnded = false;
        } else {
            game = null;
            gameVideo.source = "";
            boxFrontImage.source = "";
            videoEnded = false;
        }
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

    FontLoader {
        id: fontLoader
        source: "assets/font/BebasNeue-Regular.ttf"
    }

    Rectangle {
        id: container
        width: parent.width
        height: parent.height
        color: "transparent"

        Rectangle {
            id: alphabetSelector
            width: 50
            height: parent.height * 0.95
            color: "#000000"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter

            ListView {
                id: alphabetList
                anchors.fill: parent
                model: ["All", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
                "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
                currentIndex: 0
                delegate: Rectangle {
                    width: alphabetSelector.width
                    height: root.height * 0.035
                    color: alphabetList.currentIndex === index ? "#ffffff" : "transparent"
                    radius: 3

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: alphabetList.currentIndex === index ? "#000000" : "#ffffff"
                        font.family: fontLoader.name
                        font.pixelSize: root.width * 0.012
                        font.bold: alphabetList.currentIndex === index
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            alphabetList.currentIndex = index;
                            currentFilter = modelData;
                            filteredGames.updateFilter();
                        }
                    }
                }
            }
        }

        Row {
            id: headerRow
            width: parent.width
            height: parent.height * 0.05
            anchors.top: parent.top
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.margins: 5
            anchors.leftMargin: root.width * 0.1

            Image {
                anchors.verticalCenter: parent.verticalCenter
                source: "assets/icons/allgames.png"
                width: root.width * 0.024
                height: root.height * 0.04
                mipmap: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "All Games"
                font.family: fontLoader.name
                font.pixelSize: root.width * 0.020
                color: "white"
            }
        }

        ListView {
            id: gameListView
            width: parent.width / 3 - alphabetSelector.width
            height: parent.height * 0.85
            anchors.left: alphabetSelector.right
            anchors.verticalCenter: parent.verticalCenter
            model: filteredGames
            clip: true
            currentIndex: 0

            delegate: Rectangle {
                width: gameListView.width -10
                height: 70
                color: gameListView.currentIndex === index ? "#ffffff" : "#000000"
                radius: 5

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 1

                    Text {
                        text: model.title
                        color: gameListView.currentIndex === index ? "#000000" : "#ffffff"
                        font.family: fontLoader.name
                        font.pixelSize: root.width * 0.014
                        font.bold: gameListView.currentIndex === index
                        elide: Text.ElideRight
                        width: gameListView.width - 20
                    }

                    Text {
                        text: root.findCollectionForGame(model)
                        color: gameListView.currentIndex === index ? "#000000" : "#aaaaaa"
                        font.family: fontLoader.name
                        font.pixelSize: root.width * 0.011
                        elide: Text.ElideRight
                        width: gameListView.width - 20
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        gameListView.currentIndex = index;
                        videoEnded = false;
                    }
                    onDoubleClicked: {
                        if (filteredGames.count > 0) {
                            const filteredGame = filteredGames.get(index);
                            if (filteredGame) {
                                let collectionFound = false;
                                for (let i = 0; i < api.collections.count; i++) {
                                    const collection = api.collections.get(i);
                                    for (let j = 0; j < collection.games.count; j++) {
                                        const game = collection.games.get(j);
                                        if (game.title === filteredGame.title &&
                                            game.assets.video === filteredGame.assets.video &&
                                            game.assets.boxFront === filteredGame.assets.boxFront) {
                                            //console.log("Colección actual:", collection.name);
                                        //console.log("Lanzando juego:", game.title);
                                        game.launch();
                                        collectionFound = true;
                                        break;
                                            }
                                    }
                                    if (collectionFound) break;
                                }
                            }
                        }
                    }
                }
            }

            focus: true

            Item {
                anchors.fill: parent
                visible: filteredGames.count === 0

                Text {
                    anchors.centerIn: parent
                    text: "No games available"
                    color: "#ffffff"
                    font.family: fontLoader.name
                    font.pixelSize: root.width * 0.02
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 30
                        samples: 30
                        color: "white"
                        horizontalOffset: -2
                        verticalOffset: 5
                        spread: 0.35
                    }
                }
            }

            onCurrentIndexChanged: {
                game = gameListView.model.get(currentIndex);
                gameVideo.source = game.assets.video
                boxFrontImage.source = "";
                videoEnded = false;
            }

            Component.onCompleted: {
                root.updateSelectedGame();
                gameListView.forceActiveFocus();
            }

            Keys.onUpPressed: if (currentIndex > 0) {
                currentIndex--;
                videoEnded = false;
                game = gameListView.model.get(currentIndex);
                gameVideo.source = game.assets.video;
                boxFrontImage.source = "";
            }
            Keys.onDownPressed: if (currentIndex < count - 1) {
                currentIndex++;
                videoEnded = false;
                game = gameListView.model.get(currentIndex);
                gameVideo.source = game.assets.video;
                boxFrontImage.source = "";
            }
            Keys.onPressed: (event) => {
                if (!event.isAutoRepeat) {
                    if (api.keys.isAccept(event)) {
                        if (filteredGames.count > 0) {
                            const filteredGame = filteredGames.get(gameListView.currentIndex);
                            if (filteredGame) {
                                let collectionFound = false;
                                for (let i = 0; i < api.collections.count; i++) {
                                    const collection = api.collections.get(i);
                                    for (let j = 0; j < collection.games.count; j++) {
                                        const game = collection.games.get(j);
                                        if (game.title === filteredGame.title &&
                                            game.assets.video === filteredGame.assets.video &&
                                            game.assets.boxFront === filteredGame.assets.boxFront) {
                                            console.log("Colección actual:", collection.name);
                                        console.log("Lanzando juego:", game.title);
                                        game.launch();
                                        collectionFound = true;
                                        break;
                                            }
                                    }
                                    if (collectionFound) break;
                                }
                            }
                        }
                        event.accepted = true;
                    }
                    else if (api.keys.isNextPage(event)) {
                        if (alphabetList.currentIndex < alphabetList.count - 1) {
                            alphabetList.currentIndex++;
                            currentFilter = alphabetList.model[alphabetList.currentIndex];
                            filteredGames.updateFilter();
                        }
                        event.accepted = true;
                    }
                    else if (api.keys.isPrevPage(event)) {
                        if (alphabetList.currentIndex > 0) {
                            alphabetList.currentIndex--;
                            currentFilter = alphabetList.model[alphabetList.currentIndex];
                            filteredGames.updateFilter();
                        }
                        event.accepted = true;
                    }
                }
            }
        }

        Row {
            id: filterRow
            width: gameListView.width
            height: parent.height * 0.05
            anchors.left: alphabetSelector.right
            anchors.top: gameListView.bottom
            anchors.topMargin: 10
            spacing: 15

            Row {
                spacing: 3

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: "assets/icons/lb.png"
                    width: root.width * 0.024
                    height: root.height * 0.04
                    mipmap: true
                }

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: "assets/icons/rb.png"
                    width: root.width * 0.024
                    height: root.height * 0.04
                    mipmap: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "FILTER BY LETTER"
                    font.family: fontLoader.name
                    font.pixelSize: root.width * 0.015
                    color: "white"
                }
            }

            Row{
                spacing: 3

                Image {
                    anchors.verticalCenter: parent.verticalCenter
                    source: "assets/icons/a.png"
                    width: root.width * 0.024
                    height: root.height * 0.044
                    mipmap: true
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "LAUNCH"
                    font.family: fontLoader.name
                    font.pixelSize: root.width * 0.015
                    color: "white"
                }
            }
        }

        Item {
            id: videoContend
            width: parent.width * 2 / 3
            height: parent.height
            anchors.right: parent.right

            FastBlur {
                anchors.fill: parent
                source: boxFrontImage
                radius: 30
                cached: true
                transparentBorder : true
            }

            FastBlur {
                anchors.fill: parent
                source: gameVideo
                cached: true
                radius: 60
                transparentBorder : true
            }

            Video {
                id: gameVideo
                width: parent.width * 0.90
                height: parent.height * 0.9
                anchors.centerIn: parent
                source: ""
                fillMode: VideoOutput.PreserveAspectFit
                autoPlay: true
                loops: 1
                visible: !videoEnded

                onSourceChanged: {
                    if (source !== "") {
                        gameVideo.play();
                    }
                }

                onStopped: {
                    if (gameVideo.position === gameVideo.duration) {
                        boxFrontImage.source = getFallbackImage(game.assets.boxFront, "assets/no-image/default.png");
                        videoEnded = true;
                        fadeInAnimation.start();
                    }
                }

                onErrorChanged: {
                    if (error !== MediaPlayer.NoError) {
                        boxFrontImage.source = getFallbackImage(game.assets.boxFront, "assets/no-image/default.png");
                        videoEnded = true;
                        fadeInAnimation.start();
                    }
                }
            }

            Image {
                id: boxFrontImage
                width: gameVideo.width
                height: gameVideo.height
                anchors.centerIn: parent
                source: ""
                fillMode: Image.PreserveAspectFit
                visible: videoEnded

                onStatusChanged: {
                    if (status === Image.Error) {
                        source = "assets/no-image/default.png";
                    }
                }
            }

            Item {
                id: gameDetailsContainer
                width: parent.width * 0.4
                height: parent.height * 0.15
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height * 0.05
                anchors.right: parent.right
                anchors.rightMargin: parent.width * 0.05
                visible: videoEnded

                NumberAnimation {
                    id: fadeInAnimation
                    target: gameDetailsContainer
                    property: "opacity"
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
                            model: displayRating(game ? game.rating : 0).split(" ")
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
                        text: formatGameGenre(game.genre)
                        color: "white"
                        font.family: fontLoader.name
                        font.pixelSize: root.width * 0.020
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
                        font.family: fontLoader.name
                        font.pixelSize: root.width * 0.018

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
                visible: filteredGames.count === 0 || gameVideo.status === MediaPlayer.Loading

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        id: loadingText
                        text: filteredGames.count === 0 ? "No games available" : "Loading..."
                        color: "#ffffff"
                        font.pixelSize: root.width * 0.02
                        font.family: fontLoader.name
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter

                        layer.enabled: true
                        layer.effect: DropShadow {
                            radius: 30
                            samples: 30
                            color: "white"
                            horizontalOffset: -2
                            verticalOffset: 5
                            spread: 0.35
                        }
                    }
                }
            }
        }
    }
}
