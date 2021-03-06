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
local scrollable = require("ui.widgets.scrollable")
local network = require("daemons.network")

return function(args)
    local args = args or {}
    local height = args.height or dpi(100)
    local width = args.width or height
    local toggle_height = height / 2
    local toggle_width = width / 2
    local toggle_border_radius = dpi(25)

    local open_wifi_submenu = function() end
    local open_sounds_submenu = function() end
    local open_screenshot_submenu = function() end
    -- toggles
    
    -- wifi toggle
    local ssid_text = wibox.widget {
        valign = "center",
        align = "center",
        markup = utils.coloured_text("None", "#000000"),
        widget = wibox.widget.textbox
    }

    local wifi_toggle = wibox.widget {
        toggle({
            height = toggle_height,
            width = toggle_width * 0.7,
            shape = utils.prrect(toggle_border_radius, true, false, false, true),
            child = wibox.widget {
                icon {
                    icon = beautiful.wifi_icon,
                    colour = "#000000",
                    size = dpi(25)
                },
                ssid_text,
                layout = wibox.layout.flex.horizontal
            }
        },
        function(self)
            if not self:toggle() then
                network:turn_off()
            else
                network:turn_on()
            end
        end),
        button({
            height = toggle_height,
            width = toggle_width * 0.3,
            shape = utils.prrect(toggle_border_radius, false, true, true, false),
            child = icon {
                icon = beautiful.right_icon,
                colour = "#000000",
                size = dpi(25)
            }
        },
        function()
            open_wifi_submenu()
        end),
        layout = wibox.layout.fixed.horizontal
    }

    network:connect_signal("connection", function(_, ssid)
        ssid_text.markup = utils.coloured_text(ssid, "#000000")
    end)
    network:connect_signal("status", function(_, status)
        wifi_toggle.children[1].status = status
        if status ~= "connected" then
            ssid_text.markup = utils.coloured_text("None", "#000000")
        end
    end)

    --[[awesome.connect_signal("signals::network", function(status, ssid)
        wifi_toggle.all_children[3].markup = utils.coloured_text(ssid, "#000000")
        wifi_toggle.status = status
    end)]]--
    
    -- sound toggle
    local sounds_text = wibox.widget {
        valign = "center",
        align = "center",
        markup = utils.coloured_text("Sound", "#000000"),
        widget = wibox.widget.textbox
    }

    local sounds_toggle = wibox.widget {
        toggle({
            height = toggle_height,
            width = toggle_width * 0.7,
            shape = utils.prrect(toggle_border_radius, true, false, false, true),
            child = wibox.widget {
                icon{ icon = beautiful.volume_icon, colour = "#000000", size = dpi(25) },
                sounds_text,
                layout = wibox.layout.flex.horizontal
            }
        }, function()
            awesome.emit_signal("audio::toggle")
        end),
        button({
            height = toggle_height,
            width = toggle_width * 0.3,
            shape = utils.prrect(toggle_border_radius, false, true, true, false),
            child = icon {
                icon = beautiful.right_icon,
                colour = "#000000",
                size = dpi(25)
            }
        },
        function()
            open_sounds_submenu()
        end),
        layout = wibox.layout.fixed.horizontal
    }
    
    awesome.connect_signal("audio::toggle", function()
        if not sounds_toggle.children[1]:toggle() then
            sounds_toggle.all_children[3].markup = utils.coloured_text(beautiful.volume_icon_off, "#000000")
            sounds_text.markup = utils.coloured_text("Mute", "#000000")
        else
            sounds_toggle.all_children[3].markup = utils.coloured_text(beautiful.volume_icon, "#000000")
            sounds_text.markup = utils.coloured_text("Sound", "#000000")
        end
    end)
    
    awesome.connect_signal("audio::mute", function()
        sounds_toggle.all_children[3].markup = utils.coloured_text(beautiful.volume_icon_off, "#000000")
        sounds_text.markup = utils.coloured_text("Mute", "#000000")
        if sounds_toggle.children[1].state then sounds_toggle.children[1]:toggle() end
    end)
    
    awesome.connect_signal("audio::unmute", function()
        sounds_toggle.all_children[3].markup = utils.coloured_text(beautiful.volume_icon, "#000000")
        sounds_text.markup = utils.coloured_text("Sound", "#000000")
        if not sounds_toggle.children[1].state then sounds_toggle.children[1]:toggle() end
    end)
    
    -- bluetooth toggle
    local bluetooth_toggle = toggle({
        size = toggle_height,
        shape = utils.rrect(toggle_border_radius),
        child = wibox.widget {
            icon{ icon = beautiful.bluetooth_icon, colour = "#000000", size = dpi(25) },
            wibox.widget {
                valign = "center",
                align = "center",
                markup = utils.coloured_text("None", "#000000"),
                widget = wibox.widget.textbox
            },
            layout = wibox.layout.flex.horizontal
        }
    }, function(self)
        if not self:toggle() then
            awful.spawn("bluetoothctl power off")
        else
            awful.spawn("bluetoothctl power on")
        end
    end)
    
    -- screenshot button
    local screenshot_button = wibox.widget {
        button({ 
            height = toggle_height,
            width = toggle_width * 0.7,
            bg = beautiful.colours.blue,
            shape = utils.prrect(toggle_border_radius, true, false, false, true),
            child = wibox.widget {
                icon{ icon = utils.coloured_text(beautiful.screenshot_icon, "#000000"), size = dpi(25) },
                {
                    valign = "center",
                    align = "center",
                    markup = utils.coloured_text("Screenshot", "#000000"),
                    widget = wibox.widget.textbox
                },
                layout = wibox.layout.flex.horizontal
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
        end),
        button({
            height = toggle_height,
            width = toggle_width * 0.3,
            shape = utils.prrect(toggle_border_radius, false, true, true, false),
            child = icon {
                icon = beautiful.right_icon,
                colour = "#000000",
                size = dpi(25)
            }
        },
        function()
            open_screenshot_submenu()
        end),
        layout = wibox.layout.fixed.horizontal
    }
    
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
    
    -- submenus
    
    local available_wifi = wibox.widget {
        visible = true,
        spacing = dpi(5),
        layout = scrollable.vertical,
        widget = wibox.container.background
    }
    
    local wifi_submenu = wibox.widget {
        button({
            width = dpi(30),
            bg = beautiful.colours.blue,
            shape = utils.rrect(dpi(8)),
            child = wibox.widget {
                valign = "center",
                align = "center",
                markup = utils.coloured_text("Scan", "#000000"),
                widget = wibox.widget.textbox
            }
        }, function(self)
            network:scan_networks()
            awesome.emit_signal("signals::network_scan_start")
        end),
        {
            available_wifi,
            forced_width = 100,
            step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
            speed = 100,
            layout = wibox.layout.fixed.vertical,
        },
        visible = false,
        forced_height = height,
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
    
    --network:connect_signal("scan_finished", function(_, networks)
    --    for n in networks do
    --        naughty.notify({ message = n.ssid })
     --   end
    --end)

    awesome.connect_signal("signals::network_scan_finished", function(networks)
        available_wifi:reset()
        for _, network in ipairs(networks) do
            --naughty.notify{ message = network }
            available_wifi:add(wibox.widget {
                {
                    text = network,
                    widget = wibox.widget.textbox
                },
                --TODO: textinput widget to get password
                button({ width = dpi(30), bg = beautiful.colours.blue, shape = utils.rrect(dpi(8)) }, function() 
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
                width = dpi(30),
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
                width = dpi(30),
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
        forced_height = height,
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
    
            --[[vol:connect_signal("property::value", function()
                playerctl:set_volume(vol.value / 100, player)
            end)]]--

            vol:connect_signal("button::press", function()
                vol.button_held = true
            end)

            vol:connect_signal("mouse::leave", function()
                if not vol.button_held then
                    return
                end
                playerctl:set_volume(vol.value / 100, player)
                vol.button_held = false
            end)

            playerctl:connect_signal("volume", function(_, value)
                vol.value = math.floor(value * 100)
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
    
    local screenshot_button_height = (height - dpi(10)) / 3
    local screenshot_submenu = wibox.widget {
        button({
            width = dpi(30),
            height = screenshot_button_height,
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
            width = dpi(30),
            height = screenshot_button_height,
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
            width = dpi(30),
            height = screenshot_button_height,
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
        forced_height = height,
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

    local control = wibox.widget {
        toggles,
        wifi_submenu,
        sounds_submenu,
        screenshot_submenu,

        forced_height = height,
        forced_width = width,
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
    }

    return control
end
