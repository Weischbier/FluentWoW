--- FluentWoW – Controls/TextBlock/TextBlock.lua
-- Read-only text label with token-driven typography.
-- WinUI reference: https://learn.microsoft.com/windows/apps/design/controls/text-block
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens

local function refreshHeight(self)
    if self._refreshingHeight then return end

    self._refreshingHeight = true
    self:SetHeight(math.max(1, self.Label:GetStringHeight() or 0))
    self._refreshingHeight = false
end

-------------------------------------------------------------------------------
-- Mixin
-------------------------------------------------------------------------------

---@class FWoWTextBlock
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
    refreshHeight(self)
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
    refreshHeight(self)
end

---@param key string token key for colour, e.g. "Color.Text.Secondary"
function TextBlockMixin:SetColorKey(key)
    self._colorKey = key
    self.Label:SetTextColor(T:GetColor(key))
end

---@param wrapping boolean
function TextBlockMixin:SetWrapping(wrapping)
    self._wrapping = wrapping == true
    self.Label:SetWordWrap(wrapping)
    refreshHeight(self)
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWTextBlock_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, TextBlockMixin)
    self:FWoWInit()
    self._colorKey = "Color.Text.Primary"
    self._typographyKey = "Body"
    self._wrapping = false
    self._refreshingHeight = false
    local font, size, flags = T:GetFont("Body")
    self.Label:SetFont(font, size, flags)
    self.Label:SetTextColor(T:GetColor("Color.Text.Primary"))
    self:HookScript("OnSizeChanged", function(frame, width)
        if frame._wrapping and width and width > 0 then
            refreshHeight(frame)
        end
    end)
    refreshHeight(self)
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@return FWoWTextBlock
function lib:CreateTextBlock(parent, name)
    local f = CreateFrame("Frame", name, parent, "FWoWTextBlockTemplate")
    ---@cast f FWoWTextBlock
    return f
end
