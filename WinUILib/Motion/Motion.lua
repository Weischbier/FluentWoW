--- WinUILib – Motion/Motion.lua
-- Tween-based animation engine with rich easing curves and WoW-native presets.
--
-- Easing functions derived from rxi/flux (MIT license, Copyright (c) 2016 rxi).
-- Timer patterns derived from airstruck/knife (MIT license).
-- See Libs/Motion/ for original source files with full license text.
--
-- Architecture:
--   - OnUpdate driver frame runs ONLY when tweens/timers are active (Rule #6)
--   - All presets respect Motion.reducedMotion
--   - Durations come from tokens (Motion.Duration.*)
--   - WoW-native AnimationGroups used for Scale (GPU-accelerated)
--   - OnUpdate tweens used for Alpha, Position, Color (property flexibility)
-------------------------------------------------------------------------------

local lib = WinUILib

local Motion = {}
lib:RegisterModule("Motion", Motion)

Motion.reducedMotion = false

-------------------------------------------------------------------------------
-- Easing functions (from rxi/flux, MIT license)
-- Each takes p in [0,1] and returns eased value in [0,1].
-------------------------------------------------------------------------------

local easing = {}
Motion.easing = easing

easing.linear = function(p) return p end

local easingDefs = {
    quad    = "p * p",
    cubic   = "p * p * p",
    quart   = "p * p * p * p",
    quint   = "p * p * p * p * p",
    expo    = "2 ^ (10 * (p - 1))",
    sine    = "-math.cos(p * (math.pi * .5)) + 1",
    circ    = "-(math.sqrt(1 - (p * p)) - 1)",
    back    = "p * p * (2.7 * p - 1.7)",
    elastic = "-(2^(10 * (p - 1)) * math.sin((p - 1.075) * (math.pi * 2) / .3))",
}

local function makefunc(str, expr)
    local fn = loadstring("return function(p) " .. str:gsub("%$e", expr) .. " end")
    return fn()
end

for k, v in pairs(easingDefs) do
    easing[k .. "in"]    = makefunc("return $e", v)
    easing[k .. "out"]   = makefunc("p = 1 - p; return 1 - ($e)", v)
    easing[k .. "inout"] = makefunc(
        "p = p * 2; if p < 1 then return .5 * ($e) "
        .. "else p = 2 - p; return .5 * (1 - ($e)) + .5 end", v)
end

-------------------------------------------------------------------------------
-- Tween driver (OnUpdate-based, auto-stops when idle)
-------------------------------------------------------------------------------

local _tweens  = {}
local _timers  = {}
local _driver  = CreateFrame("Frame")
local _running = false

local function startDriver()
    if _running then return end
    _running = true
    _driver:SetScript("OnUpdate", function(_, dt)
        -- process tweens
        for i = #_tweens, 1, -1 do
            local tw = _tweens[i]
            if tw._delay > 0 then
                tw._delay = tw._delay - dt
            else
                if not tw._inited then
                    -- snapshot start values on first tick
                    for _, v in ipairs(tw._vars) do
                        v.start = v.obj[v.key]
                        v.diff  = v.target - v.start
                    end
                    tw._inited = true
                    if tw._onstart then tw._onstart() end
                end
                tw._progress = tw._progress + tw._rate * dt
                local p = tw._progress
                if p >= 1 then p = 1 end
                local x = easing[tw._ease](p)
                for _, v in ipairs(tw._vars) do
                    v.obj[v.key] = v.start + x * v.diff
                end
                if tw._onupdate then tw._onupdate() end
                if p >= 1 then
                    table.remove(_tweens, i)
                    if tw._oncomplete then tw._oncomplete() end
                end
            end
        end
        -- process timers
        for i = #_timers, 1, -1 do
            local t = _timers[i]
            t._elapsed = t._elapsed + dt
            if t._elapsed >= t._delay then
                table.remove(_timers, i)
                lib.Utils.SafeCall(t._callback)
            end
        end
        -- stop driver when idle (Rule #6)
        if #_tweens == 0 and #_timers == 0 then
            _running = false
            _driver:SetScript("OnUpdate", nil)
        end
    end)
end

-------------------------------------------------------------------------------
-- Tween handle methods (chainable)
-------------------------------------------------------------------------------

local TweenMT = {}
TweenMT.__index = TweenMT

---@param easeName string  e.g. "quadout", "cubicin", "linear", "backinout"
---@return table self
function TweenMT:ease(easeName)
    if easing[easeName] then self._ease = easeName end
    return self
end

---@param d number seconds
---@return table self
function TweenMT:delay(d)
    self._delay = d
    return self
end

---@param fn function
---@return table self
function TweenMT:onstart(fn)
    self._onstart = fn
    return self
end

---@param fn function
---@return table self
function TweenMT:onupdate(fn)
    self._onupdate = fn
    return self
end

---@param fn function
---@return table self
function TweenMT:oncomplete(fn)
    self._oncomplete = fn
    return self
end

---@return table new tween handle chained after this one
function TweenMT:after(obj, time, vars)
    local next_tw = Motion:Tween(obj, time, vars)
    -- remove from active list; it will be re-added by oncomplete
    for i = #_tweens, 1, -1 do
        if _tweens[i] == next_tw then
            table.remove(_tweens, i)
            break
        end
    end
    local prev_complete = self._oncomplete
    self._oncomplete = function()
        if prev_complete then prev_complete() end
        table.insert(_tweens, next_tw)
        startDriver()
    end
    return next_tw
end

function TweenMT:stop()
    for i = #_tweens, 1, -1 do
        if _tweens[i] == self then
            table.remove(_tweens, i)
            return
        end
    end
end

-------------------------------------------------------------------------------
-- Core tween API
-------------------------------------------------------------------------------

--- Create a tween that transitions properties of `obj` over `time` seconds.
--- Uses proxy tables to tween arbitrary properties (alpha, position, color).
---@param obj table  object whose numeric keys will be tweened
---@param time number  duration in seconds
---@param vars table  { key = targetValue, ... }
---@return table tween handle (chainable)
function Motion:Tween(obj, time, vars)
    local tw = setmetatable({
        _rate     = time > 0 and (1 / time) or 0,
        _progress = time > 0 and 0 or 1,
        _delay    = 0,
        _ease     = "quadout",
        _owner    = nil,
        _inited   = false,
        _vars     = {},
    }, TweenMT)

    for k, v in pairs(vars) do
        table.insert(tw._vars, {
            obj    = obj,
            key    = k,
            start  = obj[k] or 0,
            target = v,
            diff   = v - (obj[k] or 0),
        })
    end

    -- instant completion for zero-duration tweens
    if time <= 0 then
        for _, v in ipairs(tw._vars) do
            v.obj[v.key] = v.target
        end
        if tw._oncomplete then tw._oncomplete() end
        return tw
    end

    table.insert(_tweens, tw)
    startDriver()
    return tw
end

-------------------------------------------------------------------------------
-- Timer API
-------------------------------------------------------------------------------

--- Execute `callback` after `delay` seconds.
---@param delay number
---@param callback function
---@return table timer handle
function Motion:After(delay, callback)
    local t = { _delay = delay, _elapsed = 0, _callback = callback }
    table.insert(_timers, t)
    startDriver()
    return t
end

--- Execute `callback` every `interval` seconds, up to `limit` times.
---@param interval number
---@param callback function
---@param limit? integer
function Motion:Every(interval, callback, limit)
    local count = 0
    local function tick()
        count = count + 1
        callback(count)
        if limit and count >= limit then return end
        Motion:After(interval, tick)
    end
    Motion:After(interval, tick)
end

--- Cancel a tween or timer handle.
---@param handle table
function Motion:Cancel(handle)
    for i = #_tweens, 1, -1 do
        if _tweens[i] == handle then table.remove(_tweens, i); return end
    end
    for i = #_timers, 1, -1 do
        if _timers[i] == handle then table.remove(_timers, i); return end
    end
end

-------------------------------------------------------------------------------
-- Stop helpers
-------------------------------------------------------------------------------

--- Stop all tweens owned by a specific frame.
---@param frame Frame
function Motion:Stop(frame)
    for i = #_tweens, 1, -1 do
        if _tweens[i]._owner == frame then
            table.remove(_tweens, i)
        end
    end
    -- also stop any native AnimationGroups
    if frame._wuilScaleAG then
        frame._wuilScaleAG:Stop()
    end
end

--- Stop all active tweens and timers.
function Motion:StopAll()
    for i = #_tweens, 1, -1 do _tweens[i] = nil end
    for i = #_timers, 1, -1 do _timers[i] = nil end
    if _running then
        _running = false
        _driver:SetScript("OnUpdate", nil)
    end
end

-------------------------------------------------------------------------------
-- Token-duration helper
-------------------------------------------------------------------------------

local function dur(key)
    return lib.Tokens:GetNumber("Motion.Duration." .. key)
end

-------------------------------------------------------------------------------
-- High-level animation presets
-------------------------------------------------------------------------------

--- Fade a frame in from alpha 0 to 1 with easing.
---@param frame Frame
---@param duration? number
---@param onDone? function
---@return table|nil tween handle
function Motion:FadeIn(frame, duration, onDone)
    if self.reducedMotion then
        frame:SetAlpha(1)
        frame:Show()
        if onDone then onDone() end
        return nil
    end
    self:Stop(frame)
    duration = duration or dur("Entrance")
    frame:Show()
    frame:SetAlpha(0)
    local proxy = { alpha = 0 }
    local tw = self:Tween(proxy, duration, { alpha = 1 })
        :ease("quadout")
        :onupdate(function() frame:SetAlpha(proxy.alpha) end)
        :oncomplete(function()
            frame:SetAlpha(1)
            if onDone then onDone() end
        end)
    tw._owner = frame
    return tw
end

--- Fade a frame out from current alpha to 0, then hide.
---@param frame Frame
---@param duration? number
---@param onDone? function
---@return table|nil tween handle
function Motion:FadeOut(frame, duration, onDone)
    if self.reducedMotion then
        frame:SetAlpha(0)
        frame:Hide()
        if onDone then onDone() end
        return nil
    end
    self:Stop(frame)
    duration = duration or dur("Exit")
    local startAlpha = frame:GetAlpha()
    local proxy = { alpha = startAlpha }
    local tw = self:Tween(proxy, duration, { alpha = 0 })
        :ease("quadout")
        :onupdate(function() frame:SetAlpha(proxy.alpha) end)
        :oncomplete(function()
            frame:Hide()
            frame:SetAlpha(1)
            if onDone then onDone() end
        end)
    tw._owner = frame
    return tw
end

--- Slide a frame in from an offset with fade.
---@param frame Frame
---@param direction string  "UP"|"DOWN"|"LEFT"|"RIGHT"
---@param distance number  pixels to slide
---@param duration? number
---@param onDone? function
---@return table|nil tween handle
function Motion:SlideIn(frame, direction, distance, duration, onDone)
    if self.reducedMotion then
        frame:Show()
        if onDone then onDone() end
        return nil
    end
    self:Stop(frame)
    duration = duration or dur("Entrance")

    local point, rel, relPoint, finalX, finalY = frame:GetPoint(1)
    if not point then return nil end

    local startX, startY = finalX, finalY
    if     direction == "UP"    then startY = finalY - distance
    elseif direction == "DOWN"  then startY = finalY + distance
    elseif direction == "LEFT"  then startX = finalX - distance
    elseif direction == "RIGHT" then startX = finalX + distance
    end

    frame:ClearAllPoints()
    frame:SetPoint(point, rel, relPoint, startX, startY)
    frame:Show()
    frame:SetAlpha(0)

    local proxy = { x = startX, y = startY, alpha = 0 }
    local tw = self:Tween(proxy, duration, {
        x = finalX, y = finalY, alpha = 1,
    })
        :ease("quadout")
        :onupdate(function()
            frame:ClearAllPoints()
            frame:SetPoint(point, rel, relPoint, proxy.x, proxy.y)
            frame:SetAlpha(proxy.alpha)
        end)
        :oncomplete(function()
            frame:ClearAllPoints()
            frame:SetPoint(point, rel, relPoint, finalX, finalY)
            frame:SetAlpha(1)
            if onDone then onDone() end
        end)
    tw._owner = frame
    return tw
end

--- Tactile press-and-release scale effect (uses WoW native Scale animation).
---@param frame Frame
---@param duration? number
function Motion:ScalePress(frame, duration)
    if self.reducedMotion then return end
    duration = duration or dur("Fast")
    local ag = frame._wuilScaleAG
    if not ag then
        ag = frame:CreateAnimationGroup()
        local s1 = ag:CreateAnimation("Scale")
        s1:SetScale(0.95, 0.95)
        s1:SetDuration(duration * 0.5)
        s1:SetSmoothing("OUT")
        s1:SetOrder(1)
        local s2 = ag:CreateAnimation("Scale")
        s2:SetScale(1 / 0.95, 1 / 0.95)
        s2:SetDuration(duration * 0.5)
        s2:SetSmoothing("IN")
        s2:SetOrder(2)
        frame._wuilScaleAG = ag
    end
    ag:Stop()
    ag:Play()
end

--- Smoothly transition a color property from one value to another.
--- `applyFn(r, g, b, a)` is called each frame to apply the color.
---@param frame Frame  owner for Stop() tracking
---@param fromR number @param fromG number @param fromB number @param fromA number
---@param toR number @param toG number @param toB number @param toA number
---@param duration? number
---@param applyFn function  function(r, g, b, a)
---@param onDone? function
---@return table|nil tween handle
function Motion:ColorTo(frame, fromR, fromG, fromB, fromA, toR, toG, toB, toA, duration, applyFn, onDone)
    if self.reducedMotion then
        applyFn(toR, toG, toB, toA)
        if onDone then onDone() end
        return nil
    end
    duration = duration or dur("Normal")
    local proxy = { r = fromR, g = fromG, b = fromB, a = fromA }
    local tw = self:Tween(proxy, duration, { r = toR, g = toG, b = toB, a = toA })
        :ease("quadout")
        :onupdate(function() applyFn(proxy.r, proxy.g, proxy.b, proxy.a) end)
        :oncomplete(function()
            applyFn(toR, toG, toB, toA)
            if onDone then onDone() end
        end)
    tw._owner = frame
    return tw
end

--- Smoothly expand or collapse a frame's height.
---@param frame Frame
---@param fromH number
---@param toH number
---@param duration? number
---@param onDone? function
---@return table|nil tween handle
function Motion:HeightTo(frame, fromH, toH, duration, onDone)
    if self.reducedMotion then
        frame:SetHeight(toH)
        if onDone then onDone() end
        return nil
    end
    self:Stop(frame)
    duration = duration or dur("Normal")
    frame:SetHeight(fromH)
    local proxy = { h = fromH }
    local tw = self:Tween(proxy, duration, { h = toH })
        :ease("quadout")
        :onupdate(function() frame:SetHeight(proxy.h) end)
        :oncomplete(function()
            frame:SetHeight(toH)
            if onDone then onDone() end
        end)
    tw._owner = frame
    return tw
end
