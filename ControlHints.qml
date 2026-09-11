import QtQuick 2.15
import QtGraphicalEffects 1.12

Row {
    id: filterRow

    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property real uiScale: 1.0
    readonly property real iconSizeLarge: 60 * uiScale
    readonly property real iconSizeSmall: 47 * uiScale

    spacing: 15

    Row {
        spacing: 5

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: filterRow.iconSizeLarge
            height: filterRow.iconSizeLarge

            Image {
                id: lbIcon
                anchors.fill: parent
                source: "assets/icons/lb.svg"
                mipmap: true
            }

            ColorOverlay {
                anchors.fill: lbIcon
                source: lbIcon
                color: (filterRow.palette && filterRow.palette.name === "Ice White") ? filterRow.palette.textPrimary : "white"
            }
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: filterRow.iconSizeLarge
            height: filterRow.iconSizeLarge

            Image {
                id: rbIcon
                anchors.fill: parent
                source: "assets/icons/rb.svg"
                mipmap: true
            }

            ColorOverlay {
                anchors.fill: rbIcon
                source: rbIcon
                color: (filterRow.palette && filterRow.palette.name === "Ice White") ? filterRow.palette.textPrimary : "white"
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "FILTER BY LETTER"
            font.family: filterRow.fontFamily
            font.pixelSize: filterRow.parent.width * 0.015 * filterRow.fontScale
            color: filterRow.palette ? filterRow.palette.textPrimary : "white"
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: filterRow.iconSizeSmall
            height: filterRow.iconSizeSmall

            Image {
                id: aIcon
                anchors.fill: parent
                source: "assets/icons/a.svg"
                mipmap: true
            }

            ColorOverlay {
                anchors.fill: aIcon
                source: aIcon
                color: (filterRow.palette && filterRow.palette.name === "Ice White") ? filterRow.palette.textPrimary : "white"
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "LAUNCH"
            font.family: filterRow.fontFamily
            font.pixelSize: filterRow.parent.width * 0.015 * filterRow.fontScale
            color: filterRow.palette ? filterRow.palette.textPrimary : "white"
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: filterRow.iconSizeSmall
            height: filterRow.iconSizeSmall
            visible: settingsHintIcon.visible

            Image {
                id: settingsHintIcon
                anchors.fill: parent
                source: "assets/icons/y.svg"
                mipmap: true
                visible: status !== Image.Error
                onStatusChanged: {
                    if (status === Image.Error) visible = false;
                }
            }

            ColorOverlay {
                anchors.fill: settingsHintIcon
                source: settingsHintIcon
                visible: settingsHintIcon.visible
                color: (filterRow.palette && filterRow.palette.name === "Ice White") ? filterRow.palette.textPrimary : "white"
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
