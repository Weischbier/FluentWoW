--- FluentWoW – Controls/Base/ControlBase.lua
-- Base mixin applied to all FluentWoW controls.
-- Provides: state machine, token access, tooltip, enable/disable, lifecycle.
-------------------------------------------------------------------------------

local lib = FluentWoW

---@class FWoWControlBase
local ControlBase = {}
lib._controls.ControlBase = ControlBase

---@param opts? table
function ControlBase:FWoWInit(opts)
    self._FWoW        = true
    self._opts        = opts or {}
    self._enabled     = true
    self._vsm         = lib.StateMachine:New(self)
    self._tooltipText = nil
    self._tooltipTitle = nil

    self._themeListener = function()
        if self.OnStateChanged then
            lib.Utils.SafeCall(self.OnStateChanged, self, self._vsm:GetState(), self._vsm:GetState())
        end
    end
    lib.EventBus:On("ThemeChanged", self._themeListener)
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
        local tr, tg, tb = lib.Tokens:GetColor("Color.Text.Secondary")
        GameTooltip:AddLine(self._tooltipText, tr, tg, tb, true)
    end
    GameTooltip:Show()
end
