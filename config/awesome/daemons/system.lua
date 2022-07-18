local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")
local utils = require("utils")

local system = {}
local instance = nil

function system:watch_cpu()
    local script = [[
        sh -c "
        vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'
        "
    ]]

    awful.widget.watch(script, 10, function(_, stdout)
        local cpu = string.gsub(stdout, "^%s(.-)%s*$", "%1")
        self:emit_signal("cpu", 100 - tonumber(cpu))
    end)
end

function system:watch_ram()
    local script = [[
        sh -c "
        free -m | grep 'Mem:' | awk '{printf \"%d@@%d@\", $7, $2}'
        "
    ]]

    awful.widget.watch(script, 30, function(_, stdout)
        local available = tostring(stdout:match("(.*)@@"))
        local total = tostring(stdout:match("@@(.*)@"))
        local used = total - available
        self:emit_signal("ram", used, total)
    end)
end

function system:watch_temp()
    local script = [[
        sh -c "
        cat /sys/class/thermal/thermal_zone0/temp
        "
    ]]

    awful.widget.watch(script, 30, function(_, stdout)
        local temp = math.floor(tonumber(stdout) / 1000)
        self:emit_signal("temp", temp)
    end)
end

function system:watch_disk()
    local script = [[
        sh -c "
        df -k / | sed 1d | awk '{printf \"%d@@%d@\", $2, $3}'
        "
    ]]

    awful.widget.watch(script, 30, function(_, stdout)
        local size = tostring(stdout:match("(.*)@@"))
        local used = tostring(stdout:match("@@(.*)@"))
        self:emit_signal("disk", size, used)
    end)
end

local function new()
    local obj = gobject{}
    gtable.crush(obj, system, true)

    obj:watch_cpu()
    obj:watch_ram()
    obj:watch_temp()
    obj:watch_disk()

    return obj
end

if not instance then
    instance = new()
end

return instance
