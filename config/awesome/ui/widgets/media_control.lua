local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local playerctl = require("modules.bling").signal.playerctl.cli()
local button = require("ui.widgets.button")
local gears = require("gears")

return function(args)
    local width = args.width or dpi(100)
    local button_width = (width - dpi(10)) / 3

    local player = wibox.widget {
        button(button_width, { bg = "#00000000", icon = beautiful.media_previous_icon }, function()
            playerctl:previous(args.player)
        end),
        button(button_width, { bg = "#00000000", shape = gears.shape.rectangle, icon = beautiful.media_play_icon }, function()
            playerctl:play_pause(args.player)
        end),
        button(button_width, { bg = "#00000000", icon = beautiful.media_next_icon }, function()
            playerctl:next(args.player)
        end),
        layout = wibox.layout.flex.horizontal
    }

    return player
end
