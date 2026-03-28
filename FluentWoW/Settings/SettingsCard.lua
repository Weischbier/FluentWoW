--- FluentWoW – Settings/SettingsCard.lua
-- Settings card control — mirrors WCT SettingsCard.
-- Icon + title + description + trailing action control slot.
--
-- Pixel-fidelity: DesignSpecs §2.1, settings.instructions.md
--   Card padding: 12px top, 16px L/R/B
--   Icon-to-subtitle: 12px, action icon-to-text: 8px
--
-- States: Normal | Hover | Pressed | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Tex = lib.Textures

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class FWoWSettingsCard
local CardMixin = {}

local function registerThemeListener(self)
    if self._themeListenerRegistered or not self._themeListener then return end
    lib.EventBus:On("ThemeChanged", self._themeListener)
    self._themeListenerRegistered = true
end

local function unregisterThemeListener(self)
    if not self._themeListenerRegistered or not self._themeListener then return end
    lib.EventBus:Off("ThemeChanged", self._themeListener)
    self._themeListenerRegistered = false
end

local function updateLayout(self)
    if self._updatingLayout then return end
    self._updatingLayout = true

    local actionMinWidth = self._actionControl and T:GetNumber("Spacing.XXXL") or 0
    local actionWidth = 0
    local actionHeight = 0

    if self._actionControl then
        actionWidth = math.max(actionMinWidth, self._actionControl:GetWidth())
        actionHeight = self._actionControl:GetHeight() or 0
    end

    self.Action:SetWidth(actionWidth)
    self.Action:SetHeight(math.max(32, actionHeight))
    self.TitleLabel:SetWordWrap(true)
    self.DescLabel:SetWordWrap(true)

    self.TitleLabel:ClearAllPoints()
    if self.Icon:IsShown() then
        self.TitleLabel:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", T:GetNumber("Spacing.LG"), 0)
    else
        self.TitleLabel:SetPoint("TOPLEFT", self, "TOPLEFT", T:GetNumber("Spacing.XL"), -T:GetNumber("Spacing.LG"))
    end
    if actionWidth > 0 then
        self.TitleLabel:SetPoint("RIGHT", self.Action, "LEFT", -T:GetNumber("Spacing.XL"), 0)
    else
        self.TitleLabel:SetPoint("RIGHT", self, "RIGHT", -T:GetNumber("Spacing.XL"), 0)
    end

    self.DescLabel:ClearAllPoints()
    self.DescLabel:SetPoint("TOPLEFT", self.TitleLabel, "BOTTOMLEFT", 0, -T:GetNumber("Spacing.LG"))
    self.DescLabel:SetPoint("RIGHT", self.TitleLabel, "RIGHT", 0, 0)

    local padTop = T:GetNumber("Spacing.LG")
    local padBottom = T:GetNumber("Spacing.XL")
    local gap = self.DescLabel:IsShown() and T:GetNumber("Spacing.LG") or 0
    local titleHeight = self.TitleLabel:GetStringHeight() or 0
    local descHeight = self.DescLabel:IsShown() and (self.DescLabel:GetStringHeight() or 0) or 0
    local textHeight = titleHeight + gap + descHeight
    local iconHeight = self.Icon:IsShown() and (self.Icon:GetHeight() or 20) or 0
    local desiredHeight = math.max(52, padTop + math.max(textHeight, iconHeight, actionHeight) + padBottom)

    if math.abs((self:GetHeight() or 0) - desiredHeight) > 0.5 then
        self:SetHeight(desiredHeight)
    end

    self._updatingLayout = false
end

local function applyVisuals(self, state)
    state = state or self:GetState()

    local bgKey = "Color.Surface.Raised"
    if state == "Pressed"  then bgKey = "Color.Surface.Elevated"
    elseif state == "Disabled" then bgKey = "Color.Surface.Raised" end

    self.BG:SetVertexColor(T:GetColor(bgKey))
    self.Border:SetVertexColor(T:GetColor("Color.Border.Subtle"))

    -- Hover overlay
    if state == "Hover" then
        self.Hover:SetVertexColor(T:GetColor("Color.Overlay.Hover"))
        self.Hover:Show()
    else
        self.Hover:Hide()
    end

    -- Text
    local titleKey = state == "Disabled" and "Color.Text.Disabled" or "Color.Text.Primary"
    local descKey  = state == "Disabled" and "Color.Text.Disabled" or "Color.Text.Secondary"
    self.TitleLabel:SetTextColor(T:GetColor(titleKey))
    if self.DescLabel:IsShown() then
        self.DescLabel:SetTextColor(T:GetColor(descKey))
    end

    -- Icon tint
    if self.Icon:IsShown() then
        local iconKey = state == "Disabled" and "Color.Icon.Disabled" or "Color.Icon.Default"
        self.Icon:SetVertexColor(T:GetColor(iconKey))
    end

    -- Opacity
    if state == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
    end
