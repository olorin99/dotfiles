local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")

local control_centre = require("ui.widgets.control_centre")
local media_controller = require("ui.widgets.media_control")
local battery = require("ui.widgets.battery")
local brightness = require("ui.widgets.brightness")
local volume = require("ui.widgets.volume")
local clock = require("ui.widgets.clock")
local button = require("ui.widgets.button")
local cpu = require("ui.widgets.cpu")
local ram = require("ui.widgets.ram")

function panel_section(widgets)
    return wibox.widget {
        {
            widgets,
            margins = dpi(10),
            widget = wibox.container.margin
        },
        bg = beautiful.panel,
        shape = utils.prrect(beautiful.rounded_corners, true, false, false, true),
        widget = wibox.container.background
    }
end

awful.screen.connect_for_each_screen(function(s)

    local sidepanel = wibox.widget {
        panel_section(wibox.widget {
            clock(50, { colour = beautiful.fg_focus }),
            {
                {
                    markup = utils.coloured_text(user.user, beautiful.fg_focus),
                    font = beautiful.font_var .. " 20",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                battery(dpi(50), "north", true),
                layout = wibox.layout.align.horizontal
            },
            control_centre(),
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical
        }),
        panel_section(wibox.widget {
            media_controller({ width = dpi(200) }),
            layout = wibox.layout.fixed.vertical
        }),
        panel_section(wibox.widget {
            brightness({ height = dpi(25), width = dpi(200) }),
            volume({ height = dpi(25), width = dpi(200) }),
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical
        }),
        panel_section(wibox.widget {
            cpu(dpi(100)),
            ram(dpi(100)),
            spacing = dpi(10),
            layout = wibox.layout.flex.horizontal
        }),
        panel_section(wibox.widget {
            button(dpi(50), { bg = beautiful.colours.maroon }, function()
                awful.spawn("shutdown now")
            end),
            button(dpi(50), { bg = beautiful.colours.green }, function()
                awful.spawn("reboot now")
            end),
            button(dpi(50), { bg = beautiful.colours.blue }, awesome.quit),
            layout = wibox.layout.flex.horizontal
        }),
        spacing = dpi(20),
        layout = wibox.layout.fixed.vertical
    }


    s.sidepanel = awful.popup{
        screen = s,
        visible = false,
        ontop = true,
        placement = awful.placement.right,
        bg = "#00000000",
        --shape = utils.prrect(beautiful.rounded_corners, true, false, false, true),
        widget = sidepanel,
        type = "dock"
    }

    awesome.connect_signal("signals::sidepanel", function(scr)
        scr.sidepanel.visible = true
    end)

    s.sidepanel:connect_signal("mouse::leave", function()
        s.sidepanel.visible = false
    end)

end)
