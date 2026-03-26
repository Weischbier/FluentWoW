--- WinUILib – Controls/ToggleSwitch/ToggleSwitch.lua
-- On/off toggle switch with sliding thumb animation.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/toggleswitch
-- States: Normal | Hover | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILToggleSwitch
local ToggleSwitchMixin = {}

function ToggleSwitchMixin:OnStateChanged(newState, prevState)
    local state = newState
    local isOn = self._isOn

    if state == "Disabled" then
        self.Track.BG:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self.Thumb.Dot:SetColorTexture(T:GetColor("Color.Icon.Disabled"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
        if isOn then
            local trackKey = (state == "Hover") and "Color.Accent.Hover" or "Color.Accent.Primary"
            self.Track.BG:SetColorTexture(T:GetColor(trackKey))
            self.Thumb.Dot:SetColorTexture(T:GetColor("Color.Icon.OnAccent"))
        else
            local trackKey = (state == "Hover") and "Color.Border.Focus" or "Color.Border.Default"
            self.Track.BG:SetColorTexture(T:GetColor(trackKey))
            self.Thumb.Dot:SetColorTexture(T:GetColor("Color.Icon.Default"))
        end
    end

    self:_UpdateThumbPosition()
end

function ToggleSwitchMixin:_UpdateThumbPosition()
    local inset = T:GetNumber("Spacing.XS") + 1  -- 3px thumb inset
    self.Thumb:ClearAllPoints()
    if self._isOn then
        self.Thumb:SetPoint("RIGHT", self.Track, "RIGHT", -inset, 0)
    else
        self.Thumb:SetPoint("LEFT", self.Track, "LEFT", inset, 0)
    end
end

---@param isOn boolean
function ToggleSwitchMixin:SetIsOn(isOn)
    self._isOn = isOn
    self:OnStateChanged(self._vsm:GetState())
end

---@return boolean
function ToggleSwitchMixin:IsOn()
    return self._isOn == true
end

---@param text string
function ToggleSwitchMixin:SetHeader(text)
    self.HeaderLabel:SetText(text)
end

---@param fn function
function ToggleSwitchMixin:SetOnToggled(fn)
    self._onToggled = fn
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILToggleSwitch_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ToggleSwitchMixin)
    self:WUILInit()
    self._isOn = false
    self:OnStateChanged("Normal")
end

function WUILToggleSwitch_OnClick(self)
    if not self._enabled then return end
    self._isOn = not self._isOn
    self:OnStateChanged(self._vsm:GetState())
    if self._onToggled then
        lib.Utils.SafeCall(self._onToggled, self, self._isOn)
    end
end

function WUILToggleSwitch_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    self:ShowTooltip()
end

function WUILToggleSwitch_OnLeave(self)
    if not self._enabled then return end
    self._vsm:SetState("Normal")
    GameTooltip:Hide()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return Frame
function lib:CreateToggleSwitch(parent, name)
    return CreateFrame("Frame", name, parent, "WUILToggleSwitchTemplate")
end
