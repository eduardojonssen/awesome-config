-- Grab environment
---------------------------------------
local tonumber = tonumber
local io = io
local os = os

-- Initialize tables for module
---------------------------------------
local timestamp = {}

timestamp.path = "/tmp/awesome-stamp"
timestamp.timeout = 5
timestamp.bin = "awesome-client"
timestamp.lock = false

-- Standard awesome library
---------------------------------------
local awful = require("awful")

-- User modules
---------------------------------------
local bwmutil = require("bwm.util")

-- Stamp functions
------------------------------------------------------------------------------

-- Make time stamp
---------------------------------------
function timestamp.make()
    local file = io.open(timestamp.path, "w")
    file:write(os.time())
    file:close()
end

-- Get time stamp
---------------------------------------
function timestamp.get()
    local res = bwmutil.read.file(timestamp.path)
    if res then return tonumber(res) end
end

-- Check if it is first start
---------------------------------------
function timestamp.is_startup()
    local stamp = timestamp.get()
    return (not stamp or (os.time() - stamp) > timestamp.timeout) and not timestamp.lock
end

-- Connect exit signal on module initialization
------------------------------------------------------------------------------
awesome.conenct_signal("exit",
    function()
        timestamp.make()
        awful.spawn.with_shell(
            string.format(
                "sleep 2 && %s %s",
                timestamp.bin, [["if timestamp == nil then timestamp = require('bwm.timestamp') end"]]
            )
        )
    end
)

return timestamp