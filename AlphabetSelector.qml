import QtQuick 2.15

Rectangle {
    id: alphabetSelector

    property alias currentIndex: alphabetList.currentIndex
    property alias model: alphabetList.model
    property string fontFamily: ""
    property var gameModel: null

    signal letterSelected(string letter, int index)

    width: 50
    height: parent.height * 0.95
    color: "#000000"

    function countGamesForLetter(letter) {
        if (!gameModel || letter === "All") return 1;

        var count = 0;
        for (var i = 0; i < gameModel.count; i++) {
            var game = gameModel.get(i);
            if (game && game.title) {
                var firstLetter = game.title.charAt(0).toUpperCase();
                if (firstLetter === letter) {
                    count++;
                }
            }
        }
        return count;
    }

    function isLetterAvailable(letter) {
        return countGamesForLetter(letter) > 0;
    }

    function findNextAvailableLetter(startIndex) {
        var letters = alphabetList.model;
        for (var i = startIndex + 1; i < letters.length; i++) {
            if (isLetterAvailable(letters[i])) {
                return i;
            }
        }
        return startIndex;
    }

    function findPreviousAvailableLetter(startIndex) {
        var letters = alphabetList.model;
        for (var i = startIndex - 1; i >= 0; i--) {
            if (isLetterAvailable(letters[i])) {
                return i;
            }
        }
        return startIndex;
    }

    function navigateToNextAvailable() {
        var nextIndex = findNextAvailableLetter(alphabetList.currentIndex);
        if (nextIndex !== alphabetList.currentIndex) {
            alphabetList.currentIndex = nextIndex;
            var letter = alphabetList.model[nextIndex];
            alphabetSelector.letterSelected(letter, nextIndex);
        }
    }

    function navigateToPreviousAvailable() {
        var prevIndex = findPreviousAvailableLetter(alphabetList.currentIndex);
        if (prevIndex !== alphabetList.currentIndex) {
            alphabetList.currentIndex = prevIndex;
            var letter = alphabetList.model[prevIndex];
            alphabetSelector.letterSelected(letter, prevIndex);
        }
    }

    function updateAvailableLetters() {
        alphabetList.model = alphabetList.model;
    }

    ListView {
        id: alphabetList
        anchors.fill: parent
        model: ["All", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
        currentIndex: 0

        delegate: Rectangle {
            property bool letterAvailable: alphabetSelector.isLetterAvailable(modelData)
            property bool isSelected: alphabetList.currentIndex === index

            width: alphabetSelector.width
            height: alphabetSelector.parent.height * 0.035
            color: isSelected ? "#ffffff" : "transparent"
            radius: 3
            opacity: letterAvailable ? 1.0 : 0.3

            Text {
                anchors.centerIn: parent
                text: modelData
                color: {
                    if (!letterAvailable) return "#666666";
                    return isSelected ? "#000000" : "#ffffff";
                }
                font.family: alphabetSelector.fontFamily
                font.pixelSize: alphabetSelector.parent.width * 0.016
                font.bold: isSelected && letterAvailable
            }

            Rectangle {
                visible: !letterAvailable && !isSelected
                anchors.right: parent.right
                anchors.rightMargin: 3
                anchors.verticalCenter: parent.verticalCenter
                width: 8
                height: 8
                color: "#444444"
                radius: 2
            }

            MouseArea {
                anchors.fill: parent
                enabled: letterAvailable

                onClicked: {
                    if (letterAvailable) {
                        alphabetList.currentIndex = index;
                        alphabetSelector.letterSelected(modelData, index);
                    }
                }
                cursorShape: letterAvailable ? Qt.PointingHandCursor : Qt.ForbiddenCursor
            }
        }
    }

    function setCurrentIndex(index) {
        var letters = alphabetList.model;
        if (index >= 0 && index < letters.length) {
            var letter = letters[index];
            if (isLetterAvailable(letter)) {
                alphabetList.currentIndex = index;
            } else {
                var nextIndex = findNextAvailableLetter(index - 1);
                if (nextIndex === index - 1) {
                    nextIndex = findPreviousAvailableLetter(index + 1);
                }
                alphabetList.currentIndex = nextIndex;
            }
        }
    }

    Connections {
        target: gameModel
        function onCountChanged() {
            alphabetSelector.updateAvailableLetters();
        }
    }
}
