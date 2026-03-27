--- FluentWoW – Controls/TabView/TabView.lua
-- Tabbed navigation container with dynamic tab strip.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/tab-view
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class FWoWTabView
local TabViewMixin = {}

local function setStripSlot(slot, control, width)
    if slot._content and slot._content ~= control then
        slot._content:ClearAllPoints()
        slot._content:SetParent(nil)
    end
    slot._content = control
    if not control then
        slot:SetWidth(1)
        slot:Hide()
        return
    end
    slot:SetWidth(width or control:GetWidth() or 1)
    slot:Show()
    control:SetParent(slot)
    control:ClearAllPoints()
    control:SetAllPoints(slot)
    control:Show()
end

function TabViewMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
end

function TabViewMixin:_ApplyTokens()
    self.TabStrip.StripBG:SetColorTexture(T:GetColor("Color.Surface.Base"))
    self.ContentArea.ContentBG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
    self.TabStrip.AddButton.BG:SetColorTexture(T:GetColor("Color.Surface.Elevated"))
    self.TabStrip.AddButton.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
end

function TabViewMixin:_RefreshTabs()
    -- release old tab buttons
    if self._tabPool then
        self._tabPool:ReleaseAll()
    else
        self._tabPool = lib.FramePool:New("Button", self.TabStrip, "FWoWTabItemTemplate")
    end

    local xOff = self.TabStrip.HeaderSlot:IsShown() and (self.TabStrip.HeaderSlot:GetWidth() + T:GetNumber("Spacing.XL")) or 0
    local stripLimit = self:GetWidth()
    if self.TabStrip.FooterSlot:IsShown() then
        stripLimit = stripLimit - self.TabStrip.FooterSlot:GetWidth() - T:GetNumber("Spacing.XL")
    end
    if self._addButtonVisible then
        self.TabStrip.AddButton:Show()
        stripLimit = stripLimit - self.TabStrip.AddButton:GetWidth() - T:GetNumber("Spacing.XL")
    else
        self.TabStrip.AddButton:Hide()
    end

    for i, tab in ipairs(self._tabs) do
        local btn = self._tabPool:Acquire()
        btn:SetParent(self.TabStrip)
        btn:ClearAllPoints()
        btn:SetPoint("LEFT", self.TabStrip, "LEFT", xOff, 0)
        btn:SetHeight(T:GetNumber("Spacing.XXXL"))  -- 32
        btn.Label:SetText(tab.text or "")
        btn._tabIndex = i
        btn._tabView = self
        btn.Hover:SetColorTexture(T:GetColor("Color.Overlay.Hover"))

        btn.Label:ClearAllPoints()
        if tab.icon then
            btn.Icon:SetTexture(tab.icon)
            btn.Icon:Show()
            btn.Label:SetPoint("LEFT", btn.Icon, "RIGHT", 8, 0)
        else
            btn.Icon:Hide()
            btn.Label:SetPoint("LEFT", btn, "LEFT", 12, 0)
        end

        if tab.closable then
            btn.CloseBtn:Show()
            btn.CloseBtn._tabIndex = i
            btn.CloseBtn._tabView = self
            btn.CloseBtn.Label:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
            btn.CloseBtn.Label:SetText(Icons.ChromeClose)
            btn.Label:SetPoint("RIGHT", btn.CloseBtn, "LEFT", -8, 0)
        else
            btn.CloseBtn:Hide()
            btn.Label:SetPoint("RIGHT", btn, "RIGHT", -12, 0)
        end

        -- auto-width based on text
        local textWidth = btn.Label:GetStringWidth() + T:GetNumber("Spacing.XXL")
        if tab.icon then textWidth = textWidth + 22 end
        if tab.closable then textWidth = textWidth + 24 end
        local targetWidth = math.max(T:GetNumber("Spacing.XXXL") * 2 + T:GetNumber("Spacing.XL"), textWidth)
        if self._tabWidthMode == "Equal" and #self._tabs > 0 then
            targetWidth = math.max(80, math.floor((stripLimit - xOff) / (#self._tabs - i + 1)))
        end
        btn:SetWidth(targetWidth)
        xOff = xOff + btn:GetWidth()

        if i == self._selectedIndex then
            btn.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
            btn.Indicator:SetColorTexture(T:GetColor("Color.Accent.Primary"))
            btn.Indicator:Show()
            btn.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
        else
            btn.BG:SetColorTexture(T:GetColor("Color.Surface.Base"))
            btn.Indicator:Hide()
            btn.Label:SetTextColor(T:GetColor("Color.Text.Secondary"))
        end
    end
end

---@param tabs table  array of { text=string, content=Frame|nil }
function TabViewMixin:SetTabs(tabs)
    self._tabs = tabs
    self._selectedIndex = #tabs > 0 and 1 or nil
    self:_RefreshTabs()
    self:_ShowContent()
end

---@param tab table
function TabViewMixin:AddTab(tab)
    table.insert(self._tabs, tab)
    self:SelectTab(#self._tabs)
    self:_RefreshTabs()
end

---@param index integer
function TabViewMixin:RemoveTab(index)
    if index < 1 or index > #self._tabs then return end
    table.remove(self._tabs, index)
    if #self._tabs == 0 then
        self._selectedIndex = nil
    elseif self._selectedIndex and self._selectedIndex > #self._tabs then
        self._selectedIndex = #self._tabs
    end
    self:_RefreshTabs()
    self:_ShowContent()
end

---@param index integer
function TabViewMixin:SelectTab(index)
    if index < 1 or index > #self._tabs then return end
    if index == self._selectedIndex then return end
    self._selectedIndex = index
    self:_RefreshTabs()
    self:_ShowContent()
    if self._onTabChanged then
        lib.Utils.SafeCall(self._onTabChanged, self, index)
    end
end

---@return integer|nil
function TabViewMixin:GetSelectedIndex()
    return self._selectedIndex
end

function TabViewMixin:_ShowContent()
    -- hide all content frames
    for _, tab in ipairs(self._tabs) do
        if tab.content then tab.content:Hide() end
    end
    -- show selected
    if self._selectedIndex then
        local tab = self._tabs[self._selectedIndex]
        if tab and tab.content then
            tab.content:SetParent(self.ContentArea)
            tab.content:ClearAllPoints()
            tab.content:SetAllPoints(self.ContentArea)
            tab.content:Show()
        end
    end
end

---@param fn function
function TabViewMixin:SetOnTabChanged(fn)
    self._onTabChanged = fn
end

---@param fn function
function TabViewMixin:SetOnAddTab(fn)
    self._onAddTab = fn
end

---@param fn function
function TabViewMixin:SetOnTabCloseRequested(fn)
    self._onTabCloseRequested = fn
end

---@param visible boolean
function TabViewMixin:SetAddButtonVisible(visible)
    self._addButtonVisible = visible == true
    self:_RefreshTabs()
end

---@param control Frame|nil
---@param width? number
function TabViewMixin:SetTabStripHeader(control, width)
    setStripSlot(self.TabStrip.HeaderSlot, control, width)
    self:_RefreshTabs()
end

---@param control Frame|nil
---@param width? number
function TabViewMixin:SetTabStripFooter(control, width)
    setStripSlot(self.TabStrip.FooterSlot, control, width)
    self:_RefreshTabs()
end

---@param mode string
function TabViewMixin:SetTabWidthMode(mode)
    self._tabWidthMode = mode == "Equal" and "Equal" or "SizeToContent"
    self:_RefreshTabs()
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWTabView_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, TabViewMixin)
    self:FWoWInit()
    self._tabs = {}
    self._selectedIndex = nil
    self._addButtonVisible = false
    self._tabWidthMode = "SizeToContent"
    self.TabStrip.AddButton.Label:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
    self.TabStrip.AddButton.Label:SetText(Icons.Add)
    self:_ApplyTokens()
end

function FWoWTabItem_OnClick(self)
    local tabView = self._tabView
    if not tabView or not tabView._enabled then return end
    tabView:SelectTab(self._tabIndex)
end

function FWoWTabItem_Close_OnClick(self)
    local tabView = self._tabView
    if not tabView or not tabView._enabled then return end
    if tabView._onTabCloseRequested then
        lib.Utils.SafeCall(tabView._onTabCloseRequested, tabView, self._tabIndex)
    else
        tabView:RemoveTab(self._tabIndex)
    end
end

function FWoWTabView_AddButton_OnClick(self)
    local tabView = self:GetParent():GetParent()
    if not tabView or not tabView._enabled or not tabView._onAddTab then return end
    lib.Utils.SafeCall(tabView._onAddTab, tabView)
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWTabView
function lib:CreateTabView(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWTabViewTemplate")
    ---@cast f FWoWTabView
    return f
end
