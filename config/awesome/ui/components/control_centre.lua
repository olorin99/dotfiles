local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local gears = require("gears")
local button = require("ui.widgets.button")
local toggle = require("ui.widgets.toggle")
local icon = require("ui.widgets.icon")
local playerctl = require("modules.bling").signal.playerctl.cli()
local naughty = require("naughty")

local open_wifi_submenu = function() end
local open_sounds_submenu = function() end
local open_screenshot_submenu = function() end
-- toggles

-- wifi toggle
local wifi_toggle = toggle({
    size = dpi(50),
    child = wibox.widget {
        icon{ icon = beautiful.wifi_icon, colour = "#000000", size = dpi(25) },
        wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("None", "#000000"),
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.flex.vertical
    }
}, function(self)
    if not self:toggle() then
        awful.spawn("nmcli radio wifi off")
    else
        awful.spawn("nmcli radio wifi on")
    end
end,
function(self)
    open_wifi_submenu()
end)

awesome.connect_signal("signals::network", function(status, ssid)
    wifi_toggle.all_children[3].markup = utils.coloured_text(ssid, "#000000")
    wifi_toggle.status = status
end)

-- sound toggle
local sounds_toggle = toggle({
    size = dpi(50),
    child = wibox.widget {
        icon{ icon = beautiful.volume_icon, colour = "#000000", size = dpi(25) },
        wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("None", "#000000"),
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.flex.vertical
    }
}, function()
    awesome.emit_signal("audio::toggle")
end,
function()
    open_sounds_submenu()
end)

awesome.connect_signal("audio::toggle", function()
    if not sounds_toggle:toggle() then
        sounds_toggle.all_children[2].markup = utils.coloured_text(beautiful.volume_icon_off, "#000000")
        sounds_toggle.all_children[3].markup = utils.coloured_text("Mute", "#000000")
    else
        sounds_toggle.all_children[2].markup = utils.coloured_text(beautiful.volume_icon, "#000000")
        sounds_toggle.all_children[3].markup = utils.coloured_text("Sound", "#000000")
    end
end)

awesome.connect_signal("audio::mute", function()
    sounds_toggle.all_children[2].markup = utils.coloured_text(beautiful.volume_icon_off, "#000000")
    sounds_toggle.all_children[3].markup = utils.coloured_text("Mute", "#000000")
    if sounds_toggle.state then sounds_toggle:toggle() end
end)

awesome.connect_signal("audio::unmute", function()
    sounds_toggle.all_children[2].markup = utils.coloured_text(beautiful.volume_icon, "#000000")
    sounds_toggle.all_children[3].markup = utils.coloured_text("Sound", "#000000")
    if not sounds_toggle.state then sounds_toggle:toggle() end
end)

-- bluetooth toggle
local bluetooth_toggle = toggle({
    size = dpi(50),
    child = wibox.widget {
        icon{ icon = beautiful.bluetooth_icon, colour = "#000000", size = dpi(25) },
        wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("None", "#000000"),
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.flex.vertical
    }
}, function(self)
    if not self:toggle() then
        awful.spawn("bluetoothctl power off")
    else
        awful.spawn("bluetoothctl power on")
    end
end)

-- screenshot button
local screenshot_button = button({ 
    size = dpi(50),
    bg = beautiful.colours.blue,
    shape = utils.rrect(dpi(8)),
    child = wibox.widget {
        icon{ icon = utils.coloured_text(beautiful.screenshot_icon, "#000000"), size = dpi(25) },
        {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("Screenshot", "#000000"),
            widget = wibox.widget.textbox
        },
        layout = wibox.layout.flex.vertical
    }}, 
    function(self)
        self.bg = beautiful.panel1
        gears.timer({
            timeout = 3,
            single_shot = true,
            callback = function()
                self.bg = beautiful.colours.blue
            end
        }):again()
        --awesome.emit_signal("signals::hide_panels", awful.screen.focused())
        awful.spawn.easy_async_with_shell("sh -c 'OUT=" .. user.home .. "/Pictures/screenshots/$(date +%s).png && maim $OUT && echo \"$OUT\"'", function(stdout, _, _, exit_code)
            if not (exit_code == 0) then
                return
            end

            naughty.notify{ title = "Screenshot", message = stdout }
        end)
end,
function()
    open_screenshot_submenu()
end)

local toggles = wibox.widget {
    wifi_toggle,
    sounds_toggle,
    bluetooth_toggle,
    screenshot_button,
    spacing = dpi(5),
    forced_num_cols = 2,
    homogeneous = true,
    expand = true,
    layout = wibox.layout.grid
}

--[[function toggles:before_draw_children(context, cr, width, height)
    cr:rectangle(0, 0, width / 2, height / 2)
    cr:clip()
end]]--

-- submenus

local available_wifi = wibox.widget {
    visible = true,
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
    widget = wibox.container.background
}

local wifi_submenu = wibox.widget {
    button({
        size = dpi(30),
        bg = beautiful.colours.blue,
        shape = utils.rrect(dpi(8)),
        child = wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("Scan", "#000000"),
            widget = wibox.widget.textbox
        }
    }, function(self)
        awesome.emit_signal("signals::network_scan_start")
    end),
    {
        available_wifi,
        --[[{
            widget = wibox.widget.textbox,
            text = "kldjfhasdfkljhaksdfjhaksdjf hdhj adfkljh asdkfjhadj askdjfh asdhfj asdhfj asdfkljh asdkjfh asdfkljh asdfkjl hasdkflj hasdfklj hasdklfj hasdkjhasdkjfh asdkfljh asdkjhf asdkjfh aksdhj adhjs adhjs fadhjsf adhj askdjha "
        },]]--
        forced_width = 100,
        step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
        speed = 100,
        layout = wibox.layout.fixed.vertical,
        --layout = wibox.container.scroll.vertical --TODO: get scrollable widget
    },
    visible = false,
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
    widget = wibox.container.background
}

