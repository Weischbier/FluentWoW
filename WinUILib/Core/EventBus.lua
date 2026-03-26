--- WinUILib – Core/EventBus.lua
-- Lightweight publish/subscribe event bus for internal framework use.
-- Decouples modules without creating direct dependencies.
--
-- Usage:
--   WinUILib.EventBus:On("ThemeChanged", function(theme) … end)
--   WinUILib.EventBus:Emit("ThemeChanged", newTheme)
--   WinUILib.EventBus:Off("ThemeChanged", handler)
-------------------------------------------------------------------------------

local lib = WinUILib

local EventBus = {}
lib:RegisterModule("EventBus", EventBus)

local _listeners = {}  -- [event] = {fn, ...}

--- Subscribe to an event.
---@param event string
---@param fn    function
function EventBus:On(event, fn)
    if not _listeners[event] then _listeners[event] = {} end
    table.insert(_listeners[event], fn)
end

--- Unsubscribe a specific handler from an event.
---@param event string
---@param fn    function
function EventBus:Off(event, fn)
    local list = _listeners[event]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == fn then table.remove(list, i) end
    end
end

--- Subscribe to an event; automatically unsubscribes after first call.
---@param event string
---@param fn    function
function EventBus:Once(event, fn)
    local wrapper
    wrapper = function(...)
        self:Off(event, wrapper)
        fn(...)
    end
    self:On(event, wrapper)
end

--- Emit an event, invoking all registered handlers with given args.
---@param event string
---@param ...   any
function EventBus:Emit(event, ...)
    local list = _listeners[event]
    if not list then return end
    -- Iterate a snapshot to allow handlers to unsubscribe themselves safely.
    local snapshot = {table.unpack(list)}
    for _, fn in ipairs(snapshot) do
        lib.Utils.SafeCall(fn, ...)
    end
end

--- Remove all handlers for an event.
---@param event string
function EventBus:Clear(event)
    _listeners[event] = nil
end
