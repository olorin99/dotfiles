local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")
local rubato = require("modules.rubato")
local control_centre = require("ui.components.control_centre")
local control_centrea = require("ui.components.control_centrea")
local media_controller = require("ui.components.media_controller")
local battery = require("ui.components.battery")
local brightness = require("ui.components.brightness")
local volume = require("ui.components.volume")
local clock = require("ui.components.clock")
local button = require("ui.widgets.button")
local cpu = require("ui.components.cpu")
local ram = require("ui.components.ram")
local temp = require("ui.components.temp")
local disk = require("ui.components.disk")

local scrollable = require("ui.widgets.scrollable")

awful.screen.connect_for_each_screen(function(s)

    local height = s.geometry.height - beautiful.top_bar_height - beautiful.useless_gap * 3
    local width = beautiful.side_panel_width - dpi(40)

    
    local sidepanel = wibox.widget {
        {
            {
                {
                    {
                        {
                            clock(100, { format = "%I", colour = beautiful.fg_focus }),
                            clock(100, { format = "%M", colour = beautiful.fg_normal }),
                            spacing = dpi(40),
                            layout = wibox.layout.fixed.horizontal
                        },
                        valign = "center",
                        halign = "center",
                        widget = wibox.container.place
                    },
                    clock(30, { format = "%A %d %B" }),
                    layout = wibox.layout.fixed.vertical
                },
                {
                    {
                        markup = utils.coloured_text(user.user, beautiful.fg_focus),
                        font = beautiful.font_var .. utils.pixels_to_point(50),
                        align = "center",
                        valign = "center",
                        widget = wibox.widget.textbox
                    },
                    nil,
                    battery(dpi(50), "north", true),
                    layout = wibox.layout.align.horizontal
                },
                control_centre { height = height * 0.15, width = width, cols = 2, rows = 2 },
                brightness { height = height * 0.02, width = width },
                volume { height = height * 0.02, width = width },
                media_controller { height = height * 0.1, width = width },
                {
                    cpu(width * 0.2),
                    ram(width * 0.2),
                    temp(width * 0.2),
                    disk(width * 0.2),
                    layout = wibox.layout.flex.horizontal
                },
                {
                    button({
                        width = dpi(50),
                        bg = beautiful.colours.maroon
                    }, function()
                        awful.spawn("shutdown now")
                    end),
                    button({
                        width = dpi(50),
                        bg = beautiful.colours.green
                    }, function()
                        awful.spawn("systemctl reboot")
                    end),
                    button({
                        width = dpi(50),
                        bg = beautiful.colours.blue
                    }, function()
                        awesome.quit()
                    end),
                    layout = wibox.layout.flex.horizontal
                },
                spacing = math.ceil(height * 0.01),
                layout = wibox.layout.fixed.vertical
            },
            margins = dpi(20),
            widget = wibox.container.margin
        },
        forced_height = height,
        forced_width = width + dpi(40),
        shape = utils.prrect(beautiful.rounded_corners, true, false, false, true),
        bg = beautiful.bg_panel,
        widget = wibox.container.background
    }
    
    s.sidepanel = awful.popup{
        screen = s,
        visible = false,
        ontop = true,
        --placement = awful.placement.right,
        placement = function(w)
            awful.placement.right(w, {
                margins = {
                    top = beautiful.top_bar_height + beautiful.useless_gap * 2,
                    bottom = beautiful.useless_gap,
                    left = 0,
                    right = 0
                }
            })
        end,
        bg = "#00000000",
        shape = utils.prrect(beautiful.rounded_corners, true, false, false, true),
        widget = sidepanel,
        type = "panel"
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
        --[[mousegrabber.run(function(mouse)
            
            local x, y = mouse.x, mouse.y

            if x < scr.sidepanel.x then
                scr.sidepanel.visible = false
                return false
            end
            return true
        end, "fleur")]]--
        --scr.animation.target = scr.geometry.width + scr.geometry.x - width
    end)

    --[[s:connect_signal("button::press", function(_, x, y, button_id, _, geo)
        naughty.notify({ message = tostring(x) .. " " .. tostring(y) })
    end)]]--

    awesome.connect_signal("signals::hide_panels", function(scr)
        --scr.animation.target = scr.geometry.width + scr.geometry.x
        --hide_timeout:again()
        scr.sidepanel.visible = false
    end)

    s.sidepanel:connect_signal("mouse::leave", function()
        --s.animation.target = s.geometry.width + s.geometry.x
        --hide_timeout:again()
        s.sidepanel.visible = false
    end)

end)
