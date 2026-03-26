--- WinUILib – Tokens/Registry.lua
-- Design-token registry with resolution: override > active theme > default.
-------------------------------------------------------------------------------

local lib = WinUILib

local Registry = {}
lib:RegisterModule("Tokens", Registry)

local _themes    = {}
local _overrides = {}
local _active    = "Default"

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
        _overrides[k] = v
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
    return _overrides[key]
        or resolve(_themes[_active] or {}, key)
        or resolve(_themes["Default"] or {}, key)
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
    return tonumber(self:Get("Spacing." .. key) or self:Get(key)) or 0
end

---@param key string
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

---@param key string
---@return number
function Registry:GetNumber(key)
    return tonumber(self:Get(key)) or 0
end
