--- WinUILib – Controls/TabView/TabView.lua
-- Tab strip + content panel container.
-- Design ref: WinUI TabView
--
-- Public API:
--   :AddTab(title, contentFrame?)  → tabIndex
--   :SelectTab(index)
--   :GetSelectedIndex()
--   :GetContentFrame(index)        → Frame
--   :RemoveTab(index)
--   OnTabSelected(self, index, title)
-------------------------------------------------------------------------------

local lib = WinUILib
local Mot = lib.Motion

local STRIP_H       = 36
local TAB_MIN_W     = 80
local TAB_MAX_W     = 160
local TAB_PADDING   = 12

local TAB_NORMAL_BG  = { 0.13, 0.13, 0.14, 1 }
local TAB_ACTIVE_BG  = { 0.10, 0.10, 0.11, 1 }
local TAB_HOVER_BG   = { 0.17, 0.17, 0.19, 1 }
local LABEL_NORMAL   = { 0.68, 0.68, 0.72 }
local LABEL_ACTIVE   = { 0.95, 0.95, 0.97 }

-------------------------------------------------------------------------------
-- TabItem scripts
-------------------------------------------------------------------------------

function WUILTabItem_OnLoad(self)
    self._tabView  = nil
    self._tabIndex = nil
    self._active   = false
end

function WUILTabItem_OnEnter(self)
    if not self._active then
        local bg = _G[self:GetName() .. "_BG"]
        if bg then bg:SetColorTexture(table.unpack(TAB_HOVER_BG)) end
    end
end

function WUILTabItem_OnLeave(self)
    if not self._active then
        local bg = _G[self:GetName() .. "_BG"]
        if bg then bg:SetColorTexture(table.unpack(TAB_NORMAL_BG)) end
    end
end

function WUILTabItem_OnClick(self, btn)
    if btn ~= "LeftButton" then return end
    if self._tabView and self._tabIndex then
        self._tabView:SelectTab(self._tabIndex)
    end
end

-------------------------------------------------------------------------------
-- TabView scripts
-------------------------------------------------------------------------------

function WUILTabView_OnLoad(self)
    Mixin(self, lib._controls.ControlBase)
    Mixin(self, lib._controls.TabView)
    self:WUILInit()
    self._tabs         = {}   -- { title, tabBtn, contentFrame }
    self._selectedIdx  = nil
    self._tabPool      = lib.FramePool:New("Button", self, "WUILTabItemTemplate")
end

-------------------------------------------------------------------------------
-- TabView mixin
-------------------------------------------------------------------------------

---@class WUILTabView : WUILControlBase
local TabView = {}
lib._controls.TabView = TabView

--- Adds a tab. Returns the 1-based index.
---@param title         string
---@param contentFrame  Frame?  Supply a pre-created frame; or nil to create one.
---@return integer
function TabView:AddTab(title, contentFrame)
    -- Create tab button
    local btn = self._tabPool:Acquire()
    btn._tabView  = self
    btn._tabIndex = #self._tabs + 1
    btn._active   = false
    local lbl = _G[btn:GetName() .. "_Label"]
    if lbl then
        lbl:SetText(title or "")
        lbl:SetTextColor(table.unpack(LABEL_NORMAL))
    end

    -- Create content frame if not provided
    if not contentFrame then
        contentFrame = CreateFrame("Frame", nil, self)
        contentFrame:SetPoint("TOPLEFT",     self, "TOPLEFT",     0, -STRIP_H - 1)
        contentFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
        contentFrame:Hide()
    end
    contentFrame:SetParent(self)

    local tabEntry = { title = title, btn = btn, content = contentFrame }
    table.insert(self._tabs, tabEntry)

    -- Layout tabs
    self:_LayoutTabs()

    -- Auto-select first tab
    if #self._tabs == 1 then
        self:SelectTab(1)
    end

    return #self._tabs
end

---@param index integer  1-based
function TabView:SelectTab(index)
    if index < 1 or index > #self._tabs then return end
    local prev = self._selectedIdx

    -- Deactivate previous
    if prev and self._tabs[prev] then
        local old = self._tabs[prev]
        old.btn._active = false
        local bg  = _G[old.btn:GetName() .. "_BG"]
        local ln  = _G[old.btn:GetName() .. "_ActiveLine"]
        local lbl = _G[old.btn:GetName() .. "_Label"]
        if bg  then bg:SetColorTexture(table.unpack(TAB_NORMAL_BG)) end
        if ln  then ln:Hide() end
        if lbl then lbl:SetTextColor(table.unpack(LABEL_NORMAL)) end
        Mot:FadeOut(old.content, 0.10)
    end

    -- Activate new
    self._selectedIdx = index
    local new = self._tabs[index]
    new.btn._active = true
    local bg  = _G[new.btn:GetName() .. "_BG"]
    local ln  = _G[new.btn:GetName() .. "_ActiveLine"]
    local lbl = _G[new.btn:GetName() .. "_Label"]
    if bg  then bg:SetColorTexture(table.unpack(TAB_ACTIVE_BG)) end
    if ln  then ln:Show() end
    if lbl then lbl:SetTextColor(table.unpack(LABEL_ACTIVE)) end
    Mot:FadeIn(new.content, 0.15)

    if self.OnTabSelected then
        lib.Utils.SafeCall(self.OnTabSelected, self, index, new.title)
    end
end

---@return integer?
function TabView:GetSelectedIndex()
    return self._selectedIdx
end

---@param index integer
---@return Frame?
function TabView:GetContentFrame(index)
    local entry = self._tabs[index]
    return entry and entry.content
end

--- Removes a tab. Selects the nearest remaining tab.
---@param index integer
function TabView:RemoveTab(index)
    local entry = self._tabs[index]
    if not entry then return end
    self._tabPool:Release(entry.btn)
    entry.content:Hide()
    table.remove(self._tabs, index)
    -- Re-number remaining tabs
    for i, t in ipairs(self._tabs) do t.btn._tabIndex = i end
    self:_LayoutTabs()
    -- Reselect
    if self._selectedIdx == index then
        self._selectedIdx = nil
        local newIdx = math.min(index, #self._tabs)
        if newIdx >= 1 then self:SelectTab(newIdx) end
    elseif self._selectedIdx and self._selectedIdx > index then
        self._selectedIdx = self._selectedIdx - 1
    end
end

--- Repositions all tab buttons evenly across the strip.
function TabView:_LayoutTabs()
    local count  = #self._tabs
    if count == 0 then return end
    local totalW = self:GetWidth()
    local tabW   = math.max(TAB_MIN_W, math.min(TAB_MAX_W, totalW / count))
    for i, entry in ipairs(self._tabs) do
        entry.btn:SetWidth(tabW)
        entry.btn:ClearAllPoints()
        entry.btn:SetPoint("TOPLEFT", self, "TOPLEFT", (i - 1) * tabW, 0)
        entry.btn:SetHeight(STRIP_H)
        entry.btn:Show()
    end
end

-------------------------------------------------------------------------------
-- Factory
-------------------------------------------------------------------------------

---@param parent Frame
---@param width  number?
---@param height number?
---@return Frame
function lib:CreateTabView(parent, width, height)
    local tv = CreateFrame("Frame", nil, parent, "WUILTabViewTemplate")
    if width  then tv:SetWidth(width) end
    if height then tv:SetHeight(height) end
    return tv
end
