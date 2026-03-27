--- FluentWoW – Controls/ToggleSwitch/ToggleSwitch.lua
-- On/off toggle switch with sliding thumb animation.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/toggleswitch
-- States: Normal | Hover | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

local function thumbInset()
    return T:GetNumber("Spacing.XS") + 1
end

local function thumbTravel(self)
    return self.Track:GetWidth() - self.Thumb:GetWidth() - (thumbInset() * 2)
end

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class FWoWToggleSwitch
local ToggleSwitchMixin = {}

function ToggleSwitchMixin:OnStateChanged(newState, prevState)
    local state = newState
    local isOn = self._isOn

    if state == "Disabled" then
        self.Track.BG:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self.Thumb.Dot:SetColorTexture(T:GetColor("Color.Icon.Disabled"))
        self.Thumb.Shadow:SetColorTexture(T:GetColor("Color.Surface.Base"), 0.7)
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self.StateLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
        if isOn then
            local trackKey = (state == "Hover") and "Color.Accent.Hover" or "Color.Accent.Primary"
            self.Track.BG:SetColorTexture(T:GetColor(trackKey))
            self.Thumb.Dot:SetColorTexture(T:GetColor("Color.Icon.OnAccent"))
            self.StateLabel:SetTextColor(T:GetColor("Color.Accent.Primary"))
        else
            local trackKey = (state == "Hover") and "Color.Border.Focus" or "Color.Border.Default"
            self.Track.BG:SetColorTexture(T:GetColor(trackKey))
            self.Thumb.Dot:SetColorTexture(T:GetColor("Color.Icon.Default"))
            self.StateLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
        end
        self.Thumb.Shadow:SetColorTexture(T:GetColor("Color.Surface.Base"), 0.7)
    end

    self:_UpdateContentLabel()
    self:_UpdateThumbPosition(newState ~= prevState)
end

function ToggleSwitchMixin:_UpdateContentLabel()
    local labelText = self._isOn and self._onContent or self._offContent
    self.StateLabel:SetText(labelText or "")
end

function ToggleSwitchMixin:_ApplyThumbOffset(offset)
    self.Thumb:ClearAllPoints()
    self.Thumb:SetPoint("LEFT", self.Track, "LEFT", offset, 0)
    self._thumbOffset = offset
end

function ToggleSwitchMixin:_UpdateThumbPosition(animated)
    local targetOffset = thumbInset()
    if self._isOn then
        targetOffset = targetOffset + thumbTravel(self)
    end

    if not animated or Mot.reducedMotion then
        self:_ApplyThumbOffset(targetOffset)
        return
    end

    Mot:Stop(self.Thumb)
    local proxy = { offset = self._thumbOffset or targetOffset }
    local tween = Mot:Tween(proxy, T:GetNumber("Motion.Duration.Fast"), { offset = targetOffset })
        :ease("quadout")
        :onupdate(function()
            self:_ApplyThumbOffset(proxy.offset)
        end)
        :oncomplete(function()
            self:_ApplyThumbOffset(targetOffset)
        end)
    tween._owner = self.Thumb
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

---@param text string
function ToggleSwitchMixin:SetOnContent(text)
    self._onContent = text
    self:_UpdateContentLabel()
end

---@param text string
function ToggleSwitchMixin:SetOffContent(text)
    self._offContent = text
    self:_UpdateContentLabel()
end

---@param fn function
function ToggleSwitchMixin:SetOnToggled(fn)
    self._onToggled = fn
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWToggleSwitch_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ToggleSwitchMixin)
    self:FWoWInit()
    self._isOn = false
    self._onContent = "On"
    self._offContent = "Off"
    self._thumbOffset = thumbInset()
    self:OnStateChanged("Normal")
end

function FWoWToggleSwitch_OnClick(self)
    if not self._enabled then return end
    self._isOn = not self._isOn
    self:OnStateChanged(self._vsm:GetState())
    if self._onToggled then
        lib.Utils.SafeCall(self._onToggled, self, self._isOn)
    end
end

function FWoWToggleSwitch_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    self:ShowTooltip()
end

function FWoWToggleSwitch_OnLeave(self)
    if not self._enabled then return end
    self._vsm:SetState("Normal")
    GameTooltip:Hide()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWToggleSwitch
function lib:CreateToggleSwitch(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWToggleSwitchTemplate")
    ---@cast f FWoWToggleSwitch
    return f
end
