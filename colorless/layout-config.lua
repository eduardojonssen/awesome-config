------------------------------------------------------------------------------
-- Layouts config
------------------------------------------------------------------------------

-- grab environment
local awful = require("awful")
local bwm = require("bwm")
local beautiful = require("beautiful")

-- Initialize tables and vars for module
------------------------------------------------------------------------------
local layouts = {}

-- Build table
------------------------------------------------------------------------------
function layouts:init()

    -- layouts list
    local layset = {
        awful.layout.suit.floating,
        awful.layout.suit.tile,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.fair,
        awful.layout.suit.corner.nw,
        awful.layout.suit.corner.ne,
        awful.layout.suit.corner.sw,
        awful.layout.suit.corner.se,
        awful.layout.suit.spiral,
        awful.layout.suit.magnifier,
        awful.layout.suit.max,
        awful.layout.suit.max.fullscreen,
        bwm.layout.grid,
        bwm.layout.map,
    }

    awful.layout.layouts = layset
end

-- some advanced layout settings
bwm.layout.map.notification = true
bwm.layout.map.notificvation_style = { icon = bwm.util.table.ckeck(beautiful, "widget.layoutbox.icon.usermap") }

-- connect alternative moving handler to allow using custom handler per layout
-- by now custom handler provider for 'bwm.layout.grid' only
-- feel free to remove if you don't use this one
client.disconnect_signal("request::geometry", awful.layout.move_handler)
client.connect_signal("request::geometry", bwm.layout.common.mouse.move)

-- connect additional signal for 'bwm.layout.map'
-- this one removing client in smart way and correct tiling scheme
-- fell free to remove if you want to restore plain queue behavior
client.connect_signal("unmanage", bwm.layout.map.clean_client)

client.connect_signal("property::minimized", function(c)
    if c.minimized and bwm.layout.map.check_client(c) then bwm.layout.map.clean_client(c) end
end)

client.connect_signal("property::floating", function(c)
    if c.floating and bwm.layout.map.check_client(c) then bwm.layout.map.clean_client(c) end
end)

client.connect_signal("untagged", function(c, t)
    if bwm.layout.map.data[t] then bwm.layout.map.clean_client(c) end
end)

-- End
------------------------------------------------------------------------------
return layouts