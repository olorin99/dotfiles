local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")

local naughty = require("naughty")

local network = {}
local instance = nil

function network:turn_off()
    awful.spawn("nmcli radio wifi off")
end

function network:turn_on()
    awful.spawn("nmcli radio wifi on")
end


function network:active_connection()
    awful.spawn.easy_async_with_shell("nmcli -f GENERAL.CONNECTION dev show wlp3s0 | awk '{printf $2; for (i=3; i<=NF; i++) printf FS$i; print NL}'", function(stdout, _, _, exit_code)
        if not (exit_code == 0) then
            self:emit_signal("error", "unable to get active connection")
            return
        end

        local connection = stdout:gsub("\n", "")
        self:emit_signal("connection", connection)
    end)
end

function network:scan_networks()
    self._private.networks = {}
    awful.spawn.with_line_callback("nmcli -t dev wifi list", {
        stdout = function(out)

            local str = out:sub(25)
            local ssid = "err"

            local i = 1
            for v in str:gmatch("([^:]+)") do
                --if k == 1 then
                --    ssid = v
                --end
                naughty.notify({ message = v })
                k = k+1
            end

            table.insert(self._private.networks, { ssid = ssid })
            naughty.notify({ message = ssid })
        end,
        output_done = function()
            self:emit_signal("scan_finished", self._private.networks)
        end
    })
end

function network:monitor_device()
    awful.spawn.easy_async_with_shell("ps x | grep \"nmcli dev monitor\" | grep -v grep | awk '{print $1}' | xargs kill", function()

        awful.spawn.with_line_callback("nmcli dev monitor", {
            stdout = function(out)
                if out:match("wlp3s0: connected") then
                    self:active_connection()
                    self:emit_signal("status", true)
                else
                    self:emit_signal("status", false)
                end
            end
        })

    end)
end

local function new()
    local obj = gobject{}
    gtable.crush(obj, network, true)
    obj._private = {}
    obj._private.networks = {}
    obj:monitor_device()
    obj:active_connection()
    return obj
end

if not instance then
    instance = new()
end

return instance
