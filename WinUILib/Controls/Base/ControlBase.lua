--- WinUILib – Controls/Base/ControlBase.lua
-- Base mixin applied to all WinUILib controls.
-- Provides: state machine, token access, tooltip, enable/disable, lifecycle.
-------------------------------------------------------------------------------

local lib = WinUILib

---@class WUILControlBase
local ControlBase = {}
lib._controls.ControlBase = ControlBase

---@param opts? table
function ControlBase:WUILInit(opts)
    self._wuil        = true
    self._opts        = opts or {}
    self._enabled     = true
    self._vsm         = lib.StateMachine:New(self)
    self._tooltipText = nil
    self._tooltipTitle = nil
end

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

---@param title string
---@param text? string
function ControlBase:SetTooltip(title, text)
    self._tooltipTitle = title
    self._tooltipText  = text
end

---@param key string
---@return any
function ControlBase:Token(key)
    return lib.Tokens:Get(key)
end

---@return string
function ControlBase:GetState()
    return self._vsm:GetState()
end

---@param newState string
---@param prevState string
function ControlBase:OnStateChanged(newState, prevState)
end

---@param flag string
---@param value boolean
function ControlBase:OnFlagChanged(flag, value)
end

--- Shows the standard tooltip for this control.
function ControlBase:ShowTooltip()
    if not self._tooltipTitle then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local r, g, b = lib.Tokens:GetColor("Color.Text.Primary")
    GameTooltip:SetText(self._tooltipTitle, r, g, b, true)
    if self._tooltipText then
        GameTooltip:AddLine(self._tooltipText, nil, nil, nil, true)
    end
    GameTooltip:Show()
end
