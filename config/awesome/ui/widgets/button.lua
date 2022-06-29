local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local utils = require("utils")
local dpi = beautiful.xresources.apply_dpi
local icon = require("ui.widgets.icon")

return function(args, left, right)
    local c = args.client or nil
    local bg = args.bg or "#00ff00"
    local hover = args.hover or args.bg .. "be" or "#ff0000"
    local margins = args.margins or dpi(5)
    local shape = args.shape or gears.shape.circle
    local width = args.width or dpi(10)
    local height = args.height or width
    local child = args.child or nil
    
    local button = wibox.widget {
        child,
        forced_height = height,
        forced_width = width,
        bg = bg,
        shape = shape,
        widget = wibox.container.background
    }

    button:buttons(gears.table.join(
        awful.button({ }, 1, function()
            if left then
                left(button, c)
            end
        end),
        awful.button({ }, 3, function()
            if right then
                right(button, c)
            end
        end)
    ))

    button:connect_signal("mouse::enter", function()
        button.bg = hover
    end)

    button:connect_signal("mouse::leave", function()
        button.bg = bg
    end)

    if c then
        c:connect_signal("focus", function()
            button.bg = bg
        end)
        c:connect_signal("unfocus", function()
            button.bg = bg .. "64"
        end)
    end

    return button
end
