local awful = require("awful")
local gears = require("gears")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local utils = require("utils")

local modKey = "Mod4"
local shift = "Shift"
local control = "Control"


local global_keys = gears.table.join(
    awful.key({ modKey }, "s",
                hotkeys_popup.show_help,
                { description = "show help", group = "awesome" }),
    awful.key({ modKey, "Control" }, "r",
                awesome.restart,
                { description = "restart awesome", group = "awesome" }),
    awful.key({ modKey, "Shift" }, "q",
                awesome.quit,
                { description = "quit awesome", group = "awesome" }),

    awful.key({ modKey }, "space",
                function() awful.layout.inc(1) end,
                { description = "next layout", group = "layout" }),

    awful.key({  }, "XF86MonBrightnessUp",
                function()
                    awful.spawn("brightnessctl set 5%+ -q", false)
                end,
                { description = "increase brightness", group = "device" }),
    awful.key({  }, "XF86MonBrightnessDown",
                function()
                    awful.spawn("brightnessctl set 5%- -q", false)
                end,
                { description = "decrease brightness", group = "device" }),
    
    awful.key({ modKey }, "Tab",
                function()
                    awesome.emit_signal("bling::window_switcher::turn_on")
                end,
                { description = "switch windows", group = "launcher" }),
    awful.key({ modKey }, "Return",
                function() awful.spawn(user.terminal) end,
                { description = "launch terminal", group = "launcher" }),
    awful.key({ modKey }, "r",
                function() awful.spawn.with_shell("rofi -show drun") end,
                { description = "show rofi", group = "launcher" }),
    awful.key({ modKey }, "h",
                function() awesome.emit_signal("signals::hide_panels", awful.screen.focused()) end,
                { description = "hide panels", group = "launcher" }),
    awful.key({ modKey }, "e",
                function() awesome.emit_signal("signals::sidepanel", awful.screen.focused()) end,
                { description = "sidebar", group = "launcher" }),
    --awful.key({ }, "Super_R",
    --            nil,
    --            function() awful.spawn.with_shell("rofi -show drun") end,
    --            { description = "show rofi", group = "client" }),
    --awful.key({  }, "Super_L",
    --            nil,
    --            function() awful.spawn.with_shell("rofi -show drun") end,
    --            { description = "show rofi", group = "client" }),
    
    awful.key({ }, "XF86AudioRaiseVolume",
                function() awesome.emit_signal("audio::increment") end,
                { descritption = "increase volume", group = "media" }),
    awful.key({ }, "XF86AudioLowerVolume",
                function() awesome.emit_signal("audio::decrement") end,
                { description = "decrease volume", group = "media" }),
    awful.key({ }, "XF86AudioMute",
                function() awesome.emit_signal("audio::toggle") end,
                { description = "toggle mute", group = "media" }),
    awful.key({ }, "XF86AudioPlay",
                function() awful.spawn.with_shell("playerctl play-pause") end,
                { description = "play/pause", group = "media" }),
    awful.key({ control }, "#80",
                function() awesome.emit_signal("audio::increment") end,
                { descritption = "increase volume", group = "media" }),
    awful.key({ control }, "#88",
                function() awesome.emit_signal("audio::decrement") end,
                { description = "decrease volume", group = "media" }),
    awful.key({ control }, "#84",
                function() awful.spawn.with_shell("playerctl play-pause") end,
                { description = "pause/play", group = "media" }),
    awful.key({ control }, "#83",
                function() awful.spawn.with_shell("playerctl previous") end,
                { description = "previous", group = "media" }),
    awful.key({ control }, "#85",
                function() awful.spawn.with_shell("playerctl next") end,
                { description = "next", group = "media" }),

    awful.key({ modKey, "Control" }, "Right",
                function() awful.tag.viewidx(1) end,
                { description = "move next tag", group = "tag" }),
    awful.key({ modKey, "Control" }, "Left",
                function() awful.tag.viewidx(-1) end,
                { description = "move previous tag", group = "tag" }),
    awful.key({ modKey, "Control", "Shift" }, "Right",
                function()
                    if client.focus then
                        local tag = client.focus.first_tag
                        local index = tag.index
                        client.focus:move_to_tag(awful.screen.focused().tags[index + 1])
                    end
                end,
                { description = "move next tag", group = "tag" }),
    awful.key({ modKey, "Control", "Shift" }, "Left",
                function()
                    if client.focus then
                        local tag = client.focus.first_tag
                        local index = tag.index
                        client.focus:move_to_tag(awful.screen.focused().tags[index - 1])
                    end
                end,
                { description = "move previous tag", group = "tag" })
)

for i = 1, 9 do
    global_keys = gears.table.join(global_keys,
        awful.key({ modKey }, "#" .. i + 9,
                function()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                    if tag then
                        tag:view_only()
                    end
                end,
                { description = "view tag #" .. i, group = "tag"}),
        awful.key({ modKey, "Control" }, "#" .. i + 9,
                function()
                    local screen = awful.screen.focused()
                    local tag = screen.tags[i]
                    if tag then
                        awful.tag.viewtoggle(tag)
                    end
                end,
                { description = "toggle tag #" .. i, group = "tag"}),
        awful.key({ modKey, "Shift" }, "#" .. i + 9,
                function()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then
                            client.focus:move_to_tag(tag)
                        end
                    end
                end,
                { description = "move focused client to  tag #" .. i, group = "tag"}),
        awful.key({ modKey, "Control", "Shift" }, "#" .. i + 9,
                function()
                    if client.focus then
                        local tag = client.focus.screen.tags[i]
                        if tag then
                            client.focus:toggle_tag(tag)
                        end
                    end
                end,
                { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end


local client_keys = gears.table.join(
    awful.key({ modKey, "Shift" }, "Up",
                function(c) 
                    c.maximized = not c.maximized
                    c:raise()
                end,
                { description = "maximize window", group = "client" }),
    awful.key({ modKey, "Shift" }, "Down",
                function(c)
                    c.minimized = true
                end,
                { description = "minimize window", group = "client" }),
    awful.key({ modKey }, "q",
                function(c)
                    c:kill()
                end,
                { description = "close window", group = "client" }),
    
    awful.key({ modKey }, "Right",
                function(c)
                    utils.snap(c, "right")
                end,
                { description = "snap to right", group = "client" }),
    awful.key({ modKey }, "Left",
                function(c)
                    utils.snap(c, "left")
                end,
                { description = "snap to left", group = "client" }),
    awful.key({ modKey }, "Up",
                function(c)
                    utils.snap(c, "top")
                end,
                { description = "snap to top", group = "client" }),
    awful.key({ modKey }, "Down",
                function(c)
                    utils.snap(c, "bottom")
                end,
                { description = "snap to bottom", group = "client" }),
    awful.key({ }, "F11",
                function(c)
                    c.fullscreen = not c.fullscreen
                    c:raise()
                end)
)

local client_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modKey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modKey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

root.keys(global_keys)


return {
    global_keys = global_keys,
    client_keys = client_keys,
    client_buttons = client_buttons
}