open_wifi_submenu = function()
    toggles.visible = false
    wifi_submenu.visible = true
end

wifi_submenu:connect_signal("mouse::leave", function()
    wifi_submenu.visible = false
    toggles.visible = true
end)

awesome.connect_signal("signals::network_scan_finished", function(networks)
    available_wifi:reset()
    for _, network in ipairs(networks) do
        naughty.notify{ message = network }
        available_wifi:add(wibox.widget {
            {
                text = network,
                widget = wibox.widget.textbox
            },
            --TODO: textinput widget to get password
            button({ size = dpi(30), bg = beautiful.colours.blue, shape = utils.rrect(dpi(8)) }, function() 
                awful.spawn("nmcli dev wifi connect " .. network)
            end),
            layout = wibox.layout.fixed.horizontal
        })
    end
end)

local players = wibox.widget {
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical,
    widget = wibox.container.background
}
local sounds_submenu = wibox.widget {
    {
        button({
            size = dpi(30),
            bg = beautiful.colours.blue,
            shape = utils.rrect(dpi(8)),
            child = wibox.widget {
                valign = "center",
                align = "center",
                markup = utils.coloured_text("Sound", "#000000"),
                widget = wibox.widget.textbox
            }
        }, function(self)
            awesome.emit_signal("audio::unmute")
        end),
        button({
            size = dpi(30),
            bg = beautiful.colours.blue,
            shape = utils.rrect(dpi(8)),
            child = wibox.widget {
                valign = "center",
                align = "center",
                markup = utils.coloured_text("Mute", "#000000"),
                widget = wibox.widget.textbox
            }
        }, function(self)
            awesome.emit_signal("audio::mute")
        end),
        spacing = dpi(5),
        layout = wibox.layout.flex.horizontal
    },
    players,
    visible = false,
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical
}


open_sounds_submenu = function()
    toggles.visible = false
    sounds_submenu.visible = true
awful.spawn.easy_async("playerctl -l", function(stdout, _, _, exit_code)
    if not (exit_code == 0) then
        return
    end

    players:reset()
    for player in stdout:gmatch("([^\r\n]*)[\r\n]") do
        local vol = wibox.widget {
            bar_shape = utils.rrect(dpi(8)),
            bar_height = dpi(10),
            bar_color = beautiful.panel1,
            bar_active_color = beautiful.colours.blue,
            handle_color = beautiful.colours.blue,
            handle_shape = gears.shape.circle,
            handle_width = dpi(9),
            forced_width = dpi(100),
            forced_height = dpi(10),
            value = 70,
            maximum = 100,
            minimum = 0,
            widget = wibox.widget.slider
        }

        vol:connect_signal("property::value", function()
            playerctl:set_volume(vol.value / 100, player)
        end)

        

        players:add(wibox.widget {
            {
                text = player,
                widget = wibox.widget.textbox
            },
            nil,
            vol,
            spacing = dpi(5),
            layout = wibox.layout.align.horizontal
        })
    end

end)
end

sounds_submenu:connect_signal("mouse::leave", function()
    sounds_submenu.visible = false
    toggles.visible = true
end)


local screenshot_submenu = wibox.widget {
    button({
        size = dpi(30),
        bg = beautiful.colours.blue,
        shape = utils.rrect(dpi(8)),
        child = wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("Screen", "#000000"),
            widget = wibox.widget.textbox
        }
    }, function(self)
        awful.spawn.easy_async_with_shell("sh -c 'OUT=" .. user.home .. "/Pictures/screenshots/$(date +%s).png && maim $OUT && echo \"$OUT\"'", function(stdout, _, _, exit_code)
            if not (exit_code == 0) then
                return
            end

            naughty.notify{ title = "Screenshot", message = stdout }
        end)
    end),
    button({
        size = dpi(30),
        bg = beautiful.colours.blue,
        shape = utils.rrect(dpi(8)),
        child = wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("Window", "#000000"),
            widget = wibox.widget.textbox
        }
    }, function(self)
        awful.spawn.easy_async_with_shell("sh -c 'OUT=" .. user.home .. "/Pictures/screenshots/$(date +%s).png && maim -i $(xdotool getactivewindow) $OUT && echo \"$OUT\"'", function(stdout, _, _, exit_code)
            if not (exit_code == 0) then
                return
            end

            naughty.notify{ title = "Screenshot", message = stdout }
        end)
    end),
    button({
        size = dpi(30),
        bg = beautiful.colours.blue,
        shape = utils.rrect(dpi(8)),
        child = wibox.widget {
            valign = "center",
            align = "center",
            markup = utils.coloured_text("Selection", "#000000"),
            widget = wibox.widget.textbox
        }
    }, function(self)
        awful.spawn.easy_async_with_shell("sh -c 'OUT=" .. user.home .. "/Pictures/screenshots/$(date +%s).png && maim -s $OUT && echo \"$OUT\"'", function(stdout, _, _, exit_code)
            if not (exit_code == 0) then
                return
            end

            naughty.notify{ title = "Screenshot", message = stdout }
        end)
    end),
    visible = false,
    spacing = dpi(5),
    layout = wibox.layout.fixed.vertical
}

open_screenshot_submenu = function()
    toggles.visible = false
    screenshot_submenu.visible = true
end
screenshot_submenu:connect_signal("mouse::leave", function()
    screenshot_submenu.visible = false
    toggles.visible = true
end)

return function(args)

    local control = wibox.widget {
        toggles,
        wifi_submenu,
        sounds_submenu,
        screenshot_submenu,

        forced_height = dpi(105),
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
    }

    return control
end
