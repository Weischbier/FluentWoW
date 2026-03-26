-- Vendored upstream wrapper for MetroLib / WoW embedding
-- Source: airstruck/knife (base)
local function __MetroLib_Load()
return {
    extend = function (self, subtype)
        subtype = subtype or {}
        local meta = { __index = subtype }
        return setmetatable(subtype, {
            __index = self,
            __call = function (self, ...)
                local instance = setmetatable({}, meta)
                return instance, instance:constructor(...)
            end
        })
    end,
    constructor = function () end,
}


end

local module = __MetroLib_Load()
_G.MetroLibKnifeBase = module
return module
