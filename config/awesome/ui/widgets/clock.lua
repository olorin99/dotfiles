local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

return function(size, orientation)

    local clock = wibox.widget {
        format = "<span color=\"black\">%I:%M</span>",
        font = beautiful.font_var .. " " .. tostring(size),
        widget = wibox.widget.textclock
    }

    local clock_widget = wibox.widget {
        clock,
        direction = orientation or "north",
        widget = wibox.container.rotate
    }

    return clock_widget

end
