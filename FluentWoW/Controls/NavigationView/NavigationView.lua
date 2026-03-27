--- FluentWoW – Controls/NavigationView/NavigationView.lua
-- Sidebar navigation with collapsible pane, selection indicator, and content area.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/navigationview
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

local PANE_WIDTH_EXPANDED  = 200
local PANE_WIDTH_COLLAPSED = 48

-------------------------------------------------------------------------------
-- NavigationView Mixin
-------------------------------------------------------------------------------

---@class FWoWNavigationView
local NavViewMixin = {}

function NavViewMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
    self.Pane.PaneBG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
    self.Divider.Line:SetColorTexture(T:GetColor("Color.Border.Subtle"))
    self.ContentArea.ContentBG:SetColorTexture(T:GetColor("Color.Surface.Base"))
    self:_RefreshItems()
end

---@param items table[] Array of {key, label, icon?, content?}
function NavViewMixin:SetItems(items)
    self._itemData = items
    self:_BuildItems()
end

---@param key string
function NavViewMixin:SelectItem(key)
    if self._selectedKey == key then return end
    self._selectedKey = key
    self:_RefreshItems()
    self:_ShowContent(key)
    if self._onSelectionChanged then
        lib.Utils.SafeCall(self._onSelectionChanged, self, key)
    end
end

---@return string|nil
function NavViewMixin:GetSelectedKey()
    return self._selectedKey
end

---@param fn function(self, key)
function NavViewMixin:SetOnSelectionChanged(fn)
    self._onSelectionChanged = fn
end

---@param expanded boolean
---@param instant? boolean
function NavViewMixin:SetPaneExpanded(expanded, instant)
    if self._paneExpanded == expanded then return end
    self._paneExpanded = expanded

    local targetW = expanded and PANE_WIDTH_EXPANDED or PANE_WIDTH_COLLAPSED

    if instant or Mot.reducedMotion then
        self.Pane:SetWidth(targetW)
    else
        local fromW = self.Pane:GetWidth()
        local proxy = { w = fromW }
        Mot:Tween(proxy, T:GetNumber("Motion.Duration.Normal"), { w = targetW })
            :ease("quadout")
            :onupdate(function() self.Pane:SetWidth(proxy.w) end)
            :oncomplete(function() self.Pane:SetWidth(targetW) end)
    end

    for _, btn in ipairs(self._navButtons or {}) do
        btn.Label:SetShown(expanded)
    end

    if self.Pane.ToggleBtn then
        self.Pane.ToggleBtn.Icon:SetText(Icons.GlobalNavButton)
    end
end

---@return boolean
function NavViewMixin:IsPaneExpanded()
    return self._paneExpanded == true
end

function NavViewMixin:_BuildItems()
    if not self._navPool then
        self._navPool = lib.FramePool:New("Button", self.Pane.ItemContainer, "FWoWNavItemTemplate", function(btn)
            btn._navView = nil
            btn._itemKey = nil
        end)
    end
    self._navPool:ReleaseAll()
    self._navButtons = {}

    local container = self.Pane.ItemContainer
    local yOff = 0

    for i, item in ipairs(self._itemData or {}) do
        local btn = self._navPool:Acquire()
        btn:ClearAllPoints()
        btn:SetPoint("TOPLEFT", container, "TOPLEFT", 4, -yOff)
        btn:SetPoint("RIGHT", container, "RIGHT", -4, 0)
        local navItemH = T:GetNumber("Spacing.XXXL") + T:GetNumber("Spacing.MD")  -- 32+8 = 40
        btn:SetHeight(navItemH)
        btn._navView = self
        btn._itemKey = item.key

        if item.icon and ICON_FONT then
            btn.Icon:SetFont(ICON_FONT, T:GetNumber("Icon.MD"), "")
            btn.Icon:SetText(item.icon)
        else
            btn.Icon:SetText("")
        end

        btn.Label:SetText(item.label or "")
        btn.Label:SetShown(self._paneExpanded)

        local font = T:Get("Typography.Body")
        if font then
            btn.Label:SetFont(font.font, font.size, font.flags)
        end

        btn:Show()
        self._navButtons[i] = btn
        yOff = yOff + navItemH + T:GetNumber("Spacing.XS")
    end

    self:_RefreshItems()
end

function NavViewMixin:_RefreshItems()
    for _, btn in ipairs(self._navButtons or {}) do
        local selected = btn._itemKey == self._selectedKey
        if selected then
            btn.BG:SetColorTexture(T:GetColor("Color.Surface.Elevated"))
            btn.BG:Show()
            btn.Indicator:SetColorTexture(T:GetColor("Color.Accent.Primary"))
            btn.Indicator:Show()
            btn.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
            btn.Icon:SetTextColor(T:GetColor("Color.Accent.Primary"))
        else
            btn.BG:Hide()
            btn.Indicator:Hide()
            btn.Label:SetTextColor(T:GetColor("Color.Text.Secondary"))
            btn.Icon:SetTextColor(T:GetColor("Color.Text.Secondary"))
        end
    end
end

function NavViewMixin:_ShowContent(key)
    -- Hide all content frames
    for _, item in ipairs(self._itemData or {}) do
        if item._contentFrame then
            item._contentFrame:Hide()
        end
    end
    -- Show selected
    for _, item in ipairs(self._itemData or {}) do
        if item.key == key and item._contentFrame then
            item._contentFrame:Show()
        end
    end
end

---@param key string
---@param frame Frame
function NavViewMixin:SetItemContent(key, frame)
    for _, item in ipairs(self._itemData or {}) do
        if item.key == key then
            item._contentFrame = frame
            frame:SetParent(self.ContentArea)
            frame:SetAllPoints(self.ContentArea)
            frame:Hide()
            if key == self._selectedKey then
                frame:Show()
            end
            return
        end
    end
end

---@return Frame
function NavViewMixin:GetContentArea()
    return self.ContentArea
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWNavigationView_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, NavViewMixin)
    self:FWoWInit()
    self._paneExpanded = true
    self._selectedKey = nil
    self._itemData = {}
    self._navButtons = {}

    self.Pane:SetWidth(PANE_WIDTH_EXPANDED)

    if ICON_FONT then
        self.Pane.ToggleBtn.Icon:SetFont(ICON_FONT, T:GetNumber("Icon.MD"), "")
        self.Pane.ToggleBtn.Icon:SetText(Icons.GlobalNavButton)
    end

    self:OnStateChanged("Normal")
end

function FWoWNavToggleBtn_OnClick(self)
    local nav = self:GetParent():GetParent()
    nav:SetPaneExpanded(not nav:IsPaneExpanded())
end

function FWoWNavToggleBtn_OnEnter(self)
    self.BG:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
    self.BG:Show()
end

function FWoWNavToggleBtn_OnLeave(self)
    self.BG:Hide()
end

function FWoWNavItem_OnClick(self)
    local nav = self._navView
    if nav and self._itemKey then
        nav:SelectItem(self._itemKey)
    end
end

function FWoWNavItem_OnEnter(self)
    if self._itemKey ~= self._navView._selectedKey then
        self.BG:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
        self.BG:Show()
    end
end

function FWoWNavItem_OnLeave(self)
    if self._itemKey ~= self._navView._selectedKey then
        self.BG:Hide()
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWNavigationView
function lib:CreateNavigationView(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWNavigationViewTemplate")
    ---@cast f FWoWNavigationView
    return f
end
