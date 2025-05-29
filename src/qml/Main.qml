import QtQuick 2.15
import QtQuick.Controls.Material
import QtQuick.Layouts

ApplicationWindow {
    id: appWindow
    width: 1450
    height: 850
    visible: true
    title: "BirchFlow"
    minimumWidth: 1450
    minimumHeight: 850


    function setSettings() {
        appSetting.setValue("app_width", appWindow.width)
        appSetting.setValue("app_height", appWindow.height)
        appSetting.setValue("app_x", appWindow.x)
        appSetting.setValue("app_y", appWindow.y)
    }
    function loadSettings() {
        appWindow.x = appSetting.getValue("app_x", 10);
        appWindow.y = appSetting.getValue("app_y", 10);
        appWindow.width = appSetting.getValue("app_width", 1450);
        appWindow.height = appSetting.getValue("app_height", 850);
    }
    Rectangle {
        anchors.fill: parent
        color: "#1f2630"

        App {
            id: app
            anchors.fill: parent
        }
    }

    Notification {
        id: notification
        anchors.fill: parent
    }

    onWidthChanged: {
        notification.updatePositions();
        setSettings();
    }
    onHeightChanged: {
        notification.updatePositions()
        setSettings();
    }

    onClosing: {
        setSettings();
    }

    Component.onCompleted: loadSettings()
}
