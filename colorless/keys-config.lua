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

    -- initial key
    -- first prefix key
    local keyseq = { { env.mod }, "c", {}, {} }

    -- second sequence keys
    keyseq[3] = {
        -- second and last key in sequence, full description and action is necessary
        {
            {}, "p", function() toggle_placement(env) end,
            { description = "Switch master/slave window placement", group = "Clients management" }
        },

        -- not last key in sequence, no description needed here
        { {}, "k", {}, {} }, -- application kill group
        { {}, "n", {}, {} }, -- application minimize group
        { {}, "r", {}, {} }, -- application restore group

        -- { {}, "g", {}, {} }, -- run or rise group
        -- { {}, "f", {}, {} }, -- launch application group
    }

    -- application kill actions,
    -- last key in sequence, full description and action is necessary
    keyseq[3][2][3] = {
        {
            {}, "f", function() if client.focus then client.focus:kill() end end,
            { description = "Kill focused client", group = "Kill application", keyset = { "f" } }
        },
        {
            {}, "a", kill_all,
            { description = "Kill all clients with current tag", group = "Kill application", keyset = { "a" } }
        },
    }

    -- application minimize actions,
    -- last key in sequence, full description and action is necessary
    keyseq[3][3][3] = {
        {
            {}, "f", function() if client.focus then client.focus.minimized = true end end,
            { description = "Minimize focused client", group = "Clients management", keyset = { "f" } }
        },
        {
            {}, "a", minimize_all,
            { description = "Minimize all clients with current tag", group = "Clients management", keyset = { "a" } }
        },
        {
            {}, "e", minimize_all_except_focused,
            { description = "Minimize all clients except focused", group = "Clients management", keyset = { "e" } }
        },
    }

    -- application restore actions,
    -- last key in sequence, full description and action is necessary
    keyseq[3][4][3] = {
        {
            {}, "f", restore_client,
            { description = "Restore minimized client", group = "Clients management", keyset = { "f" } }
        },
        {
            {}, "a", restore_all,
            { description = "Restore all clients with current tag", group = "Clients management", keyset = { "a" } }
        },
    }

    -- quick lauch key sequence actions, auto fill up last sequence key
    for i = 1, 9 do
        local ik = tostring(i)
        table.insert(keyseq[3][5][3], {
            {}, ik, function() qlaunch:run_or_raise(ik) end,
            { description = "Run or rise application " .. ik, group = "Run or Rise", keyset = { ik } }
        })
        table.insert(keyseq[3][6][3], {
            {}, ik, function() qlaunch:run_or_raise(ik, true) end,
            { description = "Launch application " .. ik, group = "Quick Launch", keyset = { ik } }
        })
    end

    -- Global keys
    ------------------------------------------------------------------------------
    self.raw.root = {
        {
            { env.mod }, "F1", function() redtip:show() end,
            { description = "Show hotkeys helper" , group = "Main" }
        },
        {
            { env.mod }, "F2", function() bwm.service.navigator:run() end,
            { description = "Window control mode", group = "Main" }
        },
        {
            { env.mod, "Control" }, "r", awesome.restart,
            { description = "Reload awesome", group = "Main" }
        },
        {
            { env.mod }, "c", function() bwm.float.keychain:activate(keyseq, "User") end,
            { description = "User key sequence", group = "Main" }
        },
        {
            { env.mod }, "Return", function() awful.spawn(env.terminal) end,
            { description = "Open a terminal", group = "Main" }
        }
    }

end