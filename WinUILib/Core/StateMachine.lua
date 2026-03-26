--- WinUILib – Core/StateMachine.lua
-- Minimal visual-state-machine (VSM) equivalent for WoW controls.
-- Each control owns a StateMachine that tracks its logical state and
-- dispatches state-change callbacks so visuals update deterministically.
--
-- States used by the framework:
--   "Normal" | "Hover" | "Pressed" | "Disabled" | "Focused" |
--   "Selected" | "Checked" | "Expanded" | "Error" | "Warning"
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

--- Creates a new state-machine instance bound to a control frame.
---@param control table  The control mixin table (must have :OnStateChanged hook).
---@param initial string  Initial state, default "Normal".
---@return table machine
function StateMachine:New(control, initial)
    local machine = {
        _control  = control,
        _state    = initial or "Normal",
        _flags    = {},   -- additional boolean flags (Checked, Disabled, …)
        _handlers = {},   -- [state] = {fn, ...}
    }
    setmetatable(machine, { __index = StateMachine })
    return machine
end

--- Returns the current primary state string.
---@return string
function StateMachine:GetState()
    return self._state
end

--- Transitions to a new primary state and fires handlers.
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

--- Sets / clears a boolean flag (Checked, Disabled, etc.) without replacing
--- the primary hover/press state.  Fires OnStateChanged with the flag name.
---@param flag  string
---@param value boolean
function StateMachine:SetFlag(flag, value)
    if self._flags[flag] == value then return end
    self._flags[flag] = value
    -- Also transition primary state for Disabled since it overrides everything.
    if flag == "Disabled" then
        if value then
            self:SetState("Disabled")
        else
            self:SetState("Normal")
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

--- Registers a handler for a specific state transition.
---@param state string
---@param fn    function  Receives (control, newState, prevState)
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
