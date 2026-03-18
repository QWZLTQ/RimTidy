pragma Singleton
import QtQuick

// Fluent / macOS / Win11 inspired theme
QtObject {
    // Surface colors
    readonly property color background: "#F3F3F3"
    readonly property color surface: "#FAFAFA"
    readonly property color card: "#FFFFFF"
    readonly property color sidebar: "#F0F0F0"

    // Borders
    readonly property color border: "#E0E0E0"
    readonly property color borderSubtle: "#EBEBEB"

    // Accent
    readonly property color accent: "#0078D4"
    readonly property color accentHover: "#106EBE"
    readonly property color accentPressed: "#005A9E"
    readonly property color accentLight: "#CCE4F7"

    // Text
    readonly property color textPrimary: "#1A1A1A"
    readonly property color textSecondary: "#5C5C5C"
    readonly property color textTertiary: "#8A8A8A"

    // Semantic
    readonly property color danger: "#D13438"
    readonly property color success: "#107C10"
    readonly property color warning: "#FFB900"

    // Hover / Selection
    readonly property color hover: "#F5F5F5"
    readonly property color selection: "#CCE4F7"
    readonly property color selectionActive: "#B4D6F0"

    // Title bar
    readonly property color titleBar: "#F3F3F3"
    readonly property color titleBarBorder: "#E0E0E0"
    readonly property color closeHover: "#E81123"

    // Sizing
    readonly property int borderRadius: 8
    readonly property int borderRadiusSmall: 4
    readonly property int borderRadiusLarge: 12
    readonly property int titleBarHeight: 34
    readonly property int spacing: 8
    readonly property int spacingSmall: 4
    readonly property int spacingLarge: 16

    // Font
    readonly property string fontFamily: "Segoe UI"
    readonly property int fontSizeSmall: 11
    readonly property int fontSize: 13
    readonly property int fontSizeLarge: 15
}
