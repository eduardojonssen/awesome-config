------------------------------------------------------------------------------
-- Menu config
------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local bwm = require("bwm")

-- Initialize tables and vars for module
------------------------------------------------------------------------------
local menu = {}

-- Build function
---------------------------------------
function menu:init(args)

    -- vars
    local args = args or {}
    local env = args.env or {}
    local separator = args.separator or { widget = bwm.gauge.separator.horizontal() }
    local theme = args.theme or { auto_hotkey = true }
    local icon_style = args.icon_style or {}

    -- Application submenu
    ---------------------------------------

    -- WARNING!
    -- 'dfparser' module used to parse available desktop files for building application list and finding app icons,
    -- it may cause significant delay on wm start/restart due to the synchronous type of the scripts.
    -- This issue can be reduced by using additional settings like custom desktop files directory
    -- and user only icon theme. See colored configs for more details.

    -- At worst, you can give up all applications widgets (appmenu, applaunch, appswitcher, qlaunch) in your config
    local appmenu = bwm.service.dfparser.menu({ icons = icon_style, wm_name = "awesome" })

    -- Main menu
    ---------------------------------------
    self.mainmenu = bwm.menu({
        items = {
            { "Applications",   appmenu,        },
            { "Terminal",       env.terminal,   },
            separator,
            { "Web Browser",    "google-chrome-stable", },
            { "VSCode",         "code",                 },
            separator,
            { "Restart",        awesome.restart,    },
            { "Exit",           awesome.quit,       },
        }
    })

    -- Menu panel widget
    ---------------------------------------

    -- theme vars
    local deficon = bwm.util.base.placeholder()
    local icon = bwm.util.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or deficon
    local color = bwm.util.table.check(beautiful, "color.icon") and beautiful.color.icon or nil

    -- widget
    self.widget = bwm.gauge.svgbox(icon, nil, color)
    self.buttons = awful.util.table.join(
        awful.button({ }, 1, function() self.mainmenu:toggle() end )
    )
end

-- End
------------------------------------------------------------------------------
return menu