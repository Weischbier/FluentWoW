--- WinUILib – Core/Bootstrap.lua
-- Global namespace, version negotiation, module registration.
-- Last-writer-wins on major; minor bumped to highest seen.
-------------------------------------------------------------------------------

local MAJOR, MINOR = "WinUILib", 10000  -- 1.0.0 encoded

if WinUILib and (WinUILib.version or 0) >= MINOR then return end

---@class WinUILib
local lib = WinUILib or {}
WinUILib = lib

lib.version    = MINOR
lib.name       = MAJOR
lib._controls  = lib._controls  or {}
lib._themes    = lib._themes    or {}
lib._tokens    = lib._tokens    or {}
lib._styles    = lib._styles    or {}
lib._callbacks = lib._callbacks or {}

-------------------------------------------------------------------------------
-- Error / debug helpers
-------------------------------------------------------------------------------

---@param msg string
---@param level? integer
function lib:Error(msg, level)
    error(("[WinUILib] %s"):format(msg), (level or 1) + 1)
end

---@param cond any
---@param msg string
---@return boolean
function lib:Assert(cond, msg)
    if not cond then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF4444[WinUILib] ASSERT: " .. tostring(msg) .. "|r")
        end
        return false
    end
    return true
end

---@param msg string
function lib:Debug(msg)
    if self.debug and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF88CCFF[WinUILib] " .. tostring(msg) .. "|r")
    end
end

-------------------------------------------------------------------------------
-- Module registration
-------------------------------------------------------------------------------

---@param name string
---@param tbl table
function lib:RegisterModule(name, tbl)
    if self[name] then return end
    self[name] = tbl
    tbl._lib = self
end
