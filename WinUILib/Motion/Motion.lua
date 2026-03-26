--- WinUILib – Motion/Motion.lua
-- Thin wrapper over WoW's animation API.
-- Provides named presets aligned with the token Motion.Duration / Motion.Easing
-- tables so controls animate consistently without magic numbers.
--
-- Usage:
--   WinUILib.Motion:FadeIn(frame, 0.20)
--   WinUILib.Motion:FadeOut(frame, 0.15, function() frame:Hide() end)
--   WinUILib.Motion:SlideIn(frame, "UP", 8, 0.25)
--   WinUILib.Motion:ScalePress(frame)
--   WinUILib.Motion:Stop(frame)
--
-- All functions are safe to call in combat (they only manipulate frame
-- animations, not secure protected frames).
-------------------------------------------------------------------------------

local lib = WinUILib

local Motion = {}
lib:RegisterModule("Motion", Motion)

-- Reduced-motion flag – set by user or parent addon; skips non-essential anim.
Motion.reducedMotion = false

local function dur(key)
    return lib.Tokens:GetNumber("Motion.Duration." .. key)
end

-------------------------------------------------------------------------------
-- Internal helpers
-------------------------------------------------------------------------------

--- Gets or creates a named AnimationGroup on a frame.
---@param frame Frame
---@param tag   string  Unique label, e.g. "FadeIn"
---@return AnimationGroup
local function getGroup(frame, tag)
    if not frame._wuilAnims then frame._wuilAnims = {} end
    if not frame._wuilAnims[tag] then
        frame._wuilAnims[tag] = frame:CreateAnimationGroup()
    end
    return frame._wuilAnims[tag]
end

--- Creates (or recycles) an Alpha animation inside a group.
---@param group AnimationGroup
---@param from  number 0-1
---@param to    number 0-1
---@param duration number seconds
---@param easing  string WoW easing name
---@return Animation
local function alphaAnim(group, from, to, duration, easing)
    local anim = group:CreateAnimation("Alpha")
    anim:SetFromAlpha(from)
    anim:SetToAlpha(to)
    anim:SetDuration(duration)
    anim:SetSmoothing(easing or "Smooth")
    return anim
end

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

--- Fades a frame in.
---@param frame    Frame
---@param duration number?   Defaults to Motion.Duration.Entrance token
---@param onDone   function? Callback on completion
function Motion:FadeIn(frame, duration, onDone)
    if self.reducedMotion then
        frame:SetAlpha(1)
        frame:Show()
        if onDone then onDone() end
        return
    end
    duration = duration or dur("Entrance")
    local grp = getGroup(frame, "FadeIn")
    grp:Stop()
    -- Ensure visible before animating
    frame:Show()
    frame:SetAlpha(0)
    local anim = alphaAnim(grp, 0, 1, duration, "Smooth")
    if onDone then
        grp:SetScript("OnFinished", function()
            grp:SetScript("OnFinished", nil)
            onDone()
        end)
    end
    grp:Play()
end

--- Fades a frame out.
---@param frame    Frame
---@param duration number?
---@param onDone   function?  Typically hides the frame.
function Motion:FadeOut(frame, duration, onDone)
    if self.reducedMotion then
        frame:SetAlpha(0)
        frame:Hide()
        if onDone then onDone() end
        return
    end
    duration = duration or dur("Exit")
    local grp = getGroup(frame, "FadeOut")
    grp:Stop()
    local alpha = alphaAnim(grp, frame:GetAlpha(), 0, duration, "Smooth")
    grp:SetScript("OnFinished", function()
        grp:SetScript("OnFinished", nil)
        frame:Hide()
        frame:SetAlpha(1)
        if onDone then onDone() end
    end)
    grp:Play()
end

--- Slides a frame in from a direction.
---@param frame     Frame
---@param direction string  "UP"|"DOWN"|"LEFT"|"RIGHT"
---@param distance  number  pixels
---@param duration  number?
---@param onDone    function?
function Motion:SlideIn(frame, direction, distance, duration, onDone)
    if self.reducedMotion then
        frame:Show()
        if onDone then onDone() end
        return
    end
    duration = duration or dur("Entrance")
    local dx, dy = 0, 0
    if direction == "UP"    then dy = -distance
    elseif direction == "DOWN"  then dy =  distance
    elseif direction == "LEFT"  then dx =  distance
    elseif direction == "RIGHT" then dx = -distance
    end

    local grp = getGroup(frame, "SlideIn")
    grp:Stop()
    frame:Show()

    local trans = grp:CreateAnimation("Translation")
    trans:SetOffset(dx, dy)
    trans:SetDuration(0)
    trans:SetOrder(1)

    local move = grp:CreateAnimation("Translation")
    move:SetOffset(-dx, -dy)
    move:SetDuration(duration)
    move:SetSmoothing("Smooth")
    move:SetOrder(2)

    local fade = alphaAnim(grp, 0, 1, duration, "Smooth")
    fade:SetOrder(2)

    if onDone then
        grp:SetScript("OnFinished", function()
            grp:SetScript("OnFinished", nil)
            onDone()
        end)
    end
    grp:Play()
end

--- Quick scale-press feedback (subtle shrink on click).
---@param frame Frame
function Motion:ScalePress(frame)
    if self.reducedMotion then return end
    local grp = getGroup(frame, "Press")
    grp:Stop()
    local s1 = grp:CreateAnimation("Scale")
    s1:SetScale(0.95, 0.95)
    s1:SetDuration(dur("Fast"))
    s1:SetSmoothing("Linear")
    s1:SetOrder(1)

    local s2 = grp:CreateAnimation("Scale")
    s2:SetScale(1/0.95, 1/0.95)
    s2:SetDuration(dur("Fast"))
    s2:SetSmoothing("Smooth")
    s2:SetOrder(2)

    grp:Play()
end

--- Stops all WinUILib animations on a frame.
---@param frame Frame
function Motion:Stop(frame)
    if not frame._wuilAnims then return end
    for _, grp in pairs(frame._wuilAnims) do
        grp:Stop()
    end
end
