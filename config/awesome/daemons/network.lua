local awful = require("awful")
local gobject = require("gears.object")
local gtable = require("gears.table")
local utils = require("utils")
local naughty = require("naughty")

local network = {}
local instance = nil

function network:turn_off()
    awful.spawn("nmcli radio wifi off")
    self._private.wifi.hw_state = "disabled"
end

function network:turn_on()
    awful.spawn("nmcli radio wifi on")
    self._private.wifi.hw_state = "enabled"
end

function network:toggle()
    if self._private.wifi.hw_state == "enabled" then
        self:turn_off()
    else
        self:turn_on()
    end
end

function network:status()
    awful.spawn.easy_async("nmcli -t g status", function(stdout, _, _, exit_code)
        if not (exit_code == 0) then
            self:emit_signal("error", "unable to get status")
            return
        end

        local sections = utils.split(stdout, ":")

        self._private.state = sections[1]
        self._private.connectivity = sections[2]
        self._private.wifi.hw_state = sections[3]
        self._private.wifi.state = sections[4]
        self._private.wwan.hw_state = sections[5]
        self._private.wwan.state = sections[6]
        self:emit_signal("status", self._private.state, self._private.connectivity, self._private.wifi, self._private.wwan)
    end)
end

function network:strength()
    awful.spawn.easy_async_with_shell("nmcli -f IN-USE,SIGNAL,SSID dev wifi | awk '/^\\*/{if (NR!=1) {print $2}}'", function(stdout, _, _, exit_code)
        if not (exit_code == 0) then
            self:emit_signal("error", "unable to get wifi strength")
            return
        end

        self._private.wifi.strength = tonumber(stdout)
        self:emit_signal("strength", self._private.wifi.strength)
    end)
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

            local k = 1
            for v in str:gmatch("([^:]+)") do
                if k == 1 then
                    ssid = v
                end
                --naughty.notify({ message = v })
                k = k+1
            end

            table.insert(self._private.networks, { ssid = ssid })
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
                    self:strength()
                    --self:emit_signal("status", true)
                --else
                    --self:emit_signal("status", false)
                end
                self:status()
            end
        })

    end)
end

local function new()
    local obj = gobject{}
    gtable.crush(obj, network, true)
    
    obj._private = {}
    obj._private.networks = {}
    obj._private.state = "disconnected"
    obj._private.connectivity = "none"
    obj._private.wifi = {
        hw_state = "enabled",
        state = "enabled",
        strength = 0
    }
    obj._private.wwan = {
        hw_state = "missing",
        state = "enabled"
    }

    obj:status()
    obj:monitor_device()
    obj:active_connection()
    obj:strength()
    return obj
end

if not instance then
    instance = new()
end

return instance
