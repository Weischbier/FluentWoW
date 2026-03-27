--- FluentWoW – Core/Bootstrap.lua
-- Global namespace, version negotiation, module registration.
-- Uses LibStub when available (Ace3-style hand-off); falls back to direct global.
-------------------------------------------------------------------------------

local MAJOR, MINOR = "FluentWoW-1.0", 10000  -- 1.00.00 encoded

-------------------------------------------------------------------------------
-- LibStub registration (same pattern Ace3 uses to hand off the lib)
-------------------------------------------------------------------------------

---@class FluentWoW
local lib, oldMinor
if LibStub then
    lib, oldMinor = LibStub:NewLibrary(MAJOR, MINOR)
    if not lib then return end          -- a newer copy is already loaded
else
    -- Fallback: direct global version guard (no LibStub available)
    if FluentWoW and (FluentWoW.version or 0) >= MINOR then return end
    lib = FluentWoW or {}
end

-- Always expose as a global so `local lib = FluentWoW` keeps working
FluentWoW = lib

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
    error(("[FluentWoW] %s"):format(msg), (level or 1) + 1)
end

---@param cond any
---@param msg string
---@return boolean
function lib:Assert(cond, msg)
    if not cond then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF4444[FluentWoW] ASSERT: " .. tostring(msg) .. "|r")
        end
        return false
    end
    return true
end

---@param msg string
function lib:Debug(msg)
    if self.debug and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF88CCFF[FluentWoW] " .. tostring(msg) .. "|r")
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
