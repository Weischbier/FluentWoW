--- WinUILib – Settings/SettingsCard.lua
-- Settings card: icon + title + description + trailing control slot.
-- Design ref: CommunityToolkit SettingsCard / WinUI SettingsCard
--
-- Public API:
--   :SetIcon(atlas, size?)
--   :SetTitle(text)
--   :SetDescription(text)
--   :SetControl(frame)    places a control in the right-side slot
--   :SetClickable(bool, callback)   makes the whole card clickable
-------------------------------------------------------------------------------

local lib = WinUILib
local Mot = lib.Motion

local HOVER_ALPHA = 0.04

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function WUILSettingsCard_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.SettingsCard)
    self:WUILInit()
    self._clickable = false
    self._control   = nil
    -- Hide icon by default (shown only when :SetIcon is called)
    local icon = _G[self:GetName() .. "_Icon"]
    if icon then icon:Hide() end
end

function WUILSettingsCard_OnEnter(self)
    if not self._clickable then return end
    local h = _G[self:GetName() .. "_Hover"]
    if h then h:SetAlpha(HOVER_ALPHA) end
end

function WUILSettingsCard_OnLeave(self)
    local h = _G[self:GetName() .. "_Hover"]
    if h then h:SetAlpha(0) end
end

-------------------------------------------------------------------------------
-- SettingsCard mixin
-------------------------------------------------------------------------------

---@class WUILSettingsCard : WUILControlBase
local SettingsCard = {}
lib._controls.SettingsCard = SettingsCard

---@param atlas string
---@param size  number?  default 20
function SettingsCard:SetIcon(atlas, size)
    local icon  = _G[self:GetName() .. "_Icon"]
    local iconBG = _G[self:GetName() .. "_IconBG"]
    if not icon then return end
    icon:SetAtlas(atlas)
    if size then icon:SetSize(size, size) end
    icon:Show()
    -- Widen the icon column
    if iconBG then iconBG:SetWidth(48) end
end

---@param text string
function SettingsCard:SetTitle(text)
    local t = _G[self:GetName() .. "_Title"]
    if t then t:SetText(text or "") end
end

---@param text string
function SettingsCard:SetDescription(text)
    local d = _G[self:GetName() .. "_Description"]
    if d then
        d:SetText(text or "")
        d:SetShown((text or "") ~= "")
        -- Auto-adjust card height
        local h = math.max(64, 44 + d:GetStringHeight() + 8)
        self:SetHeight(h)
    end
end

--- Places a pre-created control frame into the right-side slot.
---@param frame Frame
function SettingsCard:SetControl(frame)
    if self._control then
        self._control:ClearAllPoints()
    end
    self._control = frame
    if frame then
        local slot = _G[self:GetName() .. "_ControlSlot"]
        if slot then
            frame:SetParent(slot)
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", slot, "CENTER")
        end
    end
end

--- Makes the entire card surface clickable (e.g. navigates to a sub-page).
---@param clickable bool
---@param callback  function?  Receives the card as arg
function SettingsCard:SetClickable(clickable, callback)
    self._clickable  = clickable
    self._clickCB    = callback
    self:EnableMouse(true)
    if clickable then
        self:SetScript("OnMouseUp", function(s, btn)
            if btn == "LeftButton" and s._clickCB then
                Mot:ScalePress(s)
                lib.Utils.SafeCall(s._clickCB, s)
            end
        end)
    else
        self:SetScript("OnMouseUp", nil)
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent      Frame
---@param title       string?
---@param description string?
---@param control     Frame?
---@return Frame
function lib:CreateSettingsCard(parent, title, description, control)
    local card = CreateFrame("Frame", nil, parent, "WUILSettingsCardTemplate")
    if title       then card:SetTitle(title) end
    if description then card:SetDescription(description) end
    if control     then card:SetControl(control) end
    return card
end
