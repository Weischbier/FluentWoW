--- WinUILib-Gallery – Gallery.lua
-- Main gallery window and navigation shell.
-- Opens with /wuil or /winuigallery
--
-- Architecture:
--   - Outer window (standard movable frame)
--   - Left NavigationView-style sidebar with page list
--   - Right content area that swaps page frames
--   - Source snippet viewer (toggleable)
-------------------------------------------------------------------------------

local WUIL = WinUILib

WinUILibGallery = {}
local Gallery   = WinUILibGallery

-- Page registry: { id, title, createFn }
Gallery._pages    = {}
Gallery._current  = nil
Gallery._window   = nil

local NAV_W   = 180
local WIN_W   = 900
local WIN_H   = 620
local NAV_ITEM_H = 36

-------------------------------------------------------------------------------
-- Page registration
-------------------------------------------------------------------------------

--- Registers a gallery page.
---@param id       string  Unique identifier
---@param title    string  Display name in the sidebar
---@param createFn function  function(contentFrame) → builds the page
function Gallery:RegisterPage(id, title, createFn)
    table.insert(self._pages, { id = id, title = title, create = createFn })
end

-------------------------------------------------------------------------------
-- Window construction
-------------------------------------------------------------------------------

function Gallery:CreateWindow()
    if self._window then return self._window end

    local win = CreateFrame("Frame", "WinUILibGalleryFrame", UIParent,
                            BackdropTemplateMixin and "BackdropTemplate")
    win:SetSize(WIN_W, WIN_H)
    win:SetPoint("CENTER")
    win:SetMovable(true)
    win:EnableMouse(true)
    win:RegisterForDrag("LeftButton")
    win:SetScript("OnDragStart", win.StartMoving)
    win:SetScript("OnDragStop",  win.StopMovingOrSizing)
    win:SetFrameStrata("HIGH")
    win:SetToplevel(true)

    -- Background
    win:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile     = true, tileSize = 8, edgeSize = 1,
        insets   = { left=1, right=1, top=1, bottom=1 },
    })
    win:SetBackdropColor(0.10, 0.10, 0.11, 0.98)
    win:SetBackdropBorderColor(0.28, 0.28, 0.32, 1)

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, win)
    titleBar:SetPoint("TOPLEFT")
    titleBar:SetPoint("TOPRIGHT")
    titleBar:SetHeight(40)
    titleBar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        tile   = true, tileSize = 8,
    })
    titleBar:SetBackdropColor(0.13, 0.13, 0.14, 1)

    -- Allow dragging from the title bar too
    titleBar:SetMovable(false)
    titleBar:SetScript("OnMouseDown", function() win:StartMoving() end)
    titleBar:SetScript("OnMouseUp",   function() win:StopMovingOrSizing() end)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 16, 0)
    titleText:SetText("|cFF05B7E0W|rinUILib Gallery")

    local closeBtn = WUIL:CreateButton(win, "Subtle")
    closeBtn:SetLabel("✕")
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -8, 0)
    closeBtn.OnActivated = function() win:Hide() end

    -- Left navigation sidebar
    local sidebar = CreateFrame("Frame", nil, win)
    sidebar:SetPoint("TOPLEFT", win, "TOPLEFT", 0, -40)
    sidebar:SetPoint("BOTTOMLEFT")
    sidebar:SetWidth(NAV_W)
    sidebar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        tile   = true, tileSize = 8,
    })
    sidebar:SetBackdropColor(0.10, 0.10, 0.11, 1)

    local navLabel = sidebar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    navLabel:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 12, -12)
    navLabel:SetText("CONTROLS")
    navLabel:SetTextColor(0.50, 0.50, 0.55)

    -- Content area
    local content = CreateFrame("Frame", "WinUILibGalleryContent", win)
    content:SetPoint("TOPLEFT",     win, "TOPLEFT",     NAV_W + 1, -40)
    content:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", 0, 0)

    self._win     = win
    self._sidebar = sidebar
    self._content = content
    self._navBtns = {}

    -- Build nav buttons after pages are registered (deferred)
    return win
