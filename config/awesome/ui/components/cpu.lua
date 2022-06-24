local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")

return function(size)

    local cpu_text = wibox.widget {
        align = "center",
        valign = "center",
        markup = utils.coloured_text("70%", beautiful.fg_focus),
        widget = wibox.widget.textbox
    }

    local cpu_progress = wibox.widget {
        cpu_text,
        colors = { beautiful.colours.green },
        bg = beautiful.panel1,
        forced_height = size,
        forced_width = size,
        --border_width = beautiful.border_width,
        --border_color = beautiful.border_color,
        rounded_edge = true,
        value = 70,
        max_value = 100,
        min_value = 0,
        start_angle = 3 * math.pi / 2,
        widget = wibox.container.arcchart
    }


    local cpu = wibox.widget {
        cpu_progress,
        cpu_text,
        layout = wibox.layout.stack
    }

    awesome.connect_signal("signals::cpu", function(value)
        value = math.min(100, math.max(0, value))
        cpu_progress.value = value
        cpu_text.markup = utils.coloured_text(tostring(value) .. "%", beautiful.fg_focus)
    end)

    return cpu_progress
end
