import QtQuick 2.15
import "qrc:/qmlutils" as PegasusUtils

Item {
    id: gameDescriptionContainer

    property var game: null
    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property int cardRadius: vpx(5)
    property real cardOpacity: 0.95

    function colorWithAlpha(colorValue, alpha) {
        var c = Qt.darker(colorValue, 1.0);
        return Qt.rgba(c.r, c.g, c.b, alpha);
    }

    Rectangle {
        id: cardBackground
        anchors.fill: parent
        radius: gameDescriptionContainer.cardRadius
        color: gameDescriptionContainer.palette ? gameDescriptionContainer.palette.surface : "#000000"
        opacity: gameDescriptionContainer.cardOpacity
        border.width: vpx(2)
        border.color: gameDescriptionContainer.palette
            ? gameDescriptionContainer.colorWithAlpha(gameDescriptionContainer.palette.accent, 0.35)
            : "transparent"
    }

    PegasusUtils.AutoScroll {
        id: autoscroll
        anchors.fill: parent
        anchors.margins: 18
        pixelsPerSecond: 20
        scrollWaitDuration: 2000

        Text {
            id: descriptionText
            width: autoscroll.width
            text: (gameDescriptionContainer.game && gameDescriptionContainer.game.description)
                  ? gameDescriptionContainer.game.description
                  : "Sin descripción disponible."
            color: gameDescriptionContainer.palette ? gameDescriptionContainer.palette.textPrimary : "white"
            font.family: gameDescriptionContainer.fontFamily
            font.pixelSize: Math.max(12, gameDescriptionContainer.width * 0.042 * gameDescriptionContainer.fontScale)
            wrapMode: Text.WordWrap
            lineHeight: 1.2
        }
    }
}
