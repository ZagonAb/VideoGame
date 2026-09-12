import QtQuick 2.15
import QtQuick.Layouts 1.15
import SortFilterProxyModel 0.2
import QtMultimedia 5.15
import QtGraphicalEffects 1.12

FocusScope {
    id: root
    focus: true
    property var game: null
    property string currentFilter: "All"
    property bool videoEnded: false
    width: parent.width
    height: parent.height

    property int pendingLaunchIndex: -1
    readonly property string currentVersion: "1.0.3"
    property string _pendingUpdateVersion: ""
    property string _pendingUpdateUrl: ""
    property string _pendingUpdateNotes: ""

    function isNewerVersion(latest, current) {
        var a = latest.split('.').map(Number);
        var b = current.split('.').map(Number);
        var len = Math.max(a.length, b.length);
        for (var i = 0; i < len; i++) {
            var av = a[i] || 0;
            var bv = b[i] || 0;
            if (av > bv) return true;
            if (av < bv) return false;
        }
        return false;
    }

    function checkForUpdates() {
        var xhr = new XMLHttpRequest();
        var url = "https://api.github.com/repos/ZagonAb/VideoGame/releases/latest";
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;
            if (xhr.status !== 200) {
                console.log("[update] no release info available (status " + xhr.status + ")");
                return;
            }
            try {
                var data = JSON.parse(xhr.responseText);
                var latestTag = data.tag_name || "";
                var latestVersion = latestTag.replace(/^v/, "");
                var releaseUrl = data.html_url || "";
                var releaseNotes = data.body || "";
                if (!latestVersion || !root.isNewerVersion(latestVersion, root.currentVersion)) {
                    return;
                }
                var lastNotified = api.memory.has("lastUpdateNotified")
                    ? api.memory.get("lastUpdateNotified") : "";
                if (latestVersion === lastNotified) {
                    return;
                }
                root._pendingUpdateVersion = latestVersion;
                root._pendingUpdateUrl = releaseUrl;
                root._pendingUpdateNotes = releaseNotes;
                api.memory.set("lastUpdateNotified", latestVersion);
                postLaunchUpdateTimer.restart();
            } catch (e) {
                console.warn("[update] failed to parse release info:", e);
            }
        };
        xhr.onerror = function() {
            console.warn("[update] network error while checking for updates");
        };
        xhr.send();
    }

    Timer {
        id: postLaunchUpdateTimer
        interval: 900
        repeat: false
        onTriggered: {
            if (root._pendingUpdateVersion !== "") {
                updateNotification.show(root._pendingUpdateVersion, root._pendingUpdateUrl, root._pendingUpdateNotes);
                root._pendingUpdateVersion = "";
                root._pendingUpdateUrl = "";
                root._pendingUpdateNotes = "";
            }
        }
    }

    property var fontsList: [
        { name: "Abril Fatface", path: "assets/fonts/abrilfatface/abrilfatface.ttf" },
        { name: "Arimo", path: "assets/fonts/arimo/arimo.ttf" },
        { name: "Barlow", path: "assets/fonts/barlow/barlow.ttf" },
        { name: "Cairo", path: "assets/fonts/cairo/cairo.ttf" },
        { name: "Comfortaa", path: "assets/fonts/comfortaa/comfortaa.ttf" },
        { name: "DM Serif Display", path: "assets/fonts/dm/dm.ttf" },
        { name: "EB Garamond", path: "assets/fonts/ebgaramond/ebgaramond.ttf" },
        { name: "Heebo", path: "assets/fonts/heebo/heebo.ttf" },
        { name: "Inter", path: "assets/fonts/inter/inter.ttf" },
        { name: "Kanit", path: "assets/fonts/kanit/kanit.ttf" },
        { name: "Maven Pro", path: "assets/fonts/mavenpro/mavenpro.ttf" },
        { name: "Mukta", path: "assets/fonts/mukta/mukta.ttf" },
        { name: "Oswald", path: "assets/fonts/oswald/oswald.ttf" },
        { name: "Play", path: "assets/fonts/play/play.ttf" },
        { name: "Prompt", path: "assets/fonts/prompt/prompt.ttf" },
        { name: "Raleway", path: "assets/fonts/raleway/raleway.ttf" },
        { name: "Shadows Into Light", path: "assets/fonts/shadowsintolight/shadowsintolight.ttf" },
        { name: "Smooch", path: "assets/fonts/smooch/smooch.ttf" },
        { name: "Teko", path: "assets/fonts/teko/teko.ttf" },
        { name: "Anton", path: "assets/fonts/anton/anton.ttf" },
        { name: "Arvo", path: "assets/fonts/arvo/arvo.ttf" },
        { name: "Bebas Neue", path: "assets/fonts/bebasneue/bebasneue.ttf" },
        { name: "Castoro", path: "assets/fonts/castoro/castoro.ttf" },
        { name: "Crimson Text", path: "assets/fonts/crimson/crimson.ttf" },
        { name: "DM Sans", path: "assets/fonts/dmsans/dmsans.ttf" },
        { name: "Exo 2", path: "assets/fonts/exo2/exo2.ttf" },
        { name: "Hind", path: "assets/fonts/hind/hind.ttf" },
        { name: "Jacquard", path: "assets/fonts/jacquard/jacquard.ttf" },
        { name: "Lato", path: "assets/fonts/lato/lato.ttf" },
        { name: "Merriweather", path: "assets/fonts/merriweather/merriweather.ttf" },
        { name: "Nanum Gothic", path: "assets/fonts/nanumgothic/nanumgothic.ttf" },
        { name: "Pacifico", path: "assets/fonts/pacifico/pacifico.ttf" },
        { name: "Playfair Display", path: "assets/fonts/playfair/playfair.ttf" },
        { name: "PT Serif", path: "assets/fonts/ptserif/ptserif.ttf" },
        { name: "Red Hat Display", path: "assets/fonts/redhatdisplay/redhatdisplay.ttf" },
        { name: "Signika Negative", path: "assets/fonts/signikanegative/signikanegative.ttf" },
        { name: "Space Grotesk", path: "assets/fonts/spacegrotesk/spacegrotesk.ttf" },
        { name: "Tiny5", path: "assets/fonts/tiny5/tiny5.ttf" },
        { name: "Archivo", path: "assets/fonts/archivo/archivo.ttf" },
        { name: "Assistant", path: "assets/fonts/assistant/assistant.ttf" },
        { name: "Bitter", path: "assets/fonts/bitter/bitter.ttf" },
        { name: "Caveat", path: "assets/fonts/caveat/caveat.ttf" },
        { name: "Dancing Script", path: "assets/fonts/dancing/dancing.ttf" },
        { name: "DotGothic16", path: "assets/fonts/dotgothic16/dotgothic16.ttf" },
        { name: "Fjalla One", path: "assets/fonts/fjallaone/fjallaone.ttf" },
        { name: "IBM Plex Mono", path: "assets/fonts/ibmplexmono/ibmplexmono.ttf" },
        { name: "Jersey", path: "assets/fonts/jersey/jersey.ttf" },
        { name: "Libre Franklin", path: "assets/fonts/librefranklin/librefranklin.ttf" },
        { name: "Montserrat", path: "assets/fonts/montserrat/montserrat.ttf" },
        { name: "Nunito", path: "assets/fonts/nunito/nunito.ttf" },
        { name: "Pixelify Sans", path: "assets/fonts/pixelify/pixelify.ttf" },
        { name: "Poppins", path: "assets/fonts/poppins/poppins.ttf" },
        { name: "Rajdhani", path: "assets/fonts/rajdhani/rajdhani.ttf" },
        { name: "Sekuya", path: "assets/fonts/sekuya/sekuya.ttf" },
        { name: "Slabo 27px", path: "assets/fonts/slabo27px/slabo27px.ttf" },
        { name: "Tajawal", path: "assets/fonts/tajawal/tajawal.ttf" },
        { name: "Titillium Web", path: "assets/fonts/titillium/titillium.ttf" }
    ]

    property var colorSchemes: [
        {
            name: "Black",
            background: "#000000", surface: "#000000",
            accent: "#ffffff", accentText: "#000000",
            textPrimary: "#ffffff", textSecondary: "#aaaaaa"
        },
        {
            name: "Night Blue",
            background: "#0d1b2a", surface: "#13273c",
            accent: "#3a86ff", accentText: "#ffffff",
            textPrimary: "#e0e6ed", textSecondary: "#93a4b8"
        },
        {
            name: "Crimson",
            background: "#1a0000", surface: "#2b0a0d",
            accent: "#e63946", accentText: "#ffffff",
            textPrimary: "#f1e3e4", textSecondary: "#c98f92"
        },
        {
            name: "Emerald",
            background: "#04120b", surface: "#0a2318",
            accent: "#2ecc71", accentText: "#04120b",
            textPrimary: "#e7f6ee", textSecondary: "#8fc9a8"
        },
        {
            name: "Neon Purple",
            background: "#120318", surface: "#220a2e",
            accent: "#c77dff", accentText: "#120318",
            textPrimary: "#efe3f5", textSecondary: "#b39ac0"
        },
        {
            name: "Retro Amber",
            background: "#1a1206", surface: "#2b1e08",
            accent: "#ffb703", accentText: "#1a1206",
            textPrimary: "#f3e9d2", textSecondary: "#c9ac74"
        },
        {
            name: "Ocean Teal",
            background: "#031b1e", surface: "#062e33",
            accent: "#14ffec", accentText: "#031b1e",
            textPrimary: "#dffbfa", textSecondary: "#7fc9c5"
        },
        {
            name: "Sunset Orange",
            background: "#1a0f05", surface: "#2b1a08",
            accent: "#ff7b25", accentText: "#1a0f05",
            textPrimary: "#fbe8d8", textSecondary: "#d1a377"
        },
        {
            name: "Rose Gold",
            background: "#1a0e12", surface: "#2b171d",
            accent: "#e8b4bc", accentText: "#1a0e12",
            textPrimary: "#f7e6e9", textSecondary: "#c99aa1"
        },
        {
            name: "Forest Green",
            background: "#07130a", surface: "#0f2415",
            accent: "#4caf50", accentText: "#07130a",
            textPrimary: "#e3f3e5", textSecondary: "#94b899"
        },
        {
            name: "Slate Gray",
            background: "#14161a", surface: "#20232a",
            accent: "#8ca0b3", accentText: "#14161a",
            textPrimary: "#e8ebef", textSecondary: "#9aa5b1"
        },
        {
            name: "Cyberpunk Pink",
            background: "#0f0018", surface: "#1e0330",
            accent: "#ff2bd6", accentText: "#0f0018",
            textPrimary: "#f7e2fb", textSecondary: "#c98ad4"
        },
        {
            name: "Ice White",
            background: "#f4f7fa", surface: "#ffffff",
            accent: "#2563eb", accentText: "#ffffff",
            textPrimary: "#111827", textSecondary: "#5b6472"
        },
        {
            name: "Solar Yellow",
            background: "#1a1600", surface: "#2b2500",
            accent: "#ffd60a", accentText: "#1a1600",
            textPrimary: "#fff6d6", textSecondary: "#cbb35a"
        },
        {
            name: "Deep Indigo",
            background: "#080318", surface: "#12082e",
            accent: "#7c5cff", accentText: "#ffffff",
            textPrimary: "#e6e0fb", textSecondary: "#a79ad1"
        },
        {
            name: "Copper",
            background: "#180d05", surface: "#2b1a0d",
            accent: "#c97b3d", accentText: "#180d05",
            textPrimary: "#f2e1cf", textSecondary: "#c9a179"
        }
    ]

    property int fontIndex: 21
    property real fontScale: 1.0
    property int colorSchemeIndex: 0
    property int titleCollectionSpacing: 10
    property int gameDelegateRadius: 5
    property int alphabetDelegateRadius: 50
    property bool videoPlaybackEnabled: true
    property bool titleMarqueeEnabled: false
    property bool collectionMarqueeEnabled: false
    property int videoVolume: 100
    property int sfxVolume: 100

    property var languages: [
        { code: "en", name: "English" },
        { code: "es", name: "Español" }
    ]
    property int languageIndex: 0

    readonly property string language: (languageIndex >= 0 && languageIndex < languages.length)
        ? languages[languageIndex].code : "en"

    property var uiStrings: ({
        en: {
            title: "SETTINGS",
            font: "Font",
            fontSize: "Font Size",
            colorScheme: "Color Scheme",
            language: "Language",
            spacing: "Title/Collection Spacing",
            gameRadius: "Game List Radius",
            alphaRadius: "A-Z Selector Radius",
            videoPlayback: "Video Playback",
            videoPlaybackOn: "ON",
            videoPlaybackOff: "OFF",
            titleMarquee: "Title Marquee",
            titleMarqueeOn: "ON",
            titleMarqueeOff: "OFF",
            collectionMarquee: "Collection Marquee",
            collectionMarqueeOn: "ON",
            collectionMarqueeOff: "OFF",
            videoVolume: "Video Volume",
            sfxVolume: "Sound Effects Volume",
            reset: "Reset to Default",
            hint: "\u2191\u2193 Navigate    \u2190\u2192 Change / Reset    B Close",
            updateTitle: "New Update Available",
            updateBody: "A new version is available: ",
            viewChanges: "View Changes",
            openGithub: "Open on GitHub",
            close: "Close",
            updateHint: "\u2190\u2192 Navigate    A Select    B Close"
        },
        es: {
            title: "AJUSTES",
            font: "Fuente",
            fontSize: "Tamaño de fuente",
            colorScheme: "Esquema de color",
            language: "Idioma",
            spacing: "Espaciado título/colección",
            gameRadius: "Radio de lista de juegos",
            alphaRadius: "Radio del selector A-Z",
            videoPlayback: "Reproducción de Video",
            videoPlaybackOn: "Activado",
            videoPlaybackOff: "Desactivado",
            titleMarquee: "Desplazamiento del título",
            titleMarqueeOn: "Activado",
            titleMarqueeOff: "Desactivado",
            collectionMarquee: "Desplazamiento de colección",
            collectionMarqueeOn: "Activado",
            collectionMarqueeOff: "Desactivado",
            videoVolume: "Volumen de video",
            sfxVolume: "Volumen de efectos de sonido",
            reset: "Restaurar valores por defecto",
            hint: "\u2191\u2193 Navegar    \u2190\u2192 Cambiar / Restaurar    B Cerrar",
            updateTitle: "Nueva actualización disponible",
            updateBody: "Hay una nueva versión disponible: ",
            viewChanges: "Ver cambios",
            openGithub: "Abrir en GitHub",
            close: "Cerrar",
            updateHint: "\u2190\u2192 Navegar    A Seleccionar    B Cerrar"
        }
    })

    readonly property var strings: uiStrings[language] ? uiStrings[language] : uiStrings["en"]
    readonly property int defaultFontIndex: 21
    readonly property real defaultFontScale: 1.0
    readonly property int defaultColorSchemeIndex: 0
    readonly property int defaultLanguageIndex: 0
    readonly property int defaultTitleCollectionSpacing: 10
    readonly property int defaultGameDelegateRadius: 5
    readonly property int defaultAlphabetDelegateRadius: 50
    readonly property bool defaultVideoPlaybackEnabled: true
    readonly property bool defaultTitleMarqueeEnabled: false
    readonly property bool defaultCollectionMarqueeEnabled: false
    readonly property int defaultVideoVolume: 100
    readonly property int defaultSfxVolume: 100

    readonly property string selectedFontPath: (fontIndex >= 0 && fontIndex < fontsList.length)
        ? fontsList[fontIndex].path : "assets/fonts/bebasneue/bebasneue.ttf"
    readonly property var palette: colorSchemes[colorSchemeIndex]

    function loadSettings() {
        if (api.memory.has("settingsFontIndex")) {
            const idx = api.memory.get("settingsFontIndex");
            if (idx >= 0 && idx < fontsList.length) fontIndex = idx;
        }
        if (api.memory.has("settingsFontScale")) {
            const scale = api.memory.get("settingsFontScale");
            if (scale >= 0.7 && scale <= 1.5) fontScale = scale;
        }
        if (api.memory.has("settingsColorSchemeIndex")) {
            const cidx = api.memory.get("settingsColorSchemeIndex");
            if (cidx >= 0 && cidx < colorSchemes.length) colorSchemeIndex = cidx;
        }
        if (api.memory.has("settingsLanguageIndex")) {
            const lidx = api.memory.get("settingsLanguageIndex");
            if (lidx >= 0 && lidx < languages.length) languageIndex = lidx;
        }
        if (api.memory.has("settingsTitleCollectionSpacing")) {
            const sp = api.memory.get("settingsTitleCollectionSpacing");
            if (sp >= -20 && sp <= 40) titleCollectionSpacing = sp;
        }
        if (api.memory.has("settingsGameDelegateRadius")) {
            const gr = api.memory.get("settingsGameDelegateRadius");
            if (gr >= 0 && gr <= 40) gameDelegateRadius = gr;
        }
        if (api.memory.has("settingsAlphabetDelegateRadius")) {
            const ar = api.memory.get("settingsAlphabetDelegateRadius");
            if (ar >= 0 && ar <= 50) alphabetDelegateRadius = ar;
        }
        if (api.memory.has("settingsVideoPlaybackEnabled")) {
            const vpe = api.memory.get("settingsVideoPlaybackEnabled");
            videoPlaybackEnabled = (vpe === true || vpe === "true");
        }
        if (api.memory.has("settingsTitleMarqueeEnabled")) {
            const tme = api.memory.get("settingsTitleMarqueeEnabled");
            titleMarqueeEnabled = (tme === true || tme === "true");
        }
        if (api.memory.has("settingsCollectionMarqueeEnabled")) {
            const cme = api.memory.get("settingsCollectionMarqueeEnabled");
            collectionMarqueeEnabled = (cme === true || cme === "true");
        }
        if (api.memory.has("settingsVideoVolume")) {
            const vv = api.memory.get("settingsVideoVolume");
            if (vv >= 0 && vv <= 100) videoVolume = vv;
        }
        if (api.memory.has("settingsSfxVolume")) {
            const sv = api.memory.get("settingsSfxVolume");
            if (sv >= 0 && sv <= 100) sfxVolume = sv;
        }
        console.log("[settings] loaded -> fontIndex:", fontIndex, "fontScale:", fontScale,
                     "colorSchemeIndex:", colorSchemeIndex, "languageIndex:", languageIndex,
                     "titleCollectionSpacing:", titleCollectionSpacing,
                     "gameDelegateRadius:", gameDelegateRadius,
                     "alphabetDelegateRadius:", alphabetDelegateRadius,
                     "videoPlaybackEnabled:", videoPlaybackEnabled,
                     "titleMarqueeEnabled:", titleMarqueeEnabled,
                     "collectionMarqueeEnabled:", collectionMarqueeEnabled,
                     "videoVolume:", videoVolume, "sfxVolume:", sfxVolume);
    }

    function saveSettings() {
        api.memory.set("settingsFontIndex", fontIndex);
        api.memory.set("settingsFontScale", fontScale);
        api.memory.set("settingsColorSchemeIndex", colorSchemeIndex);
        api.memory.set("settingsLanguageIndex", languageIndex);
        api.memory.set("settingsTitleCollectionSpacing", titleCollectionSpacing);
        api.memory.set("settingsGameDelegateRadius", gameDelegateRadius);
        api.memory.set("settingsAlphabetDelegateRadius", alphabetDelegateRadius);
        api.memory.set("settingsVideoPlaybackEnabled", videoPlaybackEnabled);
        api.memory.set("settingsTitleMarqueeEnabled", titleMarqueeEnabled);
        api.memory.set("settingsCollectionMarqueeEnabled", collectionMarqueeEnabled);
        api.memory.set("settingsVideoVolume", videoVolume);
        api.memory.set("settingsSfxVolume", sfxVolume);
        console.log("[settings] saved -> fontIndex:", fontIndex, "fontScale:", fontScale,
                     "colorSchemeIndex:", colorSchemeIndex, "languageIndex:", languageIndex,
                     "titleCollectionSpacing:", titleCollectionSpacing,
                     "gameDelegateRadius:", gameDelegateRadius,
                     "alphabetDelegateRadius:", alphabetDelegateRadius,
                     "videoPlaybackEnabled:", videoPlaybackEnabled,
                     "titleMarqueeEnabled:", titleMarqueeEnabled,
                     "collectionMarqueeEnabled:", collectionMarqueeEnabled,
                     "videoVolume:", videoVolume, "sfxVolume:", sfxVolume);
    }

    function resetSettingsToDefault() {
        fontIndex = defaultFontIndex;
        fontScale = defaultFontScale;
        colorSchemeIndex = defaultColorSchemeIndex;
        languageIndex = defaultLanguageIndex;
        titleCollectionSpacing = defaultTitleCollectionSpacing;
        gameDelegateRadius = defaultGameDelegateRadius;
        alphabetDelegateRadius = defaultAlphabetDelegateRadius;
        videoPlaybackEnabled = defaultVideoPlaybackEnabled;
        titleMarqueeEnabled = defaultTitleMarqueeEnabled;
        collectionMarqueeEnabled = defaultCollectionMarqueeEnabled;
        videoVolume = defaultVideoVolume;
        sfxVolume = defaultSfxVolume;
        saveSettings();
        settingsOverlay.syncValues(fontIndex, fontScale, colorSchemeIndex, languageIndex,
                                    titleCollectionSpacing, gameDelegateRadius,
                                    alphabetDelegateRadius, videoPlaybackEnabled,
                                    titleMarqueeEnabled, collectionMarqueeEnabled,
                                    videoVolume, sfxVolume);
        console.log("[settings] reset to defaults");
    }

    function openSettings() {
        settingsOverlay.open(fontIndex, fontScale, colorSchemeIndex, languageIndex,
                              titleCollectionSpacing, gameDelegateRadius,
                              alphabetDelegateRadius, videoPlaybackEnabled,
                              titleMarqueeEnabled, collectionMarqueeEnabled,
                              videoVolume, sfxVolume);
    }

    SoundEffect {
        id: soundUp
        source: "assets/sound/up.wav"
        volume: root.sfxVolume / 100
    }

    SoundEffect {
        id: soundDown
        source: "assets/sound/down.wav"
        volume: root.sfxVolume / 100
    }

    SoundEffect {
        id: soundOk
        source: "assets/sound/ok.wav"
        volume: root.sfxVolume / 100
    }

    SoundEffect {
        id: soundNotice
        source: "assets/sound/notice.wav"
        volume: root.sfxVolume / 100
    }

    function playAndLaunch(gameIndex) {
        soundOk.play();
        videoContent.pauseVideo();
        pendingLaunchIndex = gameIndex;

        const g = (gameIndex >= 0 && gameIndex < filteredGames.count) ? filteredGames.get(gameIndex) : null;
        launchOverlay.trigger(g);
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

    property string pendingGameTitle: ""
    property string pendingGameCollection: ""

    function collectionNameOf(gameObject) {
        return (gameObject && gameObject.collections && gameObject.collections.count > 0)
            ? gameObject.collections.get(0).name : "";
    }

    function saveState() {
        const currentGame = (gameList.currentIndex >= 0 && gameList.currentIndex < filteredGames.count)
            ? filteredGames.get(gameList.currentIndex) : null;
        const title = currentGame ? currentGame.title : "";
        const collectionName = collectionNameOf(currentGame);
        console.log("[persist] saveState -> filter:", currentFilter, "index:", gameList.currentIndex,
                     "title:", title, "collection:", collectionName);
        api.memory.set("lastFilter", currentFilter);
        api.memory.set("lastGameTitle", title);
        api.memory.set("lastGameCollection", collectionName);
    }

    function findIndexForGame(title, collectionName) {
        for (var i = 0; i < filteredGames.count; i++) {
            const g = filteredGames.get(i);
            if (g && g.title === title && collectionNameOf(g) === collectionName) return i;
        }
        for (var j = 0; j < filteredGames.count; j++) {
            const g2 = filteredGames.get(j);
            if (g2 && g2.title === title) return j;
        }
        return -1;
    }

    function applyPendingGameSelection() {
        console.log("[persist] applyPendingGameSelection -> pendingGameTitle:", pendingGameTitle,
                     "pendingGameCollection:", pendingGameCollection,
                     "filteredGames.count:", filteredGames.count);
        if (!pendingGameTitle || filteredGames.count <= 0) {
            pendingGameTitle = "";
            pendingGameCollection = "";
            return;
        }
        const idx = findIndexForGame(pendingGameTitle, pendingGameCollection);
        console.log("[persist] applyPendingGameSelection -> found index:", idx,
                     "for title:", pendingGameTitle, "collection:", pendingGameCollection);
        if (idx >= 0) {
            gameList.currentIndex = idx;
            gameList.scrollToCurrent();
            console.log("[persist] applyPendingGameSelection -> gameList.currentIndex now:", gameList.currentIndex);
            Qt.callLater(gameList.scrollToCurrent);
        }

        restoreSettleTimer.restart();
    }

    function finalizePendingGameSelection() {
        console.log("[persist] finalizePendingGameSelection -> pendingGameTitle:", pendingGameTitle,
                     "filteredGames.count:", filteredGames.count,
                     "gameList.currentIndex (before):", gameList.currentIndex);
        if (!pendingGameTitle || filteredGames.count <= 0) {
            pendingGameTitle = "";
            pendingGameCollection = "";
            return;
        }
        const idx = findIndexForGame(pendingGameTitle, pendingGameCollection);
        console.log("[persist] finalizePendingGameSelection -> re-applied index:", idx);
        if (idx >= 0) {
            gameList.currentIndex = idx;
            gameList.scrollToCurrent();
            Qt.callLater(gameList.scrollToCurrent);
        }
        pendingGameTitle = "";
        pendingGameCollection = "";
    }

    function restoreState() {
        console.log("[persist] restoreState called. has lastFilter:", api.memory.has("lastFilter"));
        if (!api.memory.has("lastFilter")) return;

        const savedFilter = api.memory.get("lastFilter");
        const savedTitle = api.memory.has("lastGameTitle") ? api.memory.get("lastGameTitle") : "";
        const savedCollection = api.memory.has("lastGameCollection") ? api.memory.get("lastGameCollection") : "";
        console.log("[persist] restoreState -> savedFilter:", savedFilter, "savedTitle:", savedTitle,
                     "savedCollection:", savedCollection);

        pendingGameTitle = savedTitle;
        pendingGameCollection = savedCollection;

        currentFilter = savedFilter;
        filteredGames.updateFilter();
        console.log("[persist] after updateFilter() -> filteredGames.count:", filteredGames.count,
                     "gameList.currentIndex:", gameList.currentIndex);

        const letters = alphabetSelector.model;
        const letterIndex = letters.indexOf(savedFilter);
        console.log("[persist] letterIndex for", savedFilter, "=", letterIndex);
        if (letterIndex >= 0) {
            alphabetSelector.setCurrentIndex(letterIndex);
        }

        applyPendingGameSelection();
        console.log("[persist] restoreState finished. gameList.currentIndex:", gameList.currentIndex,
                     "pendingGameTitle:", pendingGameTitle);
    }

    function launchGame(gameIndex) {
        if (filteredGames.count > 0) {
            const filteredGame = filteredGames.get(gameIndex);
            if (filteredGame) {
                root.saveState();
                const targetCollection = collectionNameOf(filteredGame);
                let collectionFound = false;
                for (let i = 0; i < api.collections.count; i++) {
                    const collection = api.collections.get(i);
                    if (targetCollection && collection.name !== targetCollection) continue;
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

        onCountChanged: {
            console.log("[persist] filteredGames.onCountChanged -> new count:", filteredGames.count,
                         "gameList.currentIndex:", gameList.currentIndex);
            if (root.pendingGameTitle) {
                restoreSettleTimer.restart();
            }
        }
    }

    Timer {
        id: restoreSettleTimer
        interval: 50
        repeat: false
        onTriggered: root.finalizePendingGameSelection()
    }

    function updateSelectedGame() {
        console.log("[persist] updateSelectedGame called. filteredGames.count:", filteredGames.count);
        if (filteredGames.count > 0) {
            gameList.currentIndex = 0;
            gameList.positionViewAtBeginning();
            Qt.callLater(gameList.positionViewAtBeginning);
            console.log("[persist] updateSelectedGame -> forced gameList.currentIndex = 0");
            game = gameList.model.get(0);
            videoContent.resetVideo();
            videoEnded = false;
        } else {
            game = null;
            videoEnded = false;
        }
    }

    readonly property real aspectRatio: root.height > 0 ? (root.width / root.height) : 1.777

    readonly property string layoutMode: {
        if (aspectRatio >= 1.55) return "wide";
        if (aspectRatio >= 1.15) return "standard";
        return "square";
    }

    readonly property real referenceMinSide: 1080
    readonly property real uiScale: Math.min(root.width, root.height) / referenceMinSide
    readonly property real alphabetSelectorWidth: 50 * uiScale
    readonly property real headerIconSize: 45 * uiScale

    readonly property var layoutProfiles: ({
        wide: {
            gameListWidthFn: function() { return root.width / 2.5 - alphabetSelector.width; },
            videoWidthFn: function() { return root.width * 2 / 3.5; },
            videoHeightFn: function() { return root.height; }
        },
        standard: {
            gameListWidthFn: function() { return root.width * 0.46 - alphabetSelector.width; },
            videoWidthFn: function() { return root.width * 0.50; },
            videoHeightFn: function() { return root.height; }
        },
        square: {
            gameListWidthFn: function() { return root.width * 0.50 - alphabetSelector.width; },
            videoWidthFn: function() { return root.width * 0.50; },
            videoHeightFn: function() { return gameList.height * 0.5; }
        }
    })

    readonly property var currentProfile: layoutProfiles[layoutMode]

    FontLoader {
        id: fontLoader
        source: root.selectedFontPath
    }

    Rectangle {
        id: globalBackground
        anchors.fill: parent
        color: root.palette.background
        z: -1
    }

    Rectangle {
        id: container
        width: parent.width
        height: parent.height
        color: "transparent"

        AlphabetSelector {
            id: alphabetSelector
            width: root.alphabetSelectorWidth
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            fontFamily: fontLoader.name
            fontScale: root.fontScale
            palette: root.palette
            delegateRadius: root.alphabetDelegateRadius
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
            spacing: 10

            Item {
                anchors.verticalCenter: parent.verticalCenter
                width: root.headerIconSize
                height: root.headerIconSize

                Image {
                    id: headerIcon
                    anchors.fill: parent
                    source: "assets/icons/allgames.svg"
                    mipmap: true
                }

                ColorOverlay {
                    anchors.fill: headerIcon
                    source: headerIcon
                    color: (root.palette && root.palette.name === "Ice White") ? root.palette.textPrimary : "white"
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "VIDEO GAMES"
                font.underline: true
                font.family: fontLoader.name
                font.pixelSize: root.width * 0.020 * root.fontScale
                color: root.palette.textPrimary
            }
        }

        GameListView {
            id: gameList
            width: root.currentProfile.gameListWidthFn()
            height: parent.height * 0.85
            anchors.left: alphabetSelector.right
            anchors.verticalCenter: parent.verticalCenter
            model: filteredGames
            fontFamily: fontLoader.name
            fontScale: root.fontScale
            palette: root.palette
            titleCollectionSpacing: root.titleCollectionSpacing
            delegateRadius: root.gameDelegateRadius
            titleMarqueeEnabled: root.titleMarqueeEnabled
            collectionMarqueeEnabled: root.collectionMarqueeEnabled
            gameCollectionFinder: root.findCollectionForGame
            soundEffectUp: soundUp
            soundEffectDown: soundDown
            subFilterEnabled: root.currentFilter !== "All"

            onGameSelected: function(index) {
                videoEnded = false;
                videoContent.resetVideo();
            }

            onGameLaunched: function(index) {
                root.playAndLaunch(index);
            }

            onGameChanged: function(selectedGame) {
                game = selectedGame;
                videoContent.resetVideo();
                videoEnded = false;
            }

            Keys.onPressed: function(event) {
                if (!event.isAutoRepeat) {
                    if (api.keys.isAccept(event)) {
                        root.playAndLaunch(currentIndex);
                        event.accepted = true;
                    }
                    else if (api.keys.isNextPage(event)) {
                        soundUp.play();
                        alphabetSelector.navigateToNextAvailable();
                        event.accepted = true;
                    }
                    else if (api.keys.isPrevPage(event)) {
                        soundDown.play();
                        alphabetSelector.navigateToPreviousAvailable();
                        event.accepted = true;
                    }
                    else if (api.keys.isFilters(event)) {
                        root.openSettings();
                        event.accepted = true;
                    }
                }
            }

            Component.onCompleted: {
                console.log("[persist] gameList.onCompleted (default init)");
                root.updateSelectedGame();
                gameList.forceActiveFocus();
            }

            Connections {
                target: gameList
                function onCurrentIndexChanged() {
                    console.log("[persist] gameList.currentIndex changed ->", gameList.currentIndex,
                                 "(filteredGames.count:", filteredGames.count, ")");
                }
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
            fontScale: root.fontScale
            palette: root.palette
            uiScale: root.uiScale
            z: 100
        }

        VideoContent {
            id: videoContent
            width: root.currentProfile.videoWidthFn()
            height: root.currentProfile.videoHeightFn()
            anchors.right: parent.right
            anchors.top: root.layoutMode === "square" ? gameList.top : undefined
            anchors.verticalCenter: root.layoutMode === "square" ? undefined : parent.verticalCenter
            game: root.game
            fontFamily: fontLoader.name
            fontScale: root.fontScale
            palette: root.palette
            videoPlaybackEnabled: root.videoPlaybackEnabled
            volume: root.videoVolume / 100

            onVideoFinished: {
                root.videoEnded = true;
            }

            onVideoError: {
                root.videoEnded = true;
            }
        }

        GameDescription {
            id: gameDescriptionPanel
            visible: root.layoutMode === "square"
            width: videoContent.width
            height: root.layoutMode === "square"
                    ? Math.max(0, gameList.height - videoContent.height - 10)
                    : 0
            anchors.right: parent.right
            anchors.top: videoContent.bottom
            anchors.topMargin: 10
            game: root.game
            fontFamily: fontLoader.name
            fontScale: root.fontScale
            palette: root.palette
            z: 90
        }

        Rectangle {
            id: scrubDimOverlay
            anchors.fill: parent
            color: "black"
            z: 10
            opacity: gameList.scrubActive ? 0.75 : 0.0
            visible: opacity > 0

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Rectangle {
            id: scrubIndicator
            anchors.centerIn: parent
            width: Math.min(gameList.width, gameList.height) * 0.42
            height: width
            radius: width / 2
            color: root.palette ? root.palette.accent : "#ffffff"
            border.width: 2
            border.color: root.palette ? root.palette.background : "#000000"
            opacity: 0
            scale: 0.4
            visible: opacity > 0
            z: 20

            layer.enabled: true
            layer.effect: DropShadow {
                radius: 18
                samples: 26
                color: "black"
                spread: 0.35
            }

            Text {
                anchors.centerIn: parent
                text: (gameList.scrubGroups.length > 0 && gameList.scrubIndex >= 0
                       && gameList.scrubIndex < gameList.scrubGroups.length)
                      ? gameList.scrubGroups[gameList.scrubIndex] : ""
                color: root.palette ? root.palette.accentText : "#000000"
                font.family: fontLoader.name
                font.bold: true
                font.pixelSize: scrubIndicator.width * 0.5
            }
        }

        ParallelAnimation {
            id: scrubIndicatorShowAnim
            NumberAnimation {
                target: scrubIndicator; property: "opacity"
                from: 0; to: 1; duration: 220; easing.type: Easing.OutQuad
            }
            NumberAnimation {
                target: scrubIndicator; property: "scale"
                from: 0.4; to: 1.0; duration: 320
                easing.type: Easing.OutBack; easing.overshoot: 1.3
            }
        }

        ParallelAnimation {
            id: scrubIndicatorHideAnim
            NumberAnimation {
                target: scrubIndicator; property: "opacity"
                from: 1; to: 0; duration: 180; easing.type: Easing.InQuad
            }
            NumberAnimation {
                target: scrubIndicator; property: "scale"
                from: 1.0; to: 0.5; duration: 180; easing.type: Easing.InQuad
            }
        }

        Connections {
            target: gameList
            function onScrubActiveChanged() {
                if (gameList.scrubActive)
                    scrubIndicatorShowAnim.restart();
                else
                    scrubIndicatorHideAnim.restart();
            }
        }

        Rectangle {
            id: launchOverlay
            anchors.fill: parent
            color: "black"
            opacity: 0
            visible: opacity > 0
            z: 1000

            property string logoSource: ""
            property string gameTitle: ""

            function trigger(game) {
                logoSource = (game && game.assets) ? (game.assets.logo || game.assets.marquee || "") : "";
                gameTitle = game ? game.title : "";
                launchLogo.scale = 0.35;
                launchLogo.opacity = 0;
                opacity = 0;
                launchAnimation.restart();
            }

            Image {
                id: launchLogo
                anchors.centerIn: parent
                source: launchOverlay.logoSource
                fillMode: Image.PreserveAspectFit
                width: parent.width * 0.35
                height: parent.height * 0.35
                smooth: true
                opacity: 0
                scale: 0.35
                visible: source !== "" && status !== Image.Error
            }

            Text {
                id: launchTitleFallback
                anchors.centerIn: parent
                width: parent.width * 0.7
                text: launchOverlay.gameTitle
                color: root.palette.textPrimary
                font.family: fontLoader.name
                font.bold: true
                font.pixelSize: root.width * 0.045 * root.fontScale
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                visible: !launchLogo.visible
                opacity: launchLogo.opacity
                scale: launchLogo.scale

                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 24
                    samples: 32
                    color: "black"
                    spread: 0.4
                }
            }

            SequentialAnimation {
                id: launchAnimation

                ParallelAnimation {
                    NumberAnimation {
                        target: launchOverlay
                        property: "opacity"
                        from: 0; to: 0.92
                        duration: 300
                        easing.type: Easing.OutQuad
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 80 }
                        NumberAnimation {
                            target: launchLogo
                            property: "opacity"
                            from: 0; to: 1
                            duration: 420
                            easing.type: Easing.OutQuad
                        }
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 80 }
                        NumberAnimation {
                            target: launchLogo
                            property: "scale"
                            from: 0.35; to: 1.0
                            duration: 520
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.3
                        }
                    }
                }

                PauseAnimation { duration: 380 }

                onStopped: {
                    root.launchGame(root.pendingLaunchIndex);
                    root.pendingLaunchIndex = -1;
                }
            }
        }

        Settings {
            id: settingsOverlay
            anchors.fill: parent
            z: 2000

            fontsList: root.fontsList
            colorSchemes: root.colorSchemes
            fontFamily: fontLoader.name
            palette: root.palette
            languages: root.languages
            strings: root.strings

            onFontPicked: function(index) {
                root.fontIndex = index;
                root.saveSettings();
            }

            onScalePicked: function(value) {
                root.fontScale = value;
                root.saveSettings();
            }

            onSchemePicked: function(index) {
                root.colorSchemeIndex = index;
                root.saveSettings();
            }

            onLanguagePicked: function(index) {
                root.languageIndex = index;
                root.saveSettings();
            }

            onSpacingPicked: function(value) {
                root.titleCollectionSpacing = value;
                root.saveSettings();
            }

            onGameRadiusPicked: function(value) {
                root.gameDelegateRadius = value;
                root.saveSettings();
            }

            onAlphaRadiusPicked: function(value) {
                root.alphabetDelegateRadius = value;
                root.saveSettings();
            }

            onVideoPlaybackPicked: function(value) {
                console.log("[settings] Video Playback picked ->", value,
                             "| juego actual:", root.game ? root.game.title : "null");
                root.videoPlaybackEnabled = value;
                root.saveSettings();
            }

            onTitleMarqueePicked: function(value) {
                root.titleMarqueeEnabled = value;
                root.saveSettings();
            }

            onCollectionMarqueePicked: function(value) {
                root.collectionMarqueeEnabled = value;
                root.saveSettings();
            }

            onVideoVolumePicked: function(value) {
                root.videoVolume = value;
                root.saveSettings();
            }

            onSfxVolumePicked: function(value) {
                root.sfxVolume = value;
                root.saveSettings();
            }

            onResetRequested: {
                root.resetSettingsToDefault();
            }

            onClosed: {
                gameList.forceActiveFocus();
            }
        }

        UpdateNotification {
            id: updateNotification
            anchors.fill: parent
            z: 2500

            fontFamily: fontLoader.name
            palette: root.palette
            strings: root.strings
            soundEffectUp: soundUp
            soundEffectDown: soundDown
            soundEffectOk: soundOk
            soundEffectCancel: soundDown
            soundEffectNotice: soundNotice

            onClosed: {
                gameList.forceActiveFocus();
            }
        }
    }

    Component.onCompleted: {
        console.log("[persist] root.onCompleted -> scheduling restoreState() via Qt.callLater");
        console.log("[layout] aspectRatio:", aspectRatio.toFixed(3),
                     "layoutMode:", layoutMode,
                     "uiScale:", uiScale.toFixed(3));
        root.loadSettings();
        Qt.callLater(root.restoreState);
        Qt.callLater(root.checkForUpdates);
    }
}
