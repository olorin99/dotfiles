---------------------------
-- Default awesome theme --
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local gfs = require("gears.filesystem")
local themes_path = gfs.get_themes_dir()

local utils = require("utils")

local colours = {
    rosewater = "#f5e0dc",
    flamingo = "#f2cdcd",
    pink = "#f5c2e7",
    mauve = "#cba6f7",
    red = "#f38ba8",
    maroon = "#eba0ac",
    peach = "#fab387",
    yellow = "#f9e2af",
    green = "#a6e3a1",
    teal = "#94e2d5",
    sky = "#89dceb",
    sapphire = "#74c7ec",
    blue = "#89b4fa",
    lavender = "#b4befe",
    text = "#cdd6f4",
    subtext1 = "#bac2de",
    subtext0 = "#a6adc8",
    overlay2 = "#9399b2",
    overlay1 = "#7f849c",
    overlay0 = "#6c7086",
    surface2 = "#585b70",
    surface1 = "#45475a",
    surface0 = "#313244",
    base = "#1e1e2e",
    mantle = "#181825",
    crust = "#11111b"
}

local theme = {}

theme.colours = colours
theme.font_var = "Montserrat"

theme.font          = theme.font_var .. " 8"

theme.bg_normal     = colours.base
theme.bg_focus      = colours.crust
theme.bg_urgent     = colours.mantle
theme.bg_minimize   = "#444444"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = colours.subtext0
theme.fg_focus      = colours.text
theme.fg_urgent     = colours.subtext1
theme.fg_minimize   = "#ffffff"

theme.useless_gap   = dpi(8)
theme.border_width  = dpi(1)
theme.border_color = "#000000"
theme.border_normal = "#000000"
theme.border_focus  = "#050407"
theme.border_marked = "#91231c"

theme.rounded_corners = dpi(15)

theme.panel = colours.mantle
theme.panel1 = colours.surface2

theme.success = colours.green
theme.warning = colours.peach
theme.error = colours.maroon

-- icons
theme.icon_font_var = "Material Icons, Regular"
theme.icon_font = theme.icon_font_var .. " 8"

theme.search_icon = utils.utf8("e8b6")
theme.home_icon = utils.utf8("e88a")

-- device icons
theme.wifi_icon = utils.utf8("e1d8")
theme.wifi_icon_1 = utils.utf8("ebe4")
theme.wifi_icon_2 = utils.utf8("ebd6")
theme.wifi_icon_3 = utils.utf8("ebe1")
theme.wifi_icon_4 = utils.utf8("e1d8")
theme.bluetooth_icon = utils.utf8("e1a7")

theme.brightness_icon = utils.utf8("e1ac")

theme.volume_icon = utils.utf8("e050")
theme.volume_icon_off = utils.utf8("e04f")

-- media icons
theme.media_play_icon = utils.utf8("e037")
theme.media_pause_icon = utils.utf8("e034")
theme.media_next_icon = utils.utf8("e044")
theme.media_previous_icon = utils.utf8("e045")


-- ensure is same order as awful.layout.layouts
theme.layout_icons = {
    themes_path.."default/layouts/tilew.png",
    themes_path.."default/layouts/floatingw.png"
}

theme.wallpaper = user.home .. "/Pictures/Wallpapers/_DSC0941.jpg"


-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
