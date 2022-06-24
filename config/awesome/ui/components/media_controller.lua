local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local playerctl = require("modules.bling").signal.playerctl.cli()
local button = require("ui.widgets.button")
local gears = require("gears")
local icon = require("ui.widgets.icon")

return function(args)
    local width = args.width or dpi(100)
    local button_width = (width - dpi(10)) / 3

    local player = wibox.widget {
        button({ size = button_width, bg = "#00000000", child = icon({ icon = beautiful.media_previous_icon, size = button_width }) }, function()
            playerctl:previous(args.player)
        end),
        button({ size = button_width, bg = "#00000000", child = icon({ icon = beautiful.media_play_icon, size = button_width}) }, function()
            playerctl:play_pause(args.player)
        end),
        button({ size = button_width, bg = "#00000000", child = icon({ icon = beautiful.media_next_icon, size = button_width }) }, function()
            playerctl:next(args.player)
        end),
        layout = wibox.layout.flex.horizontal
    }

    return player
end
