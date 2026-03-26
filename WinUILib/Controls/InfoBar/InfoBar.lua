--- WinUILib – Controls/InfoBar/InfoBar.lua
-- Inline notification bar with severity-coloured left edge and icon.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/infobar
-- Severities: Info | Success | Warning | Error
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Severity token maps
-------------------------------------------------------------------------------

local SEVERITY = {
    Info    = { edge = "Color.Accent.Primary",    icon = "Color.Accent.Primary",    iconColor = "Color.Icon.OnAccent" },
    Success = { edge = "Color.Feedback.Success",  icon = "Color.Feedback.Success",  iconColor = "Color.Icon.OnAccent" },
    Warning = { edge = "Color.Feedback.Warning",  icon = "Color.Feedback.Warning",  iconColor = "Color.Text.Primary"  },
    Error   = { edge = "Color.Feedback.Error",    icon = "Color.Feedback.Error",    iconColor = "Color.Icon.OnAccent" },
}

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILInfoBar
local InfoBarMixin = {}

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
    self.Icon:SetColorTexture(1, 1, 1)
    self.Icon:SetVertexColor(T:GetColor(sev.icon))
    self.Title:SetTextColor(T:GetColor("Color.Text.Primary"))
    self.Message:SetTextColor(T:GetColor("Color.Text.Secondary"))
    self.CloseBtn.X:SetTextColor(T:GetColor("Color.Text.Secondary"))
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
end

---@param text string
function InfoBarMixin:SetMessage(text)
    self.Message:SetText(text)
end

---@param show boolean
function InfoBarMixin:SetClosable(show)
    self._closable = show
    if show then self.CloseBtn:Show() else self.CloseBtn:Hide() end
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

---@param path string  atlas or file path
---@param isAtlas? boolean
function InfoBarMixin:SetIcon(path, isAtlas)
    if isAtlas then
        self.Icon:SetAtlas(path)
    else
        self.Icon:SetTexture(path)
    end
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILInfoBar_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, InfoBarMixin)
    self:WUILInit()
    self._severity = "Info"
    self._closable = true
    self:_ApplySeverity()
end

function WUILInfoBar_OnClose(self)
    local parent = self:GetParent()
    parent:Close()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return WUILInfoBar
function lib:CreateInfoBar(parent, name)
    return CreateFrame("Frame", name, parent, "WUILInfoBarTemplate")
end
