import QtQuick 2.15
import QtQuick.Layouts 1.15
import SortFilterProxyModel 0.2
import QtMultimedia 5.15

FocusScope {
    id: root
    focus: true
    property var game: null
    property string currentFilter: "All"
    property bool videoEnded: false
    width: parent.width
    height: parent.height

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

    function launchGame(gameIndex) {
        if (filteredGames.count > 0) {
            const filteredGame = filteredGames.get(gameIndex);
            if (filteredGame) {
                let collectionFound = false;
                for (let i = 0; i < api.collections.count; i++) {
                    const collection = api.collections.get(i);
                    for (let j = 0; j < collection.games.count; j++) {
                        const game = collection.games.get(j);
                        if (game.title === filteredGame.title &&
                            game.assets.video === filteredGame.assets.video &&
                            game.assets.boxFront === filteredGame.assets.boxFront) {
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
            gameList.currentIndex = 0;
            game = gameList.model.get(0);
            videoContent.videoSource = game.assets.video;
            videoContent.resetVideo();
            videoEnded = false;
        } else {
            game = null;
            videoContent.videoSource = "";
            videoEnded = false;
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

        AlphabetSelector {
            id: alphabetSelector
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            fontFamily: fontLoader.name
            gameModel: api.allGames

            onLetterSelected: function(letter, index) {
                currentFilter = letter;
                filteredGames.updateFilter();
            }

            Connections {
                target: api.allGames
                function onCountChanged() {
                    alphabetSelector.updateAvailableLetters();
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

        GameListView {
            id: gameList
            width: parent.width / 3 - alphabetSelector.width
            height: parent.height * 0.85
            anchors.left: alphabetSelector.right
            anchors.verticalCenter: parent.verticalCenter
            model: filteredGames
            fontFamily: fontLoader.name
            gameCollectionFinder: root.findCollectionForGame

            onGameSelected: function(index) {
                videoEnded = false;
                videoContent.resetVideo();
            }

            onGameLaunched: function(index) {
                root.launchGame(index);
            }

            onGameChanged: function(selectedGame) {
                game = selectedGame;
                videoContent.videoSource = game.assets.video;
                videoContent.resetVideo();
                videoEnded = false;
            }

            Keys.onPressed: function(event) {
                if (!event.isAutoRepeat) {
                    if (api.keys.isAccept(event)) {
                        root.launchGame(currentIndex);
                        event.accepted = true;
                    }
                    else if (api.keys.isNextPage(event)) {
                        alphabetSelector.navigateToNextAvailable();
                        event.accepted = true;
                    }
                    else if (api.keys.isPrevPage(event)) {
                        alphabetSelector.navigateToPreviousAvailable();
                        event.accepted = true;
                    }
                }
            }

            Component.onCompleted: {
                root.updateSelectedGame();
                gameList.forceActiveFocus();
            }
        }

        ControlHints {
            id: controlHints
            width: gameList.width
            height: parent.height * 0.05
            anchors.left: alphabetSelector.right
            anchors.top: gameList.bottom
            anchors.topMargin: 10
            fontFamily: fontLoader.name
        }

        VideoContent {
            id: videoContent
            width: parent.width * 2 / 3
            height: parent.height
            anchors.right: parent.right
            game: root.game
            fontFamily: fontLoader.name
            videoEnded: root.videoEnded

            onVideoFinished: {
                root.videoEnded = true;
            }

            onVideoError: {
                root.videoEnded = true;
            }
        }
    }
}
