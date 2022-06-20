local awful = require("awful")

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
