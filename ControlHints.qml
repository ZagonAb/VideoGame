import QtQuick 2.15

Row {
    id: filterRow

    property string fontFamily: ""

    spacing: 15

    Row {
        spacing: 3

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "assets/icons/lb.png"
            width: filterRow.parent.width * 0.024
            height: filterRow.parent.height * 0.04
            mipmap: true
        }

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "assets/icons/rb.png"
            width: filterRow.parent.width * 0.024
            height: filterRow.parent.height * 0.04
            mipmap: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "FILTER BY LETTER"
            font.family: filterRow.fontFamily
            font.pixelSize: filterRow.parent.width * 0.015
            color: "white"
        }
    }

    Row {
        spacing: 3

        Image {
            anchors.verticalCenter: parent.verticalCenter
            source: "assets/icons/a.png"
            width: filterRow.parent.width * 0.024
            height: filterRow.parent.height * 0.044
            mipmap: true
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "LAUNCH"
            font.family: filterRow.fontFamily
            font.pixelSize: filterRow.parent.width * 0.015
            color: "white"
        }
    }
}
