import QtQuick 2.15

Row {
    id: filterRow

    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null

    spacing: 15

    Row {
        spacing: 5

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "assets/icons/lb.svg"
            width: filterRow.parent.width * 0.042
            height: filterRow.parent.height * 0.064
            mipmap: true
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "assets/icons/rb.svg"
            width: filterRow.parent.width * 0.042
            height: filterRow.parent.height * 0.064
            mipmap: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "FILTER BY LETTER"
            font.family: filterRow.fontFamily
            font.pixelSize: filterRow.parent.width * 0.015 * filterRow.fontScale
            color: filterRow.palette ? filterRow.palette.textPrimary : "white"
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "assets/icons/a.svg"
            width: filterRow.parent.width * 0.024
            height: filterRow.parent.height * 0.044
            mipmap: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "LAUNCH"
            font.family: filterRow.fontFamily
            font.pixelSize: filterRow.parent.width * 0.015 * filterRow.fontScale
            color: filterRow.palette ? filterRow.palette.textPrimary : "white"
        }

        Image {
            id: settingsHintIcon
            anchors.verticalCenter: parent.verticalCenter
            source: "assets/icons/y.svg"
            width: filterRow.parent.width * 0.024
            height: filterRow.parent.height * 0.044
            mipmap: true
            visible: status !== Image.Error
            onStatusChanged: {
                if (status === Image.Error) visible = false;
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "SETTINGS"
            font.family: filterRow.fontFamily
            font.pixelSize: filterRow.parent.width * 0.015 * filterRow.fontScale
            color: filterRow.palette ? filterRow.palette.textPrimary : "white"
        }
    }
}
