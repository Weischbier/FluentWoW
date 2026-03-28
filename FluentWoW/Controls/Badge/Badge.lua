--- FluentWoW – Controls/Badge/Badge.lua
-- Compact status pill / badge indicator with severity coloring.
-- WinUI reference: N/A (Community Toolkit InfoBadge)
-- Appearances: Accent | Success | Warning | Error | Subtle
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion
local Tex = lib.Textures

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT

-------------------------------------------------------------------------------
-- Appearance token maps
-------------------------------------------------------------------------------

local APPEARANCES = {
    Accent  = { bg = "Color.Accent.Primary",   label = "Color.Text.OnAccent" },
    Success = { bg = "Color.Feedback.Success",  label = "Color.Text.OnAccent" },
    Warning = { bg = "Color.Feedback.Warning",  label = "Color.Text.Primary"  },
    Error   = { bg = "Color.Feedback.Error",    label = "Color.Text.OnAccent" },
    Subtle  = { bg = "Color.Surface.Elevated",  label = "Color.Text.Primary"  },
}

-------------------------------------------------------------------------------
-- Badge Mixin
-------------------------------------------------------------------------------

---@class FWoWBadge
local BadgeMixin = {}

function BadgeMixin:OnStateChanged(newState, prevState)
    local app = self._appearance or APPEARANCES.Accent

    self.BG:SetVertexColor(T:GetColor(app.bg))
    self.Label:SetTextColor(T:GetColor(app.label))
    if self.Icon:IsShown() then
        self.Icon:SetTextColor(T:GetColor(app.label))
    end

    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
end

---@param text string
function BadgeMixin:SetText(text)
    self.Label:SetText(text)
    self:_UpdateSize()
end

---@return string
function BadgeMixin:GetText()
    return self.Label:GetText() or ""
end

---@param icon string Fluent icon character
function BadgeMixin:SetIcon(icon)
    if icon and icon ~= "" then
        if ICON_FONT then
            self.Icon:SetFont(ICON_FONT, T:GetNumber("Icon.SM"), "")
        end
        self.Icon:SetText(icon)
        self.Icon:Show()
        self.Label:ClearAllPoints()
        self.Label:SetPoint("LEFT", self.Icon, "RIGHT", 4, 0)
        self.Label:SetPoint("RIGHT", -6, 0)
    else
        self.Icon:Hide()
        self.Label:ClearAllPoints()
        self.Label:SetPoint("CENTER")
    end
    self:_UpdateSize()
end

---@param name string "Accent"|"Success"|"Warning"|"Error"|"Subtle"
function BadgeMixin:SetAppearance(name)
    self._appearance = APPEARANCES[name] or APPEARANCES.Accent
    self:OnStateChanged(self._vsm:GetState())
end

function BadgeMixin:_UpdateSize()
    local labelW = self.Label:GetStringWidth() or 0
    local iconW = self.Icon:IsShown() and (T:GetNumber("Icon.SM") + 4) or 0
    local padding = 12 + iconW
    local w = math.max(labelW + padding, 20)
    self:SetWidth(w)
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWBadge_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, BadgeMixin)
    self:FWoWInit()
    self._appearance = APPEARANCES.Accent

    lib.SetupTexture(self.BG, Tex.BadgePill, 10)

    local font = T:Get("Typography.Caption")
    if font then
        self.Label:SetFont(font.font, font.size, font.flags)
    end
    self.Icon:Hide()

    self:OnStateChanged("Normal")
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@param appearance? string "Accent"|"Success"|"Warning"|"Error"|"Subtle"
---@return FWoWBadge
function lib:CreateBadge(parent, name, appearance)
    local f = CreateFrame("Frame", name, parent, "FWoWBadgeTemplate")
    ---@cast f FWoWBadge
    if appearance then
        f:SetAppearance(appearance)
    end
    return f
end
