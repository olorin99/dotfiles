local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")

local battery = require("ui.components.battery")
local button = require("ui.widgets.button")
local clock = require("ui.components.clock")
local icon = require("ui.widgets.icon")
local wifi = require("ui.components.wifi_indicator")

local naughty = require("naughty")

local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end)
)

awful.screen.connect_for_each_screen(function(s)

    local height = beautiful.top_bar_height
    local margins = height * 0.2
    local icon_size = (height - margins * 2) * 0.8

    local taglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons,
        style = {
            fg_focus = "#000000",
            bg_focus = beautiful.active,
            bg_occupied = beautiful.inactive,
            bg_empty = beautiful.inactive,
            shape = utils.rrect(dpi(8))
        },
        widget_template = {
            {
                {
                    id = "text_role",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                id = "background_role",
                forced_width = height,
                forced_height = height * 0.5,
                widget = wibox.container.background
            },
            margins = height * 0.05,
            widget = wibox.container.margin
        }
    }


    local layout_switcher = button({ 
        width = height,
        height = height - margins * 2,
        bg = beautiful.inactive,
        shape = utils.rrect(dpi(15)),
        child = wibox.widget {
            valign = "center",
            halign = "center",
            forced_height = icon_size,
            forced_width = icon_size,
            image = beautiful.layout_icons[1],
            widget = wibox.widget.imagebox
        }
    },
    function(self)
        awful.layout.inc(1)
    end)

    tag.connect_signal("property::layout", function(t)
        if not beautiful.layout_icons then return end
        layout_switcher.children[1].image = beautiful.layout_icons[awful.layout.get_tag_layout_index(t)]
    end)
    tag.connect_signal("property::selected", function(t)
        if not beautiful.layout_icons then return end
        layout_switcher.children[1].image = beautiful.layout_icons[awful.layout.get_tag_layout_index(t)]
    end)

    local bar = wibox.widget {
        {
            --left
            layout_switcher,
            --mid
            {
                taglist,
                left = dpi(20),
                widget = wibox.container.margin
            },
            --right
            {
                wifi { size = height * 0.5 },
                battery(height, "north", true),
                clock(height / 2, { colour = beautiful.fg_focus }),
                button({
                    width = height,
                    height = height - margins * 2,
                    bg = beautiful.colours.peach,
                    shape = utils.rrect(dpi(15)),
                    child = icon{ icon = beautiful.notification_icon, colour = "#000000", size = icon_size }
                }, function()
                    awesome.emit_signal("signals::notification_panel", s)
                end),
                button({
                    width = height,
                    height = height - margins * 2,
                    bg = beautiful.colours.green,
                    shape = utils.rrect(dpi(15)),
                    child = icon{ icon = beautiful.search_icon, colour = "#000000", size = icon_size }
                    }, function()
                        awful.spawn("rofi -show drun")
                end),
                button({
                    width = height,
                    height = height - margins * 2,
                    bg = beautiful.colours.blue,
                    shape = utils.rrect(dpi(15)),
                    child = icon{ icon = beautiful.home_icon, colour = "#000000", size = icon_size }
                    }, function()
                        awesome.emit_signal("signals::sidepanel", s)
                end),
                spacing = dpi(5),
                layout = wibox.layout.fixed.horizontal
            },
            spacing = dpi(10),
            layout = wibox.layout.align.horizontal
        },
        right = dpi(20),
        left = dpi(20),
        top = margins,
        bottom = margins,
        widget = wibox.container.margin
    }

    s.bar = awful.wibar({
        screen = s,
        --position = "top",
        visible = true,
        ontop = false,
        height = height,
        width = s.geometry.width -dpi(48),
        bg = beautiful.panel,
        shape = utils.rrect(beautiful.rounded_corners),
        widget = bar,
        type = "panel"
    })

    awful.placement.top(s.bar, { margins = beautiful.useless_gap })
    s.bar:struts({ top = s.bar.height + beautiful.useless_gap, bottom = 0, left = 0, right = 0 })
end)
