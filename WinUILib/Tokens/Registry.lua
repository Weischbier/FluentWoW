--- WinUILib – Tokens/Registry.lua
-- Design-token registry.  Consumers resolve tokens by semantic name; the
-- registry looks them up through the active theme with fallback to defaults.
--
-- Token resolution order:
--   1. Addon override  (registered via Registry:Override)
--   2. Active theme    (registered via Registry:RegisterTheme)
--   3. Default theme   (loaded by DefaultTheme.lua)
--
-- Usage:
--   local c = WinUILib.Tokens:Get("Color.Accent.Primary")  -- returns {r,g,b,a}
--   local s = WinUILib.Tokens:GetSpacing("SM")             -- returns number
-------------------------------------------------------------------------------

local lib = WinUILib

local Registry = {}
lib:RegisterModule("Tokens", Registry)

local _themes    = {}          -- [themeName] = token table
local _overrides = {}          -- flat override table
local _active    = "Default"   -- active theme name

-------------------------------------------------------------------------------
-- Theme management
-------------------------------------------------------------------------------

--- Registers a named theme token table.
---@param name   string  Theme identifier, e.g. "Default", "Light", "Custom"
---@param tokens table   Flat or nested token map.
function Registry:RegisterTheme(name, tokens)
    _themes[name] = tokens
    lib.EventBus:Emit("ThemeRegistered", name)
end

--- Activates a registered theme by name.
---@param name string
function Registry:SetTheme(name)
    if not _themes[name] then
        lib:Debug("SetTheme: unknown theme '" .. tostring(name) .. "'")
        return
    end
    _active = name
    lib.EventBus:Emit("ThemeChanged", name)
end

--- Returns the active theme name.
---@return string
function Registry:GetThemeName()
    return _active
end

--- Overrides one or more tokens at session level (highest priority).
---@param overrides table  Flat key→value map, e.g. { ["Color.Accent.Primary"] = {r,g,b,a} }
function Registry:Override(overrides)
    for k, v in pairs(overrides) do
        _overrides[k] = v
    end
    lib.EventBus:Emit("TokensOverridden", overrides)
end

-------------------------------------------------------------------------------
-- Token resolution
-------------------------------------------------------------------------------

--- Resolves a dot-separated token path against a flat or nested table.
---@param tbl  table
---@param path string  e.g. "Color.Accent.Primary"
---@return any|nil
local function resolve(tbl, path)
    -- Try flat key first (fast path)
    local v = tbl[path]
    if v ~= nil then return v end
    -- Walk nested tables
    local node = tbl
    for segment in path:gmatch("[^%.]+") do
        if type(node) ~= "table" then return nil end
        node = node[segment]
    end
    return node ~= tbl and node or nil
end

--- Retrieves a token value by semantic name.
---@param key string  Dot-separated path, e.g. "Color.Surface.Base"
---@return any|nil
function Registry:Get(key)
    return _overrides[key]
        or resolve(_themes[_active]   or {}, key)
        or resolve(_themes["Default"] or {}, key)
end

--- Convenience – returns a colour token as r,g,b,a (all 0-1).
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
    return 0, 0, 0, 1
end

--- Convenience – returns a spacing token as a number.
---@param key string  e.g. "Spacing.SM" or just "SM" when prefixed by caller
---@return number
function Registry:GetSpacing(key)
    return tonumber(self:Get("Spacing." .. key) or self:Get(key)) or 0
end

--- Convenience – returns a font token: fontPath, size, flags.
---@param key string  e.g. "Typography.Body"
---@return string, number, string
function Registry:GetFont(key)
    local t = self:Get("Typography." .. key) or self:Get(key)
    if type(t) == "table" then
        return t.font or "Fonts\\FRIZQT__.TTF",
               t.size or 12,
               t.flags or ""
    end
    return "Fonts\\FRIZQT__.TTF", 12, ""
end

--- Convenience – returns a numeric token (radius, duration, z-order, etc.).
---@param key string
---@return number
function Registry:GetNumber(key)
    return tonumber(self:Get(key)) or 0
end
