--- FluentWoW – Controls/InfoBar/InfoBar.lua
-- Inline notification bar with severity-coloured left edge and icon.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/infobar
-- Severities: Info | Success | Warning | Error
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

-------------------------------------------------------------------------------
-- Severity token maps
-------------------------------------------------------------------------------

local SEVERITY = {
    Info    = { edge = "Color.Accent.Primary",    icon = "Color.Accent.Primary",    iconColor = "Color.Icon.OnAccent", glyph = "Info" },
    Success = { edge = "Color.Feedback.Success",  icon = "Color.Feedback.Success",  iconColor = "Color.Icon.OnAccent", glyph = "StatusCircleCheckmark" },
    Warning = { edge = "Color.Feedback.Warning",  icon = "Color.Feedback.Warning",  iconColor = "Color.Text.Primary",  glyph = "Warning" },
    Error   = { edge = "Color.Feedback.Error",    icon = "Color.Feedback.Error",    iconColor = "Color.Icon.OnAccent", glyph = "ErrorBadge" },
}

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class FWoWInfoBar
local InfoBarMixin = {}

local function updateLayout(self)
    local leftInset = self._iconVisible == false and T:GetNumber("Spacing.XL") or 44
    local rightInset = T:GetNumber("Spacing.XL")
    local topInset = T:GetNumber("Spacing.LG")
    local actionWidth = 0
    local actionHeight = 0

    if self._actionControl then
        self.ActionSlot:SetShown(true)
        self._actionControl:SetParent(self.ActionSlot)
        self._actionControl:ClearAllPoints()
        self._actionControl:SetPoint("TOPRIGHT", self.ActionSlot, "TOPRIGHT", 0, 0)
        actionWidth = math.max(self._actionControl:GetWidth(), 80)
        actionHeight = self._actionControl:GetHeight()
        self.ActionSlot:SetSize(actionWidth, actionHeight)
    else
        self.ActionSlot:Hide()
    end

    self.Title:ClearAllPoints()
    self.Message:ClearAllPoints()

    local anchorRight = -rightInset
    if self._closable then
        anchorRight = -40
    end
    if self._actionControl then
        anchorRight = -(actionWidth + T:GetNumber("Spacing.XL") + (self._closable and 32 or 0))
    end

    if self._iconVisible == false then
        self.Icon:Hide()
    else
        self.Icon:Show()
    end

    self.Title:SetPoint("TOPLEFT", self, "TOPLEFT", leftInset, -topInset)
    self.Title:SetPoint("RIGHT", self, "RIGHT", anchorRight, 0)

    if self.Title:GetText() == nil or self.Title:GetText() == "" then
        self.Title:Hide()
        self.Message:SetPoint("TOPLEFT", self, "TOPLEFT", leftInset, -topInset)
    else
        self.Title:Show()
        self.Message:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT", 0, -4)
    end
    self.Message:SetPoint("RIGHT", self, "RIGHT", anchorRight, 0)
    self.Message:SetJustifyV("TOP")

    local titleHeight = self.Title:IsShown() and self.Title:GetStringHeight() or 0
    local messageHeight = self.Message:GetStringHeight()
    local textHeight = titleHeight + messageHeight + (self.Title:IsShown() and 4 or 0)
    local contentHeight = math.max(16, textHeight, actionHeight, self._iconVisible == false and 0 or 16) + (topInset * 2)
    self:SetHeight(math.max(48, contentHeight))
end

function InfoBarMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
    self:_ApplySeverity()
end

function InfoBarMixin:_ApplySeverity()
    local sev = SEVERITY[self._severity] or SEVERITY.Info
    self.BG:SetColorTexture(T:GetColor("Color.Surface.Raised"))
    self.LeftEdge:SetColorTexture(T:GetColor(sev.edge))
    self.Icon:SetText(Icons[sev.glyph])
    self.Icon:SetTextColor(T:GetColor(sev.icon))
    self.Title:SetTextColor(T:GetColor("Color.Text.Primary"))
    self.Message:SetTextColor(T:GetColor("Color.Text.Secondary"))
    self.CloseBtn.X:SetTextColor(T:GetColor("Color.Text.Secondary"))
    updateLayout(self)
end

---@param severity string  "Info"|"Success"|"Warning"|"Error"
function InfoBarMixin:SetSeverity(severity)
    self._severity = severity
    self:_ApplySeverity()
end

---@return string
function InfoBarMixin:GetSeverity()
    return self._severity or "Info"
end

---@param text string
function InfoBarMixin:SetTitle(text)
    self.Title:SetText(text)
    updateLayout(self)
end

---@param text string
function InfoBarMixin:SetMessage(text)
    self.Message:SetText(text)
    updateLayout(self)
end

---@param show boolean
function InfoBarMixin:SetClosable(show)
    self._closable = show
    if show then self.CloseBtn:Show() else self.CloseBtn:Hide() end
    updateLayout(self)
end

---@param show boolean
function InfoBarMixin:SetIconVisible(show)
    self._iconVisible = show ~= false
    updateLayout(self)
end

---@param control Frame|nil
function InfoBarMixin:SetActionControl(control)
    self._actionControl = control
    updateLayout(self)
end

---@param fn function
function InfoBarMixin:SetOnClosed(fn)
    self._onClosed = fn
end

function InfoBarMixin:Open()
    Mot:FadeIn(self)
end

function InfoBarMixin:Close()
    Mot:FadeOut(self, nil, function()
        if self._onClosed then
            lib.Utils.SafeCall(self._onClosed, self)
        end
    end)
end

---@param iconName string  Fluent icon name (key in FluentWoW.Icons) or a raw UTF-8 glyph string
function InfoBarMixin:SetIcon(iconName)
    local glyph = Icons[iconName] or iconName
    self.Icon:SetText(glyph)
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWInfoBar_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, InfoBarMixin)
    self:FWoWInit()
    self._severity = "Info"
    self._closable = true
    self._iconVisible = true
    self._actionControl = nil
    self.Icon:SetFont(ICON_FONT, T:GetNumber("Icon.MD"), "")
    self.CloseBtn.X:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
    self.CloseBtn.X:SetText(Icons.ChromeClose)
    self:_ApplySeverity()
end

function FWoWInfoBar_OnClose(self)
    local parent = self:GetParent()
    parent:Close()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWInfoBar
function lib:CreateInfoBar(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWInfoBarTemplate")
    ---@cast f FWoWInfoBar
    return f
end
