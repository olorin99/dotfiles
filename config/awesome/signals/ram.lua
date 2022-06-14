local awful = require("awful")

local script = [[
    sh -c "
    free -m | grep 'Mem:' | awk '{printf \"%d@@%d@\", $7, $2}'
    "]]

awful.widget.watch(script, 30, function(_, stdout)
    local available = stdout:match('(.*)@@')
    local total = stdout:match('@@(.*)@')
    local used = tonumber(total) - tonumber(available)
    awesome.emit_signal("signals::ram", used, tonumber(total))
end)
