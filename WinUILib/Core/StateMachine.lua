--- WinUILib – Core/StateMachine.lua
-- Visual-state-machine (VSM) for controls.
-- States: Normal | Hover | Pressed | Disabled | Focused |
--         Selected | Checked | Expanded | Error | Warning
-------------------------------------------------------------------------------

local lib = WinUILib

local StateMachine = {}
lib:RegisterModule("StateMachine", StateMachine)

StateMachine.States = {
    Normal   = "Normal",
    Hover    = "Hover",
    Pressed  = "Pressed",
    Disabled = "Disabled",
    Focused  = "Focused",
    Selected = "Selected",
    Checked  = "Checked",
    Expanded = "Expanded",
    Error    = "Error",
    Warning  = "Warning",
}

---@param control table
---@param initial? string
---@return table
function StateMachine:New(control, initial)
    local machine = {
        _control  = control,
        _state    = initial or "Normal",
        _flags    = {},
        _handlers = {},
    }
    setmetatable(machine, { __index = StateMachine })
    return machine
end

---@return string
function StateMachine:GetState()
    return self._state
end

---@param newState string
function StateMachine:SetState(newState)
    if self._state == newState then return end
    local prev = self._state
    self._state = newState
    self:_Dispatch(newState, prev)
    if self._control and self._control.OnStateChanged then
        lib.Utils.SafeCall(self._control.OnStateChanged, self._control, newState, prev)
    end
end

---@param flag string
---@param value boolean
function StateMachine:SetFlag(flag, value)
    if self._flags[flag] == value then return end
    self._flags[flag] = value
    if flag == "Disabled" then
        if value then
            self._preDisableState = self._state
            self:SetState("Disabled")
        else
            self:SetState(self._preDisableState or "Normal")
            self._preDisableState = nil
        end
    end
    if self._control and self._control.OnFlagChanged then
        lib.Utils.SafeCall(self._control.OnFlagChanged, self._control, flag, value)
    end
end

---@param flag string
---@return boolean
function StateMachine:GetFlag(flag)
    return self._flags[flag] == true
end

---@param state string
---@param fn function
function StateMachine:OnState(state, fn)
    if not self._handlers[state] then self._handlers[state] = {} end
    table.insert(self._handlers[state], fn)
end

function StateMachine:_Dispatch(state, prev)
    local list = self._handlers[state]
    if not list then return end
    for _, fn in ipairs(list) do
        lib.Utils.SafeCall(fn, self._control, state, prev)
    end
end
