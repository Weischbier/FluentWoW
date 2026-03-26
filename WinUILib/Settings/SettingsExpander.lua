--- WinUILib – Settings/SettingsExpander.lua
-- Expandable settings group header that stacks nested SettingsCard items.
-- Design ref: CommunityToolkit SettingsExpander
--
-- Public API:
--   Inherits all SettingsCard API, plus:
--   :AddItem(settingsCardFrame)
--   :SetExpanded(bool, animate?)
--   :IsExpanded()
-------------------------------------------------------------------------------

local lib = WinUILib

local HEADER_H  = 64
local ITEM_GAP  = 1     -- 1px separator between nested cards
local EXPAND_DUR   = 0.20
local COLLAPSE_DUR = 0.15

-------------------------------------------------------------------------------
-- Script handler
-------------------------------------------------------------------------------

function WUILSettingsExpander_OnLoad(self)
    -- Call parent init
    WUILSettingsCard_OnLoad(self)
    Mixin(self, lib._controls.SettingsExpander)
    self._expanded  = false
    self._items     = {}
    self._childH    = 0

    -- Make header row clickable to toggle
    self:SetClickable(true, function(s) s:SetExpanded(not s._expanded, true) end)
end

-------------------------------------------------------------------------------
-- SettingsExpander mixin
-------------------------------------------------------------------------------

---@class WUILSettingsExpander : WUILSettingsCard
local SettingsExpander = {}
lib._controls.SettingsExpander = SettingsExpander

--- Appends a SettingsCard (or any Frame) as a nested item.
---@param frame Frame
function SettingsExpander:AddItem(frame)
    local children = _G[self:GetName() .. "_Children"]
    if not children then return end

    table.insert(self._items, frame)
    frame:SetParent(children)
    frame:ClearAllPoints()

    -- Stack vertically
    local yOff = 0
    for i, item in ipairs(self._items) do
        item:ClearAllPoints()
        item:SetPoint("TOPLEFT",  children, "TOPLEFT",  0, -yOff)
        item:SetPoint("TOPRIGHT", children, "TOPRIGHT", 0, -yOff)
        yOff = yOff + (item:GetHeight() or 64) + ITEM_GAP
    end
    self._childH = yOff
    children:SetHeight(math.max(1, yOff))

    -- If expanded, update container height
    if self._expanded then
        self:_ApplyExpandedHeight()
    end
end

---@param expanded boolean
---@param animate  boolean?  default true
function SettingsExpander:SetExpanded(expanded, animate)
    if self._expanded == expanded then return end
    self._expanded = expanded

    local clip = _G[self:GetName() .. "_ChildrenClip"]
    if not clip then return end

    local targetH = expanded and self._childH or 0
    local dur     = (animate ~= false)
                    and (expanded and EXPAND_DUR or COLLAPSE_DUR)
                    or 0

    -- Update chevron tint
    local ch = _G[self:GetName() .. "_ExpandChevron"]
    if ch then
        if expanded then
            ch:SetColorTexture(0.05, 0.55, 0.88, 1)
        else
            ch:SetColorTexture(0.68, 0.68, 0.72, 1)
        end
    end

    if dur == 0 or lib.Motion.reducedMotion then
        clip:SetHeight(targetH)
        self:SetHeight(HEADER_H + targetH)
    else
        local startH  = clip:GetHeight()
        local elapsed = 0
        clip:SetScript("OnUpdate", function(c, dt)
            elapsed = elapsed + dt
            local t    = math.min(1, elapsed / dur)
            local ease = 1 - (1 - t) * (1 - t)
            local h    = startH + (targetH - startH) * ease
            c:SetHeight(h)
            self:SetHeight(HEADER_H + h)
            if t >= 1 then c:SetScript("OnUpdate", nil) end
        end)
    end
end

---@return boolean
function SettingsExpander:IsExpanded()
    return self._expanded == true
end

function SettingsExpander:_ApplyExpandedHeight()
    local clip = _G[self:GetName() .. "_ChildrenClip"]
    if clip then
        clip:SetHeight(self._childH)
        self:SetHeight(HEADER_H + self._childH)
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent      Frame
---@param title       string?
---@param description string?
---@return Frame
function lib:CreateSettingsExpander(parent, title, description)
    local se = CreateFrame("Frame", nil, parent, "WUILSettingsExpanderTemplate")
    if title       then se:SetTitle(title) end
    if description then se:SetDescription(description) end
    return se
end