end

function Gallery:BuildNavButtons()
    local yOff = -36
    for i, page in ipairs(self._pages) do
        local btn = CreateFrame("Button", nil, self._sidebar)
        btn:SetPoint("TOPLEFT",  self._sidebar, "TOPLEFT",  0, yOff)
        btn:SetPoint("TOPRIGHT", self._sidebar, "TOPRIGHT", 0, yOff)
        btn:SetHeight(NAV_ITEM_H)
        btn:EnableMouse(true)
        btn:RegisterForClicks("LeftButtonUp")

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0)

        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        lbl:SetPoint("LEFT", btn, "LEFT", 16, 0)
        lbl:SetText(page.title)
        lbl:SetTextColor(0.68, 0.68, 0.72)

        local activeLine = btn:CreateTexture(nil, "OVERLAY")
        activeLine:SetPoint("LEFT")
        activeLine:SetSize(3, NAV_ITEM_H)
        activeLine:SetColorTexture(0.05, 0.55, 0.88, 0)

        btn._page       = page
        btn._bg         = bg
        btn._lbl        = lbl
        btn._activeLine = activeLine

        btn:SetScript("OnEnter", function(self)
            if not self._active then
                self._bg:SetColorTexture(1, 1, 1, 0.04)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if not self._active then
                self._bg:SetColorTexture(0, 0, 0, 0)
            end
        end)
        btn:SetScript("OnClick", function(self)
            Gallery:SelectPage(self._page.id)
        end)

        self._navBtns[page.id] = btn
        yOff = yOff - NAV_ITEM_H
    end
end

--- Selects and displays a page by ID.
---@param id string
function Gallery:SelectPage(id)
    -- Deactivate current
    if self._current then
        local oldBtn = self._navBtns[self._current]
        if oldBtn then
            oldBtn._active = false
            oldBtn._bg:SetColorTexture(0, 0, 0, 0)
            oldBtn._lbl:SetTextColor(0.68, 0.68, 0.72)
            oldBtn._activeLine:SetColorTexture(0.05, 0.55, 0.88, 0)
        end
        if self._pageFrames and self._pageFrames[self._current] then
            WUIL.Motion:FadeOut(self._pageFrames[self._current], 0.10)
        end
    end

    self._current = id

    -- Activate new nav button
    local btn = self._navBtns[id]
    if btn then
        btn._active = true
        btn._bg:SetColorTexture(1, 1, 1, 0.06)
        btn._lbl:SetTextColor(0.95, 0.95, 0.97)
        btn._activeLine:SetColorTexture(0.05, 0.55, 0.88, 1)
    end

    -- Create or show page frame
    if not self._pageFrames then self._pageFrames = {} end
    if not self._pageFrames[id] then
        -- Find page def
        for _, page in ipairs(self._pages) do
            if page.id == id then
                local pf = CreateFrame("Frame", nil, self._content)
                pf:SetAllPoints()
                page.create(pf)
                self._pageFrames[id] = pf
                break
            end
        end
    end
    local pf = self._pageFrames[id]
    if pf then
        WUIL.Motion:FadeIn(pf, 0.15)
    end
end

-------------------------------------------------------------------------------
-- Slash commands
-------------------------------------------------------------------------------

SLASH_WUIL1     = "/wuil"
SLASH_WUIL2     = "/winuigallery"
SlashCmdList["WUIL"] = function()
    if not Gallery._win then
        Gallery:CreateWindow()
        Gallery:BuildNavButtons()
        -- Select first page
        if Gallery._pages[1] then
            Gallery:SelectPage(Gallery._pages[1].id)
        end
    end
    if Gallery._win:IsShown() then
        Gallery._win:Hide()
    else
        Gallery._win:Show()
    end
end
