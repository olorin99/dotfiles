local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")
local utils = require("utils")
local dpi = beautiful.xresources.apply_dpi
local icon = require("ui.widgets.icon")

function button_helper(args)
    if args.image then
        return wibox.widget {
            id = "here_icon_is",
            valign = "center",
            halign = "center",
            image = args.image,
            widget = wibox.widget.imagebox
        }
    elseif args.icon then
        return icon({ icon = args.icon, size = args.icon_size })
    else
        return wibox.widget {
            id = "text_role",
            valign = "center",
            align = "center",
            markup = args.text,
            font = args.font,
            widget = wibox.widget.textbox
        }
    end
end


return function(size, args, left, right)
    local c = args.client or nil
    local bg = args.bg or "#00ff00"
    local hover = args.hover or args.bg .. "be" or "#ff0000"
    local margins = args.margins or dpi(5)
    local shape = args.shape or gears.shape.circle
    args.text = args.text or ""
    args.font = args.font or beautiful.font
    args.icon_size = size

    local button = wibox.widget {
        button_helper(args),
        forced_height = size,
        forced_width = size,
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
