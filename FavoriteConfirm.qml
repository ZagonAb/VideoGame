import QtQuick 2.15
import QtGraphicalEffects 1.12

FocusScope {
    id: favoriteConfirm

    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property var strings: ({})
    property var soundNavigate: null
    property var soundOpen: null
    property var soundCancel: null

    signal confirmed()
    signal cancelled()

    readonly property var _fallbackStrings: ({
        favRemoveTitle: "Remove \"%1\" from Favorites?",
        favRemoveCancel: "Cancel",
        favRemoveConfirm: "Remove"
    })

    function tr(key) {
        return (strings && strings[key] !== undefined) ? strings[key] : _fallbackStrings[key];
    }

    visible: opacity > 0
    opacity: 0

    property string gameTitle: ""
    property int focusIndex: 0

    function open(title) {
        gameTitle = title;
        focusIndex = 0;
        favoriteConfirm.forceActiveFocus();
        showAnim.restart();
        if (soundOpen) soundOpen.play();
    }

    function close() {
        hideAnim.restart();
    }

    function doCancel() {
        favoriteConfirm.close();
        if (soundCancel) soundCancel.play();
        favoriteConfirm.cancelled();
    }

    function doConfirm() {
        favoriteConfirm.close();
        favoriteConfirm.confirmed();
    }

    Keys.onPressed: function(event) {
        event.accepted = true;
        if (event.key === Qt.Key_Left || event.key === Qt.Key_Right) {
            focusIndex = focusIndex === 0 ? 1 : 0;
            if (soundNavigate) soundNavigate.play();
        }
        else if (api.keys.isCancel(event)) {
            favoriteConfirm.doCancel();
        }
        else if (api.keys.isAccept(event)) {
            if (focusIndex === 1) {
                favoriteConfirm.doConfirm();
            } else {
                favoriteConfirm.doCancel();
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.6
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.5, parent.height * 0.9)
        height: cardColumn.height + parent.height * 0.08
        radius: vpx(5)
        color: favoriteConfirm.palette ? favoriteConfirm.palette.surface : "#1a1a1a"
        border.width: 2
        border.color: favoriteConfirm.palette ? favoriteConfirm.palette.accent : "#ffffff"

        layer.enabled: true
        layer.effect: DropShadow {
            radius: 24
            samples: 32
            color: "#000000"
            spread: 0.3
        }

        Column {
            id: cardColumn
            anchors.centerIn: parent
            width: parent.width * 0.85
            spacing: favoriteConfirm.height * 0.03

            Text {
                width: parent.width
                text: favoriteConfirm.tr("favRemoveTitle").arg(favoriteConfirm.gameTitle)
                color: favoriteConfirm.palette ? favoriteConfirm.palette.textPrimary : "#ffffff"
                font.family: favoriteConfirm.fontFamily
                font.bold: true
                font.pixelSize: favoriteConfirm.width * 0.022 * favoriteConfirm.fontScale
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: favoriteConfirm.width * 0.03

                Rectangle {
                    id: cancelButton
                    width: favoriteConfirm.width * 0.14
                    height: favoriteConfirm.height * 0.07
                    radius: vpx(5)
                    color: favoriteConfirm.focusIndex === 0
                        ? (favoriteConfirm.palette ? favoriteConfirm.palette.accent : "#ffffff")
                        : "transparent"
                    border.width: 2
                    border.color: favoriteConfirm.palette ? favoriteConfirm.palette.accent : "#ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: favoriteConfirm.tr("favRemoveCancel")
                        font.family: favoriteConfirm.fontFamily
                        font.bold: favoriteConfirm.focusIndex === 0
                        font.pixelSize: favoriteConfirm.width * 0.018 * favoriteConfirm.fontScale
                        color: favoriteConfirm.focusIndex === 0
                            ? (favoriteConfirm.palette ? favoriteConfirm.palette.accentText : "#000000")
                            : (favoriteConfirm.palette ? favoriteConfirm.palette.textPrimary : "#ffffff")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: favoriteConfirm.doCancel()
                    }
                }

                Rectangle {
                    id: confirmButton
                    width: favoriteConfirm.width * 0.14
                    height: favoriteConfirm.height * 0.07
                    radius: vpx(5)
                    color: favoriteConfirm.focusIndex === 1
                        ? (favoriteConfirm.palette ? favoriteConfirm.palette.accent : "#ffffff")
                        : "transparent"
                    border.width: 2
                    border.color: favoriteConfirm.palette ? favoriteConfirm.palette.accent : "#ffffff"

                    Text {
                        anchors.centerIn: parent
                        text: favoriteConfirm.tr("favRemoveConfirm")
                        font.family: favoriteConfirm.fontFamily
                        font.bold: favoriteConfirm.focusIndex === 1
                        font.pixelSize: favoriteConfirm.width * 0.018 * favoriteConfirm.fontScale
                        color: favoriteConfirm.focusIndex === 1
                            ? (favoriteConfirm.palette ? favoriteConfirm.palette.accentText : "#000000")
                            : (favoriteConfirm.palette ? favoriteConfirm.palette.textPrimary : "#ffffff")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: favoriteConfirm.doConfirm()
                    }
                }
            }
        }
    }

    NumberAnimation {
        id: showAnim
        target: favoriteConfirm
        property: "opacity"
        to: 1
        duration: 220
        easing.type: Easing.OutQuad
    }

    NumberAnimation {
        id: hideAnim
        target: favoriteConfirm
        property: "opacity"
        to: 0
        duration: 180
        easing.type: Easing.InQuad
    }
}
