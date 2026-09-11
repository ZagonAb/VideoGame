import QtQuick 2.15
import QtGraphicalEffects 1.12
import QtMultimedia 5.15

Item {
    id: videoContent

    property var game: null
    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property bool videoPlaybackEnabled: true
    property real volume: 1.0
    property real reflectionZoom: 7.5
    property real reflectionZoomBoxFront: 7.5

    signal videoFinished()
    signal videoError()

    property string displayState: "empty"

    readonly property string currentVideoPath:
        (game && game.assets && game.assets.video) ? game.assets.video : ""
    readonly property string currentBoxFrontPath:
        (game && game.assets && game.assets.boxFront && game.assets.boxFront !== "")
            ? game.assets.boxFront : "assets/no-image/default.png"

    function log(msg) {
        console.log("[VideoContent] " + msg);
    }

    function pauseVideo() {
        log("pauseVideo() llamado. displayState=" + displayState);
        if (videoLoader.item) {
            videoLoader.item.pause();
            log("  -> video pausado (se está lanzando el juego)");
        } else {
            log("  -> no hay bloque de video activo, nada que pausar");
        }
    }

    function resetVideo() {
        log("resetVideo() solicitado. game=" + (game ? game.title : "null"));
        evaluateState("resetVideo");
    }

    function wantsVideo() {
        return videoContent.videoPlaybackEnabled && currentVideoPath !== "";
    }

    function evaluateState(reason) {
        log("evaluateState(\"" + reason + "\") | game=" + (game ? game.title : "null") +
            " | videoPlaybackEnabled=" + videoPlaybackEnabled +
            " | currentVideoPath=" + (currentVideoPath || "(vacío)") +
            " | displayState actual=" + displayState);

        if (!game) {
            log("  decisión -> EMPTY (no hay juego)");
            switchTo("empty");
            return;
        }

        if (!wantsVideo()) {
            log("  decisión -> BOXFRONT (playback desactivado o el juego no tiene video)");
            switchTo("boxfront");
            return;
        }

        if (displayState === "video" && videoLoader.item) {
            log("  decisión -> VIDEO ya activo, actualizando el clip in-place (sin recrear el Loader)");
            videoLoader.item.loadPath(currentVideoPath);
        } else {
            log("  decisión -> VIDEO nuevo (creando el bloque desde cero)");
            switchTo("video");
        }
    }

    function switchTo(newState) {
        log("switchTo(\"" + newState + "\") desde \"" + displayState + "\"");

        if (newState === "video") {
            boxFrontLoader.active = false;
            displayState = "video";
            videoLoader.active = true;
        } else if (newState === "boxfront") {
            videoLoader.active = false;
            displayState = "boxfront";
            boxFrontLoader.active = true;
        } else {
            videoLoader.active = false;
            boxFrontLoader.active = false;
            displayState = "empty";
        }

        log("  resultado -> displayState=" + displayState +
            " videoLoader.active=" + videoLoader.active +
            " boxFrontLoader.active=" + boxFrontLoader.active);
    }

    onGameChanged: evaluateState("gameChanged")
    onVideoPlaybackEnabledChanged: evaluateState("videoPlaybackEnabledChanged")

    Loader {
        id: videoLoader
        anchors.fill: parent
        active: false
        asynchronous: false

        sourceComponent: Component {
            Item {
                id: videoBlock
                anchors.fill: parent

                Component.onCompleted: {
                    videoContent.log("  [VideoBlock] CREADO. cargando -> " + videoContent.currentVideoPath);
                    gameVideo._loadedPath = videoContent.currentVideoPath;
                    gameVideo.source = videoContent.currentVideoPath;
                }
                Component.onDestruction: videoContent.log("  [VideoBlock] DESTRUIDO")

                function pause() {
                    gameVideo.pause();
                }

                function loadPath(path) {
                    if (path === gameVideo._loadedPath) {
                        videoContent.log("  [VideoBlock] loadPath: mismo clip -> reiniciando desde el principio (" + path + ")");
                        gameVideo.resetVideo();
                    } else {
                        videoContent.log("  [VideoBlock] loadPath: clip nuevo -> " + path);
                        gameVideo._loadedPath = path;
                        gameVideo.source = path;
                    }
                }

                Item {
                    id: videoReflectionContainer
                    anchors.fill: parent
                    clip: true

                    ShaderEffectSource {
                        id: videoReflectionSource
                        anchors.fill: parent
                        sourceItem: gameVideo
                        hideSource: false
                        scale: videoContent.reflectionZoom

                        layer.enabled: true
                        layer.effect: FastBlur {
                            radius: 60
                            transparentBorder: true
                        }
                    }
                }

                VideoPlayer {
                    id: gameVideo
                    width: parent.width * 0.90
                    height: parent.height * 0.9
                    anchors.centerIn: parent
                    source: ""
                    volume: videoContent.volume

                    property string _loadedPath: ""

                    onVideoFinished: {
                        videoContent.log("evento: el video terminó naturalmente -> BOXFRONT");
                        videoContent.switchTo("boxfront");
                        videoContent.videoFinished();
                    }

                    onVideoError: {
                        videoContent.log("evento: error de video -> BOXFRONT");
                        videoContent.switchTo("boxfront");
                        videoContent.videoError();
                    }
                }

                Item {
                    id: videoLoadingHint
                    anchors.fill: parent
                    visible: gameVideo.status === MediaPlayer.Loading

                    Column {
                        anchors.centerIn: parent
                        spacing: 20

                        Image {
                            id: loadingSpinner
                            source: "assets/icons/spinner.svg"
                            width: videoContent.parent ? videoContent.parent.width * 0.08 : videoContent.width * 0.08
                            height: width
                            anchors.horizontalCenter: parent.horizontalCenter
                            mipmap: true

                            RotationAnimation {
                                target: loadingSpinner
                                property: "rotation"
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                                running: videoLoadingHint.visible
                            }

                            onStatusChanged: {
                                if (status === Image.Error) {
                                    loadingText.visible = true;
                                    loadingSpinner.visible = false;
                                }
                            }
                        }

                        Text {
                            id: loadingText
                            text: "Loading..."
                            color: videoContent.palette ? videoContent.palette.textPrimary : "#ffffff"
                            font.pixelSize: (videoContent.parent ? videoContent.parent.width : videoContent.width) * 0.04 * videoContent.fontScale
                            font.family: videoContent.fontFamily
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: false

                            layer.enabled: true
                            layer.effect: DropShadow {
                                radius: 10
                                samples: 10
                                color: "white"
                                horizontalOffset: -2
                                verticalOffset: -2
                                spread: 0.10
                            }
                        }
                    }
                }
            }
        }
    }

    Loader {
        id: boxFrontLoader
        anchors.fill: parent
        active: false
        asynchronous: false

        sourceComponent: Component {
            Item {
                id: boxFrontBlock
                anchors.fill: parent

                Component.onCompleted: videoContent.log("  [BoxFrontBlock] CREADO. imagen -> " + videoContent.currentBoxFrontPath)
                Component.onDestruction: videoContent.log("  [BoxFrontBlock] DESTRUIDO")

                Item {
                    id: boxFrontReflectionContainer
                    anchors.fill: parent
                    clip: true

                    Image {
                        id: boxFrontReflectionImage
                        anchors.fill: parent
                        source: videoContent.currentBoxFrontPath
                        fillMode: Image.PreserveAspectCrop
                        scale: videoContent.reflectionZoomBoxFront
                        asynchronous: true

                        layer.enabled: true
                        layer.effect: FastBlur {
                            radius: 60
                            transparentBorder: true
                        }

                        onStatusChanged: {
                            if (status === Image.Error) {
                                source = "assets/no-image/default.png";
                            }
                        }

                        Connections {
                            target: videoContent
                            function onCurrentBoxFrontPathChanged() {
                                boxFrontReflectionImage.source = videoContent.currentBoxFrontPath;
                            }
                        }
                    }
                }

                Image {
                    id: boxFrontImage
                    width: parent.width * 0.90
                    height: parent.height * 0.9
                    anchors.centerIn: parent
                    source: videoContent.currentBoxFrontPath
                    fillMode: Image.PreserveAspectFit

                    property real fadeOpacity: 0
                    property real popScale: 0.96
                    opacity: fadeOpacity
                    scale: popScale
                    transformOrigin: Item.Center

                    ParallelAnimation {
                        id: boxFrontAppearAnimation

                        NumberAnimation {
                            target: boxFrontImage
                            property: "fadeOpacity"
                            from: 0
                            to: 1
                            duration: 400
                            easing.type: Easing.OutQuad
                        }

                        NumberAnimation {
                            target: boxFrontImage
                            property: "popScale"
                            from: 0.96
                            to: 1.0
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }

                    function startFadeIn() {
                        boxFrontAppearAnimation.stop();
                        fadeOpacity = 0;
                        popScale = 0.96;
                        boxFrontAppearAnimation.start();
                    }

                    Component.onCompleted: startFadeIn()

                    onStatusChanged: {
                        if (status === Image.Error) {
                            videoContent.log("  [BoxFrontBlock] error cargando imagen, usando fallback");
                            source = "assets/no-image/default.png";
                        }
                    }

                    Connections {
                        target: videoContent
                        function onCurrentBoxFrontPathChanged() {
                            boxFrontImage.source = videoContent.currentBoxFrontPath;
                            boxFrontImage.startFadeIn();
                        }
                    }
                }
            }
        }
    }

    Item {
        id: itemNoGames
        anchors.fill: parent
        visible: videoContent.displayState === "empty"

        Column {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: "There are no games."
                color: videoContent.palette ? videoContent.palette.textPrimary : "#ffffff"
                font.pixelSize: (videoContent.parent ? videoContent.parent.width : videoContent.width) * 0.04 * videoContent.fontScale
                font.family: videoContent.fontFamily
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    GameDetails {
        id: gameDetails
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.05
        anchors.right: parent.right
        z: 100

        game: videoContent.game
        fontFamily: videoContent.fontFamily
        fontScale: videoContent.fontScale
        palette: videoContent.palette
        visible: videoContent.displayState === "boxfront"
    }
}
