--- WinUILib – Controls/Expander/Expander.lua
-- Collapsible section control with animated height reveal.
-- Design ref: WinUI Expander
--
-- Public API:
--   :SetHeader(text)
--   :SetExpanded(bool, animate?)
--   :IsExpanded()
--   :GetContentFrame()  → Frame (place child widgets here)
--   :SetContentHeight(n)
--   OnExpandedChanged(self, expanded)
-------------------------------------------------------------------------------

local lib = WinUILib
local Mot = lib.Motion

local HEADER_H    = 40
local EXPAND_DUR  = 0.20
local COLLAPSE_DUR = 0.15

-------------------------------------------------------------------------------
-- Script handler
-------------------------------------------------------------------------------

function WUILExpander_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.Expander)
    self:WUILInit()
    self._expanded     = false
    self._contentH     = 120
    self._animating    = false

    -- Make header area clickable
    local header = CreateFrame("Button", nil, self)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT")
    header:SetHeight(HEADER_H)
    header:EnableMouse(true)
    header:RegisterForClicks("LeftButtonUp")
    header:SetScript("OnClick", function()
        self:SetExpanded(not self._expanded, true)
    end)
    header:SetScript("OnEnter", function()
        local hbg = _G[self:GetName() .. "_HeaderBG"]
        if hbg then hbg:SetColorTexture(0.22, 0.22, 0.24, 1) end
    end)
    header:SetScript("OnLeave", function()
        local hbg = _G[self:GetName() .. "_HeaderBG"]
        if hbg then hbg:SetColorTexture(0.17, 0.17, 0.19, 1) end
    end)
    self._headerBtn = header

    -- Initial collapsed state
    local clip = _G[self:GetName() .. "_ContentClip"]
    if clip then
        clip:SetHeight(0)
        -- Stretch clip width to match container
        clip:SetPoint("TOPLEFT",  self, "TOPLEFT",  0, -HEADER_H)
        clip:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -HEADER_H)
    end
end

-------------------------------------------------------------------------------
-- Expander mixin
-------------------------------------------------------------------------------

---@class WUILExpander : WUILControlBase
local Expander = {}
lib._controls.Expander = Expander

---@param text string
function Expander:SetHeader(text)
    local ht = _G[self:GetName() .. "_HeaderTitle"]
    if ht then ht:SetText(text or "") end
end

--- Expands or collapses the content section.
---@param expanded boolean
---@param animate  boolean?  default true
function Expander:SetExpanded(expanded, animate)
    if self._expanded == expanded then return end
    self._expanded = expanded
    local clip     = _G[self:GetName() .. "_ContentClip"]
    if not clip then return end

    local targetH = expanded and self._contentH or 0
    local dur     = (animate ~= false) and (expanded and EXPAND_DUR or COLLAPSE_DUR) or 0

    if dur == 0 or Mot.reducedMotion then
        clip:SetHeight(targetH)
        self:SetHeight(HEADER_H + targetH)
        self:_UpdateChevron()
    else
        -- Animate height via OnUpdate
        local startH = clip:GetHeight()
        local elapsed = 0
        clip:SetScript("OnUpdate", function(c, dt)
            elapsed = elapsed + dt
            local t   = math.min(1, elapsed / dur)
            -- Simple ease-out
            local ease = 1 - (1 - t) * (1 - t)
            local h    = startH + (targetH - startH) * ease
            c:SetHeight(h)
            self:SetHeight(HEADER_H + h)
            if t >= 1 then
                c:SetScript("OnUpdate", nil)
                self:_UpdateChevron()
            end
        end)
    end

    if self.OnExpandedChanged then
        lib.Utils.SafeCall(self.OnExpandedChanged, self, expanded)
    end
end

---@return boolean
function Expander:IsExpanded()
    return self._expanded == true
end

--- Returns the inner content Frame where child widgets should be placed.
---@return Frame
function Expander:GetContentFrame()
    return _G[self:GetName() .. "_Content"]
end

--- Sets the height of the content area when fully expanded.
---@param h number
function Expander:SetContentHeight(h)
    self._contentH = h
    local content = _G[self:GetName() .. "_Content"]
    if content then content:SetHeight(h) end
    if self._expanded then
        local clip = _G[self:GetName() .. "_ContentClip"]
        if clip then clip:SetHeight(h) end
        self:SetHeight(HEADER_H + h)
    end
end

function Expander:_UpdateChevron()
    local ch = _G[self:GetName() .. "_Chevron"]
    if not ch then return end
    -- Tint chevron to accent when expanded
    if self._expanded then
        ch:SetColorTexture(0.05, 0.55, 0.88, 1)
    else
        ch:SetColorTexture(0.68, 0.68, 0.72, 1)
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent        Frame
---@param headerText    string?
---@param contentHeight number?
---@return Frame
function lib:CreateExpander(parent, headerText, contentHeight)
    local ex = CreateFrame("Frame", nil, parent, "WUILExpanderTemplate")
    if headerText    then ex:SetHeader(headerText) end
    if contentHeight then ex:SetContentHeight(contentHeight) end
    return ex
end