end

function CardMixin:OnStateChanged(newState, prevState)
    applyVisuals(self, newState)
end

-------------------------------------------------------------------------------
-- Public API (stability-critical — see settings.instructions.md)
-------------------------------------------------------------------------------

---@param text string
function CardMixin:SetTitle(text)
    self.TitleLabel:SetText(text or "")
    updateLayout(self)
end

---@param text string
function CardMixin:SetDescription(text)
    if text and text ~= "" then
        self.DescLabel:SetText(text)
        self.DescLabel:Show()
    else
        self.DescLabel:Hide()
    end
    updateLayout(self)
end

---@param path string|number  texture path or fileID
function CardMixin:SetIconTexture(path)
    if path then
        self.Icon:SetTexture(path)
        self.Icon:Show()
    else
        self.Icon:Hide()
    end
    updateLayout(self)
end

---@param control Frame  any FluentWoW control (ToggleSwitch, ComboBox, Button, etc.)
function CardMixin:SetActionControl(control)
    if self._actionControl then
        self._actionControl:ClearAllPoints()
        self._actionControl:SetParent(nil)
    end
    self._actionControl = control
    if control then
        control:SetParent(self.Action)
        control:ClearAllPoints()
        control:SetPoint("RIGHT", self.Action, "RIGHT")
        control:SetPoint("CENTER", self.Action, "CENTER", 0, 0)
        control:Show()
        if not control._fwowSettingsCardLayoutHooked then
            control._fwowSettingsCardLayoutHooked = true
            control:HookScript("OnSizeChanged", function()
                updateLayout(self)
            end)
        end
    end
    updateLayout(self)
end

---@return Frame|nil
function CardMixin:GetActionControl()
    return self._actionControl
end

---@param clickable boolean
function CardMixin:SetClickable(clickable)
    self._clickable = clickable
    self:EnableMouse(clickable)
end

---@param callback function(self)
function CardMixin:SetOnClick(callback)
    self._onClick = callback
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWSettingsCard_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, CardMixin)
    self:FWoWInit()
    self._clickable = false
    self._actionControl = nil
    self._updatingLayout = false
    self._themeListenerRegistered = false

    lib.SetupTexture(self.BG, Tex.RR4, 4)
    lib.SetupTexture(self.Border, Tex.RR4_Border, 4)
    lib.SetupTexture(self.Hover, Tex.RR4, 4)

    -- Typography
    local titleFont = T:Get("Typography.Body")
    if titleFont then
        self.TitleLabel:SetFont(titleFont.font, titleFont.size, titleFont.flags)
    end
    local descFont = T:Get("Typography.Caption")
    if descFont then
        self.DescLabel:SetFont(descFont.font, descFont.size, descFont.flags)
    end

    updateLayout(self)

    applyVisuals(self)

    self._themeListener = function() applyVisuals(self) end
    registerThemeListener(self)
    self:HookScript("OnShow", function(frame)
        registerThemeListener(frame)
        applyVisuals(frame)
    end)
    self:HookScript("OnHide", function(frame)
        unregisterThemeListener(frame)
    end)
    self:HookScript("OnSizeChanged", function(frame)
        updateLayout(frame)
    end)
end

function FWoWSettingsCard_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
end

function FWoWSettingsCard_OnLeave(self)
    if not self._enabled then return end
    self._vsm:SetState("Normal")
end

function FWoWSettingsCard_OnMouseDown(self)
    if not self._enabled or not self._clickable then return end
    self._vsm:SetState("Pressed")
end

function FWoWSettingsCard_OnMouseUp(self)
    if not self._enabled or not self._clickable then return end
    self._vsm:SetState("Normal")
    if self._onClick then lib.Utils.SafeCall(self._onClick, self) end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWSettingsCard
function lib:CreateSettingsCard(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWSettingsCardTemplate")
    ---@cast f FWoWSettingsCard
    return f
end
