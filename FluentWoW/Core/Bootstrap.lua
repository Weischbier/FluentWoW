--- FluentWoW – Core/Bootstrap.lua
-- Global namespace, version negotiation, module registration, Embed support.
-- Mirrors the Ace3 library hand-off pattern: LibStub registration, mixins, Embed.
-------------------------------------------------------------------------------

local MAJOR, MINOR = "FluentWoW-1.0", 10500  -- 1.05.00 encoded

-------------------------------------------------------------------------------
-- LibStub registration  (identical to Ace3 libraries)
-- Consumer pattern:  local lib = LibStub("FluentWoW-1.0")
-------------------------------------------------------------------------------

---@class FluentWoW
local lib, _oldMinor
if LibStub then
    lib, _oldMinor = LibStub:NewLibrary(MAJOR, MINOR)
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
lib.embeds     = lib.embeds     or {}          -- tracks Embed targets (Ace3 pattern)

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

-------------------------------------------------------------------------------
-- Embed support  (Ace3 mixin pattern)
--
-- Usage with AceAddon:
--   local MyAddon = LibStub("AceAddon-3.0"):NewAddon("MyAddon", "FluentWoW-1.0")
--   -- MyAddon now has all Create* factory methods mixed in
--
-- Standalone usage:
--   local myTable = {}
--   LibStub("FluentWoW-1.0"):Embed(myTable)
--   local btn = myTable:CreateButton(parent)
-------------------------------------------------------------------------------

--- Embed all factory methods (Create*) and module accessors into a target table.
-- Mirrors the Ace3 Embed() contract: libraries that expose :Embed() are
-- auto-embedded by AceAddon:NewAddon() when listed in the varargs.
---@param target table  The table to mix methods into
---@return table target  The same table, for chaining
function lib:Embed(target)
    for k, v in pairs(self) do
        if type(v) == "function" and k:match("^Create") then
            target[k] = v
        end
    end
    -- Also expose token + event accessors so embedded consumers can theme
    target.Tokens   = self.Tokens
    target.EventBus = self.EventBus
    target.Motion   = self.Motion
    self.embeds[target] = true
    return target
end

--- Called by AceAddon after the consumer's :OnInitialize fires.
---@param target table
function lib:OnEmbedInitialize(target)  -- intentional no-op; available for override
end

--- Called by AceAddon after the consumer's :OnEnable fires.
---@param target table
function lib:OnEmbedEnable(target)      -- intentional no-op; available for override
end

--- Called by AceAddon after the consumer's :OnDisable fires.
---@param target table
function lib:OnEmbedDisable(target)     -- intentional no-op; available for override
end

-------------------------------------------------------------------------------
-- Re-embed on upgrade  (Ace3 pattern: keeps existing consumers current)
-------------------------------------------------------------------------------

for target in pairs(lib.embeds) do
    lib:Embed(target)
end
