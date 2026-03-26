--- WinUILib – Controls/Slider/Slider.lua
-- Horizontal slider with min/max/step and accent fill track.
-- Design ref: WinUI Slider
--
-- Public API:
--   :SetRange(min, max)
--   :SetValue(v)        :GetValue()
--   :SetStep(step)
--   :SetShowValueLabel(bool)
--   :SetEnabled(bool)
--   OnValueChanged(self, value)
--
-- Combat note: value changes during combat are allowed (no taint risk)
-- because we only manipulate texture sizes/positions on non-secure frames.
-------------------------------------------------------------------------------

local lib = WinUILib

local THUMB_HOVER_SIZE = 18
local THUMB_NORM_SIZE  = 16
local TRACK_PADDING    = 8   -- px left/right of track

local TRACK_BG_COL  = { 0.28, 0.28, 0.32, 1 }
local TRACK_FG_COL  = { 0.05, 0.55, 0.88, 1 }
local THUMB_COL     = { 1.00, 1.00, 1.00, 1 }
local THUMB_HOV_COL = { 0.40, 0.78, 1.00, 1 }

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILSlider_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.Slider)
    self:WUILInit()
    self._min     = 0
    self._max     = 100
    self._value   = 0
    self._step    = 1
    self._dragging = false
    self:SetScript("OnUpdate", nil)  -- ensure clean state
    self:_UpdateThumb()
end

function WUILSlider_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
    local thumb = _G[self:GetName() .. "_Thumb"]
    if thumb then
        thumb:SetSize(THUMB_HOVER_SIZE, THUMB_HOVER_SIZE)
        thumb:SetColorTexture(table.unpack(THUMB_HOV_COL))
    end
end

function WUILSlider_OnLeave(self)
    if not self._enabled or self._dragging then return end
    self._vsm:SetState("Normal")
    local thumb = _G[self:GetName() .. "_Thumb"]
    if thumb then
        thumb:SetSize(THUMB_NORM_SIZE, THUMB_NORM_SIZE)
        thumb:SetColorTexture(table.unpack(THUMB_COL))
    end
end

function WUILSlider_OnMouseDown(self, btn)
    if btn ~= "LeftButton" or not self._enabled then return end
    self._dragging = true
    self._vsm:SetState("Pressed")
    self:SetScript("OnUpdate", WUILSlider_OnUpdate)
    self:GetScript("OnUpdate")(self)  -- immediate snap
end

function WUILSlider_OnMouseUp(self, btn)
    if btn ~= "LeftButton" then return end
    self._dragging = false
    self:SetScript("OnUpdate", nil)
    self._vsm:SetState(MouseIsOver(self) and "Hover" or "Normal")
    local thumb = _G[self:GetName() .. "_Thumb"]
    if thumb then
        local isHover = MouseIsOver(self)
        thumb:SetSize(isHover and THUMB_HOVER_SIZE or THUMB_NORM_SIZE,
                      isHover and THUMB_HOVER_SIZE or THUMB_NORM_SIZE)
        thumb:SetColorTexture(table.unpack(isHover and THUMB_HOV_COL or THUMB_COL))
    end
end

function WUILSlider_OnUpdate(self)
    -- Compute value from mouse cursor X within track bounds
    local cursorX = select(1, GetCursorPosition()) / UIParent:GetEffectiveScale()
    local left    = self:GetLeft()  + TRACK_PADDING
    local right   = self:GetRight() - TRACK_PADDING
    if not left then return end
    local frac  = math.max(0, math.min(1, (cursorX - left) / (right - left)))
    local raw   = self._min + frac * (self._max - self._min)
    -- Snap to step
    local snapped = self._min + math.floor((raw - self._min) / self._step + 0.5) * self._step
    snapped = math.max(self._min, math.min(self._max, snapped))
    if snapped ~= self._value then
        self._value = snapped
        self:_UpdateThumb()
        if self.OnValueChanged then
            lib.Utils.SafeCall(self.OnValueChanged, self, snapped)
        end
    end
end

function WUILSlider_OnSizeChanged(self)
    self:_UpdateThumb()
end

-------------------------------------------------------------------------------
-- Slider mixin
-------------------------------------------------------------------------------

---@class WUILSlider : WUILControlBase
local Slider = {}
lib._controls.Slider = Slider

---@param min number  @param max number
function Slider:SetRange(min, max)
    self._min = min
    self._max = max
    self._value = math.max(min, math.min(max, self._value))
    self:_UpdateThumb()
end

---@param v number
function Slider:SetValue(v)
    v = math.max(self._min, math.min(self._max, v))
    self._value = v
    self:_UpdateThumb()
end

---@return number
function Slider:GetValue()
    return self._value
end

---@param step number
function Slider:SetStep(step)
    self._step = math.max(0.001, step)
end

---@param show boolean
function Slider:SetShowValueLabel(show)
    local label = _G[self:GetName() .. "_ValueLabel"]
    if label then label:SetShown(show) end
end

--- Repositions the thumb and resizes the fill track.
function Slider:_UpdateThumb()
    local thumb = _G[self:GetName() .. "_Thumb"]
    local fill  = _G[self:GetName() .. "_TrackFill"]
    local label = _G[self:GetName() .. "_ValueLabel"]
    if not (thumb and fill) then return end

    local trackW = self:GetWidth() - TRACK_PADDING * 2
    if trackW <= 0 then return end

    local range = self._max - self._min
    local frac  = range > 0 and (self._value - self._min) / range or 0
    local thumbX = TRACK_PADDING + frac * trackW - (THUMB_NORM_SIZE / 2)

    thumb:ClearAllPoints()
    thumb:SetPoint("LEFT", self, "LEFT", thumbX, 0)

    fill:SetWidth(math.max(0, frac * trackW))

    if label and label:IsShown() then
        label:SetText(tostring(self._value))
    end
end

function Slider:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self:SetAlpha(lib.Tokens:GetNumber("Opacity.Disabled"))
        self:EnableMouse(false)
    elseif prevState == "Disabled" then
        self:SetAlpha(1)
        self:EnableMouse(true)
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param min    number?
---@param max    number?
---@param value  number?
---@return Frame
function lib:CreateSlider(parent, min, max, value)
    local sl = CreateFrame("Frame", nil, parent, "WUILSliderTemplate")
    sl:SetRange(min or 0, max or 100)
    if value then sl:SetValue(value) end
    return sl
end
