import QtQuick 2.15

Rectangle {
    id: row

    property string label: ""
    property string valueText: ""
    property bool active: false
    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property real panelWidth: width
    property bool showArrows: true
    property bool rowDisabled: false

    height: parent ? parent.height : 40
    radius: 8
    clip: true
    opacity: row.rowDisabled ? 0.4 : 1.0
    color: active ? (palette ? palette.accent : "#ffffff") : "transparent"

    Row {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Text {
            text: row.label
            width: parent.width * (row.showArrows ? 0.5 : 1.0)
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            font.family: row.fontFamily
            font.pixelSize: row.panelWidth * 0.045 * row.fontScale
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            maximumLineCount: 1
            elide: Text.ElideRight
            color: row.active
                ? (row.palette ? row.palette.accentText : "black")
                : (row.palette ? row.palette.textPrimary : "white")
        }

        Text {
            visible: row.showArrows
            text: "◀"
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: row.panelWidth * 0.04 * row.fontScale
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            color: row.active
                ? (row.palette ? row.palette.accentText : "black")
                : (row.palette ? row.palette.textSecondary : "#aaaaaa")
        }

        Text {
            visible: row.showArrows
            text: row.valueText
            width: parent.width * 0.25
            height: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.family: row.fontFamily
            font.pixelSize: row.panelWidth * 0.045 * row.fontScale
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            maximumLineCount: 1
            elide: Text.ElideRight
            color: row.active
                ? (row.palette ? row.palette.accentText : "black")
                : (row.palette ? row.palette.textPrimary : "white")
        }

        Text {
            visible: row.showArrows
            text: "▶"
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: row.panelWidth * 0.04 * row.fontScale
            fontSizeMode: Text.Fit
            minimumPixelSize: 10
            color: row.active
                ? (row.palette ? row.palette.accentText : "black")
                : (row.palette ? row.palette.textSecondary : "#aaaaaa")
        }
    }
}
