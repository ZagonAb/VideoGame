import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtMultimedia 5.15
import QtGraphicalEffects 1.12

FocusScope {
    id: attractMode

    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property var strings: ({})
    property bool videoPlaybackEnabled: true
    property real volume: 1.0
    property var gamesModel: null

    signal exitRequested()

    readonly property var _fallbackStrings: ({
        attractBadge: "ATTRACT MODE",
        attractHint: "Press any button to browse"
    })
    function tr(key) {
        return (strings && strings[key] !== undefined) ? strings[key] : _fallbackStrings[key];
    }

    visible: opacity > 0
    opacity: 0

    property bool running: false
    property var currentGame: null
    property int lastPickedIndex: -1
    property string mediaState: "none"
    property int kenBurnsDirection: 0
    readonly property int slideIntervalMs: 11000
    readonly property int safetyTimeoutMs: 45000

    readonly property real kenBurnsPanX: (kenBurnsDirection === 0 ? -1 : kenBurnsDirection === 1 ? 1 : 0) * 36
    readonly property real kenBurnsPanY: (kenBurnsDirection === 2 ? -1 : kenBurnsDirection === 3 ? 1 : 0) * 24

    readonly property string currentVideoPath:
        (currentGame && videoPlaybackEnabled && currentGame.assets && currentGame.assets.video)
            ? currentGame.assets.video : ""

    property int artStage: 0

    readonly property string currentArtPath: {
        if (!currentGame || !currentGame.assets) return "assets/no-image/default.png";
        const a = currentGame.assets;
        if (artStage === 0 && a.background) return a.background;
        if (artStage <= 1 && a.screenshot) return a.screenshot;
        return "assets/no-image/default.png";
    }

    readonly property int currentArtFillMode:
        (artStage === 0 && currentGame && currentGame.assets && currentGame.assets.background)
            ? Image.PreserveAspectCrop : Image.PreserveAspectFit

    readonly property string currentLogoPath:
        (currentGame && currentGame.assets && currentGame.assets.logo) ? currentGame.assets.logo : ""

    function log(msg) {
        console.log("[AttractMode] " + msg);
    }

    function randomInt(maxExclusive) {
        return Math.floor(Math.random() * maxExclusive);
    }

    function hasUsableAssets(g) {
        if (!g || !g.assets) return false;
        return !!(g.assets.video || g.assets.background || g.assets.screenshot ||
                  g.assets.titlescreen || g.assets.boxFront || g.assets.logo);
    }

    function pickRandomGame() {
        if (!gamesModel || gamesModel.count <= 0) return null;
        const total = gamesModel.count;
        const attempts = Math.min(total, 25);
        for (var i = 0; i < attempts; i++) {
            const idx = randomInt(total);
            if (total > 1 && idx === lastPickedIndex) continue;
            const g = gamesModel.get(idx);
            if (hasUsableAssets(g)) {
                lastPickedIndex = idx;
                return g;
            }
        }
        lastPickedIndex = randomInt(total);
        return gamesModel.get(lastPickedIndex);
    }

    function start() {
        if (!gamesModel || gamesModel.count <= 0) {
            log("start() aborted, no games available");
            return;
        }
        log("start()");
        running = true;
        lastPickedIndex = -1;
        attractMode.forceActiveFocus();
        showAnim.restart();
        contentRoot.opacity = 0;
        assignNewGameAndFadeIn();
    }

    function stop() {
        log("stop()");
        running = false;
        slideTimer.stop();
        safetyTimer.stop();
        fadeOutAnim.stop();
        fadeInAnim.stop();
        if (videoLoader.item && videoLoader.item.videoItem) videoLoader.item.videoItem.pause();
        videoLoader.active = false;
        hideAnim.restart();
    }

    function requestExit() {
        if (!running) return;
        log("requestExit()");
        stop();
        exitRequested();
    }

    function nextSlide() {
        if (!running) return;
        log("nextSlide()");
        if (contentRoot.opacity > 0) {
            fadeOutAnim.restart();
        } else {
            assignNewGameAndFadeIn();
        }
    }

    function assignNewGameAndFadeIn() {
        currentGame = pickRandomGame();
        log("new game -> " + (currentGame ? currentGame.title : "null"));
        kenBurnsDirection = randomInt(4);
        artStage = 0;
        evaluateMedia();
        fadeInAnim.restart();
    }

    function evaluateMedia() {
        slideTimer.stop();
        safetyTimer.stop();
        if (currentVideoPath !== "") {
            mediaState = "video";
            videoLoader.active = true;
            safetyTimer.interval = safetyTimeoutMs;
            safetyTimer.restart();
        } else {
            videoLoader.active = false;
            mediaState = "image";
            artImage.scale = 1.0;
            artTranslate.x = 0;
            artTranslate.y = 0;
            kenBurnsAnim.restart();
            slideTimer.interval = slideIntervalMs;
            slideTimer.restart();
        }
    }

    Keys.onPressed: function(event) {
        event.accepted = true;
        attractMode.requestExit();
    }

    Rectangle {
        anchors.fill: parent
        color: attractMode.palette ? attractMode.palette.background : "#000000"
    }

    Item {
        id: contentRoot
        anchors.fill: parent
        opacity: 0

        Loader {
            id: videoLoader
            anchors.fill: parent
            active: false
            asynchronous: false
            visible: attractMode.mediaState === "video"

            sourceComponent: Component {
                Item {
                    id: videoWrapper
                    anchors.fill: parent
                    property alias videoItem: attractVideo

                    Item {
                        anchors.fill: parent
                        clip: true

                        ShaderEffectSource {
                            anchors.fill: parent
                            sourceItem: attractVideo
                            hideSource: false
                            scale: 7.5

                            layer.enabled: true
                            layer.effect: FastBlur {
                                radius: 60
                                transparentBorder: true
                            }
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "black"
                            opacity: 0.2
                        }
                    }

                    VideoPlayer {
                        id: attractVideo
                        width: parent.width * 0.90
                        height: parent.height * 0.90
                        anchors.centerIn: parent
                        source: attractMode.currentVideoPath
                        volume: attractMode.volume

                        onVideoFinished: attractMode.nextSlide()
                        onVideoError: attractMode.nextSlide()
                    }
                }
            }
        }

        Item {
            id: imageBranch
            anchors.fill: parent
            visible: attractMode.mediaState === "image"

            Item {
                anchors.fill: parent
                clip: true

                ShaderEffectSource {
                    id: artReflectionSource
                    anchors.fill: parent
                    sourceItem: artImage
                    hideSource: false
                    scale: 7.5
                    live: false

                    layer.enabled: true
                    layer.effect: FastBlur {
                        radius: 60
                        transparentBorder: true
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "black"
                    opacity: 0.2
                }
            }

            Image {
                id: artImage
                width: parent.width * 0.90
                height: parent.height * 0.90
                anchors.centerIn: parent
                fillMode: attractMode.currentArtFillMode
                asynchronous: true
                smooth: true
                source: attractMode.currentArtPath
                scale: 1.0
                transformOrigin: Item.Center
                transform: Translate { id: artTranslate; x: 0; y: 0 }

                onStatusChanged: {
                    if (status === Image.Error) {
                        if (attractMode.artStage < 2) attractMode.artStage++;
                    } else if (status === Image.Ready) {
                        artReflectionSource.scheduleUpdate();
                    }
                }
            }
        }

        Image {
            id: logoOverlay
            visible: attractMode.currentLogoPath !== ""
            source: attractMode.currentLogoPath
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * 0.10
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.42
            height: parent.height * 0.22
            fillMode: Image.PreserveAspectFit
            asynchronous: true

            layer.enabled: true
            layer.effect: DropShadow {
                radius: 24
                samples: 32
                color: "black"
                spread: 0.4
            }
        }

        Text {
            visible: attractMode.currentLogoPath === "" && attractMode.currentGame !== null
            text: attractMode.currentGame ? attractMode.currentGame.title : ""
            anchors.bottom: parent.bottom
            anchors.bottomMargin: parent.height * 0.10
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.7
            color: attractMode.palette ? attractMode.palette.textPrimary : "#ffffff"
            font.family: attractMode.fontFamily
            font.bold: true
            font.pixelSize: attractMode.width * 0.05 * attractMode.fontScale
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap

            layer.enabled: true
            layer.effect: DropShadow {
                radius: 24
                samples: 32
                color: "black"
                spread: 0.4
            }
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: parent.height * 0.03
        radius: 6
        color: attractMode.palette ? attractMode.palette.accent : "#ffffff"
        opacity: 0.92
        width: badgeText.implicitWidth + 24
        height: badgeText.implicitHeight + 12

        Text {
            id: badgeText
            anchors.centerIn: parent
            text: attractMode.tr("attractBadge")
            font.family: attractMode.fontFamily
            font.bold: true
            font.pixelSize: attractMode.width * 0.018 * attractMode.fontScale
            color: attractMode.palette ? attractMode.palette.accentText : "#000000"
        }
    }

    Text {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.02
        anchors.horizontalCenter: parent.horizontalCenter
        text: attractMode.tr("attractHint")
        font.family: attractMode.fontFamily
        font.pixelSize: attractMode.width * 0.02 * attractMode.fontScale
        color: attractMode.palette ? attractMode.palette.textSecondary : "#aaaaaa"
        opacity: 0.85
    }

    MouseArea {
        anchors.fill: parent
        onClicked: attractMode.requestExit()
    }

    NumberAnimation {
        id: fadeOutAnim
        target: contentRoot
        property: "opacity"
        to: 0
        duration: 260
        easing.type: Easing.InQuad
        onStopped: {
            if (attractMode.running) attractMode.assignNewGameAndFadeIn();
        }
    }

    NumberAnimation {
        id: fadeInAnim
        target: contentRoot
        property: "opacity"
        to: 1
        duration: 480
        easing.type: Easing.OutQuad
    }

    NumberAnimation {
        id: showAnim
        target: attractMode
        property: "opacity"
        to: 1
        duration: 500
        easing.type: Easing.OutQuad
    }

    NumberAnimation {
        id: hideAnim
        target: attractMode
        property: "opacity"
        to: 0
        duration: 350
        easing.type: Easing.InQuad
        onStopped: {
            attractMode.mediaState = "none";
            attractMode.currentGame = null;
        }
    }

    ParallelAnimation {
        id: kenBurnsAnim
        NumberAnimation {
            target: artImage
            property: "scale"
            from: 1.0
            to: 1.14
            duration: attractMode.slideIntervalMs + 400
            easing.type: Easing.Linear
        }
        NumberAnimation {
            target: artTranslate
            property: "x"
            from: 0
            to: attractMode.kenBurnsPanX
            duration: attractMode.slideIntervalMs + 400
            easing.type: Easing.Linear
        }
        NumberAnimation {
            target: artTranslate
            property: "y"
            from: 0
            to: attractMode.kenBurnsPanY
            duration: attractMode.slideIntervalMs + 400
            easing.type: Easing.Linear
        }
    }

    Timer {
        id: slideTimer
        repeat: false
        onTriggered: attractMode.nextSlide()
    }

    Timer {
        id: safetyTimer
        repeat: false
        onTriggered: attractMode.nextSlide()
    }
}
