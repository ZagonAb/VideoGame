import QtQuick 2.15

FocusScope {
    id: notification

    property var strings: ({})
    readonly property var _fallbackStrings: ({
        updateTitle: "New Update Available",
        updateBody: "A new version is available: ",
        viewChanges: "View Changes",
        openGithub: "Open on GitHub",
        close: "Close",
        updateHint: "\u2190\u2192 Navigate    A Select    B Close"
    })
    function tr(key) {
        return (strings && strings[key] !== undefined) ? strings[key] : _fallbackStrings[key];
    }

    property string fontFamily: ""
    property var palette: null
    property var soundEffectUp: null
    property var soundEffectDown: null
    property var soundEffectOk: null
    property var soundEffectCancel: null
    property var soundEffectNotice: null
    property string latestVersion: ""
    property string releaseUrl: ""
    property string releaseNotes: ""
    property bool expanded: false

    signal closed()

    visible: opacity > 0
    opacity: 0
    property real cardScale: 0.5

    function show(version, url, notes) {
        latestVersion = version;
        releaseUrl = url;
        releaseNotes = notes || "";
        expanded = false;
        cardScale = 0.5;
        opacity = 0;
        notification.forceActiveFocus();
        if (notification.soundEffectNotice) notification.soundEffectNotice.play();
        openAnimation.restart();
        Qt.callLater(function() { viewButton.forceActiveFocus(); });
    }

    function hide() {
        closeAnimation.restart();
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: 0.75 * notification.opacity

        MouseArea {
            anchors.fill: parent
            onClicked: notification.hide()
        }
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: notification.expanded
            ? Math.min(parent.width * 0.82, 860)
            : Math.min(parent.width * 0.5, 640)
        height: column.height + margin * 2
        radius: 14
        clip: true
        color: notification.palette ? notification.palette.surface : "#111111"
        border.color: notification.palette ? notification.palette.accent : "#ffffff"
        border.width: 2
        opacity: notification.opacity
        scale: notification.cardScale

        property real margin: width * 0.02

        Behavior on width {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
        }

        Behavior on height {
            NumberAnimation { duration: 220; easing.type: Easing.OutQuad }
        }

        Column {
            id: column
            anchors.top: parent.top
            anchors.topMargin: card.margin
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - card.margin * 2
            spacing: card.width * 0.025

            Text {
                width: parent.width
                text: "\u2728 " + notification.tr("updateTitle")
                horizontalAlignment: Text.AlignHCenter
                font.family: notification.fontFamily
                font.bold: true
                font.pixelSize: card.width * 0.055
                fontSizeMode: Text.HorizontalFit
                minimumPixelSize: 14
                color: notification.palette ? notification.palette.accent : "#ffffff"
            }

            Text {
                width: parent.width
                text: notification.tr("updateBody") + notification.latestVersion
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                font.family: notification.fontFamily
                font.pixelSize: card.width * 0.035
                color: notification.palette ? notification.palette.textPrimary : "white"
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: card.width * 0.03

                Rectangle {
                    id: viewButton
                    width: column.width * 0.3
                    height: card.width * 0.08
                    radius: 8
                    color: activeFocus
                        ? (notification.palette ? notification.palette.accent : "#ffffff")
                        : "transparent"
                    border.color: notification.palette ? notification.palette.accent : "#ffffff"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: notification.tr("viewChanges")
                        font.family: notification.fontFamily
                        font.bold: true
                        font.pixelSize: card.width * 0.028
                        fontSizeMode: Text.HorizontalFit
                        minimumPixelSize: 10
                        width: parent.width * 0.9
                        horizontalAlignment: Text.AlignHCenter
                        color: viewButton.activeFocus
                            ? (notification.palette ? notification.palette.accentText : "black")
                            : (notification.palette ? notification.palette.textPrimary : "white")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            viewButton.forceActiveFocus();
                            notification.expanded = !notification.expanded;
                        }
                    }

                    Keys.onPressed: function(event) {
                        if (event.isAutoRepeat) return;
                        if (api.keys.isAccept(event)) {
                            event.accepted = true;
                            if (notification.soundEffectOk) notification.soundEffectOk.play();
                            notification.expanded = !notification.expanded;
                        } else if (api.keys.isCancel(event)) {
                            event.accepted = true;
                            if (notification.soundEffectCancel) notification.soundEffectCancel.play();
                            notification.hide();
                        } else if (event.key === Qt.Key_Right) {
                            event.accepted = true;
                            if (notification.soundEffectDown) notification.soundEffectDown.play();
                            openButton.forceActiveFocus();
                        }
                    }
                }

                Rectangle {
                    id: openButton
                    width: column.width * 0.34
                    height: card.width * 0.08
                    radius: 8
                    color: activeFocus
                        ? (notification.palette ? notification.palette.accent : "#ffffff")
                        : "transparent"
                    border.color: notification.palette ? notification.palette.accent : "#ffffff"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: notification.tr("openGithub")
                        font.family: notification.fontFamily
                        font.bold: true
                        font.pixelSize: card.width * 0.028
                        fontSizeMode: Text.HorizontalFit
                        minimumPixelSize: 10
                        width: parent.width * 0.9
                        horizontalAlignment: Text.AlignHCenter
                        color: openButton.activeFocus
                            ? (notification.palette ? notification.palette.accentText : "black")
                            : (notification.palette ? notification.palette.textPrimary : "white")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (notification.releaseUrl) Qt.openUrlExternally(notification.releaseUrl);
                            notification.hide();
                        }
                    }

                    Keys.onPressed: function(event) {
                        if (event.isAutoRepeat) return;
                        if (api.keys.isAccept(event)) {
                            event.accepted = true;
                            if (notification.soundEffectOk) notification.soundEffectOk.play();
                            if (notification.releaseUrl) Qt.openUrlExternally(notification.releaseUrl);
                            notification.hide();
                        } else if (api.keys.isCancel(event)) {
                            event.accepted = true;
                            if (notification.soundEffectCancel) notification.soundEffectCancel.play();
                            notification.hide();
                        } else if (event.key === Qt.Key_Left) {
                            event.accepted = true;
                            if (notification.soundEffectUp) notification.soundEffectUp.play();
                            viewButton.forceActiveFocus();
                        } else if (event.key === Qt.Key_Right) {
                            event.accepted = true;
                            if (notification.soundEffectDown) notification.soundEffectDown.play();
                            closeButton.forceActiveFocus();
                        }
                    }
                }

                Rectangle {
                    id: closeButton
                    width: column.width * 0.24
                    height: card.width * 0.08
                    radius: 8
                    color: activeFocus
                        ? (notification.palette ? notification.palette.accent : "#ffffff")
                        : "transparent"
                    border.color: notification.palette ? notification.palette.accent : "#ffffff"
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: notification.tr("close")
                        font.family: notification.fontFamily
                        font.bold: true
                        font.pixelSize: card.width * 0.028
                        fontSizeMode: Text.HorizontalFit
                        minimumPixelSize: 10
                        width: parent.width * 0.9
                        horizontalAlignment: Text.AlignHCenter
                        color: closeButton.activeFocus
                            ? (notification.palette ? notification.palette.accentText : "black")
                            : (notification.palette ? notification.palette.textPrimary : "white")
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: notification.hide()
                    }

                    Keys.onPressed: function(event) {
                        if (event.isAutoRepeat) return;
                        if (api.keys.isAccept(event) || api.keys.isCancel(event)) {
                            event.accepted = true;
                            if (notification.soundEffectCancel) notification.soundEffectCancel.play();
                            notification.hide();
                        } else if (event.key === Qt.Key_Left) {
                            event.accepted = true;
                            if (notification.soundEffectUp) notification.soundEffectUp.play();
                            openButton.forceActiveFocus();
                        }
                    }
                }
            }

            Text {
                width: parent.width
                visible: notification.expanded && notification.releaseNotes.length > 0
                text: notification.releaseNotes
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                font.family: notification.fontFamily
                font.pixelSize: card.width * 0.026
                color: notification.palette ? notification.palette.textSecondary : "#cccccc"
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: notification.tr("updateHint")
                font.family: notification.fontFamily
                font.pixelSize: card.width * 0.03
                fontSizeMode: Text.HorizontalFit
                minimumPixelSize: 9
                color: notification.palette ? notification.palette.textSecondary : "#aaaaaa"
            }
        }
    }

    Keys.onPressed: function(event) {
        if (!event.isAutoRepeat && api.keys.isCancel(event)) {
            event.accepted = true;
            if (notification.soundEffectCancel) notification.soundEffectCancel.play();
            notification.hide();
        }
    }

    ParallelAnimation {
        id: openAnimation
        NumberAnimation {
            target: notification
            property: "opacity"
            from: 0; to: 1
            duration: 250
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: notification
            property: "cardScale"
            from: 0.5; to: 1.0
            duration: 380
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    ParallelAnimation {
        id: closeAnimation
        NumberAnimation {
            target: notification
            property: "opacity"
            from: 1; to: 0
            duration: 200
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: notification
            property: "cardScale"
            from: 1.0; to: 0.6
            duration: 200
            easing.type: Easing.InQuad
        }

        onStopped: {
            notification.closed();
        }
    }
}
