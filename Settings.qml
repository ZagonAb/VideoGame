import QtQuick 2.15
import QtGraphicalEffects 1.12

FocusScope {
    id: settingsRoot

    property var fontsList: []
    property var colorSchemes: []
    property var languages: []
    property var strings: ({})

    readonly property var _fallbackStrings: ({
        title: "SETTINGS", font: "Font", fontSize: "Font Size",
        colorScheme: "Color Scheme", language: "Language",
        spacing: "Title/Collection Spacing", gameRadius: "Game List Radius",
        alphaRadius: "A-Z Selector Radius",
        videoVolume: "Video Volume", sfxVolume: "Sound Effects Volume",
        reset: "Reset to Default",
        hint: "\u2191\u2193 Navigate    \u2190\u2192 Change / Reset    B Close"
    })
    function tr(key) {
        return (strings && strings[key] !== undefined) ? strings[key] : _fallbackStrings[key];
    }

    property string fontFamily: ""
    property var palette: null

    property int fontIndex: 0
    property real fontScaleValue: 1.0
    property int colorSchemeIndex: 0
    property int languageIndex: 0
    property int spacingValue: 10
    property int gameRadiusValue: 5
    property int alphaRadiusValue: 50
    property int videoVolumeValue: 100
    property int sfxVolumeValue: 100
    property int activeRow: 0
    readonly property int rowCount: 10
    onActiveRowChanged: Qt.callLater(scrollToActiveRow)

    readonly property var rowItems: [rowFont, rowFontSize, rowColorScheme, rowLanguage,
                                       rowSpacing, rowGameRadius, rowAlphaRadius,
                                       rowVideoVolume, rowSfxVolume, rowReset]

    function scrollToActiveRow() {
        if (activeRow < 0 || activeRow >= rowItems.length) return;
        const item = rowItems[activeRow];
        if (!item) return;
        const itemTop = item.y;
        const itemBottom = item.y + item.height;
        if (itemTop < flick.contentY) {
            flick.contentY = Math.max(0, itemTop);
        } else if (itemBottom > flick.contentY + flick.height) {
            flick.contentY = Math.max(0, Math.min(flick.contentHeight - flick.height, itemBottom - flick.height));
        }
    }

    property real panelScale: 0.5

    signal fontPicked(int index)
    signal scalePicked(real value)
    signal schemePicked(int index)
    signal languagePicked(int index)
    signal spacingPicked(int value)
    signal gameRadiusPicked(int value)
    signal alphaRadiusPicked(int value)
    signal videoVolumePicked(int value)
    signal sfxVolumePicked(int value)
    signal resetRequested()
    signal closed()

    visible: opacity > 0
    opacity: 0

    function open(initFontIndex, initScale, initSchemeIndex, initLanguageIndex, initSpacing, initGameRadius, initAlphaRadius, initVideoVolume, initSfxVolume) {
        syncValues(initFontIndex, initScale, initSchemeIndex, initLanguageIndex, initSpacing, initGameRadius, initAlphaRadius, initVideoVolume, initSfxVolume);
        activeRow = 0;
        panelScale = 0.5;
        opacity = 0;
        flick.contentY = 0;
        settingsRoot.forceActiveFocus();
        openAnimation.restart();
        Qt.callLater(scrollToActiveRow);
    }

    function syncValues(fIndex, scale, schemeIndex, langIndex, spacing, gameRadius, alphaRadius, videoVolume, sfxVolume) {
        fontIndex = fIndex;
        fontScaleValue = scale;
        colorSchemeIndex = schemeIndex;
        languageIndex = langIndex;
        spacingValue = spacing;
        gameRadiusValue = gameRadius;
        alphaRadiusValue = alphaRadius;
        videoVolumeValue = videoVolume;
        sfxVolumeValue = sfxVolume;
    }

    function close() {
        closeAnimation.restart();
    }

    function changeValue(direction) {
        if (activeRow === 0 && fontsList.length > 0) {
            const newIndex = (fontIndex + direction + fontsList.length) % fontsList.length;
            fontIndex = newIndex;
            fontPicked(newIndex);
        } else if (activeRow === 1) {
            let newScale = fontScaleValue + direction * 0.1;
            newScale = Math.max(0.7, Math.min(1.5, Math.round(newScale * 10) / 10));
            fontScaleValue = newScale;
            scalePicked(newScale);
        } else if (activeRow === 2 && colorSchemes.length > 0) {
            const newSchemeIndex = (colorSchemeIndex + direction + colorSchemes.length) % colorSchemes.length;
            colorSchemeIndex = newSchemeIndex;
            schemePicked(newSchemeIndex);
        } else if (activeRow === 3 && languages.length > 0) {
            const newLangIndex = (languageIndex + direction + languages.length) % languages.length;
            languageIndex = newLangIndex;
            languagePicked(newLangIndex);
        } else if (activeRow === 4) {
            const newSpacing = Math.max(-20, Math.min(40, spacingValue + direction));
            spacingValue = newSpacing;
            spacingPicked(newSpacing);
        } else if (activeRow === 5) {
            const newGameRadius = Math.max(0, Math.min(40, gameRadiusValue + direction));
            gameRadiusValue = newGameRadius;
            gameRadiusPicked(newGameRadius);
        } else if (activeRow === 6) {
            const newAlphaRadius = Math.max(0, Math.min(50, alphaRadiusValue + direction));
            alphaRadiusValue = newAlphaRadius;
            alphaRadiusPicked(newAlphaRadius);
        } else if (activeRow === 7) {
            const newVideoVolume = Math.max(0, Math.min(100, videoVolumeValue + direction * 5));
            videoVolumeValue = newVideoVolume;
            videoVolumePicked(newVideoVolume);
        } else if (activeRow === 8) {
            const newSfxVolume = Math.max(0, Math.min(100, sfxVolumeValue + direction * 5));
            sfxVolumeValue = newSfxVolume;
            sfxVolumePicked(newSfxVolume);
        } else if (activeRow === 9) {
            resetRequested();
        }
    }

    Keys.onUpPressed: activeRow = (activeRow + rowCount - 1) % rowCount
    Keys.onDownPressed: activeRow = (activeRow + 1) % rowCount
    Keys.onLeftPressed: changeValue(-1)
    Keys.onRightPressed: changeValue(1)

    Keys.onPressed: function(event) {
        if (!event.isAutoRepeat && (api.keys.isCancel(event) || api.keys.isFilters(event))) {
            event.accepted = true;
            settingsRoot.close();
        } else if (!event.isAutoRepeat && activeRow === 9 && api.keys.isAccept(event)) {
            event.accepted = true;
            resetRequested();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.75 * settingsRoot.opacity
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: parent.width * 0.46
        height: Math.min(parent.height * 0.94,
                          margin + titleItem.height + titleSpacing + contentColumn.height + margin)
        radius: 14
        clip: true
        color: settingsRoot.palette ? settingsRoot.palette.surface : "#111111"
        border.color: settingsRoot.palette ? settingsRoot.palette.accent : "#ffffff"
        border.width: 2
        opacity: settingsRoot.opacity
        scale: settingsRoot.panelScale

        property real margin: width * 0.06
        property real titleSpacing: width * 0.025
        property real rowHeight: Math.max(38, width * 0.115 * settingsRoot.fontScaleValue)

        Text {
            id: titleItem
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: panel.margin
            text: settingsRoot.tr("title")
            horizontalAlignment: Text.AlignHCenter
            font.family: settingsRoot.fontFamily
            font.bold: true
            font.pixelSize: panel.width * 0.09 * settingsRoot.fontScaleValue
            fontSizeMode: Text.HorizontalFit
            minimumPixelSize: 14
            color: settingsRoot.palette ? settingsRoot.palette.textPrimary : "white"
        }

        Flickable {
            id: flick
            anchors.top: titleItem.bottom
            anchors.topMargin: panel.titleSpacing
            anchors.left: parent.left
            anchors.leftMargin: panel.margin
            anchors.right: parent.right
            anchors.rightMargin: panel.margin
            anchors.bottom: parent.bottom
            anchors.bottomMargin: panel.margin
            contentWidth: width
            contentHeight: contentColumn.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height

            Column {
                id: contentColumn
                width: flick.width
                spacing: panel.width * 0.025

                SettingsRow {
                    id: rowFont
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 0
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("font")
                    valueText: (settingsRoot.fontIndex >= 0 && settingsRoot.fontIndex < settingsRoot.fontsList.length)
                        ? settingsRoot.fontsList[settingsRoot.fontIndex].name : ""
                }

                SettingsRow {
                    id: rowFontSize
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 1
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("fontSize")
                    valueText: Math.round(settingsRoot.fontScaleValue * 100) + "%"
                }

                SettingsRow {
                    id: rowColorScheme
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 2
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("colorScheme")
                    valueText: (settingsRoot.colorSchemeIndex >= 0 && settingsRoot.colorSchemeIndex < settingsRoot.colorSchemes.length)
                        ? settingsRoot.colorSchemes[settingsRoot.colorSchemeIndex].name : ""
                }

                SettingsRow {
                    id: rowLanguage
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 3
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("language")
                    valueText: (settingsRoot.languageIndex >= 0 && settingsRoot.languageIndex < settingsRoot.languages.length)
                        ? settingsRoot.languages[settingsRoot.languageIndex].name : ""
                }

                SettingsRow {
                    id: rowSpacing
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 4
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("spacing")
                    valueText: settingsRoot.spacingValue + "px"
                }

                SettingsRow {
                    id: rowGameRadius
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 5
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("gameRadius")
                    valueText: settingsRoot.gameRadiusValue + "px"
                }

                SettingsRow {
                    id: rowAlphaRadius
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 6
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("alphaRadius")
                    valueText: settingsRoot.alphaRadiusValue + "px"
                }

                SettingsRow {
                    id: rowVideoVolume
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 7
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("videoVolume")
                    valueText: settingsRoot.videoVolumeValue + "%"
                }

                SettingsRow {
                    id: rowSfxVolume
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 8
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("sfxVolume")
                    valueText: settingsRoot.sfxVolumeValue + "%"
                }

                SettingsRow {
                    id: rowReset
                    width: parent.width
                    height: panel.rowHeight
                    panelWidth: panel.width
                    active: settingsRoot.activeRow === 9
                    fontFamily: settingsRoot.fontFamily
                    fontScale: settingsRoot.fontScaleValue
                    palette: settingsRoot.palette
                    label: settingsRoot.tr("reset")
                    showArrows: false
                }

                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: settingsRoot.tr("hint")
                    font.family: settingsRoot.fontFamily
                    font.pixelSize: panel.width * 0.028 * settingsRoot.fontScaleValue
                    fontSizeMode: Text.HorizontalFit
                    minimumPixelSize: 9
                    color: settingsRoot.palette ? settingsRoot.palette.textSecondary : "#aaaaaa"
                }
            }
        }
    }

    ParallelAnimation {
        id: openAnimation
        NumberAnimation {
            target: settingsRoot
            property: "opacity"
            from: 0; to: 1
            duration: 250
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: settingsRoot
            property: "panelScale"
            from: 0.5; to: 1.0
            duration: 380
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    ParallelAnimation {
        id: closeAnimation
        NumberAnimation {
            target: settingsRoot
            property: "opacity"
            from: 1; to: 0
            duration: 200
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: settingsRoot
            property: "panelScale"
            from: 1.0; to: 0.6
            duration: 200
            easing.type: Easing.InQuad
        }

        onStopped: {
            settingsRoot.closed();
        }
    }
}
