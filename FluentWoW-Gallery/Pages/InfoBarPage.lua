--- FluentWoW-Gallery -- Pages/InfoBarPage.lua
-- Mirrors WinUI Gallery InfoBarPage: severity, closable, action.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local _T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("InfoBar", function(parent, item)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Title")
    header:SetText(item.title)
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText(item.description)
    desc:SetColorKey("Color.Text.Secondary")
    desc:SetWrapping(true)
    desc:SetWidth(680)
    stack:AddChild(desc)

    ---------------------------------------------------------------------------
    -- Example 1: All severity types
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "An InfoBar at each severity level.",
        exampleHeight = 280,
        noOutput = true,
        noOptions = true,
    })

    local severities = { "Info", "Success", "Warning", "Error" }
    local messages = {
        "This is an informational message.",
        "Operation completed successfully.",
        "Something requires your attention.",
        "An error occurred during the operation.",
    }
    local prevAnchor = ex1.example
    local prevPoint = "TOPLEFT"
    local yOff = -12

    for i, sev in ipairs(severities) do
        local bar = lib:CreateInfoBar(ex1.example)
        bar:SetSeverity(sev)
        bar:SetTitle(sev)
        bar:SetMessage(messages[i])
        bar:SetClosable(false)
        bar:SetPoint("TOPLEFT", prevAnchor, prevPoint, prevPoint == "TOPLEFT" and 12 or 0, yOff)
        bar:SetPoint("RIGHT", ex1.example, "RIGHT", -12, 0)
        bar:Open()
        prevAnchor = bar
        prevPoint = "BOTTOMLEFT"
        yOff = -8
    end

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Closable InfoBar
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A closable InfoBar.",
        exampleHeight = 120,
        noOptions = true,
    })

    local barClosable = lib:CreateInfoBar(ex2.example)
    barClosable:SetSeverity("Info")
    barClosable:SetTitle("Closable")
    barClosable:SetMessage("Click the close button to dismiss.")
    barClosable:SetClosable(true)
    barClosable:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 12, -12)
    barClosable:SetPoint("RIGHT", ex2.example, "RIGHT", -12, 0)
    barClosable:Open()

    ex2.outputLabel:SetText("")
    barClosable:SetOnClosed(function()
        ex2.outputLabel:SetText("InfoBar was closed.")
    end)

    stack:AddChild(ex2.block)

    ---------------------------------------------------------------------------
    -- Example 3: InfoBar with action button
    ---------------------------------------------------------------------------
    local ex3 = Gallery:CreateControlExample(stack, {
        headerText = "An InfoBar with an action button.",
        exampleHeight = 120,
        noOutput = true,
    })

    local barAction = lib:CreateInfoBar(ex3.example)
    barAction:SetSeverity("Warning")
    barAction:SetTitle("Update needed")
    barAction:SetMessage("A newer version is available.")
    barAction:SetClosable(false)
    barAction:SetPoint("TOPLEFT", ex3.example, "TOPLEFT", 12, -12)
    barAction:SetPoint("RIGHT", ex3.example, "RIGHT", -12, 0)

    local actionBtn = lib:CreateButton(ex3.example, nil, "Accent")
    actionBtn:SetText("Update now")
    barAction:SetActionControl(actionBtn)
    barAction:Open()

    local sevCombo = lib:CreateComboBox(ex3.options)
    sevCombo:SetHeader("Severity")
    sevCombo:SetItems({
        { text = "Info",    value = "Info"    },
        { text = "Success", value = "Success" },
        { text = "Warning", value = "Warning" },
        { text = "Error",   value = "Error"   },
    })
    sevCombo:SetSelectedIndex(3)
    sevCombo:SetPoint("TOPLEFT", ex3.optionsAnchor, "BOTTOMLEFT", 0, -8)
    sevCombo:SetOnSelectionChanged(function(_, _, itm)
        barAction:SetSeverity(itm.value)
    end)

    stack:AddChild(ex3.block)

    refresh()
end)
