------------------------------------------------------------------------------
-- Titlebar config
------------------------------------------------------------------------------

-- Grab environment
local awful = require("awful")
local wibox = require("wibox")

local bwmtitle = require("bwm.titlebar")
local clientmenu = require("bwm.float.clientmenu")

-- Initialize tables and vars for module
------------------------------------------------------------------------------
local titlebar = {}

-- Support functions
------------------------------------------------------------------------------
local function title_buttons(c)
    return awful.util.table.join(
        awful.button(
            { }, 1,
            function()
                client.focus = c; c:raise()
                awful.mouse.client.move(c)
            end
        ),
        awful.button(
            { }, 3,
            function()
                client.focus = c; c:raise()
                clientmenu:show(c)
            end
        )
    )
end

local function on_maximize(c)
    -- hide/show titlebar
    local is_max = c.maximized_vertical or c.maximized
    local action = is_max and "cut_all" or "restore_all"
    bwmtitle[action]({ c })

    -- dirty size correction
    local model = bwmtitle.get_model(c)
    if model and not model.hidden then
        c.height = c:geometry().height + (is_max and model.size or -model.size)
        if is_max then c.y = c.screen.workarea.y end
    end
end

-- Connect titlebar building signal
------------------------------------------------------------------------------
function titlebar:init(args)

    -- vars
    local args = args or {}
    local style = {}

    style.light = args.light or bwmtitle.get_style()
    style.full = args.full or { size = 28, icon = { size = 25, gap = 0, angle = 0.5 } }

    client.connect_signal(
        "request::titlebars",
        function(c)
            -- build titlebar and mouse buttons for it
            local buttons = title_buttons(c)
            bwmtitle(c)

            -- build light titlebar model
            local light = wibox.widget({
                nil,
                {
                    right = style.light.icon.gap,
                    bwmtitle.icon.focus(c),
                    layout = wibox.container.margin,
                },
                {
                    bwmtitle.icon.property(c, "floating"),
                    bwmtitle.icon.property(c, "sticky"),
                    bwmtitle.icon.property(c, "ontop"),
                    spacing = style.light.icon.gap,
                    layout = wibox.layout.fixed.horizontal()
                },
                buttons = buttons,
                layout = wibox.layout.align.horizontal,
            })

            -- build full titlebar model
            local full = wibox.widget({
                bwmtitle.icon.focus(c, style.full),
                bwmtitle.icon.label(c, style.full),
                {
                    bwmtitle.icon.property(c, "floating", style.full),
                    bwmtitle.icon.property(c, "sticky", style.full),
                    bwmtitle.icon.property(c, "ontop", style.full),
                    spacing = style.full.icon.gap,
                    layout = wibox.layout.fixed.horizontal()
                },
                buttons = buttons,
                layout = wibox.layout.align.horizontal,
            })

            -- Set both models to titlebar
            bwmtitle.add_layout(c, nil, light)
            bwmtitle.add_layout(c, nil, full, style.full.size)

            -- hide titlebar when window maximized
            if c.maximized_vertical or c.maximized then on_maximize(c) end

            c:connect_signal("property::maximized_vertical", on_maximize)
            c:connect_signal("property::maximized", on_maximize)
        end
    )
end

-- End
------------------------------------------------------------------------------
return titlebar