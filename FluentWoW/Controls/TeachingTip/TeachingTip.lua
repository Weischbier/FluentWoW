--- FluentWoW – Controls/TeachingTip/TeachingTip.lua
-- Contextual teaching callout / coach mark attached to a target element.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/dialogs-and-flyouts/teaching-tip
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

local Icons    = lib.Icons
local ICON_FONT = lib.FLUENT_ICON_FONT
local Tex = lib.Textures

-------------------------------------------------------------------------------
-- TeachingTip Mixin
-------------------------------------------------------------------------------

---@class FWoWTeachingTip
local TeachingTipMixin = {}

function TeachingTipMixin:OnStateChanged(newState, prevState)
    local card = self.Card
    card.BG:SetVertexColor(T:GetColor("Color.Surface.Elevated"))
    card.Border:SetVertexColor(T:GetColor("Color.Border.Subtle"))
    card.TitleLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
    card.BodyLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
    card.CloseBtn.X:SetTextColor(T:GetColor("Color.Text.Secondary"))
    self.Arrow.Tex:SetVertexColor(T:GetColor("Color.Surface.Elevated"))

    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
end

---@param title string
function TeachingTipMixin:SetTitle(title)
    self.Card.TitleLabel:SetText(title)
    self:_UpdateHeight()
end

---@return string
function TeachingTipMixin:GetTitle()
    return self.Card.TitleLabel:GetText() or ""
end

---@param body string
function TeachingTipMixin:SetBody(body)
    self.Card.BodyLabel:SetText(body)
    self:_UpdateHeight()
end

---@return string
function TeachingTipMixin:GetBody()
    return self.Card.BodyLabel:GetText() or ""
end

---@param control Frame action button or other control
function TeachingTipMixin:SetActionControl(control)
    self._actionControl = control
    if control then
        control:SetParent(self.Card.ActionSlot)
        control:ClearAllPoints()
        control:SetPoint("LEFT", self.Card.ActionSlot, "LEFT", 0, 0)
        self.Card.ActionSlot:Show()
    else
        self.Card.ActionSlot:Hide()
    end
    self:_UpdateHeight()
end

---@param target Frame the frame to attach to
---@param placement? string "TOP"|"BOTTOM"|"LEFT"|"RIGHT" (default: "BOTTOM")
function TeachingTipMixin:SetTarget(target, placement)
    self._target = target
    self._placement = placement or "BOTTOM"
end

---@param fn function(self)
function TeachingTipMixin:SetOnClosed(fn)
    self._onClosed = fn
end

---@param closable boolean
function TeachingTipMixin:SetClosable(closable)
    self.Card.CloseBtn:SetShown(closable ~= false)
end

function TeachingTipMixin:Open()
    if InCombatLockdown() then
        lib:Debug("TeachingTip: blocked in combat")
        return
    end

    self:_Position()
    Mot:FadeIn(self)
end

function TeachingTipMixin:Close()
    Mot:FadeOut(self, nil, function()
        if self._onClosed then
            lib.Utils.SafeCall(self._onClosed, self)
        end
    end)
end

function TeachingTipMixin:_Position()
    if not self._target then
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER")
        self.Arrow:Hide()
        return
    end

    self:ClearAllPoints()
    self.Arrow:Show()
    local gap = T:GetNumber("Spacing.MD")
    local placement = self._placement or "BOTTOM"

    if placement == "BOTTOM" then
        self:SetPoint("TOP", self._target, "BOTTOM", 0, -gap)
        self.Arrow:ClearAllPoints()
        self.Arrow:SetPoint("BOTTOM", self.Card, "TOP", 0, 0)
        self.Arrow:SetSize(16, 8)
    elseif placement == "TOP" then
        self:SetPoint("BOTTOM", self._target, "TOP", 0, gap)
        self.Arrow:ClearAllPoints()
        self.Arrow:SetPoint("TOP", self.Card, "BOTTOM", 0, 0)
        self.Arrow:SetSize(16, 8)
    elseif placement == "LEFT" then
        self:SetPoint("RIGHT", self._target, "LEFT", -gap, 0)
        self.Arrow:ClearAllPoints()
        self.Arrow:SetPoint("LEFT", self.Card, "RIGHT", 0, 0)
        self.Arrow:SetSize(8, 16)
    elseif placement == "RIGHT" then
        self:SetPoint("LEFT", self._target, "RIGHT", gap, 0)
        self.Arrow:ClearAllPoints()
        self.Arrow:SetPoint("RIGHT", self.Card, "LEFT", 0, 0)
        self.Arrow:SetSize(8, 16)
    end
end

function TeachingTipMixin:_UpdateHeight()
    local titleH = self.Card.TitleLabel:GetStringHeight() or 0
    local bodyH = self.Card.BodyLabel:GetStringHeight() or 0
    local actionH = self.Card.ActionSlot:IsShown() and (self.Card.ActionSlot:GetHeight() + T:GetNumber("Spacing.XL")) or 0
    local padding = 16 + 16 + 8  -- top + bottom + gap between title and body
    local totalH = math.max(padding + titleH + bodyH + actionH, 80)
    self:SetHeight(totalH)
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWTeachingTip_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, TeachingTipMixin)
    self._FWoWControlType = "FWoWTeachingTip"
    self:FWoWInit()
    self._placement = "BOTTOM"
    lib.SetupTexture(self.Card.BG, Tex.RR8, 8)
    lib.SetupTexture(self.Card.Border, Tex.RR8_Border, 8)
    self.Arrow.Tex:SetTexture(Tex.ArrowUp)
    self:OnStateChanged("Normal")
end

function FWoWTeachingTip_Close_OnClick(self)
    local tip = self:GetParent():GetParent()
    tip:Close()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent? Frame defaults to UIParent
---@param name? string
---@return FWoWTeachingTip
function lib:CreateTeachingTip(parent, name)
    local f = CreateFrame("Frame", name, parent or UIParent, "FWoWTeachingTipTemplate")
    ---@cast f FWoWTeachingTip
    return f
end
