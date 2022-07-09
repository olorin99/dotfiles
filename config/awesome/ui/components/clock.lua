local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")

return function(size, args)
    local args = args or {}
    local orientation = args.orientation or "north"
    local colour = args.colour or beautiful.fg_focus
    local format = args.format or "%I:%M"

    local clock = wibox.widget {
        valign = "center",
        align = "center",
        format = utils.coloured_text(format, colour),
        font = beautiful.font_var .. utils.pixels_to_point(size),
        widget = wibox.widget.textclock
    }

    local clock_widget = wibox.widget {
        clock,
        direction = orientation,
        widget = wibox.container.rotate
    }

    return clock_widget

end
