local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local utils = require("utils")
local dpi = beautiful.xresources.apply_dpi
local power = require("daemons.power")
local icon = require("ui.widgets.icon")

return function(size, orientation, percentage)

    local progress = wibox.widget {
        color = "#40a02b",
        background_color = beautiful.bg_inactive,
        forced_height = size / 2,
        forced_width = size,
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        bar_shape = utils.rrect(dpi(2)),
        shape = utils.rrect(dpi(4)),
        value = 70,
        max_value = 100,
        widget = wibox.widget.progressbar
    }

    local percentage_text = wibox.widget {
        align = "center",
        valign = "center",
        font = beautiful.font_var .. utils.pixels_to_point(size / 2),
        widget = wibox.widget.textbox
    }

    local charging_icon = icon {
        size = size / 2,
        icon = beautiful.charging_icon,
        colour = beautiful.fg_focus
    }
    charging_icon.visible = false

    local battery = wibox.widget {
        {
            {
                progress,
                charging_icon,
                layout = wibox.layout.stack
            },
            valign = "center",
            halign = "center",
            widget = wibox.container.place
        },
        percentage_text,
        spacing = dpi(5),
        layout = wibox.layout.fixed.horizontal
    }


    power:connect_signal("battery::percentage", function(self, value)
        if percentage then
            percentage_text.markup = utils.coloured_text(tostring(value) .. "%", beautiful.fg_focus)
        end
        progress.value = value
    end)

    power:connect_signal("battery::charging", function(self, charging)
        if charging then
            charging_icon.visible = true
            progress.border_color = beautiful.fg_focus
        else
            charging_icon.visible = false
            progress.border_color = beautiful.border_normal
        end
    end)
    
    return battery
end
