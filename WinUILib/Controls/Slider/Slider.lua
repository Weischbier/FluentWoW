--- FluentWoW – Controls/Slider/Slider.lua
-- Range slider with accent fill, thumb, and optional header/value labels.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/slider
-- States: Normal | Hover | Pressed | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILSlider
local SliderMixin = {}

local function headerHeight(self)
    return self.HeaderLabel:IsShown() and (T:GetNumber("Spacing.XL") + T:GetNumber("Spacing.SM")) or 0
end

local function trackInset()
    return T:GetNumber("Spacing.MD")
end

local function updateSliderLayout(self)
    local slider = self.SliderFrame
    local topInset = headerHeight(self)

    slider:ClearAllPoints()
    slider.Track:ClearAllPoints()
    self.TickContainer:ClearAllPoints()

    if self._orientation == "VERTICAL" then
        slider:SetOrientation("VERTICAL")
        slider:SetPoint("TOP", self, "TOP", 0, -topInset)
        slider:SetPoint("BOTTOM", self, "BOTTOM", 0, T:GetNumber("Spacing.LG"))
        slider:SetWidth(T:GetNumber("Spacing.XXL"))
        slider.Track:SetWidth(4)
        slider.Track:SetPoint("TOP", slider, "TOP", 0, -trackInset())
        slider.Track:SetPoint("BOTTOM", slider, "BOTTOM", 0, trackInset())
        self.TickContainer:SetPoint("TOPLEFT", slider.Track, "TOPRIGHT", T:GetNumber("Spacing.MD"), 0)
        self.TickContainer:SetPoint("BOTTOMLEFT", slider.Track, "BOTTOMRIGHT", T:GetNumber("Spacing.MD"), 0)
        self.TickContainer:SetWidth(T:GetNumber("Spacing.LG"))
    else
        slider:SetOrientation("HORIZONTAL")
        slider:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
        slider:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
        slider:SetHeight(T:GetNumber("Spacing.XXL"))
        slider.Track:SetHeight(4)
        slider.Track:SetPoint("LEFT", slider, "LEFT", 0, 0)
        slider.Track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
        self.TickContainer:SetPoint("TOPLEFT", slider.Track, "BOTTOMLEFT", 0, -T:GetNumber("Spacing.XS"))
        self.TickContainer:SetPoint("TOPRIGHT", slider.Track, "BOTTOMRIGHT", 0, -T:GetNumber("Spacing.XS"))
        self.TickContainer:SetHeight(T:GetNumber("Spacing.LG"))
    end
end

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
    if self._orientation == "VERTICAL" then
        local height = math.max(1, slider.Track:GetHeight() * pct)
        slider.Fill:ClearAllPoints()
        slider.Fill:SetPoint("BOTTOM", slider.Track, "BOTTOM", 0, 0)
        slider.Fill:SetPoint("LEFT", slider.Track, "LEFT", 0, 0)
        slider.Fill:SetPoint("RIGHT", slider.Track, "RIGHT", 0, 0)
        slider.Fill:SetHeight(height)
    else
        local width = slider.Track:GetWidth() * pct
        slider.Fill:ClearAllPoints()
        slider.Fill:SetPoint("LEFT", slider.Track, "LEFT", 0, 0)
        slider.Fill:SetPoint("TOP", slider.Track, "TOP", 0, 0)
        slider.Fill:SetPoint("BOTTOM", slider.Track, "BOTTOM", 0, 0)
        slider.Fill:SetWidth(math.max(1, width))
    end
    self:_RefreshTicks()
end

function SliderMixin:_RefreshTicks()
    if not self._tickPool then
        self._tickPool = lib.FramePool:New("Frame", self.TickContainer, "WUILSliderTickTemplate")
    end
    self._tickPool:ReleaseAll()

    local min, max = self.SliderFrame:GetMinMaxValues()
    local tickFrequency = self._tickFrequency
    if not tickFrequency or tickFrequency <= 0 or max <= min then
        self.TickContainer:Hide()
        return
    end
    self.TickContainer:Show()

    local track = self.SliderFrame.Track
    local span = self._orientation == "VERTICAL" and track:GetHeight() or track:GetWidth()
    if span <= 0 then return end

    local value = min + tickFrequency
    while value < max do
        local tick = self._tickPool:Acquire()
        tick:SetParent(self.TickContainer)
        tick:ClearAllPoints()
        tick.Line:SetColorTexture(T:GetColor("Color.Border.Default"))

        local pct = (value - min) / (max - min)
        if self._orientation == "VERTICAL" then
            tick:SetSize(T:GetNumber("Spacing.LG"), 1)
            tick:SetPoint("BOTTOMLEFT", self.TickContainer, "BOTTOMLEFT", 0, span * pct)
        else
            tick:SetSize(1, T:GetNumber("Spacing.LG"))
            tick:SetPoint("TOPLEFT", self.TickContainer, "TOPLEFT", span * pct, 0)
        end
        value = value + tickFrequency
    end
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

---@param orientation string
function SliderMixin:SetOrientation(orientation)
    self._orientation = orientation == "VERTICAL" and "VERTICAL" or "HORIZONTAL"
    updateSliderLayout(self)
    self:_UpdateFill()
end

---@param tickFrequency number|nil
function SliderMixin:SetTickFrequency(tickFrequency)
    self._tickFrequency = tickFrequency
    self:_RefreshTicks()
end

---@param enabled boolean
function SliderMixin:SetSnapToTicks(enabled)
    self._snapToTicks = enabled == true
    if self._snapToTicks and self._tickFrequency and self._tickFrequency > 0 then
        self.SliderFrame:SetValueStep(self._tickFrequency)
    end
end

---@param text string
function SliderMixin:SetHeader(text)
    self.HeaderLabel:SetText(text)
    self.HeaderLabel:SetShown(text ~= nil and text ~= "")
    updateSliderLayout(self)
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
    self._orientation = "HORIZONTAL"
    self._tickFrequency = nil
    self._snapToTicks = false
    self.HeaderLabel:Hide()
    updateSliderLayout(self)
    self:OnStateChanged("Normal")
end

function WUILSlider_OnValueChanged(self, value, userInput)
    local parent = self:GetParent()
    if userInput and parent._snapToTicks and parent._tickFrequency and parent._tickFrequency > 0 then
        local min = select(1, self:GetMinMaxValues())
        local tick = parent._tickFrequency
        local snapped = math.floor(((value - min) / tick) + 0.5) * tick + min
        if math.abs(snapped - value) > 0.001 then
            self:SetValue(snapped)
            return
        end
        value = snapped
    end
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
