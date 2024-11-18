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

    Rectangle {
        width: parent.width
        height: parent.height
        color: "#000000"

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
                delegate: Rectangle {
                    width: alphabetSelector.width
                    height: root.height * 0.035
                    color: currentFilter === modelData ? "#ffffff" : "transparent"
                    radius: 3

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: currentFilter === modelData ? "#000000" : "#ffffff"
                        font.pixelSize: root.width * 0.010
                        font.bold: currentFilter === modelData
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentFilter = modelData;
                            filteredGames.updateFilter();
                        }
                    }
                }
            }
        }

        ListView {
            id: gameListView
            width: parent.width / 3 - alphabetSelector.width
            height: parent.height
            anchors.left: alphabetSelector.right
            model: filteredGames
            clip: true
            currentIndex: 0
            delegate: Rectangle {
                width: gameListView.width
                height: 70
                color: gameListView.currentIndex === index ? "#ffffff" : "#000000"
                radius: 5

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    spacing: 5

                    Text {
                        text: model.title
                        color: gameListView.currentIndex === index ? "#000000" : "#ffffff"
                        font.bold: gameListView.currentIndex === index
                        elide: Text.ElideRight
                        width: gameListView.width - 20
                    }

                    Text {
                        text: root.findCollectionForGame(model)
                        color: gameListView.currentIndex === index ? "#000000" : "#aaaaaa"
                        font.pixelSize: 12
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
                }
            }

            focus: true
            onCurrentIndexChanged: {
                game = gameListView.model.get(currentIndex);
                gameVideo.source = game.assets.video;
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

            Keys.onReturnPressed: {
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
                        if (!collectionFound) {
                            console.log("No se encontró el juego en ninguna colección");
                        }
                    } else {
                        console.log("No se pudo obtener el juego del modelo filtrado");
                    }
                } else {
                    console.log("No hay juegos para lanzar");
                }
            }
        }

        Item {
            id: videoContend
            width: parent.width * 2 / 3
            height: parent.height
            anchors.right: parent.right

            GaussianBlur {
                anchors.fill: parent
                source: gameVideo
                radius: 150
                samples: 125
            }

            GaussianBlur {
                anchors.fill: parent
                source: boxFrontImage
                radius: 150
                samples: 125
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
                        boxFrontImage.source = game.assets.boxFront;
                        videoEnded = true;
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
            }
        }
    }
}
