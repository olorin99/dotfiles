local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local icon = require("ui.widgets.icon")
local utils = require("utils")
local network = require("daemons.network")

local naughty = require("naughty")

return function(args)
    local args = args or {}
    local colour = args.colour or beautiful.fg_focus
    local size = args.size or dpi(20)

    local indicator = icon {
        icon = beautiful.wifi_icon,
        colour = colour,
        size = size
    }

    network:connect_signal("strength", function(_, strength)
        if strength >= 85 then
            indicator.markup = utils.coloured_text(beautiful.wifi_icon, colour)
        elseif strength >= 50 then
            indicator.markup = utils.coloured_text(beautiful.wifi_icon_3, colour)
        elseif strength >= 25 then
            indicator.markup = utils.coloured_text(beautiful.wifi_icon_2, colour)
        else
            indicator.markup = utils.coloured_text(beautiful.wifi_icon_1, colour)
        end
    end)

    return indicator
end
