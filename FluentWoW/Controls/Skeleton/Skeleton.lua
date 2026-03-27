--- FluentWoW – Controls/Skeleton/Skeleton.lua
-- Animated shimmer placeholder for loading states.
-- Inspired by WinUI Shimmer / Skeleton loading patterns.
-- States: Normal | Disabled
-------------------------------------------------------------------------------

local lib = FluentWoW
local T   = lib.Tokens
local Mot = lib.Motion

-------------------------------------------------------------------------------
-- Skeleton Mixin
-------------------------------------------------------------------------------

---@class FWoWSkeleton
local SkeletonMixin = {}

function SkeletonMixin:OnStateChanged(newState, prevState)
    self.BG:SetColorTexture(T:GetColor("Color.Surface.Stroke"))

    local sr, sg, sb = T:GetColor("Color.Surface.Elevated")
    self.Shimmer:SetColorTexture(sr, sg, sb, 0.40)

    if newState == "Disabled" then
        self:SetAlpha(T:GetNumber("Opacity.Disabled"))
        self:_StopShimmer()
    else
        self:SetAlpha(1)
        if self._active then self:_StartShimmer() end
    end
end

---@param active boolean
function SkeletonMixin:SetActive(active)
    self._active = active
    if active then
        self:Show()
        self:_StartShimmer()
    else
        self:_StopShimmer()
        self:Hide()
    end
end

---@return boolean
function SkeletonMixin:IsActive()
    return self._active == true
end

---@param shape string "rect"|"circle"|"line"
function SkeletonMixin:SetShape(shape)
    self._shape = shape
    -- Circle: make it square and use approximate visual (WoW has no native round mask)
    if shape == "circle" then
        local size = math.min(self:GetWidth(), self:GetHeight())
        self:SetSize(size, size)
    end
end

function SkeletonMixin:_StartShimmer()
    if self._shimmerRunning then return end
    if Mot.reducedMotion then return end
    self._shimmerRunning = true
    self._shimmerPhase = 0

    local totalW = self:GetWidth()
    local shimmerW = math.max(totalW * 0.4, 40)
    self.Shimmer:SetWidth(shimmerW)

    self:SetScript("OnUpdate", function(_, elapsed)
        self._shimmerPhase = self._shimmerPhase + elapsed
        local duration = T:GetNumber("Motion.Duration.Slow") * 4
        if duration <= 0 then duration = 1.4 end
        local pct = (self._shimmerPhase % duration) / duration

        local startX = -shimmerW
        local endX = totalW
        local currentX = startX + pct * (endX - startX)

        self.Shimmer:ClearAllPoints()
        self.Shimmer:SetPoint("TOPLEFT", self, "TOPLEFT", currentX, 0)
        self.Shimmer:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", currentX, 0)
    end)
end

function SkeletonMixin:_StopShimmer()
    if not self._shimmerRunning then return end
    self._shimmerRunning = false
    self:SetScript("OnUpdate", nil)
end

-------------------------------------------------------------------------------
-- Script handlers
-------------------------------------------------------------------------------

function FWoWSkeleton_OnLoad(self)
    Mixin(self, lib._controls.ControlBase, SkeletonMixin)
    self:FWoWInit()
    self._active = true
    self._shimmerRunning = false
    self._shimmerPhase = 0
    self._shape = "rect"

    self:SetClipsChildren(true)
    self:OnStateChanged("Normal")
    self:_StartShimmer()
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param name? string
---@param shape? string "rect"|"circle"|"line"
---@return FWoWSkeleton
function lib:CreateSkeleton(parent, name, shape)
    local f = CreateFrame("Frame", name, parent, "FWoWSkeletonTemplate")
    ---@cast f FWoWSkeleton
    if shape then
        f:SetShape(shape)
    end
    return f
end
