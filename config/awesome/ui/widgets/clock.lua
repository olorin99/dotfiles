local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")

return function(size, args)
    local orientation = args.orientation or "north"
    local colour = args.colour or "#000000"

    local clock = wibox.widget {
        valign = "center",
        align = "center",
        format = utils.coloured_text("%I:%M", colour),
        font = beautiful.font_var .. " " .. tostring(size),
        widget = wibox.widget.textclock
    }

    local clock_widget = wibox.widget {
        clock,
        direction = orientation,
        widget = wibox.container.rotate
    }

    return clock_widget

end
