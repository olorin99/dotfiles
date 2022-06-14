local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")

local battery = require("ui.widgets.battery")
local brightness = require("ui.widgets.brightness")
local volume = require("ui.widgets.volume")
local clock = require("ui.widgets.clock")
local button = require("ui.widgets.button")
local cpu = require("ui.widgets.cpu")
local ram = require("ui.widgets.ram")

awful.screen.connect_for_each_screen(function(s)

    local sidepanel = wibox.widget {
        {
            clock(37),
            battery(dpi(50), "north", true),
            brightness(dpi(50)),
            volume(dpi(50)),
            cpu(dpi(50)),
            ram(dpi(50)),
            button(dpi(50), { bg = "#ff0000" }, function()
                awful.spawn.with_shell("shutdown now")
            end),
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical
        },
        margins = dpi(10),
        widget = wibox.container.margin
    }


    s.sidepanel = awful.popup{
        screen = s,
        visible = false,
        ontop = true,
        placement = awful.placement.right,
        bg = "#bbbbbb",
        shape = utils.rrect(dpi(15)),
        widget = sidepanel,
        type = "dock"
    }

    awesome.connect_signal("signals::sidepanel", function()
        s.sidepanel.visible = true
    end)

    s.sidepanel:connect_signal("mouse::leave", function()
        s.sidepanel.visible = false
    end)

end)
