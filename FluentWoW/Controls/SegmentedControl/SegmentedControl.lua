--- FluentWoW – Controls/SegmentedControl/SegmentedControl.lua
-- Horizontal segmented toggle selector (mutually exclusive).
-- WinUI reference: N/A (Community Toolkit SegmentedControl)
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- SegmentedControl Mixin
-------------------------------------------------------------------------------

---@class FWoWSegmentedControl
local SegmentMixin = {}

function SegmentMixin:OnStateChanged(newState, prevState)
    self.BG:SetColorTexture(T:GetColor("Color.Surface.Stroke"))
    self.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))
    self.Indicator.BG:SetColorTexture(T:GetColor("Color.Surface.Elevated"))

    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end

    self:_RefreshLabels()
end

---@param items string[] Array of segment labels
function SegmentMixin:SetItems(items)
    self._items = items
    self:_BuildSegments()
end

---@return string[]
function SegmentMixin:GetItems()
    return self._items or {}
end

---@param index number 1-based
function SegmentMixin:SetSelectedIndex(index)
    if index < 1 or index > #(self._items or {}) then return end
    self._selectedIndex = index
    self:_AnimateIndicator()
    self:_RefreshLabels()
    if self._onSelectionChanged then
        lib.Utils.SafeCall(self._onSelectionChanged, self, index, (self._items or {})[index])
    end
end

---@return number
function SegmentMixin:GetSelectedIndex()
    return self._selectedIndex or 1
end

---@return string|nil
function SegmentMixin:GetSelectedItem()
    local items = self._items or {}
    return items[self._selectedIndex or 1]
end

---@param fn function(self, index, label)
function SegmentMixin:SetOnSelectionChanged(fn)
    self._onSelectionChanged = fn
end

function SegmentMixin:_BuildSegments()
    for _, btn in ipairs(self._segButtons or {}) do
        lib.FramePool:Release(btn)
    end
    self._segButtons = {}

    local items = self._items or {}
    local count = #items
    if count == 0 then return end

    local totalW = self:GetWidth()
    local segW = totalW / count

    self.Indicator:SetWidth(segW - 4)
    self.Indicator:SetHeight(self:GetHeight() - 4)

    for i, label in ipairs(items) do
        local btn = lib.FramePool:Acquire("FWoWSegmentItemTemplate", self.SegmentContainer)
        btn:ClearAllPoints()
        btn:SetPoint("LEFT", self, "LEFT", (i - 1) * segW, 0)
        btn:SetSize(segW, self:GetHeight())
        btn._segControl = self
        btn._segIndex = i

        local font = T:Get("Typography.Body")
        if font then
            btn.Label:SetFont(font.font, font.size, font.flags)
        end
        btn.Label:SetText(label)

        btn:Show()
        self._segButtons[i] = btn
    end

    if not self._selectedIndex then
        self._selectedIndex = 1
    end
    self:_AnimateIndicator(true)
    self:_RefreshLabels()
end

function SegmentMixin:_AnimateIndicator(instant)
    local items = self._items or {}
    local count = #items
    if count == 0 then return end

    local segW = self:GetWidth() / count
    local targetX = ((self._selectedIndex or 1) - 1) * segW + 2

    if instant or Mot.reducedMotion then
        self.Indicator:ClearAllPoints()
        self.Indicator:SetPoint("LEFT", self, "LEFT", targetX, 0)
    else
        local curX = select(4, self.Indicator:GetPoint(1)) or 2
        local proxy = { x = curX }
        Mot:Tween(proxy, T:GetNumber("Motion.Duration.Fast"), { x = targetX })
            :ease("quadout")
            :onupdate(function()
                self.Indicator:ClearAllPoints()
                self.Indicator:SetPoint("LEFT", self, "LEFT", proxy.x, 0)
            end)
            :oncomplete(function()
                self.Indicator:ClearAllPoints()
                self.Indicator:SetPoint("LEFT", self, "LEFT", targetX, 0)
            end)
    end
end

function SegmentMixin:_RefreshLabels()
    for i, btn in ipairs(self._segButtons or {}) do
        if i == self._selectedIndex then
            btn.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
        else
            btn.Label:SetTextColor(T:GetColor("Color.Text.Secondary"))
        end
    end
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWSegmentedControl_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, SegmentMixin)
    self:FWoWInit()
    self._items = {}
    self._segButtons = {}
    self._selectedIndex = 1
    self:OnStateChanged("Normal")
end

function FWoWSegmentItem_OnClick(self)
    local seg = self._segControl
    if seg and self._segIndex then
        seg:SetSelectedIndex(self._segIndex)
    end
end

function FWoWSegmentItem_OnEnter(self)
    if self._segIndex ~= self._segControl._selectedIndex then
        self.Label:SetTextColor(T:GetColor("Color.Accent.Primary"))
    end
end

function FWoWSegmentItem_OnLeave(self)
    local seg = self._segControl
    if self._segIndex == seg._selectedIndex then
        self.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
    else
        self.Label:SetTextColor(T:GetColor("Color.Text.Secondary"))
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWSegmentedControl
function lib:CreateSegmentedControl(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWSegmentedControlTemplate")
    ---@cast f FWoWSegmentedControl
    return f
end
