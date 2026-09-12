import QtQuick 2.15

Item {
    id: notice

    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property real cardOpacity: 0.95
    property int cardRadius: 12
    property real cardWidthRatio: 0.42
    property int minCardWidth: 260
    property int maxCardWidth: 640
    property int autoHideDelay: 2600
    property int slideDuration: 380

    property string message: ""
    property real fadeOpacity: 0
    property real slideOffset: -(height + topOffset)
    property real topOffset: 24

    width: parent
        ? Math.min(maxCardWidth, Math.max(minCardWidth, parent.width * cardWidthRatio))
        : minCardWidth
    height: messageText.implicitHeight + 28

    anchors.top: parent ? parent.top : undefined
    anchors.topMargin: topOffset
    anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined

    opacity: fadeOpacity
    visible: opacity > 0
    transform: Translate { y: notice.slideOffset }

    function colorWithAlpha(colorValue, alpha) {
        var c = Qt.darker(colorValue, 1.0);
        return Qt.rgba(c.r, c.g, c.b, alpha);
    }

    Rectangle {
        anchors.fill: parent
        radius: notice.cardRadius
        color: notice.palette ? notice.palette.surface : "#111111"
        opacity: notice.cardOpacity
        border.width: 2
        border.color: notice.palette
            ? notice.colorWithAlpha(notice.palette.accent, 0.9)
            : "#ffffff"
    }

    Text {
        id: messageText
        anchors.centerIn: parent
        width: parent.width - 32
        text: notice.message
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.family: notice.fontFamily
        font.pixelSize: Math.max(13, notice.width * 0.052 * notice.fontScale)
        color: notice.palette ? notice.palette.textPrimary : "#ffffff"
    }

    function show(text) {
        notice.message = text;
        hideTimer.stop();
        showAnimation.stop();
        hideAnimation.stop();
        notice.slideOffset = -(notice.height + notice.topOffset);
        notice.fadeOpacity = 0;
        showAnimation.start();
        hideTimer.restart();
    }

    function hide() {
        hideTimer.stop();
        showAnimation.stop();
        hideAnimation.start();
    }

    ParallelAnimation {
        id: showAnimation
        NumberAnimation {
            target: notice
            property: "fadeOpacity"
            from: 0; to: 1
            duration: notice.slideDuration
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: notice
            property: "slideOffset"
            to: 0
            duration: notice.slideDuration
            easing.type: Easing.OutBack
            easing.overshoot: 1.1
        }
    }

    ParallelAnimation {
        id: hideAnimation
        NumberAnimation {
            target: notice
            property: "fadeOpacity"
            to: 0
            duration: 260
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: notice
            property: "slideOffset"
            to: -(notice.height + notice.topOffset)
            duration: 260
            easing.type: Easing.InQuad
        }
    }

    Timer {
        id: hideTimer
        interval: notice.autoHideDelay
        repeat: false
        onTriggered: notice.hide()
    }
}
