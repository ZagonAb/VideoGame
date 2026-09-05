import QtQuick 2.15
import QtGraphicalEffects 1.12

ListView {
    id: gameListView

    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property var gameCollectionFinder: null
    property int titleCollectionSpacing: 10
    property int delegateRadius: 5
    property var soundEffectUp: null
    property var soundEffectDown: null
    property bool subFilterEnabled: true
    property bool scrubActive: false
    property var scrubGroups: []
    property int scrubIndex: 0

    signal gameSelected(int index)
    signal gameLaunched(int index)
    signal gameChanged(var game)

    clip: true
    currentIndex: 0
    focus: true

    highlightFollowsCurrentItem: true
    highlightMoveVelocity: -1

    delegate: Rectangle {
        width: gameListView.width - 10
        height: gameListView.height * 0.1
        color: gameListView.currentIndex === index
            ? (gameListView.palette ? gameListView.palette.accent : "#ffffff")
            : (gameListView.palette ? gameListView.palette.surface : "#000000")
        radius: gameListView.delegateRadius

        Column {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: 10
            spacing: gameListView.titleCollectionSpacing

            Text {
                text: model.title
                color: gameListView.currentIndex === index
                    ? (gameListView.palette ? gameListView.palette.accentText : "#000000")
                    : (gameListView.palette ? gameListView.palette.textPrimary : "#ffffff")
                font.family: gameListView.fontFamily
                font.pixelSize: gameListView.parent.width * 0.018 * gameListView.fontScale
                font.bold: gameListView.currentIndex === index
                elide: Text.ElideRight
                width: gameListView.width - 20
            }

            Text {
                text: gameListView.gameCollectionFinder ? gameListView.gameCollectionFinder(model) : "Unknown Collection"
                color: gameListView.currentIndex === index
                    ? (gameListView.palette ? gameListView.palette.accentText : "#000000")
                    : (gameListView.palette ? gameListView.palette.textSecondary : "#aaaaaa")
                font.family: gameListView.fontFamily
                font.pixelSize: gameListView.parent.width * 0.015 * gameListView.fontScale
                elide: Text.ElideRight
                width: gameListView.width - 20
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                gameListView.currentIndex = index;
                gameListView.gameSelected(index);
                gameListView.positionViewAtIndex(index, ListView.Contain);
            }
            onDoubleClicked: {
                gameListView.gameLaunched(index);
            }
        }
    }

    onCurrentIndexChanged: {
        if (scrubActive) return;
        if (model && model.get && currentIndex >= 0 && currentIndex < count) {
            var game = model.get(currentIndex);
            gameListView.gameChanged(game);
        }
    }

    Keys.onUpPressed: function(event) {
        if (scrubActive) {
            event.accepted = true;
            return;
        }
        if (!event.isAutoRepeat) {
            scrubHoldTimer.direction = -1;
            scrubHoldTimer.restart();
        }
        if (currentIndex > 0) {
            if (soundEffectUp) soundEffectUp.play();
            currentIndex--;
            positionViewAtIndex(currentIndex, ListView.Contain);
        }
    }

    Keys.onDownPressed: function(event) {
        if (scrubActive) {
            event.accepted = true;
            return;
        }
        if (!event.isAutoRepeat) {
            scrubHoldTimer.direction = 1;
            scrubHoldTimer.restart();
        }
        if (currentIndex < count - 1) {
            if (soundEffectDown) soundEffectDown.play();
            currentIndex++;
            positionViewAtIndex(currentIndex, ListView.Contain);
        }
    }

    Keys.onReleased: function(event) {
        if (event.isAutoRepeat) return;
        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down) {
            scrubHoldTimer.stop();
            if (scrubActive) {
                event.accepted = true;
                endScrub();
            }
        }
    }

    function scrollToCurrent() {
        if (count > 0 && currentIndex >= 0 && currentIndex < count) {
            positionViewAtIndex(currentIndex, ListView.Center);
        }
    }

    function computeScrubGroups() {
        var seen = {};
        var groups = [];
        if (model && model.get) {
            for (var i = 0; i < count; i++) {
                var g = model.get(i);
                if (g && g.title && g.title.length > 1) {
                    var ch = g.title.charAt(1).toUpperCase();
                    if (!seen[ch]) {
                        seen[ch] = true;
                        groups.push(ch);
                    }
                }
            }
        }
        return groups;
    }

    function firstIndexForGroup(ch) {
        if (!model || !model.get) return -1;
        for (var i = 0; i < count; i++) {
            var g = model.get(i);
            if (g && g.title && g.title.length > 1 && g.title.charAt(1).toUpperCase() === ch) {
                return i;
            }
        }
        return -1;
    }

    function landOnGroup(gIdx) {
        scrubIndex = gIdx;
        var idx = firstIndexForGroup(scrubGroups[gIdx]);
        if (idx >= 0) {
            currentIndex = idx;
            positionViewAtIndex(idx, ListView.Center);
        }
    }

    function startScrub(direction) {
        if (!subFilterEnabled) return;
        if (count <= 0) return;
        scrubGroups = computeScrubGroups();
        if (scrubGroups.length === 0) return;
        scrubActive = true;
        var currentTitle = (model && model.get && currentIndex >= 0 && currentIndex < count)
            ? model.get(currentIndex).title : "";
        var guess = (currentTitle && currentTitle.length > 1)
            ? scrubGroups.indexOf(currentTitle.charAt(1).toUpperCase()) : -1;
        if (guess < 0) guess = 0;

        landOnGroup(guess);
        showScrubIndicator();

        scrubStepTimer.stepDirection = direction;
        scrubStepTimer.restart();
    }

    function stepScrub(direction) {
        if (!scrubActive || scrubGroups.length === 0) return;
        var next = (scrubIndex + direction + scrubGroups.length) % scrubGroups.length;
        landOnGroup(next);
        if (direction > 0 && soundEffectDown) soundEffectDown.play();
        else if (direction < 0 && soundEffectUp) soundEffectUp.play();
    }

    function endScrub() {
        if (!scrubActive) return;
        scrubActive = false;
        scrubStepTimer.stop();
        hideScrubIndicator();
        if (model && model.get && currentIndex >= 0 && currentIndex < count) {
            gameChanged(model.get(currentIndex));
        }
    }

    Timer {
        id: scrubHoldTimer
        interval: 1500
        repeat: false
        property int direction: 0
        onTriggered: gameListView.startScrub(direction)
    }

    Timer {
        id: scrubStepTimer
        interval: 280
        repeat: true
        property int stepDirection: 1
        onTriggered: gameListView.stepScrub(stepDirection)
    }

    function showScrubIndicator() {}
    function hideScrubIndicator() {}
}
