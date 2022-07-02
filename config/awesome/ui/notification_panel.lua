local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local utils = require("utils")
local button = require("ui.widgets.button")
local naughty = require("naughty")

local scrollable = require("ui.widgets.scrollable")

local function write_to_history_file(title, message)
    awful.spawn.with_shell("echo 'title=" .. title .. ",message=" .. message .. ".' >> " .. user.awesome_config .. "/.notification_history")
end


local history = wibox.widget {
    spacing = dpi(5),
    layout = scrollable.vertical--wibox.layout.fixed.vertical
}

local function load_history_file()
    awful.spawn.easy_async("cat " .. user.awesome_config .. "/.notification_history", function(stdout, _, _, exit_code)
        if not (exit_code == 0) then
            return
        end

        for line in stdout:gmatch("([^\r\n]*)[\r\n]") do

            local title = line:match("title=(.*),")
            local message = line:match("message=(.*).")
            if title and message then
                local notif = wibox.widget {
                    {
                        {
                            {
                                text = title,
                                widget = wibox.widget.textbox
                            },
                            {
                                text = message,
                                widget = wibox.widget.textbox
                            },
                            spacing = dpi(5),
                            layout = wibox.layout.align.vertical
                        },
                        margins = dpi(10),
                        widget = wibox.container.margin
                    },
                    bg = beautiful.inactive,
                    shape = utils.rrect(dpi(8)),
                    widget = wibox.container.background
                }
                history:insert(1, notif)
                --history:add(notif)
            end
        end
    end)
end

load_history_file()

naughty.connect_signal("added", function(notification)
    local notif = wibox.widget {
        {
            {
                {
                    text = notification.title,
                    widget = wibox.widget.textbox
                },
                {
                    text = notification.message,
                    widget = wibox.widget.textbox
                },
                spacing = dpi(5),
                layout = wibox.layout.align.vertical,
            },
            margins = dpi(10),
            widget = wibox.container.margin
        },
        bg = beautiful.inactive,
        shape = utils.rrect(dpi(8)),
        widget = wibox.container.background
    }
    history:insert(1, notif)
    write_to_history_file(notification.title, notification.message)
end)

awful.screen.connect_for_each_screen(function(s)
    
    local width = beautiful.side_panel_width
    local height = s.geometry.height - beautiful.useless_gap * 2 - beautiful.top_bar_height

    local recent = wibox.widget {
        forced_height = height - dpi(30 + 20 + 50 + 40),
        spacing = dpi(5),
        layout = wibox.layout.fixed.vertical
    }

    local recents_menu = wibox.widget {
        recent,
        button({
            width = dpi(100),
            height = dpi(30),
            shape = utils.rrect(dpi(8)),
            child = wibox.widget {
                valign = "center",
                align = "center",
                markup = utils.coloured_text("clear all", "#000000"),
                widget = wibox.widget.textbox
            }
        }, function()
            recent:reset()
        end),
        layout = wibox.layout.fixed.vertical
    }

    local history_menu = wibox.widget {
        history,
        layout = wibox.layout.fixed.vertical
    }

    naughty.connect_signal("added", function(notification)
        local notif = wibox.widget {
            {
                {
                    {
                        text = notification.title,
                        widget = wibox.widget.textbox
                    },
                    {
                        text = notification.message,
                        widget = wibox.widget.textbox
                    },
                    layout = wibox.layout.fixed.vertical,
                },
                margins = dpi(10),
                widget = wibox.container.margin
            },
            bg = beautiful.inactive,
            shape = utils.rrect(dpi(8)),
            widget = wibox.container.background
        }
        recent:add(notif)
    end)

    local notification_panel = wibox.widget {
        {
            {
                {
                    button({
                        width = dpi(80),
                        height = dpi(50),
                        shape = utils.rrect(dpi(8)),
                        child = wibox.widget {
                            valign = "center",
                            align = "center",
                            markup = utils.coloured_text("recents", "#000000"),
                            widget = wibox.widget.textbox
                        }
                    }, function()
                        history_menu.visible = false
                        recents_menu.visible = true
                    end),
                    button({
                        width = dpi(80),
                        height = dpi(50),
                        shape = utils.rrect(dpi(8)),
                        child = wibox.widget {
                            valign = "center",
                            align = "center",
                            markup = utils.coloured_text("history", "#000000"),
                            widget = wibox.widget.textbox
                        }
                    }, function()
                        history_menu.visible = true
                        recents_menu.visible = false
                    end),
                    layout = wibox.layout.flex.horizontal
                },
                recents_menu,
                history_menu,
                spacing = dpi(20),
                layout = wibox.layout.fixed.vertical
            },
            margins = dpi(20),
            widget = wibox.container.margin
        },
        forced_width = width,
        forced_height = height,
        bg = beautiful.panel,
        shape = utils.prrect(beautiful.rounded_corners, true, false, false, true),
        widget = wibox.container.background
    }

    s.notification_panel = awful.popup {
        screen = s,
        visible = false,
        ontop = true,
        bg = "#00000000",
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
        --placement = awful.placement.right,
        widget = notification_panel,
        type = "dock"
    }

    awesome.connect_signal("signals::notification_panel", function(scr)
        scr.notification_panel.visible = true
    end)

    awesome.connect_signal("signals::hide_panels", function(scr)
        scr.notification_panel.visible = false
    end)

    s.notification_panel:connect_signal("mouse::leave", function()
        s.notification_panel.visible = false
    end)

end)
