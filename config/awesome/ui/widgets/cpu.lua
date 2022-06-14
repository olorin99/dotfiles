local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local gears = require("gears")

return function(size)

    local cpu_text = wibox.widget {
        align = "center",
        valign = "center",
        markup = "<span color=\"black\">70%</span>",
        widget = wibox.widget.textbox
    }

    local cpu_progress = wibox.widget {
        cpu_text,
        colors = { "#00ff00" },
        bg = "#0000aa",
        forced_height = size,
        forced_width = size,
        border_width = dpi(0.5),
        border_color = "#000000",
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
        cpu_text.markup = "<span color=\"black\">" .. tostring(value) .. "%</span>"
    end)

    return cpu_progress
end
