import QtQuick 2.15
import QtGraphicalEffects 1.12

Item {
    id: filterRoot

    property string fontFamily: ""
    property real fontScale: 1.0
    property var palette: null
    property real uiScale: 1.0
    readonly property real iconSizeLarge: 60 * uiScale
    readonly property real iconSizeSmall: 47 * uiScale
    readonly property real hintFontPixelSize: 28.8 * uiScale * fontScale

    readonly property real fitScale: (width > 0 && content.implicitWidth > 0)
        ? Math.min(1.0, width / content.implicitWidth)
        : 1.0

    implicitWidth: content.implicitWidth * fitScale
    implicitHeight: content.implicitHeight * fitScale

    Row {
        id: content
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        transformOrigin: Item.Left
        scale: filterRoot.fitScale
        spacing: 8 * filterRoot.uiScale

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: filterRoot.iconSizeLarge
            height: filterRoot.iconSizeLarge

            Image {
                id: lbIcon
                anchors.fill: parent
                source: "assets/icons/lb.svg"
                mipmap: true
            }

            ColorOverlay {
                anchors.fill: lbIcon
                source: lbIcon
                color: (filterRoot.palette && filterRoot.palette.name === "Ice White") ? filterRoot.palette.textPrimary : "white"
            }
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: filterRoot.iconSizeLarge
            height: filterRoot.iconSizeLarge

            Image {
                id: rbIcon
                anchors.fill: parent
                source: "assets/icons/rb.svg"
                mipmap: true
            }

            ColorOverlay {
                anchors.fill: rbIcon
                source: rbIcon
                color: (filterRoot.palette && filterRoot.palette.name === "Ice White") ? filterRoot.palette.textPrimary : "white"
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "FILTER BY LETTER"
            font.family: filterRoot.fontFamily
            font.pixelSize: filterRoot.hintFontPixelSize
            color: filterRoot.palette ? filterRoot.palette.textPrimary : "white"
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: filterRoot.iconSizeSmall
            height: filterRoot.iconSizeSmall

            Image {
                id: aIcon
                anchors.fill: parent
                source: "assets/icons/a.svg"
                mipmap: true
            }

            ColorOverlay {
                anchors.fill: aIcon
                source: aIcon
                color: (filterRoot.palette && filterRoot.palette.name === "Ice White") ? filterRoot.palette.textPrimary : "white"
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "LAUNCH"
            font.family: filterRoot.fontFamily
            font.pixelSize: filterRoot.hintFontPixelSize
            color: filterRoot.palette ? filterRoot.palette.textPrimary : "white"
        }

        Item {
            anchors.verticalCenter: parent.verticalCenter
            width: filterRoot.iconSizeSmall
            height: filterRoot.iconSizeSmall
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
                color: (filterRoot.palette && filterRoot.palette.name === "Ice White") ? filterRoot.palette.textPrimary : "white"
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "SETTINGS"
            font.family: filterRoot.fontFamily
            font.pixelSize: filterRoot.hintFontPixelSize
            color: filterRoot.palette ? filterRoot.palette.textPrimary : "white"
        }
    }
}
