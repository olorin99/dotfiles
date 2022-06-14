local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local utils = require("utils")
local dpi = beautiful.xresources.apply_dpi


return function(size, orientation, percentage)

    local progress = wibox.widget {
        color = "#00ff00",
        forced_height = size / 2,
        forced_width = size,
        border_width = dpi(0.5),
        border_color = "#000000",
        bar_shape = utils.rrect(dpi(2)),
        shape = utils.rrect(dpi(4)),
        value = 70,
        max_value = 100,
        widget = wibox.widget.progressbar
    }

    local percentage_text = wibox.widget {
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local battery = wibox.widget {
        {
            {
                progress,
                direction = orientation or "north",
                widget = wibox.container.rotate,
            },
            {
                percentage_text,
                direction = orientation or "north",
                widget = wibox.container.rotate
            },
            layout = wibox.layout.stack
        },
        valign = "center",
        halign = "center",
        widget = wibox.container.place
    }

    awesome.connect_signal("signals::battery", function(value)
        if percentage then
            percentage_text.markup = "<span color=\"black\">" .. tostring(value) .. "%</span>"
        end
        progress.value = value
    end)

    return battery

end
