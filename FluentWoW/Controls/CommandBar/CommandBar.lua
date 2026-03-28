--- FluentWoW – Controls/CommandBar/CommandBar.lua
-- Toolbar with primary command buttons and overflow menu.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/command-bar
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT
local Tex = lib.Textures

-------------------------------------------------------------------------------
-- CommandBar Mixin
-------------------------------------------------------------------------------

---@class FWoWCommandBar
local CommandBarMixin = {}

function CommandBarMixin:OnStateChanged(newState, prevState)
    self.BG:SetVertexColor(T:GetColor("Color.Surface.Raised"))
    self.TopEdge:SetColorTexture(T:GetColor("Color.Border.Subtle"))
    self.BottomEdge:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end

    self:_RefreshItems()
end

---@param commands table[] Array of {key, icon?, label?, tooltip?, onClick}
function CommandBarMixin:SetCommands(commands)
    self._commands = commands
    self:_BuildItems()
end

---@return table[]
function CommandBarMixin:GetCommands()
    return self._commands or {}
end

function CommandBarMixin:_BuildItems()
    if not self._cmdPool then
        self._cmdPool = lib.FramePool:New("Button", self.PrimaryContainer, "FWoWCommandBarItemTemplate", function(btn)
            btn._cmdBar = nil
            btn._cmdKey = nil
            btn._cmdData = nil
        end)
    end
    self._cmdPool:ReleaseAll()
    self._cmdButtons = {}

    local container = self.PrimaryContainer
    local xOff = 0
    local gap = T:GetNumber("Spacing.XS")

    for i, cmd in ipairs(self._commands or {}) do
        local btn = self._cmdPool:Acquire()
        btn:ClearAllPoints()
        btn:SetPoint("LEFT", container, "LEFT", xOff, 0)
        btn:SetSize(32, 32)
        btn._cmdBar = self
        btn._cmdKey = cmd.key
        btn._cmdData = cmd

        if cmd.icon and ICON_FONT then
            btn.Icon:SetFont(ICON_FONT, T:GetNumber("Icon.MD"), "")
            btn.Icon:SetText(cmd.icon)
            btn.Icon:SetTextColor(T:GetColor("Color.Icon.Default"))
        end

        if cmd.label then
            btn.Label:SetText(cmd.label)
            btn.Label:Show()
            local font = T:Get("Typography.Caption")
            if font then btn.Label:SetFont(font.font, font.size, font.flags) end
            btn.Label:SetTextColor(T:GetColor("Color.Text.Secondary"))
            btn:SetWidth(math.max(btn.Label:GetStringWidth() + 8, 40))
            btn:SetHeight(40)
        end

        btn:Show()
        self._cmdButtons[i] = btn
        xOff = xOff + btn:GetWidth() + gap
    end
end

function CommandBarMixin:_RefreshItems()
    for _, btn in ipairs(self._cmdButtons or {}) do
        local iconKey = self._vsm:GetState() == "Disabled" and "Color.Icon.Disabled" or "Color.Icon.Default"
        btn.Icon:SetTextColor(T:GetColor(iconKey))
        if btn.Label:IsShown() then
            local labelKey = self._vsm:GetState() == "Disabled" and "Color.Text.Disabled" or "Color.Text.Secondary"
            btn.Label:SetTextColor(T:GetColor(labelKey))
        end
    end
end

---@param hasOverflow boolean
function CommandBarMixin:SetOverflowEnabled(hasOverflow)
    self._overflowEnabled = hasOverflow
    self.OverflowBtn:SetShown(hasOverflow)
    if hasOverflow and ICON_FONT then
        self.OverflowBtn.Icon:SetFont(ICON_FONT, T:GetNumber("Icon.MD"), "")
        self.OverflowBtn.Icon:SetText(Icons.More)
        self.OverflowBtn.Icon:SetTextColor(T:GetColor("Color.Icon.Default"))
    end
end

---@param fn function(self)
function CommandBarMixin:SetOnOverflow(fn)
    self._onOverflow = fn
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWCommandBar_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, CommandBarMixin)
    self:FWoWInit()
    self._commands = {}
    self._cmdButtons = {}
    lib.SetupTexture(self.BG, Tex.RR4, 4)
    self:OnStateChanged("Normal")
end

function FWoWCommandBarItem_OnClick(self)
    local cmd = self._cmdData
    if cmd and cmd.onClick then
        lib.Utils.SafeCall(cmd.onClick, self)
    end
end

function FWoWCommandBarItem_OnEnter(self)
    self.BG:SetVertexColor(T:GetColor("Color.Overlay.Hover"))
    self.BG:Show()
    if self._cmdData and self._cmdData.tooltip then
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(self._cmdData.tooltip)
        GameTooltip:Show()
    end
end

function FWoWCommandBarItem_OnLeave(self)
    self.BG:Hide()
    GameTooltip:Hide()
end

function FWoWCommandBar_Overflow_OnClick(self)
    local bar = self:GetParent()
    if bar._onOverflow then
        lib.Utils.SafeCall(bar._onOverflow, bar)
    end
end

function FWoWCommandBar_Overflow_OnEnter(self)
    self.BG:SetVertexColor(T:GetColor("Color.Overlay.Hover"))
    self.BG:Show()
end

function FWoWCommandBar_Overflow_OnLeave(self)
    self.BG:Hide()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWCommandBar
function lib:CreateCommandBar(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWCommandBarTemplate")
    ---@cast f FWoWCommandBar
    return f
end
