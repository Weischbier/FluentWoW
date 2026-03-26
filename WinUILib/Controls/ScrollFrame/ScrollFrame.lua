--- WinUILib – Controls/ScrollFrame/ScrollFrame.lua
-- Scrollable container with thin scrollbar thumb.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/scroll-controls
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

local SCROLL_STEP = 40

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILScrollFrame
local ScrollMixin = {}

function ScrollMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
end

function ScrollMixin:_ApplyTokens()
    self.ScrollBar.Track:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
    self.ScrollBar.Thumb.BG:SetColorTexture(T:GetColor("Color.Border.Default"))
end

function ScrollMixin:_UpdateThumb()
    local sf = self.ScrollFrame
    local scrollRange = sf:GetVerticalScrollRange()
    local barHeight = self.ScrollBar:GetHeight()

    if scrollRange <= 0 then
        self.ScrollBar:Hide()
        return
    end
    self.ScrollBar:Show()

    local contentRatio = sf:GetHeight() / (sf:GetHeight() + scrollRange)
    local thumbHeight = math.max(20, barHeight * contentRatio)
    self.ScrollBar.Thumb:SetHeight(thumbHeight)

    local scrollOffset = sf:GetVerticalScroll()
    local trackSpace = barHeight - thumbHeight
    local thumbOffset = (scrollOffset / scrollRange) * trackSpace

    self.ScrollBar.Thumb:ClearAllPoints()
    self.ScrollBar.Thumb:SetPoint("TOP", self.ScrollBar, "TOP", 0, -thumbOffset)
end

--- Returns the scroll child for embedding content.
---@return Frame
function ScrollMixin:GetScrollChild()
    return self.ScrollFrame.Child
end

---@param height number
function ScrollMixin:SetContentHeight(height)
    self.ScrollFrame.Child:SetHeight(height)
    self:_UpdateThumb()
end

---@param offset number
function ScrollMixin:SetScrollOffset(offset)
    self.ScrollFrame:SetVerticalScroll(offset)
    self:_UpdateThumb()
end

---@return number
function ScrollMixin:GetScrollOffset()
    return self.ScrollFrame:GetVerticalScroll()
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILScrollFrame_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, ScrollMixin)
    self:WUILInit()
    self:_ApplyTokens()
end

function WUILScrollFrame_OnScrollLoad(self)
    self:SetScrollChild(self.Child)
end

function WUILScrollFrame_OnRangeChanged(self, xRange, yRange)
    local parent = self:GetParent()
    parent:_UpdateThumb()
end

function WUILScrollFrame_OnVerticalScroll(self, offset)
    local parent = self:GetParent()
    parent:_UpdateThumb()
end

function WUILScrollFrame_OnMouseWheel(self, delta)
    local parent = self:GetParent()
    local current = self:GetVerticalScroll()
    local maxScroll = self:GetVerticalScrollRange()
    local newScroll = current - (delta * SCROLL_STEP)
    newScroll = math.max(0, math.min(newScroll, maxScroll))
    self:SetVerticalScroll(newScroll)
    parent:_UpdateThumb()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return Frame
function lib:CreateScrollFrame(parent, name)
    return CreateFrame("Frame", name, parent, "WUILScrollFrameTemplate")
end
