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
            height: parent.height * 0.05 // Ajusta según la altura deseada
            anchors.top: parent.top // Asegúrate de anclarlo al borde superior del contenedor
            anchors.topMargin: 10 // Margen superior para separar del borde
            anchors.left: parent.left
            anchors.margins: 5
            anchors.leftMargin: root.width * 0.1

            Image {
                anchors.verticalCenter: parent.verticalCenter // Centra verticalmente la imagen
                source: "assets/icons/allgames.png"
                width: root.width * 0.024
                height: root.height * 0.04
                mipmap: true
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter // Centra verticalmente el texto
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
                        //font.pixelSize: 12
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
                        radius: 50
                        samples: 50
                        color: "white"
                        horizontalOffset: -2
                        verticalOffset: 5
                        spread: 0.35
                    }
                }
            }
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

            Item {
                anchors.fill: parent
                visible: filteredGames.count === 0

                Text {
                    id: noGames
                    anchors.centerIn: parent
                    text: "No games available"
                    color: "#ffffff"
                    font.pixelSize: root.width * 0.02
                    font.family: fontLoader.name
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    layer.enabled: true
                    layer.effect: DropShadow {
                        radius: 50
                        samples: 50
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
