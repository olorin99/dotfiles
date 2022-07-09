local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")

local naughty = require("naughty")

local power = {}
local instance = nil

function power:watch_battery_percentage()
    awful.spawn.easy_async_with_shell("sh -c 'OUT=\"$(find /sys/class/power_supply/BAT?/capacity)\" && (echo \"$OUT\" | head -1) || false'", function(battery_file, _, _, exit_code)
        if not (exit_code == 0) then
            return
        end

        awful.widget.watch("cat " .. battery_file, 30, function(_, stdout)
            self:emit_signal("battery::percentage", tonumber(stdout))
        end)
    end)
end

function power:watch_charging_status()
    awful.spawn.easy_async_with_shell("sh -c 'OUT=\"$(find /sys/class/power_supply/BAT?/status)\" && (echo \"$OUT\" | head -1) || false'", function(status_file, _, _, exit_code)
        if not (exit_code == 0) then
            return
        end

        awful.widget.watch("cat " .. status_file, 30, function(_, stdout)
            self:emit_signal("battery::charging", stdout == "Charging\n")
        end)
    end)
end

local function new()
    local obj = gobject{}
    gtable.crush(obj, power, true)
    obj:watch_battery_percentage()
    obj:watch_charging_status()
    return obj
end

if not instance then
    instance = new()
end

return instance
