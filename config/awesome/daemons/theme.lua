local awful = require("awful")
local gears = require("gears")
local gobject = require("gears.object")
local gtable = require("gears.table")
local utils = require("utils")
local beautiful = require("beautiful")

local theme = {}
local instance = nil

function theme:load_theme(path)
    beautiful.init(path)
    self:set_wallpaper_dir(user.home .. "/Pictures/Wallpapers")
    --self:set_wallpaper(beautiful.wallpaper)
end

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end
screen.connect_signal("property::geometry", set_wallpaper)

function theme:set_wallpaper(path)
    self._private.beautiful.wallpaper = path
    for s in screen do
        set_wallpaper(s)
    end
    self:emit_signal("wallpaper", path)
end

function theme:set_wallpaper_dir(dir)
    utils.directory(dir, function(result)
        self:set_wallpaper(result[1])
        local i = 1
        gears.timer {
            timeout = 60,
            call_now = true,
            single_shot = false,
            autostart = true,
            callback = function()
                self:set_wallpaper(result[i])
                i = (i + 1) % #result
                if i == 0 then i = 1 end
            end
        }
    end)
end

function theme:reload()
    awesome.restart()
    --self:emit_signal("reload", self._private.beautiful)
end


function theme:set_bg_normal(bg)
    self._private.beautiful.bg_normal = bg
end

function theme:set_bg_focus(bg)
    self._private.beautiful.bg_focus = bg
end

function theme:set_bg_secondary(bg)
    self._private.beautiful.bg_secondary = bg
end

function theme:set_bg_active(bg)
    self._private.beautiful.bg_active = bg
end

function theme:set_bg_inactive(bg)
    self._private.beautiful.bg_inactive = bg
end


local function new()
    local obj = gobject{}
    gtable.crush(obj, theme, true)

    obj._private = {}
    obj._private.beautiful = beautiful

    return obj
end

if not instance then
    instance = new()
end

return instance
