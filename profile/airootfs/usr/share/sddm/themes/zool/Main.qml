// Zool OS — شاشة الدخول (SDDM، Qt6)
import QtQuick

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "#10181c"

    readonly property color sand: "#f3e6cc"
    readonly property color sandDim: "#b9a98a"
    readonly property color gold: "#e8b04a"
    readonly property color terracotta: "#d46a43"
    readonly property color surface: "#172229"
    readonly property string display: "Reem Kufi"
    readonly property string body: "Noto Sans Arabic"

    // حقل نصي بسيط (TextInput داخل مستطيل) — لا يعتمد على نمط Qt Quick Controls
    component Field: Rectangle {
        id: fld
        property alias text: input.text
        property alias echoMode: input.echoMode
        property string hint: ""
        property alias inputItem: input
        signal accepted()
        height: 48
        radius: 24
        color: "#e6213039"
        border.width: input.activeFocus ? 2 : 1
        border.color: input.activeFocus ? root.gold : "#44e8b04a"

        TextInput {
            id: input
            anchors.fill: parent
            anchors.leftMargin: 22
            anchors.rightMargin: 22
            verticalAlignment: TextInput.AlignVCenter
            horizontalAlignment: TextInput.AlignHCenter
            color: root.sand
            selectionColor: root.gold
            selectedTextColor: root.surface
            font.family: root.body
            font.pixelSize: 17
            clip: true
            onAccepted: fld.accepted()
        }
        Text {
            anchors.centerIn: parent
            visible: input.text.length === 0
            text: fld.hint
            color: root.sandDim
            font.family: root.body
            font.pixelSize: 16
        }
    }

    Image {
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#55101820" }
            GradientStop { position: 1.0; color: "#cc101820" }
        }
    }

    // الساعة
    Column {
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.06
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 2
        Text {
            id: clockText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.sand
            font.family: root.display
            font.pixelSize: 64
            font.bold: true
            text: Qt.formatTime(new Date(), "hh:mm")
        }
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.gold
            font.family: root.body
            font.pixelSize: 18
            text: Qt.locale("ar").toString(new Date(), "dddd d MMMM yyyy")
        }
    }
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var now = new Date()
            clockText.text = Qt.formatTime(now, "hh:mm")
            dateText.text = Qt.locale("ar").toString(now, "dddd d MMMM yyyy")
        }
    }

    // بطاقة الدخول
    Rectangle {
        id: card
        anchors.centerIn: parent
        anchors.verticalCenterOffset: parent.height * 0.06
        width: 400
        height: content.implicitHeight + 64
        radius: 28
        color: "#d9172229"
        border.width: 1
        border.color: "#38e8b04a"

        Column {
            id: content
            anchors.centerIn: parent
            width: parent.width - 64
            spacing: 14

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                source: "logo.png"
                width: 96
                height: 96
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "زول"
                color: root.gold
                font.family: root.display
                font.pixelSize: 30
                font.bold: true
            }

            Field {
                id: userField
                width: parent.width
                hint: "اسم المستخدم"
                KeyNavigation.tab: passField.inputItem
                onAccepted: passField.inputItem.forceActiveFocus()
            }
            Field {
                id: passField
                width: parent.width
                hint: "كلمة المرور"
                echoMode: TextInput.Password
                onAccepted: root.doLogin()
            }

            Rectangle {
                id: loginBtn
                width: parent.width
                height: 48
                radius: 24
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.gold }
                    GradientStop { position: 1.0; color: root.terracotta }
                }
                opacity: loginArea.pressed ? 0.8 : 1.0
                Text {
                    anchors.centerIn: parent
                    text: "دخول"
                    color: "#10181c"
                    font.family: root.display
                    font.pixelSize: 19
                    font.bold: true
                }
                MouseArea {
                    id: loginArea
                    anchors.fill: parent
                    onClicked: root.doLogin()
                }
            }

            Text {
                id: errText
                anchors.horizontalCenter: parent.horizontalCenter
                text: ""
                color: root.terracotta
                font.family: root.body
                font.pixelSize: 15
                visible: text.length > 0
            }
        }
    }

    // أزرار الطاقة
    Row {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 28
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 26

        Repeater {
            model: [
                { label: "سكون", act: 0, ok: true },
                { label: "إعادة التشغيل", act: 1, ok: true },
                { label: "إيقاف التشغيل", act: 2, ok: true }
            ]
            delegate: Text {
                text: modelData.label
                color: pArea.containsMouse ? root.gold : root.sand
                font.family: root.body
                font.pixelSize: 16
                MouseArea {
                    id: pArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData.act === 0) sddm.suspend()
                        else if (modelData.act === 1) sddm.reboot()
                        else sddm.powerOff()
                    }
                }
            }
        }
    }

    function doLogin() {
        errText.text = ""
        sddm.login(userField.text, passField.text, sessionModel.lastIndex)
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            errText.text = "كلمة المرور غير صحيحة"
            passField.text = ""
            passField.inputItem.forceActiveFocus()
        }
    }

    Component.onCompleted: {
        if (userModel.lastUser && userModel.lastUser.length > 0) {
            userField.text = userModel.lastUser
            passField.inputItem.forceActiveFocus()
        } else {
            userField.inputItem.forceActiveFocus()
        }
    }
}
