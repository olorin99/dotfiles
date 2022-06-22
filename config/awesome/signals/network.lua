local awful = require("awful")

-- get network status
awful.widget.watch("nmcli dev status", 30, function(_, stdout)
    local status = false
    local ssid = "None"

    for line in stdout:gmatch("([^\r\n]*)[\r\n]") do
        local a, b = line:find("connected")
        if b ~= nil then
            status = true
            ssid = line:sub(b + 2)
        end
    end
    awesome.emit_signal("signals::network", status, ssid)
end)

local toggle_wifi = function()

end

local scan_networks = function()
    awful.spawn.easy_async("nmcli device wifi", function(stdout, _, _, exit_code)
        if not (exit_code == 0) then
            return
        end

        local networks = {}

        local f, l = stdout:find("([^\r\n]*)[\r\n]")
        local first_line = stdout:sub(1, l)
        local a, b = first_line:find(" SSID")
        local c, d = first_line:find("MODE")

        local lines = stdout:sub(l)
        for line in lines:gmatch("([^\r\n]*)[\r\n]") do
            local ssid = line:sub(a, c - 1)
            table.insert(networks, ssid)
        end

        awesome.emit_signal("signals::network_scan_finished", networks)
    end)
end

awesome.connect_signal("signals::network_scan_start", function()
    scan_networks()
end)
