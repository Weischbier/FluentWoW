--- WinUILib – Controls/ContentDialog/ContentDialog.lua
-- Modal dialog with title, body, primary/secondary buttons, and overlay.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/dialogs-and-flyouts/dialogs
-- Pixel-fidelity: DesignSpecs §2.2 — title top 32px, title-body 24px,
--   button row bottom 24px, inter-button 8px.
-- States: Normal | Disabled
-- COMBAT SAFE: Show() blocked during InCombatLockdown (Rule #2, #4).
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILContentDialog
local DialogMixin = {}

function DialogMixin:OnStateChanged(newState, prevState)
    -- dialog visuals are mostly static; just handle overlay colors
end

function DialogMixin:_ApplyTokens()
    self.Overlay:SetColorTexture(T:GetColor("Color.Overlay.Dialog"))
    self.Card.BG:SetColorTexture(T:GetColor("Color.Surface.Overlay"))
    self.Card.TitleLabel:SetTextColor(T:GetColor("Color.Text.Primary"))
    self.Card.BodyLabel:SetTextColor(T:GetColor("Color.Text.Secondary"))
    self.Card.CloseBtn.X:SetTextColor(T:GetColor("Color.Text.Secondary"))
end

---@param title string
function DialogMixin:SetTitle(title)
    self.Card.TitleLabel:SetText(title)
end

---@param body string
function DialogMixin:SetBody(body)
    self.Card.BodyLabel:SetText(body)
    self.Card.BodyLabel:SetWordWrap(true)
end

---@param text string
---@param callback? function
function DialogMixin:SetPrimaryButton(text, callback)
    self.Card.ButtonRow.PrimaryBtn:SetText(text)
    self._primaryCallback = callback
    self.Card.ButtonRow.PrimaryBtn:SetOnClick(function()
        if callback then lib.Utils.SafeCall(callback) end
        self:Close("Primary")
    end)
end

---@param text string
---@param callback? function
function DialogMixin:SetSecondaryButton(text, callback)
    self.Card.ButtonRow.SecondaryBtn:SetText(text)
    self._secondaryCallback = callback
    self.Card.ButtonRow.SecondaryBtn:SetOnClick(function()
        if callback then lib.Utils.SafeCall(callback) end
        self:Close("Secondary")
    end)
end

---@param closable boolean
function DialogMixin:SetClosable(closable)
    self._closable = closable
    if closable then
        self.Card.CloseBtn:Show()
    else
        self.Card.CloseBtn:Hide()
    end
end

---@param dismissOnOverlay boolean
function DialogMixin:SetDismissOnOverlay(dismissOnOverlay)
    self._dismissOnOverlay = dismissOnOverlay
end

---@param fn function  receives (self, result) where result = "Primary"|"Secondary"|"Close"|"Overlay"
function DialogMixin:SetOnClosed(fn)
    self._onClosed = fn
end

function DialogMixin:Open()
    if InCombatLockdown() then
        lib:Debug("ContentDialog: blocked in combat")
        return
    end
    self:_ApplyTokens()
    self.Overlay:SetAlpha(0)
    Mot:FadeIn(self.Overlay)
    Mot:SlideIn(self.Card, "UP", T:GetNumber("Spacing.XL"))
end

---@param result? string
function DialogMixin:Close(result)
    result = result or "Close"
    Mot:FadeOut(self, nil, function()
        if self._onClosed then
            lib.Utils.SafeCall(self._onClosed, self, result)
        end
    end)
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILContentDialog_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, DialogMixin)
    self:WUILInit()
    self._closable = true
    self._dismissOnOverlay = false
    self:_ApplyTokens()
end

function WUILContentDialog_OnCloseClick(self)
    local dialog = self:GetParent():GetParent()
    if dialog._closable then
        dialog:Close("Close")
    end
end

function WUILContentDialog_OnOverlayClick(self)
    if self._dismissOnOverlay then
        self:Close("Overlay")
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent? Frame  defaults to UIParent
---@param name? string
---@return WUILContentDialog
function lib:CreateContentDialog(parent, name)
    local f = CreateFrame("Frame", name, parent or UIParent, "WUILContentDialogTemplate")
    ---@cast f WUILContentDialog
    return f
end
