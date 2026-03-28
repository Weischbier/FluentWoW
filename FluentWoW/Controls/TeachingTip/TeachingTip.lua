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
local _deferredRestore = {}
local _combatWatcher = CreateFrame("Frame")
local restoreParent

local function updateLayout(self)
    local card = self.Card
    local actionSlot = card.ActionSlot
    local title = card.TitleLabel
    local body = card.BodyLabel
    local actionHeight = 0

    title:SetWordWrap(true)
    body:SetWordWrap(true)

    if self._actionControl and actionSlot:IsShown() then
        actionHeight = math.max(actionSlot:GetHeight() or 0, self._actionControl:GetHeight() or 0)
        actionSlot:SetHeight(actionHeight)
    else
        actionSlot:SetHeight(1)
    end

    title:ClearAllPoints()
    title:SetPoint("TOPLEFT", card, "TOPLEFT", 16, -16)
    title:SetPoint("RIGHT", card.CloseBtn, "LEFT", -12, 0)

    body:ClearAllPoints()
    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    body:SetPoint("RIGHT", card, "RIGHT", -16, 0)
    if actionSlot:IsShown() then
        body:SetPoint("BOTTOM", actionSlot, "TOP", 0, 12)
    else
        body:SetPoint("BOTTOM", card, "BOTTOM", 0, 16)
    end

    local titleH = title:GetStringHeight() or 0
    local bodyH = body:GetStringHeight() or 0
    local totalH = 16 + titleH + 8 + bodyH + 16
    if actionSlot:IsShown() then
        totalH = totalH + 12 + actionHeight
    end

    self:SetHeight(math.max(totalH, 80))
end

local function flushDeferredRestores()
    for tip in pairs(_deferredRestore) do
        _deferredRestore[tip] = nil
        if tip then
            tip:Hide()
            restoreParent(tip)
            if tip._deferredCloseCallback and tip._onClosed then
                lib.Utils.SafeCall(tip._onClosed, tip)
            end
            tip._deferredCloseCallback = nil
        end
    end
    _combatWatcher:UnregisterEvent("PLAYER_REGEN_ENABLED")
    _combatWatcher:SetScript("OnEvent", nil)
end

local function queueRestore(tip, invokeCloseCallback)
    _deferredRestore[tip] = true
    tip._deferredCloseCallback = invokeCloseCallback == true
    _combatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
    _combatWatcher:SetScript("OnEvent", flushDeferredRestores)
end

local function attachToOverlay(self)
    if self:GetParent() ~= UIParent then
        self._originalParent = self:GetParent()
    end
    self._originalStrata = self._originalStrata or self:GetFrameStrata()
    self:SetParent(UIParent)
    self:SetFrameStrata("TOOLTIP")
end

restoreParent = function(self)
    if self._originalParent and self:GetParent() ~= self._originalParent then
        self:SetParent(self._originalParent)
    end
    if self._originalStrata then
        self:SetFrameStrata(self._originalStrata)
    end
end

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
        control:SetPoint("CENTER", self.Card.ActionSlot, "CENTER", 0, 0)
        self.Card.ActionSlot:Show()
        if not control._fwowTeachingTipLayoutHooked then
            control._fwowTeachingTipLayoutHooked = true
            control:HookScript("OnSizeChanged", function()
                self:_UpdateHeight()
            end)
        end
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

---@param fn function(self)
function TeachingTipMixin:SetOnClose(fn)
    self:SetOnClosed(fn)
end

---@param closable boolean
function TeachingTipMixin:SetClosable(closable)
    self.Card.CloseBtn:SetShown(closable ~= false)
    self:_UpdateHeight()
end

function TeachingTipMixin:Open()
    if InCombatLockdown() then
        lib:Debug("TeachingTip: blocked in combat")
        return
    end

    attachToOverlay(self)
    self:_Position()
    Mot:FadeIn(self)
end

function TeachingTipMixin:Close()
    if InCombatLockdown() then
        queueRestore(self, true)
        return
    end
    Mot:FadeOut(self, nil, function()
        restoreParent(self)
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
    updateLayout(self)
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
    self.Card.ActionSlot:Hide()
    self:HookScript("OnHide", function(frame)
        if InCombatLockdown() then
            queueRestore(frame)
            return
        end
        restoreParent(frame)
    end)
    self:HookScript("OnShow", function(frame)
        frame:_UpdateHeight()
    end)
    self:OnStateChanged("Normal")
    self:_UpdateHeight()
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
