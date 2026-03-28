--- FluentWoW – Core/FramePool.lua
-- Frame recycling pool to avoid repeated CreateFrame allocations.
-------------------------------------------------------------------------------

local lib = FluentWoW

local FramePool = {}
lib:RegisterModule("FramePool", FramePool)

---@param frameType string
---@param parent Frame
---@param template? string
---@param resetFn? function
---@return table
function FramePool:New(frameType, parent, template, resetFn)
    local pool = {
        _frameType    = frameType,
        _parent       = parent,
        _template     = template,
        _resetFn      = resetFn,
        _free         = {},
        _active       = {},
        _activeCount  = 0,
        _counter      = 0,
    }
    setmetatable(pool, { __index = FramePool })
    return pool
end

---@return Frame
function FramePool:Acquire()
    local frame = table.remove(self._free)
    if not frame then
        self._counter = self._counter + 1
        frame = CreateFrame(self._frameType, nil, self._parent, self._template)
    end
    self._active[frame] = true
    self._activeCount = self._activeCount + 1
    frame:Show()
    return frame
end

---@param frame Frame
function FramePool:Release(frame)
    if not self._active[frame] then return end
    self._active[frame] = nil
    self._activeCount = self._activeCount - 1
    frame:Hide()
    frame:ClearAllPoints()
    if self._resetFn then
        lib.Utils.SafeCall(self._resetFn, frame)
    end
    table.insert(self._free, frame)
end

function FramePool:ReleaseAll()
    local frames = {}
    for frame in pairs(self._active) do frames[#frames + 1] = frame end
    for _, frame in ipairs(frames) do
        self:Release(frame)
    end
end

---@return integer
function FramePool:ActiveCount()
    return self._activeCount or 0
end
