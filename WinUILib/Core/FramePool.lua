--- WinUILib – Core/FramePool.lua
-- Frame recycling pool – avoids allocating new Frame objects on every show/hide
-- cycle (e.g. ComboBox items, list rows, toast notifications).
--
-- Usage:
--   local pool = WinUILib.FramePool:New("Button", parent, "WUILButtonTemplate")
--   local btn  = pool:Acquire()
--   -- … use btn …
--   pool:Release(btn)
-------------------------------------------------------------------------------

local lib = WinUILib

local FramePool = {}
lib:RegisterModule("FramePool", FramePool)

--- Creates a new pool.
---@param frameType   string  WoW frame type ("Frame", "Button", etc.)
---@param parent      Frame   Default parent for created frames.
---@param template    string? XML template name (optional).
---@param resetFn     function? Called with (frame) when a frame is released.
---@return table pool
function FramePool:New(frameType, parent, template, resetFn)
    local pool = {
        _frameType = frameType,
        _parent    = parent,
        _template  = template,
        _resetFn   = resetFn,
        _free      = {},
        _active    = {},
        _counter   = 0,
    }
    setmetatable(pool, { __index = FramePool })
    return pool
end

--- Acquires a frame from the pool, creating one if necessary.
---@return Frame
function FramePool:Acquire()
    local frame = table.remove(self._free)
    if not frame then
        self._counter = self._counter + 1
        local name = nil  -- anonymous frame; named pools can suffix counter
        frame = CreateFrame(self._frameType, name, self._parent, self._template)
    end
    self._active[frame] = true
    frame:Show()
    return frame
end

--- Returns a frame to the pool.
---@param frame Frame
function FramePool:Release(frame)
    if not self._active[frame] then return end
    self._active[frame] = nil
    frame:Hide()
    if self._resetFn then
        lib.Utils.SafeCall(self._resetFn, frame)
    end
    table.insert(self._free, frame)
end

--- Releases all currently active frames.
function FramePool:ReleaseAll()
    for frame in pairs(self._active) do
        self:Release(frame)
    end
end

--- Returns the number of active (in-use) frames.
---@return integer
function FramePool:ActiveCount()
    local n = 0
    for _ in pairs(self._active) do n = n + 1 end
    return n
end
