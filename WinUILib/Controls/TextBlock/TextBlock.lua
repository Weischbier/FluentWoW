--- WinUILib – Controls/TextBlock/TextBlock.lua
-- Read-only text label with token-driven typography.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/text-block
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class WUILTextBlock
local TextBlockMixin = {}

function TextBlockMixin:OnStateChanged(newState, prevState)
    if newState == "Disabled" then
        self.Label:SetTextColor(T:GetColor("Color.Text.Disabled"))
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
    else
        self:SetAlpha(1)
        local colorKey = self._colorKey or "Color.Text.Primary"
        self.Label:SetTextColor(T:GetColor(colorKey))
    end
end

---@param text string
function TextBlockMixin:SetText(text)
    self.Label:SetText(text)
    self:SetHeight(self.Label:GetStringHeight())
end

---@return string
function TextBlockMixin:GetText()
    return self.Label:GetText() or ""
end

---@param style string  "Display"|"Header"|"Title"|"Body"|"BodyBold"|"Caption"|"Mono"
function TextBlockMixin:SetStyle(style)
    self._typographyKey = style
    local font, size, flags = T:GetFont(style)
    self.Label:SetFont(font, size, flags)
    self:SetHeight(self.Label:GetStringHeight())
end

---@param key string token key for colour, e.g. "Color.Text.Secondary"
function TextBlockMixin:SetColorKey(key)
    self._colorKey = key
    self.Label:SetTextColor(T:GetColor(key))
end

---@param wrapping boolean
function TextBlockMixin:SetWrapping(wrapping)
    self.Label:SetWordWrap(wrapping)
    if wrapping then
        self:SetHeight(self.Label:GetStringHeight())
    end
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILTextBlock_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, TextBlockMixin)
    self:WUILInit()
    self._colorKey = "Color.Text.Primary"
    self._typographyKey = "Body"
    local font, size, flags = T:GetFont("Body")
    self.Label:SetFont(font, size, flags)
    self.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return WUILTextBlock
function lib:CreateTextBlock(parent, name)
    return CreateFrame("Frame", name, parent, "WUILTextBlockTemplate")
end
