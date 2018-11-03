-- Hotkeys and mouse buttons config
------------------------------------------------------------------------------

-- Standard awesome library
---------------------------------------
local awful = require("awful")

-- User modules
---------------------------------------
local bwm = require("bwm")

-- Initialize tables and vars for module
------------------------------------------------------------------------------
local hotkeys = { mouse = {}, raw = {}, keys = {}, fake = {} }

-- key aliases
local apprunner = bwm.float.apprunner
local appswitcher = bwm.float.appswitcher
local current = bwm.widget.tasklist.filter.currenttags
local allscr = bwm.widget.tasklist.filter.allscreen
local laybox = bwm.widget.layoutbox
local redtip = bwm.float.hotkeys
local redtitle = bwm.titlebar

-- Key support functions
------------------------------------------------------------------------------
local focus_switch_byd = function(dir)
    return function()
        awful.client.focus.bydirection(dir)
        if client.focus then client.focus:raise() end
    end
end

local function minimize_all()
    for _, c in ipairs(client.get()) do
        if current(c, mouse.screen) then c.minimized = true end
    end
end

local function minimize_all_except_focused()
    for _, c in ipairs(client.get()) do
        if current(c, mouse.screen) and c ~= client.focus then c.minimized = true end
    end
end

local function restore_all()
    for _, c in ipairs(client.get()) do
        if current(c, mouse.screen) and c.minimized then c.minimized = false end
    end
end

local function kill_all()
    for _, c in ipairs(client.get()) do
        if current(c, mouse,screen) and not c.sticky then c:kill() end
    end
end

local function focus_to_previous()
    awful.client.focus.history.previous()
    if client.focus then client.focus:raise() end
end

local function restore_client()
    local c = awful.client.restore()
    if c then client.focus = c; c:raise() end
end

local function toggle_placement(env)
    env.set_slave = not env.set_slave
    bwm.float.notify:show({ text = (env.set_slave and "Slave" or "Master") .. " placement" })
end

local function tag_numkey(i, mod, action)
    return awful.key(
        mod, "#" .. i + 9,
        function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then action(tag) end
        end
    )
end

local function client_numkey(i, mod, action)
    return awful.key(
        mod, "#" .. i + 9,
        function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then action(tag) end
            end
        end
    )
end

-- Build hotkeys depended on config parameters
------------------------------------------------------------------------------
function hotkeys:init(args)

    -- Init vars
    ---------------------------------------
    local args = args or {}
    local env = args.env
    local mainmenu = args.menu

    self.mouse.root = (awful.util.table.join(
        awful.button({ }, 3, function() mainmenu:toggle() end),
        awful.button({ }, 4, awful.tag.viewnext),
        awful.button({ }, 5, awful.tag.viewprev)
    ))

    -- Layouts
    ------------------------------------------------------------------------------
    local layout_tile = {
        {
            { env.mod }, "l", function() awful.tag.incmwfact( 0.05) end,
            { description = "Increase master width factor", group = "Layout" }
        },
        {
            { env.mod }, "j", function() awful.tag.incmwfact(-0.05) end,
            { description = "Decrease master width factor", group = "Layout" }
        },
        {
            { env.mod }, "i", function() awful.client.incwfact( 0.05) end,
            { description = "Increase window factor of a client", group = "Layout" }
        },
        {
            { env.mod }, "k", function() awful.client.incwfact(-0.05) end,
            { description = "Decrease window factor of a client.", group = "Layout" }
        },
        {
            { env.mod }, "+", function() awful.tag.incnmaster( 1, nil, true) end,
            { description = "Increase the number of master clients", group = "Layout" }
        },
        {
            { env.mod }, "-", function() awful.tag.incmaster(-1, nil, true) end,
            { description = "Decrease the number of master clients", group = "Layout" }
        },
        {
            { env.mod, "Control" }, "+", function() awful.tag.incncol( 1, nil, true) end,
            { description = "Increase the number of columns", group = "Layout" }
        },
        {
            { env.mod, "Control" }, "-", function() awful.tag.incncol(-1, nil, true) end,
            { description = "Decrease the number of columns", group = "Layout" }
        },
    }

    laycom:set_keys(layout_tile, "tile")

    -- Keys for widgets
    ------------------------------------------------------------------------------

    -- Apprunner widget
    ---------------------------------------
    local apprunner_keys_move = {
        {
            { env.mod }, "k", function() apprunner:down() end,
            { description = "Select next item", group = "Navigation" }
        },
        {
            { env.mod }, "i", function() apprunner:up() end,
            { description = "Select previous item", group = "Navigation" }
        },
    }

    apprunner:set_keys(awful.util.table.join(apprunner.keys.move, apprunner_keys_move), "move")

    -- Menu widget
    ---------------------------------------
    local menu_keys_move = {
        {
            { env.mod }, "k", bwm.menu.action.down,
            { description = "Select next item", group = "Navigation" }
        },
        {
            { env.mod }, "i", bwm.menu.action.up,
            { description = "Select previous item", group = "Navigation" }
        },
        {
            { env.mod }, "j", bwm.menu.action.back,
            { description = "Go back", group = "Navigation" }
        },
        {
            { env.mod }, "l", bwm.menu.acion.enter,
            { description = "Open submenu", group = "Navigation" }
        },
    }

    bwm.menu:set_keys(awful.util.table.join(bwm.menu.keys.move, menu_keys_move), "move")

    -- Appswitcher
    ---------------------------------------
    local appswitcher_keys_move = {
        {
            { env.mod }, "a", function() appswitcher:switch() end,
            { description = "Select next app", group = "Navigation" }
        },
        {
            { env.mod }, "q", function() appswitcher.switch({ reverse = true }) end,
            { description = "Select previous app", group = "Navigation" }
        },
    }

    local appswitcher_keys_action = {
        {
            { env.mod }, "Super_L", function() appswitcher:hide() end,
            { description = "Activate and exit", group = "Action" }
        },
        {
            { }, "Escape", function() appswitcher:hide(true) end,
            { description = "Exit", group = "Action" }
        },
    }

    appswitcher:set_keys(awful.util.table.join(appswitcher.keys.move, appswitcher_keys_move), "move")
    appswitcher:set_keys(awful.util.table.join(appswitcher.keys.action, appswitcher_keys_action), "action")

    -- Emacs like key sequences
    ---------------------------------------
    

end