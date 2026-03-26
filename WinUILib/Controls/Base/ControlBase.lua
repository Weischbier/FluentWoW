--- WinUILib – Controls/Base/ControlBase.lua
-- Base mixin applied to all WinUILib controls via Mixin(frame, ControlBase).
-- Provides: state machine, token access, event helpers, and lifecycle hooks.
-------------------------------------------------------------------------------

local lib = WinUILib

---@class WUILControlBase
local ControlBase = {}
lib._controls.ControlBase = ControlBase

--- Called once after a control frame is created and initialised.
--- Subclasses should call this in their OnLoad XML script or constructor.
---@param opts table?  Optional configuration table.
function ControlBase:WUILInit(opts)
    self._wuil          = true
    self._opts          = opts or {}
    self._enabled       = true
    self._vsm           = lib.StateMachine:New(self)
    self._tooltipText   = nil
    self._tooltipTitle  = nil

    -- Wire standard WoW scripts if this is a Frame/Button.
    self:_WireScripts()

    -- Let sub-controls finish initialisation.
    if self.OnWUILInit then
        lib.Utils.SafeCall(self.OnWUILInit, self, opts)
    end
end

--- Enables or disables the control.
---@param enabled boolean
function ControlBase:SetEnabled(enabled)
    self._enabled = enabled
    self._vsm:SetFlag("Disabled", not enabled)
    if self.EnableMouse then
        self:EnableMouse(enabled)
    end
end

---@return boolean
function ControlBase:IsEnabled()
    return self._enabled
end

--- Sets tooltip text shown on hover.
---@param title string
---@param text  string?
function ControlBase:SetTooltip(title, text)
    self._tooltipTitle = title
    self._tooltipText  = text
end

--- Retrieves the active design token value.
---@param key string  e.g. "Color.Accent.Primary"
---@return any
function ControlBase:Token(key)
    return lib.Tokens:Get(key)
end

--- Returns current VSM state.
---@return string
function ControlBase:GetState()
    return self._vsm:GetState()
end

--- Fires when the VSM state changes.  Override in sub-controls.
---@param newState string
---@param prevState string
function ControlBase:OnStateChanged(newState, prevState)
    -- default: no-op; subcontrols override
end

--- Fires when a boolean flag changes.
---@param flag  string
---@param value boolean
function ControlBase:OnFlagChanged(flag, value)
    -- default: no-op
end

-------------------------------------------------------------------------------
-- Internal helpers
-------------------------------------------------------------------------------

--- Wires WoW frame scripts for hover / press / focus / tooltip.
function ControlBase:_WireScripts()
    if not self.SetScript then return end

    -- Hover
    self:HookScript("OnEnter", function(self)
        if self._enabled and self._vsm:GetState() ~= "Pressed" then
            self._vsm:SetState("Hover")
        end
        if self._tooltipTitle then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self._tooltipTitle, 1, 1, 1, 1, true)
            if self._tooltipText then
                GameTooltip:AddLine(self._tooltipText, nil, nil, nil, true)
            end
            GameTooltip:Show()
        end
    end)

    self:HookScript("OnLeave", function(self)
        if self._enabled then
            self._vsm:SetState("Normal")
        end
        GameTooltip:Hide()
    end)

    -- Press (only relevant for Button subclass; harmless for plain Frames)
    if self.RegisterForClicks then
        self:HookScript("OnMouseDown", function(self, btn)
            if btn == "LeftButton" and self._enabled then
                self._vsm:SetState("Pressed")
            end
        end)
        self:HookScript("OnMouseUp", function(self, btn)
            if btn == "LeftButton" and self._enabled then
                self._vsm:SetState(MouseIsOver(self) and "Hover" or "Normal")
            end
        end)
    end
end
