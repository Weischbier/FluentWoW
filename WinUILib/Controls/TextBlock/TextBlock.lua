--- WinUILib – Controls/TextBlock/TextBlock.lua
-- Read-only text display with semantic typography variants.
-- Design ref: WinUI TextBlock, TextBox (read-only mode)
--
-- Variants: Body (default) | Display | Title | Caption
-- Wrapping: enabled by default; disable via :SetWrap(false)
--
-- Public API:
--   :SetText(text)
--   :GetText()
--   :SetVariant("Display"|"Title"|"Body"|"Caption")
--   :SetWrap(bool)
--   :SetJustify("LEFT"|"CENTER"|"RIGHT")
--   :SetTextColor(r, g, b, a)
-------------------------------------------------------------------------------

local lib = WinUILib
local T   = lib.Tokens

-- Typography variant → token key
local VARIANTS = {
    Display = "Display",
    Title   = "Title",
    Body    = "Body",
    Caption = "Caption",
}

-------------------------------------------------------------------------------
-- Shared init helper
-------------------------------------------------------------------------------

local function initTextBlock(self, variant)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.TextBlock)
    self:WUILInit()
    self._variant = variant or "Body"
    self:_ApplyVariant()
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILTextBlock_OnLoad(self)          initTextBlock(self, "Body") end
function WUILTextBlock_Display_OnLoad(self)  initTextBlock(self, "Display") end
function WUILTextBlock_Title_OnLoad(self)    initTextBlock(self, "Title") end
function WUILTextBlock_Caption_OnLoad(self)  initTextBlock(self, "Caption") end

-------------------------------------------------------------------------------
-- TextBlock mixin
-------------------------------------------------------------------------------

---@class WUILTextBlock : WUILControlBase
local TextBlock = {}
lib._controls.TextBlock = TextBlock

---@param text string
function TextBlock:SetText(text)
    local fs = _G[self:GetName() .. "_Text"]
    if fs then fs:SetText(text or "") end
end

---@return string
function TextBlock:GetText()
    local fs = _G[self:GetName() .. "_Text"]
    return fs and fs:GetText() or ""
end

---@param variant string  "Display"|"Title"|"Body"|"Caption"
function TextBlock:SetVariant(variant)
    self._variant = variant
    self:_ApplyVariant()
end

---@param wrap boolean
function TextBlock:SetWrap(wrap)
    local fs = _G[self:GetName() .. "_Text"]
    if fs then
        fs:SetWordWrap(wrap)
        -- Resize height to fit content when wrap is off
        if not wrap then
            self:SetHeight(fs:GetStringHeight() + 2)
        end
    end
end

---@param h string  "LEFT"|"CENTER"|"RIGHT"
function TextBlock:SetJustify(h)
    local fs = _G[self:GetName() .. "_Text"]
    if fs then fs:SetJustifyH(h) end
end

---@param r number  @param g number  @param b number  @param a number?
function TextBlock:SetTextColor(r, g, b, a)
    local fs = _G[self:GetName() .. "_Text"]
    if fs then fs:SetTextColor(r, g, b, a or 1) end
end

--- Applies the typography token to the underlying FontString.
function TextBlock:_ApplyVariant()
    local fs = _G[self:GetName() .. "_Text"]
    if not fs then return end
    local font, size, flags = T:GetFont(self._variant)
    fs:SetFont(font, size, flags)

    -- Semantic text colour per variant
    if self._variant == "Caption" then
        fs:SetTextColor(T:GetColor("Color.Text.Secondary"))
    elseif self._variant == "Display" or self._variant == "Title" then
        fs:SetTextColor(T:GetColor("Color.Text.Primary"))
    else
        fs:SetTextColor(T:GetColor("Color.Text.Primary"))
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

--- Creates a TextBlock frame.
---@param parent  Frame
---@param text    string?
---@param variant string?  "Display"|"Title"|"Body"|"Caption"
---@return Frame
function lib:CreateTextBlock(parent, text, variant)
    local template = "WUILTextBlockTemplate"
    if variant == "Display" then template = "WUILTextBlockDisplayTemplate"
    elseif variant == "Title"   then template = "WUILTextBlockTitleTemplate"
    elseif variant == "Caption" then template = "WUILTextBlockCaptionTemplate"
    end
    local tb = CreateFrame("Frame", nil, parent, template)
    if text then tb:SetText(text) end
    return tb
end
