--- WinUILib-Gallery – Pages/FeedbackPage.lua
-- Demonstrates ProgressBar, ProgressRing, InfoBar, ContentDialog, Expander.
-------------------------------------------------------------------------------

local WUIL    = WinUILib
local Gallery = WinUILibGallery

Gallery:RegisterPage("feedback", "Feedback & Dialogs", function(parent)

    local scroll = WUIL:CreateScrollFrame(parent)
    scroll:SetAllPoints()
    local content = scroll:GetScrollChild()
    content:SetWidth(parent:GetWidth() - 32)
    content:SetHeight(900)

    local function Hdr(text, anchor, yOff)
        local h = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        h:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -16)
        h:SetText(text)
        h:SetTextColor(0.95, 0.95, 0.97)
        return h
    end
    local function Note(text, anchor, yOff)
        local d = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        d:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOff or -4)
        d:SetPoint("RIGHT", content, "RIGHT", -24, 0)
        d:SetText(text)
        d:SetTextColor(0.68, 0.68, 0.72)
        d:SetWordWrap(true)
        return d
    end

    -- ── ProgressBar ─────────────────────────────────────────────────────────
    local topRef = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    topRef:SetPoint("TOPLEFT", content, "TOPLEFT", 24, -16)
    topRef:SetText("ProgressBar")
    topRef:SetTextColor(0.95, 0.95, 0.97)
    local n1 = Note("Determinate (40%) and indeterminate shimmer variant.", topRef)

    local pb1 = WUIL:CreateProgressBar(content, 280)
    pb1:SetPoint("TOPLEFT", n1, "BOTTOMLEFT", 0, -12)
    pb1:SetValue(40)
    pb1:SetHeight(6)

    local pb2 = WUIL:CreateProgressBar(content, 280)
    pb2:SetPoint("TOPLEFT", pb1, "BOTTOMLEFT", 0, -12)
    pb2:SetHeight(6)
    pb2:SetIndeterminate(true)

    -- ── ProgressRing ────────────────────────────────────────────────────────
    local h2 = Hdr("ProgressRing", pb2, -16)
    local n2 = Note("Spinning indicator for background operations.", h2)

    local pr = WUIL:CreateProgressRing(content, 32)
    pr:SetPoint("TOPLEFT", n2, "BOTTOMLEFT", 0, -12)

    -- ── InfoBar ─────────────────────────────────────────────────────────────
    local h3 = Hdr("InfoBar", pr, -12)
    local n3 = Note("Four severity levels: Informational, Success, Warning, Error.", h3)

    local ibInfo = WUIL:CreateInfoBar(content, "Informational",
        "Information",
        "A new version of this addon is available. Visit CurseForge to update.")
    ibInfo:SetPoint("TOPLEFT", n3, "BOTTOMLEFT", 0, -12)
    ibInfo:SetWidth(480)

    local ibSuccess = WUIL:CreateInfoBar(content, "Success",
        "Saved",
        "Your settings have been saved successfully.")
    ibSuccess:SetPoint("TOPLEFT", ibInfo, "BOTTOMLEFT", 0, -8)
    ibSuccess:SetWidth(480)

    local ibWarn = WUIL:CreateInfoBar(content, "Warning",
        "Performance warning",
        "Enabling this option may reduce frame rate in large raids.")
    ibWarn:SetPoint("TOPLEFT", ibSuccess, "BOTTOMLEFT", 0, -8)
    ibWarn:SetWidth(480)

    local ibErr = WUIL:CreateInfoBar(content, "Error",
        "Load error",
        "Could not load saved variable 'MyAddon_DB'. Using defaults.")
    ibErr:SetPoint("TOPLEFT", ibWarn, "BOTTOMLEFT", 0, -8)
    ibErr:SetWidth(480)

    -- ── ContentDialog ───────────────────────────────────────────────────────
    local h4 = Hdr("ContentDialog", ibErr, -16)
    local n4 = Note(
        "Modal overlay dialog.  Automatically deferred when opened in combat.",
        h4)

    local openDialogBtn = WUIL:CreateButton(content, "Subtle", "Open ContentDialog")
    openDialogBtn:SetPoint("TOPLEFT", n4, "BOTTOMLEFT", 0, -12)
    openDialogBtn:SetWidth(200)

    local dialog = WUIL:CreateContentDialog(
        "Confirm Reset",
        "This will reset all settings to their default values.  "
        .. "This action cannot be undone.")
    dialog:SetPrimaryButton("Reset",  function() WUIL:Debug("Reset confirmed") end)
    dialog:SetSecondaryButton("Cancel")

    openDialogBtn.OnActivated = function() dialog:Open() end

    -- ── Expander ────────────────────────────────────────────────────────────
    local h5 = Hdr("Expander", openDialogBtn, -16)
    local n5 = Note("Collapsible section – animated height reveal.", h5)

    local exp = WUIL:CreateExpander(content, "Advanced Options", 120)
    exp:SetPoint("TOPLEFT", n5, "BOTTOMLEFT", 0, -12)
    exp:SetWidth(480)

    -- Populate expander content
    local expContent = exp:GetContentFrame()
    local inner1 = WUIL:CreateCheckBox(expContent, "Enable debug logging", false)
    inner1:SetPoint("TOPLEFT", expContent, "TOPLEFT", 12, -12)
    local inner2 = WUIL:CreateCheckBox(expContent, "Verbose error reporting", false)
    inner2:SetPoint("TOPLEFT", inner1, "BOTTOMLEFT", 0, -8)
end)
