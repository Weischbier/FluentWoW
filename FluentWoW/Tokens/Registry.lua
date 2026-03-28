--- FluentWoW – Tokens/Registry.lua
-- Design-token registry with resolution: override > active theme > default.
-- Structural design constants (spacing, typography, radii, motion, opacity,
-- layer, density, icon sizes) are HARDCODED and cannot be overridden by themes
-- or addon overrides.  Only Color tokens are themeable.
-------------------------------------------------------------------------------

local lib = FluentWoW

local Registry = {}
lib:RegisterModule("Tokens", Registry)

local _themes    = {}
local _overrides = {}
local _active    = "Dark"

-------------------------------------------------------------------------------
-- Hardcoded design constants — NOT overridable by themes or overrides.
-- This is the core design language; gaps, font sizes, radii, timing, opacity,
-- layer ordering, density, and icon sizes are fixed by design philosophy.
-------------------------------------------------------------------------------

local _DESIGN = {
    Spacing = {
        XS   = 2,
        SM   = 4,
        MD   = 8,
        LG   = 12,
        XL   = 16,
        XXL  = 24,
        XXXL = 32,
    },

    Typography = {
        Display  = { font = "Fonts\\MORPHEUS.ttf",  size = 28, flags = "" },
        Header   = { font = "Fonts\\FRIZQT__.TTF",  size = 20, flags = "" },
        Title    = { font = "Fonts\\FRIZQT__.TTF",  size = 16, flags = "" },
        Body     = { font = "Fonts\\ARIALN.TTF",    size = 13, flags = "" },
        BodyBold = { font = "Fonts\\ARIALN.TTF",    size = 13, flags = "OUTLINE" },
        Caption  = { font = "Fonts\\ARIALN.TTF",    size = 11, flags = "" },
        Mono     = { font = "Fonts\\ARIALN.TTF",    size = 11, flags = "" },
    },

    Radii = {
        None = 0,
        SM   = 2,
        MD   = 4,
        LG   = 8,
        Full = 999,
    },

    Motion = {
        Duration = {
            Instant  = 0,
            Fast     = 0.10,
            Normal   = 0.20,
            Slow     = 0.35,
            Entrance = 0.25,
            Exit     = 0.15,
        },
        Easing = {
            Standard   = "Smooth",
            Decelerate = "Smooth",
            Accelerate = "Linear",
            Linear     = "Linear",
        },
    },

    Opacity = {
        Disabled = 0.40,
        Overlay  = 0.60,
        Ghost    = 0.70,
        Shadow   = 0.85,
    },

    Layer = {
        Base    = 1,
        Raised  = 2,
        Overlay = 3,
        Dialog  = 4,
        Toast   = 5,
    },

    Density = {
        Compact     = 0.75,
        Normal      = 1.00,
        Comfortable = 1.30,
    },

    Icon = {
        SM = 12,
        MD = 16,
        LG = 20,
        XL = 32,
    },
}

-------------------------------------------------------------------------------
-- Theme management
-------------------------------------------------------------------------------

---@param name string
---@param tokens table
function Registry:RegisterTheme(name, tokens)
    _themes[name] = tokens
    lib.EventBus:Emit("ThemeRegistered", name)
end

---@param name string
function Registry:SetTheme(name)
    if not _themes[name] then
        lib:Debug("SetTheme: unknown theme '" .. tostring(name) .. "'")
        return
    end
    _active = name
    lib.EventBus:Emit("ThemeChanged", name)
end

---@return string
function Registry:GetThemeName()
    return _active
end

---@param overrides table
function Registry:Override(overrides)
    for k, v in pairs(overrides) do
        if k:match("^Color%.") then
            _overrides[k] = v
        else
            lib:Debug("Override: '" .. tostring(k) .. "' is a hardcoded design constant and cannot be overridden")
        end
    end
    lib.EventBus:Emit("TokensOverridden", overrides)
end

-------------------------------------------------------------------------------
-- Resolution
-------------------------------------------------------------------------------

---@param tbl table
---@param path string
---@return any|nil
local function resolve(tbl, path)
    local v = tbl[path]
    if v ~= nil then return v end
    local node = tbl
    for segment in path:gmatch("[^%.]+") do
        if type(node) ~= "table" then return nil end
        node = node[segment]
    end
    return node ~= tbl and node or nil
end

---@param key string
---@return any|nil
function Registry:Get(key)
    -- Design constants are checked first and are immutable
    local design = resolve(_DESIGN, key)
    if design ~= nil then return design end
    -- Color tokens resolve through: override > active theme > Dark fallback
    return _overrides[key]
        or resolve(_themes[_active] or {}, key)
        or resolve(_themes["Dark"] or {}, key)
end

---@param key string
---@return number, number, number, number
function Registry:GetColor(key)
    local c = self:Get(key)
    if type(c) == "table" then
        return c[1] or c.r or 0,
               c[2] or c.g or 0,
               c[3] or c.b or 0,
               c[4] or c.a or 1
    end
    lib:Debug("GetColor: missing token '" .. tostring(key) .. "'")
    return 0, 0, 0, 1
end

---@param key string
---@return number
function Registry:GetSpacing(key)
    local s = key:match("^Spacing%.(.+)") or key
    return _DESIGN.Spacing[s] or 0
end

---@param key string
---@return string, number, string
function Registry:GetFont(key)
    local s = key:match("^Typography%.(.+)") or key
    local t = _DESIGN.Typography[s]
    if type(t) == "table" then
        return t.font or "Fonts\\FRIZQT__.TTF",
               t.size or 12,
               t.flags or ""
    end
    return "Fonts\\FRIZQT__.TTF", 12, ""
end

---@param key string
---@return number
function Registry:GetNumber(key)
    return tonumber(self:Get(key)) or 0
end

---@return table<string, boolean>  A set of registered theme names
function Registry:GetAvailableThemes()
    local out = {}
    for name in pairs(_themes) do
        out[name] = true
    end
    return out
end
