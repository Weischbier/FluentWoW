--- WinUILib – Settings/SettingsCard.lua
-- Settings card control — mirrors WCT SettingsCard.
-- Icon + title + description + trailing action control slot.
--
-- Pixel-fidelity: DesignSpecs §2.1, settings.instructions.md
--   Card padding: 12px top, 16px L/R/B
--   Icon-to-subtitle: 12px, action icon-to-text: 8px
--
-- States: Normal | Hover | Pressed | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILSettingsCard
local CardMixin = {}

local function applyVisuals(self, state)
    state = state or self:GetState()

    local bgKey = "Color.Surface.Raised"
    if state == "Pressed"  then bgKey = "Color.Surface.Elevated"
    elseif state == "Disabled" then bgKey = "Color.Surface.Raised" end

    self.BG:SetColorTexture(T:GetColor(bgKey))
    self.Border:SetColorTexture(T:GetColor("Color.Border.Subtle"))

    -- Hover overlay
    if state == "Hover" then
        self.Hover:SetColorTexture(T:GetColor("Color.Overlay.Hover"))
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
end

---@param text string
function CardMixin:SetDescription(text)
    if text and text ~= "" then
        self.DescLabel:SetText(text)
        self.DescLabel:Show()
        -- Expand height for two-line card
        local padT  = T:GetNumber("Spacing.LG")   -- 12
        local gap   = T:GetNumber("Spacing.XS")    -- 2
        local padB  = T:GetNumber("Spacing.XL")    -- 16
        local h = padT + self.TitleLabel:GetStringHeight() + gap + self.DescLabel:GetStringHeight() + padB
        local minH = padT + self.TitleLabel:GetStringHeight() + padB
        self:SetHeight(math.max(minH, h))
    else
        self.DescLabel:Hide()
        local padT = T:GetNumber("Spacing.LG")
        local padB = T:GetNumber("Spacing.XL")
        self:SetHeight(padT + self.TitleLabel:GetStringHeight() + padB)
    end
end

---@param path string|number  texture path or fileID
function CardMixin:SetIconTexture(path)
    if path then
        self.Icon:SetTexture(path)
        self.Icon:Show()
    else
        self.Icon:Hide()
        -- Re-anchor title to left edge
        self.TitleLabel:ClearAllPoints()
        self.TitleLabel:SetPoint("TOPLEFT", self, "TOPLEFT", T:GetNumber("Spacing.XL"), -T:GetNumber("Spacing.LG"))
        self.TitleLabel:SetPoint("RIGHT", self.Action, "LEFT", -T:GetNumber("Spacing.MD"), 0)
    end
end

---@param control Frame  any WinUILib control (ToggleSwitch, ComboBox, Button, etc.)
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
        control:Show()
    end
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

function WUILSettingsCard_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, CardMixin)
    self:WUILInit()
    self._clickable = false
    self._actionControl = nil

    -- Typography
    local titleFont = T:Get("Typography.Body")
    if titleFont then
        self.TitleLabel:SetFont(titleFont.font, titleFont.size, titleFont.flags)
    end
    local descFont = T:Get("Typography.Caption")
    if descFont then
        self.DescLabel:SetFont(descFont.font, descFont.size, descFont.flags)
    end

    applyVisuals(self)

    self._themeListener = function() applyVisuals(self) end
    lib.EventBus:On("ThemeChanged", self._themeListener)
end

function WUILSettingsCard_OnEnter(self)
    if not self._enabled then return end
    self._vsm:SetState("Hover")
end

function WUILSettingsCard_OnLeave(self)
    if not self._enabled then return end
    self._vsm:SetState("Normal")
end

function WUILSettingsCard_OnMouseDown(self)
    if not self._enabled or not self._clickable then return end
    self._vsm:SetState("Pressed")
end

function WUILSettingsCard_OnMouseUp(self)
    if not self._enabled or not self._clickable then return end
    self._vsm:SetState("Normal")
    if self._onClick then lib.Utils.SafeCall(self._onClick, self) end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return WUILSettingsCard
function lib:CreateSettingsCard(parent, name)
    return CreateFrame("Frame", name, parent, "WUILSettingsCardTemplate")
end
