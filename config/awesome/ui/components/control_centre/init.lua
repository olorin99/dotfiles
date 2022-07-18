local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")

local wifi_toggle = require("ui.components.control_centre.wifi_toggle")
local sounds_toggle = require("ui.components.control_centre.sounds_toggle")
local screenshot_toggle = require("ui.components.control_centre.screenshot_toggle")

return function(args)
    local args = args or {}
    local height = args.height or dpi(100)
    local width = args.width or height

    local cols = args.cols or 2
    local rows = args.rows or 2

    local toggle_height = height / rows
    local toggle_width = width / cols
    local border_radius = dpi(25)

    local toggles = wibox.widget {
        spacing = dpi(5),
        forced_num_cols = cols,
        forced_num_rows = rows,
        homogenous = true,
        expand = true,
        layout = wibox.layout.grid
    }

    local toggle_args = {
        width = toggle_width,
        height = toggle_height,
        toggles = toggles,
        border_radius = border_radius,
        toggles_height = height,
        toggles_width = width
    }

    local wifi_toggle, wifi_submenu = wifi_toggle(toggle_args)
    local sounds_toggle, sounds_submenu = sounds_toggle(toggle_args)
    local screenshot_toggle, screenshot_submenu = screenshot_toggle(toggle_args)

    local toggle_list = {
        wifi_toggle,
        sounds_toggle,
        screenshot_toggle
    }

    local row = 1
    local col = 1
    for i, toggle in ipairs(toggle_list) do
        toggles:add_widget_at(toggle, row, col, 1, 1)
        if i % cols == 0 then
            row = row + 1
            col = 1
        else
            col = col + 1
        end
    end


    local control = wibox.widget {
        toggles,

        wifi_submenu,
        sounds_submenu,
        screenshot_submenu,

        forced_height = height,
        forced_width = width,
        layout = wibox.layout.stack
    }
    return control
end
