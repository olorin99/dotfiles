local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")

local battery = require("ui.widgets.battery")
local brightness = require("ui.widgets.brightness")
local button = require("ui.widgets.button")
local volume = require("ui.widgets.volume")
local clock = require("ui.widgets.clock")

local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end)
)

awful.screen.connect_for_each_screen(function(s)
    local taglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        widget_template = {
            {
                {
                    id = "text_role",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                bg = "#666666",
                shape = utils.rrect(dpi(8)),
                forced_width = dpi(30),
                forced_height = dpi(30),
                widget = wibox.container.background
            },
            margins = dpi(4),
            widget = wibox.container.margin
        }
    }


    local bar = wibox.widget {
        {
            --left
            nil,
            --mid
            taglist,
            --right
            {
                battery(dpi(30), "north", true),
                brightness(dpi(30), "north"),
                volume(dpi(30), "north"),
                clock(15, "north"),
                button(dpi(30), { bg = "#abcabc", shape = utils.rrect(dpi(15)) }, function()
                    awesome.emit_signal("signals::sidepanel")
                end),
                spacing = dpi(5),
                layout = wibox.layout.fixed.horizontal
            },
            layout = wibox.layout.align.horizontal
        },
        right = dpi(20),
        left = dpi(20),
        top = dpi(5),
        bottom = dpi(5),
        widget = wibox.container.margin
    }

    s.bar = awful.wibar({
        screen = s,
        --position = "top",
        visible = true,
        ontop = false,
        type = "dock",
        height = dpi(30),
        width = s.geometry.width -dpi(48),
        bg = "#aaaaaa",
        shape = utils.rrect(dpi(15)),
        widget = bar
    })

    awful.placement.top(s.bar, { margins = dpi(8) })
    s.bar:struts({ top = s.bar.height + dpi(8) * 2, bottom = 0, left = 0, right = 0 })
end)
