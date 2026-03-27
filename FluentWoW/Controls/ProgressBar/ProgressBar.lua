--- FluentWoW – Controls/ProgressBar/ProgressBar.lua
-- Determinate + indeterminate progress bar, and progress ring spinner.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/progress-controls
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens

-------------------------------------------------------------------------------
-- ProgressBar Mixin
-------------------------------------------------------------------------------

---@class FWoWProgressBar
local BarMixin = {}

local function currentBarColorKey(self)
    if self._visualState == "Error" then
        return "Color.Feedback.Error"
    end
    if self._visualState == "Paused" then
        return "Color.Feedback.Warning"
    end
    return "Color.Accent.Primary"
end

function BarMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self.Bar.Track:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self.Bar.Fill:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
        self:_StopIndeterminate()
    else
        self:SetAlpha(1)
        self.Bar.Track:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.Bar.Fill:SetColorTexture(T:GetColor(currentBarColorKey(self)))
        if self._indeterminate then
            self:_StartIndeterminate()
        end
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

---@param visualState string
function BarMixin:SetVisualState(visualState)
    self._visualState = visualState or "Running"
    self:OnStateChanged(self._vsm:GetState())
end

---@param paused boolean
function BarMixin:SetPaused(paused)
    if paused then
        self:SetVisualState("Paused")
    elseif self._visualState == "Paused" then
        self:SetVisualState("Running")
    end
end

---@param hasError boolean
function BarMixin:SetError(hasError)
    if hasError then
        self:SetVisualState("Error")
    elseif self._visualState == "Error" then
        self:SetVisualState("Running")
    end
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

---@class FWoWProgressRing
local RingMixin = {}

function RingMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self.Ring:SetVertexColor(T:GetColor("Color.Icon.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
        self:SetScript("OnUpdate", nil)
    else
        self:SetAlpha(1)
        self.Ring:SetVertexColor(T:GetColor("Color.Accent.Primary"))
        if self._active then
            self:SetScript("OnUpdate", FWoWProgressRing_OnUpdate)
        end
    end
end

---@param active boolean
function RingMixin:SetActive(active)
    self._active = active
    if active then
        self:SetScript("OnUpdate", FWoWProgressRing_OnUpdate)
        self:Show()
    else
        self:SetScript("OnUpdate", nil)
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

function FWoWProgressBar_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, BarMixin)
    self:FWoWInit()
    self._indeterminate = false
    self._indeterminateRunning = false
    self._visualState = "Running"
    self.Bar:SetValue(0)
    self:OnStateChanged("Normal")
end

-------------------------------------------------------------------------------
-- Script handlers — ProgressRing
-------------------------------------------------------------------------------

function FWoWProgressRing_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, RingMixin)
    self:FWoWInit()
    self._active = true
    self._angle = 0
    self.Ring:SetColorTexture(T:GetColor("Color.Base.White"))
    self:OnStateChanged("Normal")
    self:SetScript("OnUpdate", FWoWProgressRing_OnUpdate)
end

function FWoWProgressRing_OnUpdate(self, elapsed)
    if not self._active then return end
    self._angle = (self._angle + elapsed * 360) % 360
    self.Ring:SetRotation(math.rad(self._angle))
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWProgressBar
function lib:CreateProgressBar(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWProgressBarTemplate")
    ---@cast f FWoWProgressBar
    return f
end

---@param parent Frame
---@param name? string
---@return FWoWProgressRing
function lib:CreateProgressRing(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWProgressRingTemplate")
    ---@cast f FWoWProgressRing
    return f
end
