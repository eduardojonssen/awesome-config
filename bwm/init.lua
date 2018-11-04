--------------------------------------------------------------------------------
-- BWM library
--------------------------------------------------------------------------------

local setmetatable = setmetatable

return setmetatable(
    { _NAME = "bwm" },
    { __index = function(table, key)
        local module = rawget(table, key)
        return module or require(table._NAME .. '.' .. key)
    end }
)