local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local playerctl = require("modules.bling").signal.playerctl.cli()
local button = require("ui.widgets.button")
local gears = require("gears")
local icon = require("ui.widgets.icon")

local naughty = require("naughty")

return function(args)
    local width = args.width or dpi(100)
    local button_width = (width / 2 - dpi(10)) / 3

    local album_art = wibox.widget {
        forced_height = width / 4,
        forced_width = width / 4,
        widget = wibox.widget.imagebox
    }

    local song_title = wibox.widget {
        markup = utils.coloured_text("Unknown", beautiful.fg_focus),
        align = "center",
        valign = "center",
        font = beautiful.font_var .. " 12",
        forced_width = width / 4 * 3,
        widget = wibox.widget.textbox
    }

    local song_artist = wibox.widget {
        markup = utils.coloured_text("Unknown", "#000000"),
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local song_position = wibox.widget {
        bar_shape = utils.rrect(dpi(8)),
        bar_height = dpi(10),
        bar_color = beautiful.panel1,
        bar_active_color = beautiful.colours.blue,
        handle_color = beautiful.colours.blue,
        handle_shape = gears.shape.circle,
        handle_width = dpi(9),
        forced_width = width / 2,
        forced_height = dpi(10),
        value = 70,
        maximum = 100,
        minimum = 0,
        widget = wibox.widget.slider
    }

    local previous = button({
        size = button_width,
        bg = "#00000000",
        child = icon{
            icon = beautiful.media_previous_icon,
            size = button_width
        }
    },
    function()
        playerctl:previous(args.player)
    end)

    local play_pause = button({
        size = button_width,
        bg = "#00000000",
        child = icon {
            icon = beautiful.media_play_icon,
            size = button_width
        }
    },
    function()
        playerctl:play_pause(args.player)
    end)

    local next = button({
        size = button_width,
        bg = "#00000000",
        child = icon {
            icon = beautiful.media_next_icon,
            size = button_width
        }
    },
    function()
        playerctl:next(args.player)
    end)

    local player = wibox.widget {
        {
            album_art,
            {
                song_title,
                song_artist,
                layout = wibox.layout.flex.vertical
            },
            nil,
            layout = wibox.layout.align.horizontal
        },
        {
            previous,
            play_pause,
            next,
            layout = wibox.layout.flex.horizontal
        },
        spacing = dpi(3),
        song_position,
        layout = wibox.layout.fixed.vertical
    }

    playerctl:connect_signal("metadata", function(_, title, artist, album_path, _, _, _)
        if title == "" then
            title = "Unknown"
        end
        if artist == "" then
            artist = "Unknown"
        end

        awful.spawn.easy_async("playerctl metadata --format '{{mpris:artUrl}}'", function(stdout, _, _, exit_code)
            if not (exit_code == 0) then
                return
            end
            local path = string.gsub(stdout, "\n", "")
            path = string.gsub(path, "file://", "")
            album_art:set_image(gears.surface.load_uncached(path))
        end)

        song_title:set_markup_silently(utils.coloured_text(title, beautiful.fg_focus))
        song_artist:set_markup_silently(utils.coloured_text(artist, beautiful.fg_focus))
    end)

    playerctl:connect_signal("position", function(_, current_pos, total_pos, player_name)
        song_position.value = (current_pos / total_pos) * 100
    end)

    return player
end
