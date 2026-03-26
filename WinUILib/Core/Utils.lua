--- WinUILib – Core/Utils.lua
-- General-purpose utility helpers used throughout the framework.
-------------------------------------------------------------------------------

local lib = WinUILib

local Utils = {}
lib:RegisterModule("Utils", Utils)

-------------------------------------------------------------------------------
-- Table helpers
-------------------------------------------------------------------------------

--- Shallow-merge src into dst; dst takes precedence for existing keys.
---@param dst table
---@param src table
---@return table dst
function Utils.Merge(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then dst[k] = v end
    end
    return dst
end

--- Deep-copy a table (no metatable preservation).
---@param orig table
---@return table
function Utils.DeepCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = type(v) == "table" and Utils.DeepCopy(v) or v
    end
    return copy
end

--- Returns true if tbl contains value.
---@param tbl table
---@param value any
---@return boolean
function Utils.Contains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

-------------------------------------------------------------------------------
-- String helpers
-------------------------------------------------------------------------------

--- Wraps text in WoW colour escape codes.
---@param text string
---@param r number  0-1
---@param g number  0-1
---@param b number  0-1
---@return string
function Utils.ColorText(text, r, g, b)
    local hex = string.format("%02X%02X%02X", r * 255, g * 255, b * 255)
    return "|cFF" .. hex .. text .. "|r"
end

--- Truncates text and appends "…" if it exceeds maxLen characters.
---@param text string
---@param maxLen integer
---@return string
function Utils.Truncate(text, maxLen)
    if #text <= maxLen then return text end
    return text:sub(1, maxLen - 1) .. "…"
end

-------------------------------------------------------------------------------
-- Frame / anchor helpers
-------------------------------------------------------------------------------

--- Clears all points and sets a single anchor.
---@param frame Frame
---@param point string
---@param relativeTo Frame|string
---@param relativePoint string
---@param x number
---@param y number
function Utils.SetPoint(frame, point, relativeTo, relativePoint, x, y)
    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, x or 0, y or 0)
end

--- Pixel-snaps a value to the nearest integer (important for 1:1 UI scale).
---@param v number
---@return number
function Utils.SnapToPixel(v)
    return math.floor(v + 0.5)
end

--- Returns effective UI pixel scale for pixel-perfect placement.
---@return number
function Utils.UIScale()
    return UIParent:GetScale()
end

-------------------------------------------------------------------------------
-- Colour helpers
-------------------------------------------------------------------------------

--- Converts hex string "#RRGGBB" or "RRGGBB" to r,g,b floats (0-1).
---@param hex string
---@return number, number, number
function Utils.HexToRGB(hex)
    hex = hex:gsub("#", "")
    local r = tonumber(hex:sub(1,2), 16) / 255
    local g = tonumber(hex:sub(3,4), 16) / 255
    local b = tonumber(hex:sub(5,6), 16) / 255
    return r, g, b
end

--- Linearly interpolates between two colour triples.
---@param r1 number  @param g1 number  @param b1 number
---@param r2 number  @param g2 number  @param b2 number
---@param t  number  0=colour1, 1=colour2
---@return number, number, number
function Utils.LerpColor(r1, g1, b1, r2, g2, b2, t)
    return r1 + (r2-r1)*t, g1 + (g2-g1)*t, b1 + (b2-b1)*t
end

-------------------------------------------------------------------------------
-- Safe call
-------------------------------------------------------------------------------

--- Calls fn with args, printing any error rather than propagating it.
---@param fn function
---@param ... any
---@return boolean ok, any result
function Utils.SafeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then
        lib:Debug("SafeCall error: " .. tostring(result))
    end
    return ok, result
end

-------------------------------------------------------------------------------
-- Combat guard
-------------------------------------------------------------------------------

--- Returns true if the caller is operating inside a secure taint context.
--- Use this before any frame mutation that might cause taint.
---@return boolean
function Utils.InCombat()
    return InCombatLockdown()
end
