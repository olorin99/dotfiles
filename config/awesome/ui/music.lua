local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local utils = require("utils")
local playerctl = require("modules.bling").signal.playerctl.cli()
local button = require("ui.widgets.button")
local icon = require("ui.widgets.icon")
local naughty = require("naughty")


local album_art = wibox.widget {
    --clip_shape = utils.rrect(dpi(15)),
    forced_height = dpi(80),
    forced_width = dpi(80),
    bg = "#ffffff",
    image = user.awesome_config .. "/icons/media-playback-start.png",
    widget = wibox.widget.imagebox
}

local song_artist = wibox.widget {
    font = beautiful.font_var .. " 14",
    markup = utils.coloured_text("Unknown", "#ffffff"),
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local song_album = wibox.widget {
    font = beautiful.font_var .. " 14",
    markup = utils.coloured_text("Unknown", "#ffffff"),
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local song_title = wibox.widget {
    font = beautiful.font_var .. " 20",
    markup = utils.coloured_text("None Playing", "#ffffff"),
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox
}

local song_position = wibox.widget {
    max_value = 100,
    value = 70,
    forced_height = dpi(10),
    bar_shape = utils.rrect(dpi(8)),
    color = beautiful.colours.blue,
    background_color = beautiful.panel1,
    widget = wibox.widget.progressbar
}
--[[local song_position = wibox.widget {
    bar_shape = gears.shape.rectangle,
    bar_height = dpi(10),
    bar_color = beautiful.panel1,
    bar_active_color = beautiful.colours.blue,
    handle_color = beautiful.colours.blue,
    handle_shape = gears.shape.circle,
    handle_width = dpi(9),
    forced_height = dpi(10),
    value = 70,
    maximum = 100,
    minimum = 0,
    widget = wibox.widget.slider
}]]--

--song_position:connect_signal("property::value", function()
--    playerctl:set_position(song_position.value)
--end)

--[[local button_hold = false
song_position:connect_signal("button::press", function()
    button_hold = true
    playerctl:pause("mpd")
end)

song_position:connect_signal("mouse::leave", function()
    if not button_hold then
        return
    end
    playerctl:set_position(song_position.value, "mpd")
    button_hold = false
end)]]--


local previous = button({
    size = dpi(60),
    bg = "#00000000",
    child = icon {
        icon = beautiful.media_previous_icon,
        size = dpi(60)
    }
},
function()
    playerctl:previous("mpd")
end)

local play_pause = button({
    size = dpi(60),
    bg = "#00000000",
    child = icon {
        icon = beautiful.media_play_icon,
        size = dpi(60)
    }
},
function()
    playerctl:play_pause("mpd")
end)

local next = button({
    size = dpi(60),
    bg = "#00000000",
    child = icon {
        icon = beautiful.media_next_icon,
        size = dpi(60)
    }
},
function()
    playerctl:next("mpd")
end)

local volume = wibox.widget {
    bar_shape = utils.rrect(dpi(8)),
    bar_height = dpi(10),
    bar_color = beautiful.panel1,
    bar_active_color = beautiful.colours.blue,
    handle_color = beautiful.colours.blue,
    handle_shape = gears.shape.circle,
    handle_width = dpi(9),
    forced_height = dpi(10),
    forced_width = dpi(100),
    value = 70,
    maximum = 100,
    minimum = 0,
    widget = wibox.widget.slider
}

volume:connect_signal("property::value", function()
    playerctl:set_volume(volume.value / 100, "mpd")
end)

--playerctl:connect_signal("volume", function(_, volume)
--    naughty.notify({ message = tostring(volume * 100) })
--    volume.value = math.floor(volume * 100)
--end)

playerctl:connect_signal("metadata", function(_, title, artist, album_path, album, player_name)
    if not (player_name == "mpd") then
        return
    end

    if title == "" then
        title = "None"
    end
    if artist == "" then
        artist = "Unknown"
    end
    if album == "" then
        album = "Unknown"
    end
    if album_path == "" then
        album_path = user.awesome_config .. "/icons/media-playback-start.png"
    end

    -- doesnt seem to produce proper album paths
    -- dont think it plays nice with NAS
    awful.spawn.easy_async("playerctl metadata --format '{{mpris:artUrl}}'", function(stdout, _, _, exit_code)
        if not (exit_code == 0) then
            return
        end
        album_path = string.gsub(stdout, "\n", "")
        album_path = string.gsub(album_path, "file://", "")
        album_art:set_image(gears.surface.load_uncached(album_path))
    end)


    song_artist:set_markup_silently(utils.coloured_text(artist, beautiful.fg_focus))
    song_title:set_markup_silently(utils.coloured_text(title, beautiful.fg_focus))
    song_album:set_markup_silently(utils.coloured_text(album, beautiful.fg_focus))
end)

playerctl:connect_signal("position", function(_, current_pos, total_pos)
    song_position.max_value = total_pos
    song_position.value = current_pos
    --song_position.value = (current_pos / total_pos) * 100
end)

function music_decorations(c)
    
    awful.titlebar(c, {
        position = "bottom",
        size = dpi(100),
        bg = beautiful.bg_normal
    }):setup {
        song_position,
        {
            {
                album_art,
                {
                    song_title,
                    {
                        {
                            song_artist,
                            {
                                orientation = "vertical",
                                forced_height = dpi(10),
                                forced_width = dpi(10),
                                thickness = dpi(1),
                                widget = wibox.widget.separator
                            },
                            song_album,
                            layout = wibox.layout.fixed.horizontal
                        },
                        valign = "center",
                        halign = "center",
                        widget = wibox.container.place
                    },
                    layout = wibox.layout.flex.vertical
                },
                {
                    volume,
                    previous,
                    play_pause,
                    next,
                    layout = wibox.layout.fixed.horizontal
                },
                layout = wibox.layout.align.horizontal
            },
            left = dpi(50),
            right = dpi(50),
            widget = wibox.container.margin
        },
        layout = wibox.layout.fixed.vertical
    }
end

table.insert(awful.rules.rules, {
    rule_any = {
        class = { "music" },
        instance = { "music" }
    },
    properties = {},
    callback = music_decorations
})
