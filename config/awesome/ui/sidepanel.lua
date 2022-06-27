local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")
local rubato = require("modules.rubato")
local control_centre = require("ui.components.control_centre")
local media_controller = require("ui.components.media_controller")
local battery = require("ui.components.battery")
local brightness = require("ui.components.brightness")
local volume = require("ui.components.volume")
local clock = require("ui.components.clock")
local button = require("ui.widgets.button")
local cpu = require("ui.components.cpu")
local ram = require("ui.components.ram")

function panel_section(widgets)
    return wibox.widget {
        {
            widgets,
            margins = dpi(10),
            widget = wibox.container.margin
        },
        bg = beautiful.panel,
        shape = utils.prrect(beautiful.rounded_corners, true, false, false, true),
        widget = wibox.container.background
    }
end

awful.screen.connect_for_each_screen(function(s)

    local sidepanel = wibox.widget {
        panel_section(wibox.widget {
            clock(50, { colour = beautiful.fg_focus }),
            {
                {
                    markup = utils.coloured_text(user.user, beautiful.fg_focus),
                    font = beautiful.font_var .. " 20",
                    align = "center",
                    valign = "center",
                    widget = wibox.widget.textbox
                },
                battery(dpi(50), "north", true),
                layout = wibox.layout.align.horizontal
            },
            control_centre(),
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical
        }),
        panel_section(wibox.widget {
            media_controller({ width = dpi(200) }),
            layout = wibox.layout.fixed.vertical
        }),
        panel_section(wibox.widget {
            brightness({ height = dpi(25), width = dpi(200) }),
            volume({ height = dpi(25), width = dpi(200) }),
            spacing = dpi(10),
            layout = wibox.layout.fixed.vertical
        }),
        panel_section(wibox.widget {
            cpu(dpi(100)),
            ram(dpi(100)),
            spacing = dpi(10),
            layout = wibox.layout.flex.horizontal
        }),
        panel_section(wibox.widget {
            button({ size = dpi(50), bg = beautiful.colours.maroon }, function()
                awful.spawn("shutdown now")
            end),
            button({ size = dpi(50), bg = beautiful.colours.green }, function()
                awful.spawn("systemctl reboot")
            end),
            button({ size = dpi(50), bg = beautiful.colours.blue }, function() awesome.quit() end),
            layout = wibox.layout.flex.horizontal
        }),
        spacing = dpi(20),
        layout = wibox.layout.fixed.vertical
    }

--    function sidepanel:before_draw_children(context, cr, width, height)
--        cr:rectangle(0, 0, self.clip_width, height)
--        cr:clip()
--    end
    
    s.sidepanel = awful.popup{
        screen = s,
        visible = false,
        ontop = true,
        placement = awful.placement.right,
        bg = "#00000000",
        --shape = utils.prrect(beautiful.rounded_corners, true, false, false, true),
        widget = sidepanel,
        type = "dock"
    }
    
    local x = s.geometry.width + s.geometry.x
    local xv = s.geometry.width + s.geometry.x - dpi(245)
    s.animation = rubato.timed {
        intro = 0.1,
        outro = 0.1,
        duration = 0.3,
        pos = x,
        rate = 60,
        easing = rubato.quadratic,
        subscribed = function(pos)
            s.sidepanel.x = pos
--            s.sidepanel.widget.clip_width = x - pos
        end
    }

    local hide_timeout = gears.timer {
        timeout = 0.4,
        call_now = false,
        single_shot = true,
        callback = function()
            s.sidepanel.visible = false
        end
    }

    awesome.connect_signal("signals::sidepanel", function(scr)
        scr.sidepanel.visible = true
        scr.animation.target = scr.geometry.width + scr.geometry.x - dpi(245)
    end)

    awesome.connect_signal("signals::hide_panels", function(scr)
        scr.animation.target = scr.geometry.width + scr.geometry.x
        hide_timeout:again()
    end)

    s.sidepanel:connect_signal("mouse::leave", function()
        s.animation.target = s.geometry.width + s.geometry.x
        hide_timeout:again()
    end)

end)
