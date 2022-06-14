local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local gears = require("gears")
local utils = require("utils")
local playerctl = require("modules.bling").signal.playerctl.cli()
local button = require("ui.widgets.button")
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
    markup = utils.coloured_text("Unknown", "#ffffff"),
    align = "center",
    widget = wibox.widget.textbox
}

local song_title = wibox.widget {
    font = beautiful.font_var .. " 20",
    markup = utils.coloured_text("None Playing", "#ffffff"),
    align = "center",
    widget = wibox.widget.textbox
}

playerctl:connect_signal("metadata", function(_, title, artist, album_path, _, _, _)
    if title == "" then
        title = "None"
    end
    if artist == "" then
        artist = "Unknown"
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


    song_artist:set_markup_silently(utils.coloured_text(artist, "#ffffff"))
    song_title:set_markup_silently(utils.coloured_text(title, "#ffffff"))
end)

function music_decorations(c)


    awful.titlebar(c, {
        position = "bottom",
        size = dpi(100),
        bg = beautiful.bg_normal
    }):setup {
        {
            {
                album_art,
                valign = "center",
                halign = "center",
                widget = wibox.container.place
            },
            {
                {
                    song_title,
                    song_artist,
                    layout = wibox.layout.fixed.vertical,
                },
                top = dpi(20),
                widget = wibox.container.margin
            },
            {
                button(dpi(50), { bg = "#00ff00" }, function()
                    playerctl:previous()
                end),
                button(dpi(50), { bg = "#ff0000" }, function()
                    playerctl:play_pause()
                end),
                button(dpi(50), { bg = "#0000ff" }, function()
                    playerctl:next()
                end),
                layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.layout.align.horizontal
        },
        left = dpi(20),
        right = dpi(20),
        widget = wibox.container.margin
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
