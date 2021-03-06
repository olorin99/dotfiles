local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local system = require("daemons.system")

return function(size)

    local ram_text = wibox.widget {
        markup = utils.coloured_text("70%", beautiful.fg_focus),
        align = "center",
        valign = "center",
        widget = wibox.widget.textbox
    }

    local ram_chart = wibox.widget {
        ram_text,
        colors = { beautiful.colours.mauve },
        bg = beautiful.bg_inactive,
        forced_height = size,
        forced_width = size,
        thickness = size * 0.2,
        rounded_edge = true,
        value = 70,
        max_value = 100,
        min_value = 0,
        start_angle = 3 * math.pi / 2,
        widget = wibox.container.arcchart
    }

    system:connect_signal("ram", function(_, used, total)
        local percentage = used / total * 100
        ram_chart.value = percentage
        ram_text.markup = utils.coloured_text(tostring(math.floor(percentage)) .. "%", beautiful.fg_focus)

    end)

    return ram_chart
end
