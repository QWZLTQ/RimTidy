pragma Singleton
import QtQuick

QtObject {
    property string mode: "light"
    property string scheme: "default"

    // ---- Full color scheme definitions ----
    readonly property var _schemes: ({
        // 默认 — 经典中性灰白/黑
        "default": {
            bgL: "#F3F3F3", surfL: "#FAFAFA", cardL: "#FFFFFF", sideL: "#F0F0F0",
            borderL: "#E0E0E0", borderSL: "#EBEBEB", hoverL: "#E8E8E8", titleL: "#F3F3F3",
            accentL: "#0078D4", accentHL: "#106EBE", accentPL: "#005A9E", accentLL: "#CCE4F7",
            selL: "#CCE4F7", selAL: "#B4D6F0",
            bgD: "#1A1A1A", surfD: "#242424", cardD: "#2D2D2D", sideD: "#242424",
            borderD: "#3A3A3A", borderSD: "#303030", hoverD: "#353535", titleD: "#1A1A1A",
            accentD: "#4CA6E8", accentHD: "#3A96D8", accentPD: "#2886C8", accentLD: "#1A3A5C",
            selD: "#264F78", selAD: "#1A4068",
            textPL: "#1A1A1A", textSL: "#5C5C5C", textTL: "#8A8A8A",
            textPD: "#E4E4E4", textSD: "#A0A0A0", textTD: "#666666"
        },
        // 石榴 — 明月珰冷青 × 石榴暖红
        "pomegranate": {
            bgL: "#D6E8EE", surfL: "#DFEEF3", cardL: "#E8F3F6", sideL: "#CEE2EA",
            borderL: "#A8C8D5", borderSL: "#B8D5DF", hoverL: "#C5DDE6", titleL: "#CEE2EA",
            accentL: "#C93756", accentHL: "#B52E4A", accentPL: "#9E2640", accentLL: "#F0C5CF",
            selL: "#F0C5CF", selAL: "#E8AAB8",
            bgD: "#1A1215", surfD: "#241A1E", cardD: "#2D2024", sideD: "#211820",
            borderD: "#3D2A30", borderSD: "#332228", hoverD: "#352830", titleD: "#1A1215",
            accentD: "#E8607A", accentHD: "#D5506A", accentPD: "#C2405A", accentLD: "#3D1A24",
            selD: "#3D1A24", selAD: "#4D2230",
            textPL: "#1A2830", textSL: "#4A6068", textTL: "#708890",
            textPD: "#F0D8DC", textSD: "#B89098", textTD: "#7A5560"
        },
        // 紫堇 — 雪青淡紫底 × 紫罗兰
        "violet": {
            bgL: "#D8D0F0", surfL: "#E0D8F4", cardL: "#E8E2F8", sideL: "#D0C8EC",
            borderL: "#B0A4D8", borderSL: "#C0B5E0", hoverL: "#CAC0E5", titleL: "#D0C8EC",
            accentL: "#7B4FD2", accentHL: "#6B3FC2", accentPL: "#5B2FB2", accentLL: "#D5CCF5",
            selL: "#D5CCF5", selAL: "#C4B8F0",
            bgD: "#1A1525", surfD: "#221D30", cardD: "#2A253A", sideD: "#201B2D",
            borderD: "#3A3050", borderSD: "#302840", hoverD: "#332D45", titleD: "#1A1525",
            accentD: "#A78BFA", accentHD: "#9575F0", accentPD: "#8360E6", accentLD: "#2D1B69",
            selD: "#2D1B69", selAD: "#3B2480",
            textPL: "#1E1830", textSL: "#4A4068", textTL: "#6A6088",
            textPD: "#E0D8F0", textSD: "#A898C8", textTD: "#706090"
        },
        // 松竹 — 萱草暖黄底 × 松绿
        "pine": {
            bgL: "#E8E0C0", surfL: "#EEE8CC", cardL: "#F4F0D8", sideL: "#E2DAB8",
            borderL: "#C8C0A0", borderSL: "#D5CEB0", hoverL: "#DAD2B5", titleL: "#E2DAB8",
            accentL: "#057748", accentHL: "#046A40", accentPL: "#035C37", accentLL: "#B8E5D0",
            selL: "#B8E5D0", selAL: "#A0D8C0",
            bgD: "#151A14", surfD: "#1D241C", cardD: "#252D24", sideD: "#1B221A",
            borderD: "#2E3D2C", borderSD: "#263326", hoverD: "#30402E", titleD: "#151A14",
            accentD: "#3FB978", accentHD: "#35A86C", accentPD: "#2B9760", accentLD: "#0D3324",
            selD: "#0D3324", selAD: "#14402E",
            textPL: "#282518", textSL: "#585540", textTL: "#787560",
            textPD: "#D8E4D0", textSD: "#98A890", textTD: "#607858"
        },
        // 碧玉 — 玉色青白底 × 碧山
        "jade": {
            bgL: "#C8E4DC", surfL: "#D2ECE5", cardL: "#DCF2EC", sideL: "#C0DED5",
            borderL: "#98C5B8", borderSL: "#A8D0C5", hoverL: "#B5D8CC", titleL: "#C0DED5",
            accentL: "#2F9988", accentHL: "#28877A", accentPL: "#21756B", accentLL: "#B0E0D5",
            selL: "#B0E0D5", selAL: "#98D5C8",
            bgD: "#121A18", surfD: "#1A2422", cardD: "#222D2A", sideD: "#182220",
            borderD: "#2A3D38", borderSD: "#223330", hoverD: "#2D403A", titleD: "#121A18",
            accentD: "#5CC4B2", accentHD: "#4CB5A3", accentPD: "#3CA694", accentLD: "#143D37",
            selD: "#143D37", selAD: "#1B4D44",
            textPL: "#152825", textSL: "#3D5E58", textTL: "#5A807A",
            textPD: "#D0E8E3", textSD: "#90B5AD", textTD: "#588078"
        },
        // 海棠 — 粉红底 × 海棠红
        "crabapple": {
            bgL: "#F0CCC5", surfL: "#F5D8D2", cardL: "#F8E2DD", sideL: "#ECC4BC",
            borderL: "#D8A8A0", borderSL: "#E0B5AD", hoverL: "#E5BDB5", titleL: "#ECC4BC",
            accentL: "#DB5A6B", accentHL: "#C94E5E", accentPL: "#B54252", accentLL: "#F5C8CF",
            selL: "#F5C8CF", selAL: "#F0B0BA",
            bgD: "#1E1416", surfD: "#281C1F", cardD: "#312327", sideD: "#25191D",
            borderD: "#40282E", borderSD: "#382025", hoverD: "#432D32", titleD: "#1E1416",
            accentD: "#F07888", accentHD: "#E06878", accentPD: "#D05868", accentLD: "#3D1A22",
            selD: "#3D1A22", selAD: "#4D222C",
            textPL: "#301818", textSL: "#684040", textTL: "#906060",
            textPD: "#F0D5D8", textSD: "#C09098", textTD: "#805560"
        },
        // 秋波 — 秋波淡蓝底 × 若竹青
        "autumn": {
            bgL: "#C5DBE8", surfL: "#D0E2EE", cardL: "#DAE9F2", sideL: "#BDD5E2",
            borderL: "#98B8CC", borderSL: "#A8C5D5", hoverL: "#B2CDD8", titleL: "#BDD5E2",
            accentL: "#4A9BB5", accentHL: "#3E8DA6", accentPL: "#327F97", accentLL: "#B5D8E8",
            selL: "#B5D8E8", selAL: "#A0CDE0",
            bgD: "#121A1E", surfD: "#1A2328", cardD: "#222C32", sideD: "#182025",
            borderD: "#283840", borderSD: "#203035", hoverD: "#2C3A42", titleD: "#121A1E",
            accentD: "#7CC5D5", accentHD: "#6CB8C8", accentPD: "#5CABBB", accentLD: "#1A2D42",
            selD: "#1A2D42", selAD: "#223A52",
            textPL: "#152028", textSL: "#3D5868", textTL: "#5A7888",
            textPD: "#D0E4EC", textSD: "#90B5C5", textTD: "#588098"
        },
        // 绀青 — 碧落天青底 × 绀宇深靛
        "indigo": {
            bgL: "#C5CDE5", surfL: "#D0D6EB", cardL: "#DAE0F0", sideL: "#BDC5E0",
            borderL: "#98A0C8", borderSL: "#A8B0D0", hoverL: "#B0B8D5", titleL: "#BDC5E0",
            accentL: "#2E4D8F", accentHL: "#263F7A", accentPL: "#1E3366", accentLL: "#B0BDE0",
            selL: "#B0BDE0", selAL: "#98AAD5",
            bgD: "#0E1320", surfD: "#161C2A", cardD: "#1E2534", sideD: "#141A28",
            borderD: "#253045", borderSD: "#1E2838", hoverD: "#283548", titleD: "#0E1320",
            accentD: "#6B9FD8", accentHD: "#5B8FC8", accentPD: "#4B7FB8", accentLD: "#141E36",
            selD: "#141E36", selAD: "#1B2844",
            textPL: "#181830", textSL: "#3D4068", textTL: "#5A6088",
            textPD: "#D0D8EC", textSD: "#90A0C0", textTD: "#586888"
        },
        // 新维加斯 — Pip-Boy 琥珀色 × 废土深褐
        "pipboy": {
            bgL: "#E8DCC0", surfL: "#EEE4CC", cardL: "#F4ECD8", sideL: "#E2D6B8",
            borderL: "#C8B890", borderSL: "#D5C8A5", hoverL: "#DACCA8", titleL: "#E2D6B8",
            accentL: "#CC9900", accentHL: "#B88A00", accentPL: "#A47A00", accentLL: "#F0DDA0",
            selL: "#F0DDA0", selAL: "#E5CC80",
            bgD: "#1A1400", surfD: "#221C08", cardD: "#2A2210", sideD: "#201A05",
            borderD: "#3D3418", borderSD: "#332C12", hoverD: "#3A3015", titleD: "#1A1400",
            accentD: "#FFCC00", accentHD: "#E6B800", accentPD: "#CCA300", accentLD: "#332800",
            selD: "#332800", selAD: "#443600",
            textPL: "#302808", textSL: "#685520", textTL: "#907840",
            textPD: "#FFCC00", textSD: "#CC9F00", textTD: "#8A6E00"
        }
    })

    // ---- Helpers ----
    function _s() { return _schemes[scheme] || _schemes["default"] }

    // ---- Surface colors ----
    readonly property color background: mode === "dark" ? _s().bgD : _s().bgL
    readonly property color surface: mode === "dark" ? _s().surfD : _s().surfL
    readonly property color card: mode === "dark" ? _s().cardD : _s().cardL
    readonly property color sidebar: mode === "dark" ? _s().sideD : _s().sideL

    // ---- Borders ----
    readonly property color border: mode === "dark" ? _s().borderD : _s().borderL
    readonly property color borderSubtle: mode === "dark" ? _s().borderSD : _s().borderSL

    // ---- Accent ----
    readonly property color accent: mode === "dark" ? _s().accentD : _s().accentL
    readonly property color accentHover: mode === "dark" ? _s().accentHD : _s().accentHL
    readonly property color accentPressed: mode === "dark" ? _s().accentPD : _s().accentPL
    readonly property color accentLight: mode === "dark" ? _s().accentLD : _s().accentLL

    // ---- Text ----
    readonly property color textPrimary: mode === "dark" ? _s().textPD : _s().textPL
    readonly property color textSecondary: mode === "dark" ? _s().textSD : _s().textSL
    readonly property color textTertiary: mode === "dark" ? _s().textTD : _s().textTL

    // ---- Semantic (universal) ----
    readonly property color danger: mode === "dark" ? "#F85149" : "#D13438"
    readonly property color success: mode === "dark" ? "#3FB950" : "#107C10"
    readonly property color warning: mode === "dark" ? "#D29922" : "#FFB900"

    // ---- Hover / Selection ----
    readonly property color hover: mode === "dark" ? _s().hoverD : _s().hoverL
    readonly property color selection: mode === "dark" ? _s().selD : _s().selL
    readonly property color selectionActive: mode === "dark" ? _s().selAD : _s().selAL

    // ---- Title bar ----
    readonly property color titleBar: mode === "dark" ? _s().titleD : _s().titleL
    readonly property color titleBarBorder: border
    readonly property color closeHover: "#E81123"

    // ---- Sizing ----
    readonly property int borderRadius: 8
    readonly property int borderRadiusSmall: 4
    readonly property int borderRadiusLarge: 12
    readonly property int titleBarHeight: 34
    readonly property int spacing: 8
    readonly property int spacingSmall: 4
    readonly property int spacingLarge: 16

    // ---- Font ----
    readonly property string fontFamily: "Microsoft YaHei UI"
    readonly property int fontSizeSmall: 11
    readonly property int fontSize: 13
    readonly property int fontSizeLarge: 15

    // ---- Scheme metadata for UI ----
    readonly property var schemeNames: ["default", "pomegranate", "violet", "pine", "jade", "crabapple", "autumn", "indigo", "pipboy"]
    readonly property var schemeLabels: ["默认", "石榴", "紫堇", "松竹", "碧玉", "海棠", "秋波", "绀青", "夕阳沙士"]

    function toggleMode() {
        mode = (mode === "light") ? "dark" : "light"
    }
}
