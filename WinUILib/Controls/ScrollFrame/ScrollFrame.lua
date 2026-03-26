--- WinUILib – Controls/ScrollFrame/ScrollFrame.lua
-- Styled scroll container with an auto-hiding scrollbar.
-- Design ref: WinUI ScrollViewer
--
-- Public API:
--   :GetScrollChild()      → Frame (place content inside)
--   :SetScrollStep(n)
--   :ScrollToTop()
--   :ScrollToBottom()
--   :ScrollBy(delta)       positive = down, negative = up
-------------------------------------------------------------------------------

local lib = WinUILib

local SCROLL_STEP   = 20
local THUMB_MIN_H   = 20
local THUMB_FADE_IN  = 0.15
local THUMB_FADE_OUT = 0.80  -- seconds of inactivity before fade

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILScrollFrame_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.ScrollFrame)
    self:WUILInit()
    self._scrollStep    = SCROLL_STEP
    self._thumbVisible  = false
    self._fadeTimer     = 0

    -- Mouse-wheel
    local sf = _G[self:GetName() .. "_Scroll"]
    if sf then sf:EnableMouseWheel(true) end

    -- Auto-hide: make scrollbar visible on hover
    self:HookScript("OnEnter", function(self)
        self:_ShowThumb()
    end)
    self:HookScript("OnLeave", function(self)
        self._fadeTimer = THUMB_FADE_OUT
        self:SetScript("OnUpdate", function(s, dt)
            s._fadeTimer = s._fadeTimer - dt
            if s._fadeTimer <= 0 then
                s:SetScript("OnUpdate", nil)
                s:_HideThumb()
            end
        end)
    end)
end

function WUILScrollFrame_OnScroll(self, offset)
    -- self = inner ScrollFrame widget; get container
    local container = self:GetParent()
    if container and container._wuil then
        container:_UpdateThumb()
    end
end

function WUILScrollFrame_OnRangeChanged(self, xRange, yRange)
    local container = self:GetParent()
    if container and container._wuil then
        container:_UpdateThumb()
    end
end

function WUILScrollFrame_OnMouseWheel(self, delta)
    local container = self:GetParent()
    if not container then return end
    local step = (container._scrollStep or SCROLL_STEP) * -delta
    self:SetVerticalScroll(
        math.max(0, math.min(self:GetVerticalScrollRange(),
                             self:GetVerticalScroll() + step)))
    container:_ShowThumb()
end

-------------------------------------------------------------------------------
-- ScrollFrame mixin
-------------------------------------------------------------------------------

---@class WUILScrollFrame : WUILControlBase
local ScrollFrame = {}
lib._controls.ScrollFrame = ScrollFrame

---@return Frame
function ScrollFrame:GetScrollChild()
    return _G[self:GetName() .. "_Scroll_Child"]
end

---@param n number  pixels per mouse-wheel tick
function ScrollFrame:SetScrollStep(n)
    self._scrollStep = n
end

function ScrollFrame:ScrollToTop()
    local sf = _G[self:GetName() .. "_Scroll"]
    if sf then sf:SetVerticalScroll(0) end
end

function ScrollFrame:ScrollToBottom()
    local sf = _G[self:GetName() .. "_Scroll"]
    if sf then sf:SetVerticalScroll(sf:GetVerticalScrollRange()) end
end

---@param delta number  Positive = scroll down
function ScrollFrame:ScrollBy(delta)
    local sf = _G[self:GetName() .. "_Scroll"]
    if not sf then return end
    sf:SetVerticalScroll(
        math.max(0, math.min(sf:GetVerticalScrollRange(),
                             sf:GetVerticalScroll() + delta)))
end

--- Recalculates and repositions the scrollbar thumb.
function ScrollFrame:_UpdateThumb()
    local sf    = _G[self:GetName() .. "_Scroll"]
    local thumb = _G[self:GetName() .. "_ScrollThumb"]
    local track = _G[self:GetName() .. "_ScrollTrack"]
    if not (sf and thumb and track) then return end

    local scrollRange = sf:GetVerticalScrollRange()
    if scrollRange <= 0 then
        thumb:Hide()
        return
    end
    thumb:Show()

    local trackH  = track:GetHeight()
    local visible = sf:GetHeight()
    local content = visible + scrollRange
    local ratio   = visible / content
    local thumbH  = math.max(THUMB_MIN_H, trackH * ratio)
    thumb:SetHeight(thumbH)

    local scrolled   = sf:GetVerticalScroll()
    local thumbRange = trackH - thumbH
    local thumbY     = -(scrolled / scrollRange) * thumbRange

    thumb:ClearAllPoints()
    thumb:SetPoint("TOPRIGHT", self, "TOPRIGHT", -2, thumbY - 4)
end

function ScrollFrame:_ShowThumb()
    self._thumbVisible = true
    local thumb = _G[self:GetName() .. "_ScrollThumb"]
    if thumb then
        thumb:SetAlpha(0.8)
    end
    self:_UpdateThumb()
end

function ScrollFrame:_HideThumb()
    self._thumbVisible = false
    local thumb = _G[self:GetName() .. "_ScrollThumb"]
    if thumb then
        lib.Motion:FadeOut(thumb, 0.30)
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param width  number?
---@param height number?
---@return Frame
function lib:CreateScrollFrame(parent, width, height)
    local sf = CreateFrame("Frame", nil, parent, "WUILScrollFrameTemplate")
    if width  then sf:SetWidth(width) end
    if height then sf:SetHeight(height) end
    return sf
end
