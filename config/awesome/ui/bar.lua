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

local taglist_buttons = gears.table.join(
    awful.button({ }, 1, function(t) t:view_only() end)
)

awful.screen.connect_for_each_screen(function(s)
    local taglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.noempty,
        buttons = taglist_buttons,
        widget_template = {
            {
                {
                    id = "text_role",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                bg = beautiful.panel1,
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
            {
                button({ 
                    size = dpi(30),
                    bg = beautiful.panel1,
                    shape = utils.rrect(dpi(15)),
                    child = wibox.widget {
                        valign = "center",
                        halign = "center",
                        image = beautiful.layout_icons[1],
                        widget = wibox.widget.imagebox
                    }
                    },
                    function(self)
                        awful.layout.inc(1)

                        local tag = s.selected_tag
                        self.children[1].image = beautiful.layout_icons[awful.layout.get_tag_layout_index(tag)]
                end),
                margins = dpi(2),
                widget = wibox.container.margin
            }
            ,
            --mid
            taglist,
            --right
            {
                battery(dpi(30), "north", true),
                clock(15, { colour = beautiful.fg_focus }),
                button({
                    size = dpi(30),
                    bg = beautiful.colours.green,
                    shape = utils.rrect(dpi(15)),
                    child = icon{ icon = beautiful.search_icon, colour = "#000000", size = dpi(20) }
                    }, function()
                        awful.spawn("rofi -show drun")
                end),
                button({
                    size = dpi(30),
                    text = utils.coloured_text(beautiful.home_icon, "#000000"),
                    bg = beautiful.colours.blue,
                    shape = utils.rrect(dpi(15)),
                    child = icon{ icon = beautiful.home_icon, colour = "#000000", size = dpi(20) }
                    }, function()
                        awesome.emit_signal("signals::sidepanel", s)
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
        bg = beautiful.panel,
        shape = utils.rrect(beautiful.rounded_corners),
        widget = bar
    })

    awful.placement.top(s.bar, { margins = beautiful.useless_gap })
    s.bar:struts({ top = s.bar.height + beautiful.useless_gap * 2, bottom = 0, left = 0, right = 0 })
end)
