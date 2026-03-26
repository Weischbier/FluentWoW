--- WinUILib – Layout/StackLayout.lua
-- Vertical (VStack) or horizontal (HStack) stack layout container.
-- Automatically arranges children with token-driven gaps and padding.
-- States: Normal (no visual states; layout-only control)
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILStackLayout
local StackMixin = {}

function StackMixin:OnStateChanged(newState, prevState)
    -- layout control has no visual state changes
end

function StackMixin:_Layout()
    if self._laying_out then return end
    self._laying_out = true

    local children = self._children
    if not children or #children == 0 then
        if self._orientation == "VERTICAL" then
            self:SetHeight(1)
        else
            self:SetWidth(1)
        end
        self._laying_out = false
        return
    end

    local padT = self._padTop or 0
    local padR = self._padRight or 0
    local padB = self._padBottom or 0
    local padL = self._padLeft or 0
    local gap  = self._gap or 0

    if self._orientation == "VERTICAL" then
        local yOff = -padT
        for i, child in ipairs(children) do
            if child:IsShown() then
                child:ClearAllPoints()
                child:SetPoint("TOPLEFT", self, "TOPLEFT", padL, yOff)
                child:SetPoint("RIGHT", self, "RIGHT", -padR, 0)
                yOff = yOff - child:GetHeight()
                if i < #children then yOff = yOff - gap end
            end
        end
        self:SetHeight(math.abs(yOff) + padB)
        self._laying_out = false
    else
        local xOff = padL
        for i, child in ipairs(children) do
            if child:IsShown() then
                child:ClearAllPoints()
                child:SetPoint("TOPLEFT", self, "TOPLEFT", xOff, -padT)
                child:SetPoint("BOTTOM", self, "BOTTOM", 0, padB)
                xOff = xOff + child:GetWidth()
                if i < #children then xOff = xOff + gap end
            end
        end
        self:SetWidth(xOff + padR)
        self._laying_out = false
    end
end

---@param child Frame
function StackMixin:AddChild(child)
    if not self._children then self._children = {} end
    child:SetParent(self)
    table.insert(self._children, child)
    self:_Layout()
end

---@param child Frame
function StackMixin:RemoveChild(child)
    if not self._children then return end
    for i, c in ipairs(self._children) do
        if c == child then
            table.remove(self._children, i)
            child:ClearAllPoints()
            child:Hide()
            break
        end
    end
    self:_Layout()
end

---@return table
function StackMixin:GetChildren()
    return self._children or {}
end

---@param orientation string  "VERTICAL"|"HORIZONTAL"
function StackMixin:SetOrientation(orientation)
    self._orientation = orientation
    self:_Layout()
end

---@param gap number  pixels between children
function StackMixin:SetGap(gap)
    self._gap = gap
    self:_Layout()
end

---@param top number
---@param right number
---@param bottom number
---@param left number
function StackMixin:SetPadding(top, right, bottom, left)
    self._padTop    = top
    self._padRight  = right
    self._padBottom = bottom
    self._padLeft   = left
    self:_Layout()
end

function StackMixin:Refresh()
    self:_Layout()
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILStackLayout_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, StackMixin)
    self:WUILInit()
    self._children = {}
    self._orientation = "VERTICAL"
    self._gap = T:GetNumber("Spacing.MD")
    self._padTop = 0
    self._padRight = 0
    self._padBottom = 0
    self._padLeft = 0
end

function WUILStackLayout_OnSizeChanged(self)
    if self._children and #self._children > 0 then
        self:_Layout()
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@param orientation? string  "VERTICAL"|"HORIZONTAL" (default VERTICAL)
---@return Frame
function lib:CreateStackLayout(parent, name, orientation)
    local f = CreateFrame("Frame", name, parent, "WUILStackLayoutTemplate")
    f._orientation = orientation or "VERTICAL"
    return f
end
