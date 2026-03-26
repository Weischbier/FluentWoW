--- WinUILib – Controls/TabView/TabView.lua
-- Tabbed navigation container with dynamic tab strip.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/tab-view
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILTabView
local TabViewMixin = {}

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
end

function TabViewMixin:_RefreshTabs()
    -- release old tab buttons
    if self._tabPool then
        self._tabPool:ReleaseAll()
    else
        self._tabPool = lib.FramePool:New("Button", self.TabStrip, "WUILTabItemTemplate")
    end

    local xOff = 0
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

        -- auto-width based on text
        local textWidth = btn.Label:GetStringWidth() + T:GetNumber("Spacing.XXL")  -- 24
        btn:SetWidth(math.max(T:GetNumber("Spacing.XXXL") * 2 + T:GetNumber("Spacing.XL"), textWidth))  -- ~80
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

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILTabView_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, TabViewMixin)
    self:WUILInit()
    self._tabs = {}
    self._selectedIndex = nil
    self:_ApplyTokens()
end

function WUILTabItem_OnClick(self)
    local tabView = self._tabView
    if not tabView or not tabView._enabled then return end
    tabView:SelectTab(self._tabIndex)
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return Frame
function lib:CreateTabView(parent, name)
    return CreateFrame("Frame", name, parent, "WUILTabViewTemplate")
end
