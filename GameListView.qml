import QtQuick 2.15
import QtGraphicalEffects 1.12

ListView {
    id: gameListView

    property string fontFamily: ""
    property var gameCollectionFinder: null

    signal gameSelected(int index)
    signal gameLaunched(int index)
    signal gameChanged(var game)

    clip: true
    currentIndex: 0
    focus: true

    delegate: Rectangle {
        width: gameListView.width - 10
        height: gameListView.height * 0.1
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
                font.family: gameListView.fontFamily
                font.pixelSize: gameListView.parent.width * 0.018
                font.bold: gameListView.currentIndex === index
                elide: Text.ElideRight
                width: gameListView.width - 20
            }

            Text {
                text: gameListView.gameCollectionFinder ? gameListView.gameCollectionFinder(model) : "Unknown Collection"
                color: gameListView.currentIndex === index ? "#000000" : "#aaaaaa"
                font.family: gameListView.fontFamily
                font.pixelSize: gameListView.parent.width * 0.015
                elide: Text.ElideRight
                width: gameListView.width - 20
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                gameListView.currentIndex = index;
                gameListView.gameSelected(index);
            }
            onDoubleClicked: {
                gameListView.gameLaunched(index);
            }
        }
    }

    onCurrentIndexChanged: {
        if (model && model.get && currentIndex >= 0 && currentIndex < count) {
            var game = model.get(currentIndex);
            gameListView.gameChanged(game);
        }
    }

    Keys.onUpPressed: {
        if (currentIndex > 0) {
            currentIndex--;
        }
    }

    Keys.onDownPressed: {
        if (currentIndex < count - 1) {
            currentIndex++;
        }
    }
}
