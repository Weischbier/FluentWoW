--- WinUILib – Controls/Slider/Slider.lua
-- Range slider with accent fill, thumb, and optional header/value labels.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/slider
-- States: Normal | Hover | Pressed | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILSlider
local SliderMixin = {}

function SliderMixin:OnStateChanged(newState, prevState)
    local state = newState

    if state == "Disabled" then
        self.SliderFrame.Track:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self.SliderFrame.Fill:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
        self.SliderFrame.Thumb:SetColorTexture(T:GetColor("Color.Icon.Disabled"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self.ValueLabel:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
        self.SliderFrame.Track:SetColorTexture(T:GetColor("Color.Border.Subtle"))
        self.HeaderLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
        self.ValueLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))

        local fillKey = (state == "Hover") and "Color.Accent.Hover" or "Color.Accent.Primary"
        self.SliderFrame.Fill:SetColorTexture(T:GetColor(fillKey))

        local thumbKey = (state == "Pressed") and "Color.Accent.Pressed" or "Color.Accent.Primary"
        self.SliderFrame.Thumb:SetColorTexture(T:GetColor(thumbKey))
    end
end

function SliderMixin:_UpdateFill()
    local slider = self.SliderFrame
    local min, max = slider:GetMinMaxValues()
    local val = slider:GetValue()
    local range = max - min
    if range <= 0 then return end
    local pct = (val - min) / range
    local width = slider:GetWidth() * pct
    slider.Fill:SetWidth(math.max(1, width))
end

---@param value number
function SliderMixin:SetValue(value)
    self.SliderFrame:SetValue(value)
end

---@return number
function SliderMixin:GetValue()
    return self.SliderFrame:GetValue()
end

---@param min number
---@param max number
function SliderMixin:SetRange(min, max)
    self.SliderFrame:SetMinMaxValues(min, max)
    self:_UpdateFill()
end

---@param step number
function SliderMixin:SetStep(step)
    self.SliderFrame:SetValueStep(step)
end

---@param text string
function SliderMixin:SetHeader(text)
    self.HeaderLabel:SetText(text)
end

---@param fn function
function SliderMixin:SetOnValueChanged(fn)
    self._onValueChanged = fn
end

---@param show boolean
function SliderMixin:SetShowValue(show)
    self._showValue = show
    if show then
        self.ValueLabel:Show()
    else
        self.ValueLabel:Hide()
    end
end

---@param formatter function
function SliderMixin:SetValueFormatter(formatter)
    self._valueFormatter = formatter
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILSlider_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, SliderMixin)
    self:WUILInit()
    self._showValue = true
    self:OnStateChanged("Normal")
end

function WUILSlider_OnValueChanged(self, value, userInput)
    local parent = self:GetParent()
    parent:_UpdateFill()
    if parent._showValue then
        if parent._valueFormatter then
            parent.ValueLabel:SetText(parent._valueFormatter(value))
        else
            parent.ValueLabel:SetText(tostring(math.floor(value + 0.5)))
        end
    end
    if parent._onValueChanged then
        lib.Utils.SafeCall(parent._onValueChanged, parent, value, userInput)
    end
end

function WUILSlider_OnEnter(self)
    local parent = self:GetParent()
    if not parent._enabled then return end
    parent._vsm:SetState("Hover")
    parent:ShowTooltip()
end

function WUILSlider_OnLeave(self)
    local parent = self:GetParent()
    if not parent._enabled then return end
    parent._vsm:SetState("Normal")
    GameTooltip:Hide()
end

function WUILSlider_OnMouseDown(self)
    local parent = self:GetParent()
    if not parent._enabled then return end
    parent._vsm:SetState("Pressed")
end

function WUILSlider_OnMouseUp(self)
    local parent = self:GetParent()
    if not parent._enabled then return end
    local isOver = self:IsMouseOver()
    parent._vsm:SetState(isOver and "Hover" or "Normal")
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return WUILSlider
function lib:CreateSlider(parent, name)
    local f = CreateFrame("Frame", name, parent, "WUILSliderTemplate")
    ---@cast f WUILSlider
    return f
end
