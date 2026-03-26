--- WinUILib – Controls/ProgressBar/ProgressBar.lua
-- Determinate + indeterminate progress bar, and progress ring spinner.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/progress-controls
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

-------------------------------------------------------------------------------
-- ProgressBar Mixin
-------------------------------------------------------------------------------

---@class WUILProgressBar
local BarMixin = {}

function BarMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self.Bar.Track:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self.Bar.Fill:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
        self.Bar.Track:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.Bar.Fill:SetColorTexture(T:GetColor("Color.Accent.Primary"))
    end
end

---@param value number 0-100
function BarMixin:SetValue(value)
    self._indeterminate = false
    self.Bar:SetValue(value)
    self:_StopIndeterminate()
end

---@return number
function BarMixin:GetValue()
    return self.Bar:GetValue()
end

---@param isIndeterminate boolean
function BarMixin:SetIndeterminate(isIndeterminate)
    self._indeterminate = isIndeterminate
    if isIndeterminate then
        self:_StartIndeterminate()
    else
        self:_StopIndeterminate()
    end
end

---@param text string
function BarMixin:SetHeader(text)
    self.HeaderLabel:SetText(text)
    self.HeaderLabel:Show()
end

function BarMixin:_StartIndeterminate()
    if self._indeterminateRunning then return end
    self._indeterminateRunning = true
    self._indeterminatePhase = 0
    self:SetScript("OnUpdate", function(_, elapsed)
        self._indeterminatePhase = (self._indeterminatePhase + elapsed * 1.5) % 2
        local pct = self._indeterminatePhase < 1
            and self._indeterminatePhase
            or (2 - self._indeterminatePhase)
        self.Bar:SetValue(pct * 100)
    end)
end

function BarMixin:_StopIndeterminate()
    if not self._indeterminateRunning then return end
    self._indeterminateRunning = false
    self:SetScript("OnUpdate", nil)
end

-------------------------------------------------------------------------------
-- ProgressRing Mixin
-------------------------------------------------------------------------------

---@class WUILProgressRing
local RingMixin = {}

function RingMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self.Ring:SetVertexColor(T:GetColor("Color.Icon.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
        self.Ring:SetVertexColor(T:GetColor("Color.Accent.Primary"))
    end
end

---@param active boolean
function RingMixin:SetActive(active)
    self._active = active
    if active then
        self:Show()
    else
        self:Hide()
    end
end

---@return boolean
function RingMixin:IsActive()
    return self._active == true
end

-------------------------------------------------------------------------------
-- Script handlers — ProgressBar
-------------------------------------------------------------------------------

function WUILProgressBar_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, BarMixin)
    self:WUILInit()
    self._indeterminate = false
    self._indeterminateRunning = false
    self.Bar:SetValue(0)
    self:OnStateChanged("Normal")
end

-------------------------------------------------------------------------------
-- Script handlers — ProgressRing
-------------------------------------------------------------------------------

function WUILProgressRing_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, RingMixin)
    self:WUILInit()
    self._active = true
    self._angle = 0
    self.Ring:SetColorTexture(1, 1, 1)
    self:OnStateChanged("Normal")
end

function WUILProgressRing_OnUpdate(self, elapsed)
    if not self._active then return end
    self._angle = (self._angle + elapsed * 360) % 360
    local ag = self.Ring:GetParent()
    if ag and ag.SetRotation then
        ag:SetRotation(math.rad(self._angle))
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return Frame
function lib:CreateProgressBar(parent, name)
    return CreateFrame("Frame", name, parent, "WUILProgressBarTemplate")
end

---@param parent Frame
---@param name? string
---@return Frame
function lib:CreateProgressRing(parent, name)
    return CreateFrame("Frame", name, parent, "WUILProgressRingTemplate")
end
