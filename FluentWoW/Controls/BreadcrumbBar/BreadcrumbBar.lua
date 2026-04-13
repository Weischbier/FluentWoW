--- FluentWoW – Controls/BreadcrumbBar/BreadcrumbBar.lua
-- Horizontal breadcrumb trail showing navigation hierarchy.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/breadcrumbbar
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local _Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

-------------------------------------------------------------------------------
-- BreadcrumbBar Mixin
-------------------------------------------------------------------------------

---@class FWoWBreadcrumbBar
local BreadcrumbMixin = {}

function BreadcrumbMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
    self:_RefreshVisuals()
end

---@param items string[] Array of breadcrumb labels
function BreadcrumbMixin:SetItems(items)
    self._items = items
    self:_BuildCrumbs()
end

---@return string[]
function BreadcrumbMixin:GetItems()
    return self._items or {}
end

---@param fn function(self, index, label)
function BreadcrumbMixin:SetOnItemClicked(fn)
    self._onItemClicked = fn
end

function BreadcrumbMixin:_BuildCrumbs()
    if not self._crumbPool then
        self._crumbPool = lib.FramePool:New("Button", self.Container, "FWoWBreadcrumbItemTemplate", function(btn)
            btn._breadcrumb = nil
            btn._index = nil
        end)
    end
    self._crumbPool:ReleaseAll()
    self._crumbs = {}

    local container = self.Container
    local xOff = 0
    local items = self._items or {}

    for i, label in ipairs(items) do
        local crumb = self._crumbPool:Acquire()
        crumb:ClearAllPoints()
        crumb:SetPoint("LEFT", container, "LEFT", xOff, 0)
        crumb._breadcrumb = self
        crumb._index = i

        local font = T:Get("Typography.Body")
        if font then
            crumb.Label:SetFont(font.font, font.size, font.flags)
        end
        crumb.Label:SetText(label)

        local isLast = (i == #items)
        if isLast then
            crumb.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
            crumb.Separator:SetText("")
        else
            crumb.Label:SetTextColor(T:GetColor("Color.Text.Secondary"))
            if ICON_FONT then
                crumb.Separator:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
                crumb.Separator:SetText(Icons.ChevronRight)
            else
                crumb.Separator:SetText("/")
            end
            crumb.Separator:SetTextColor(T:GetColor("Color.Text.Secondary"))
        end

        crumb:Show()
        local crumbWidth = crumb.Label:GetStringWidth() + (isLast and 0 or (crumb.Separator:GetStringWidth() + 16))
        crumb:SetWidth(math.max(crumbWidth, 20))
        self._crumbs[i] = crumb
        xOff = xOff + crumb:GetWidth()
    end
end

function BreadcrumbMixin:_RefreshVisuals()
    local items = self._items or {}
    for i, crumb in ipairs(self._crumbs or {}) do
        local isLast = (i == #items)
        if isLast then
            crumb.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
        else
            crumb.Label:SetTextColor(T:GetColor("Color.Text.Secondary"))
        end
        if crumb.Separator:GetText() and crumb.Separator:GetText() ~= "" then
            crumb.Separator:SetTextColor(T:GetColor("Color.Text.Secondary"))
        end
    end
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWBreadcrumbBar_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, BreadcrumbMixin)
    self:FWoWInit()
    self._items = {}
    self._crumbs = {}
    self:OnStateChanged("Normal")
end

function FWoWBreadcrumbItem_OnClick(self)
    local bar = self._breadcrumb
    if bar and bar._onItemClicked then
        lib.Utils.SafeCall(bar._onItemClicked, bar, self._index, (bar._items or {})[self._index])
    end
end

function FWoWBreadcrumbItem_OnEnter(self)
    local bar = self._breadcrumb
    local items = bar and bar._items or {}
    if self._index ~= #items then
        self.Label:SetTextColor(T:GetColor("Color.Accent.Primary"))
    end
end

function FWoWBreadcrumbItem_OnLeave(self)
    local bar = self._breadcrumb
    local items = bar and bar._items or {}
    if self._index == #items then
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
---@return FWoWBreadcrumbBar
function lib:CreateBreadcrumbBar(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWBreadcrumbBarTemplate")
    ---@cast f FWoWBreadcrumbBar
    return f
end
