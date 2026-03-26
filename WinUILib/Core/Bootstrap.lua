--- WinUILib – Core/Bootstrap.lua
-- Establishes the global WinUILib namespace, version registration, and
-- library-negotiation so multiple addons can embed different versions safely.
--
-- Usage (consuming addon):
--   local WUIL = WinUILib  -- global, set by this file after ADDON_LOADED
--
-- Version negotiation: last-writer-wins on major version; minor/patch are
-- bumped to highest seen value so callers always get the richest feature set
-- present in the session.
-------------------------------------------------------------------------------

local MAJOR, MINOR = "WinUILib", 10000  -- 1.0.0 encoded as 10000

-- Guard: if a newer (or equal) version is already loaded, do nothing.
if WinUILib and (WinUILib.version or 0) >= MINOR then return end

--- @class WinUILib
local lib = WinUILib or {}
WinUILib = lib

lib.version  = MINOR
lib.name     = MAJOR

-- Internal registries populated by sub-modules
lib._controls    = lib._controls    or {}
lib._themes      = lib._themes      or {}
lib._tokens      = lib._tokens      or {}
lib._styles      = lib._styles      or {}
lib._callbacks   = lib._callbacks   or {}

-------------------------------------------------------------------------------
-- Simple assert / error helpers
-------------------------------------------------------------------------------

--- Raises a formatted error attributed to WinUILib.
---@param msg string
---@param level? integer
function lib:Error(msg, level)
    error(("[WinUILib] %s"):format(msg), (level or 1) + 1)
end

--- Soft assert – logs a warning and returns false if condition is falsy.
---@param cond any
---@param msg string
---@return boolean
function lib:Assert(cond, msg)
    if not cond then
        if DEFAULT_CHAT_FRAME then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF4444[WinUILib] ASSERT FAILED: " .. tostring(msg) .. "|r")
        end
        return false
    end
    return true
end

--- Prints a debug message when lib.debug is true.
---@param msg string
function lib:Debug(msg)
    if self.debug and DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cFF88CCFF[WinUILib] " .. tostring(msg) .. "|r")
    end
end

-------------------------------------------------------------------------------
-- Module registration
-- Sub-modules call  WinUILib:RegisterModule(name, tbl)  to attach themselves.
-------------------------------------------------------------------------------

---@param name string  Unique module name, e.g. "Tokens", "Motion"
---@param tbl  table   Module table to attach to WinUILib.<name>
function lib:RegisterModule(name, tbl)
    if self[name] then return end   -- already registered (older embed)
    self[name] = tbl
    tbl._lib = self
end

-------------------------------------------------------------------------------
-- Lifecycle – ADDON_LOADED bootstrap
-------------------------------------------------------------------------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "WinUILib" then
        -- Fire any queued OnLoad callbacks registered by sub-modules.
        for _, cb in ipairs(lib._callbacks) do
            pcall(cb, lib)
        end
        lib._loaded = true
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

--- Register a callback to be invoked once WinUILib finishes loading.
---@param fn function  Receives `lib` as first argument.
function lib:OnLoad(fn)
    if self._loaded then
        pcall(fn, self)
    else
        table.insert(self._callbacks, fn)
    end
end
