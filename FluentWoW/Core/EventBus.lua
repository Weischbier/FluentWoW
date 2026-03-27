--- FluentWoW – Core/EventBus.lua
-- Lightweight publish/subscribe event bus for internal framework use.
-------------------------------------------------------------------------------

local lib = FluentWoW

local EventBus = {}
lib:RegisterModule("EventBus", EventBus)

local _listeners = {}

---@param event string
---@param fn function
function EventBus:On(event, fn)
    if not _listeners[event] then _listeners[event] = {} end
    table.insert(_listeners[event], fn)
end

---@param event string
---@param fn function
function EventBus:Off(event, fn)
    local list = _listeners[event]
    if not list then return end
    for i = #list, 1, -1 do
        if list[i] == fn then table.remove(list, i) end
    end
end

---@param event string
---@param fn function
function EventBus:Once(event, fn)
    local wrapper
    wrapper = function(...)
        self:Off(event, wrapper)
        fn(...)
    end
    self:On(event, wrapper)
end

---@param event string
---@param ... any
function EventBus:Emit(event, ...)
    local list = _listeners[event]
    if not list then return end
    local snapshot = { unpack(list) }
    for _, fn in ipairs(snapshot) do
        lib.Utils.SafeCall(fn, ...)
    end
end

---@param event string
function EventBus:Clear(event)
    _listeners[event] = nil
end
