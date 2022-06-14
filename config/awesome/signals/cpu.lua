local awful = require("awful")

local script = [[
    sh -c "
    vmstat 1 2 | tail -1 | awk '{printf \"%d\", $15}'
    "]]

awful.widget.watch(script, 10, function(_, stdout)
    local cpu = string.gsub(stdout, "^%s*(.-)%s*$", "%1")
    awesome.emit_signal("signals::cpu", 100 - tonumber(cpu))
end)
