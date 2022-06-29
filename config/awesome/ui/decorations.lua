local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")
local dpi = beautiful.xresources.apply_dpi

local button = require("ui.widgets.button")

client.connect_signal("request::titlebars", function (c)

    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            if c.maximized then c.maximized = not c.maximized end
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            if c.maximized then c.maximized = not c.maximized end
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {
        position = "top",
        size = dpi(30)
    }):setup {
        nil,
        {
            {
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        {
            {
                button({ width = dpi(15), bg = beautiful.colours.blue, margins = dpi(0), client = c }, function(self, c)
                    c.minimized = true
                end),
                button({ width = dpi(15), bg = beautiful.colours.green, margins = dpi(0), client = c }, function(self, c)
                    c.maximized = not c.maximized
                    c:raise()
                end),
                button({ width = dpi(15), bg = beautiful.colours.maroon, margins = dpi(0), client = c }, function(self, c)
                    c:kill()
                end),
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(5)
            },
            right = dpi(20),
            widget = wibox.container.margin
        },
        layout = wibox.layout.align.horizontal
    }

end)
