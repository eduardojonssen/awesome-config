-- Load modules
------------------------------------------------------------------------------

-- Standard awesome library
---------------------------------------
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

require("awful.autofocus")

-- User modules
---------------------------------------
local bwm = require("bwm")

-- Error handling
---------------------------------------
require("colorless.ercheck-config") -- load file with error handling

-- Setup theme and environment vars
---------------------------------------
local env = require("colorless.env-config") -- load file with environment
env:init()

-- Layout setup
---------------------------------------
local layouts = require("colorless.layout-config") -- load file with layout setup
layouts:init()

-- Main menu configuration
---------------------------------------
local mymenu = require("colorless.menu-config") -- load file with menu configuration
mymenu:init()

-- Panel widgets
-------------------------------------------------------------------------------

-- Separator
---------------------------------------
local separator = bwm.gauge.separator.vertical()

-- Tasklist
---------------------------------------
local tasklist = {}

tasklist.buttons = awful.util.table.join(
    awful.button({}, 1, bwm.widget.tasklist.action.select),
    awful.button({}, 2, bwm.widget.tasklist.action.close),
    awful.button({}, 3, bwm.widget.tasklist.action.menu),
    awful.button({}, 4, bwm.widget.tasklist.action.switch_next),
    awful.button({}, 5, bwm.widget.tasklist.action.switch_prev)
)

-- Taglist widget
---------------------------------------
local taglist = {}
taglist.style = { widget = bwm.gauge.tag.orange.new, show_tip = true }
taglist.buttons = awful.util.table.join(
    awful.button({         }, 1, function(t) t:view_only() end),
    awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({         }, 2, awful.tag.viewtoggle),
    awful.button({         }, 3, function(t) bwm.widget.layoutbox:toggle_menu(t) end),
    awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
    awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- Textclock widget
---------------------------------------
local textclock = {}
textclock.widget = bwm.widget.textclock({ timeformat = "%H:%M", dateformat = "%b %d %a" })

-- Layoutbox configure
---------------------------------------
local layoutbox = {}

layoutbox.buttons = awful.util.table.join(
    awful.button({ }, 1, function() awful.layout.inc( 1) end),
    awful.button({ }, 3, function() bwm.widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
    awful.button({ }, 4, function() awful.layout.inc( 1) end),
    awful.button({ }, 5, function() awful.layout.inc(-1) end)
)

-- Tray widget
---------------------------------------
local tray = {}
tray.widget = bwm.widget.minitray()

tray.buttons = awful.util.table.join(
    awful.button({ }, 1, function() bwm.widget.minitray:toggle() end)
)

-- Screen setup
------------------------------------------------------------------------------
awful.screen.connect_for_each_screen(
    function(s)
        -- wallpaper
        env.wallpaper(s)

        -- tags
        awful.tag({ "Main", "Web", "Code", "Chat", "Docs" }, s, awful.layout.layouts[1])

        -- layoutbox widget
        layoutbox[s] = bwm.widget.layoutbox({ screen = s })

        -- taglist widget
        taglist[s] = bwm.widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip }, taglist.style)

        -- tasklist widget
        tasklist[s] = bwm.widget.tasklist({ screen = s, buttons = tasklist.buttons })

        -- panel wibox
        s.panel = awful.wibar({ position = "bottom", screen = s, height = beautiful.panel_height or 36 })

        -- add widgets to the wibox
        s.panel:setup {
            layout = wibox.layout.align.horizontal,
            { -- left widgets
                layout = wibox.layout.fixed.horizontal,
                env.wrapper(mymenu.widget, "mainmenu", mymenu.buttons),
                separator,
                env.wrapper(taglist[s], "taglist"),
                separator,
                s.mypromptbox,
            },
            { -- middle widget
                layout = wibox.layout.align.horizontal,
                expand = "outside",
                nil,
                env.wrapper(tasklist[s], "tasklist"),
            },
            { -- right widgets
                layout = wibox.layout.fixed.horizontal,
                separator,
                env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
                separator,
                env.wrapper(textclock.widget, "textclock"),
                separator,
                env.wrapper(tray.widget, "tray", tray.buttons),
            },
        }
    end
)

-- Key bindings
------------------------------------------------------------------------------
local hotkeys = require("colorless.keys-config") -- load file with hotkeys configuration
hotkeys:init({ env = env, menu = mymenu.mainmenu })

-- Rules
------------------------------------------------------------------------------
local rules = require("colorless.rules-config") -- load fileeith rules configuration
rules:init({ hotkeys = hotkeys })

-- Titlebar setup
------------------------------------------------------------------------------
local titlebar = required("colorless.titlebar-config") -- load file with titlebar configuration
titlebar:init()

-- Base signal set for awesome wm
------------------------------------------------------------------------------
local signals = require("colorless.signals-config") -- load file with signals configuration
signals:init({ env = env })