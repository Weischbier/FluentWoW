--- WinUILib – Core/Utils.lua
-- General-purpose utility helpers used throughout the framework.
-------------------------------------------------------------------------------

local lib = WinUILib

local Utils = {}
lib:RegisterModule("Utils", Utils)

-------------------------------------------------------------------------------
-- Table helpers
-------------------------------------------------------------------------------

---@param dst table
---@param src table
---@return table
function Utils.Merge(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then dst[k] = v end
    end
    return dst
end

---@param orig table
---@return table
function Utils.DeepCopy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = type(v) == "table" and Utils.DeepCopy(v) or v
    end
    return copy
end

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

---@param text string
---@param r number
---@param g number
---@param b number
---@return string
function Utils.ColorText(text, r, g, b)
    return ("|cFF%02X%02X%02X%s|r"):format(r * 255, g * 255, b * 255, text)
end

---@param text string
---@param maxLen integer
---@return string
function Utils.Truncate(text, maxLen)
    if #text <= maxLen then return text end
    return text:sub(1, maxLen - 1) .. "\226\128\166"
end

-------------------------------------------------------------------------------
-- Frame / anchor helpers
-------------------------------------------------------------------------------

---@param frame Frame
---@param point string
---@param relativeTo Frame|string
---@param relativePoint string
---@param x? number
---@param y? number
function Utils.SetPoint(frame, point, relativeTo, relativePoint, x, y)
    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, x or 0, y or 0)
end

---@param v number
---@return number
function Utils.SnapToPixel(v)
    return math.floor(v + 0.5)
end

---@return number
function Utils.UIScale()
    return UIParent:GetScale()
end

-------------------------------------------------------------------------------
-- Colour helpers
-------------------------------------------------------------------------------

---@param hex string
---@return number, number, number
function Utils.HexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber(hex:sub(1, 2), 16) / 255,
           tonumber(hex:sub(3, 4), 16) / 255,
           tonumber(hex:sub(5, 6), 16) / 255
end

---@param r1 number @param g1 number @param b1 number
---@param r2 number @param g2 number @param b2 number
---@param t number
---@return number, number, number
function Utils.LerpColor(r1, g1, b1, r2, g2, b2, t)
    return r1 + (r2 - r1) * t, g1 + (g2 - g1) * t, b1 + (b2 - b1) * t
end

-------------------------------------------------------------------------------
-- Safe call
-------------------------------------------------------------------------------

---@param fn function
---@param ... any
---@return boolean, any
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

---@return boolean
function Utils.InCombat()
    return InCombatLockdown()
end
