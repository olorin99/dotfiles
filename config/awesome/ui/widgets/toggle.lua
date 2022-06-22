local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")
local icon = require("ui.widgets.icon")

return function(size, args, left, right)

    local enabled = args.start or true
    local bg_enabled = args.enabled or beautiful.colours.blue
    local bg_disabled = args.disabled or beautiful.panel1
    local shape = args.shape or utils.rrect(dpi(8))
    local text = args.text or ""

    local toggle = wibox.widget {
        {
            args.icon and icon({ icon = args.icon, size = args.icon_size or size / 2 }) or nil,
            {
                markup = text,
                valign = "center",
                align = "center",
                widget = wibox.widget.textbox
            },
            layout = wibox.layout.flex.vertical,
        },
        forced_height = size,
        forced_width = size,
        bg = enabled and bg_enabled or bg_disabled,
        shape = shape,
        widget = wibox.container.background
    }
    toggle.state = enabled

    toggle:buttons(gears.table.join(
        awful.button({ }, 1, function()
            if left then
                left(toggle)
            end
        end),
        awful.button({ }, 3, function()
            if right then
                right(toggle)
            end
        end)
    ))

    toggle.toggle = function(self)
        self.state = not self.state
        self:emit_signal("change::state")
        return self.state
    end

    toggle:connect_signal("change::state", function()
        toggle.bg = toggle.state and bg_enabled or bg_disabled
    end)

    toggle:connect_signal("mouse::enter", function()
        toggle.bg = toggle.state and bg_enabled .. "be" or bg_disabled .. "be"
    end)

    toggle:connect_signal("mouse::leave", function()
        toggle.bg = toggle.state and bg_enabled or bg_disabled
    end)

    return toggle
end
