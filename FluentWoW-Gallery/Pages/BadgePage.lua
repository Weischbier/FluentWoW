--- FluentWoW-Gallery -- Pages/BadgePage.lua
-- Mirrors custom Badge control page.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("Badge", function(parent, item)
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
    -- Example 1: All Badge appearances
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "Badge controls at every appearance.",
        exampleHeight = 120,
        noOutput = true,
        noOptions = true,
    })

    local appearances = { "Accent", "Success", "Warning", "Error", "Subtle" }
    local row = lib:CreateStackLayout(ex1.example, nil, "HORIZONTAL")
    row:SetGap(12)
    row:SetHeight(28)
    row:SetPoint("CENTER")

    for _, appearance in ipairs(appearances) do
        local badge = lib:CreateBadge(row)
        badge:SetText(appearance)
        badge:SetAppearance(appearance)
        row:AddChild(badge)
    end

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Badge with icon
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "Badge with an icon glyph.",
        exampleHeight = 100,
        noOutput = true,
        noOptions = true,
    })

    local iconBadge = lib:CreateBadge(ex2.example)
    iconBadge:SetText("New")
    iconBadge:SetIcon(lib.Icons.FavoriteStar)
    iconBadge:SetAppearance("Accent")
    iconBadge:SetPoint("CENTER")

    stack:AddChild(ex2.block)

    ---------------------------------------------------------------------------
    -- Example 3: Interactive appearance switcher
    ---------------------------------------------------------------------------
    local ex3 = Gallery:CreateControlExample(stack, {
        headerText = "Change the Badge appearance at runtime.",
        exampleHeight = 120,
    })

    local demoBadge = lib:CreateBadge(ex3.example)
    demoBadge:SetText("Status")
    demoBadge:SetAppearance("Accent")
    demoBadge:SetPoint("CENTER")

    ex3.outputLabel:SetText("Appearance: Accent")

    local appCombo = lib:CreateComboBox(ex3.options)
    appCombo:SetHeader("Appearance")
    appCombo:SetItems({
        { text = "Accent",  value = "Accent"  },
        { text = "Success", value = "Success" },
        { text = "Warning", value = "Warning" },
        { text = "Error",   value = "Error"   },
        { text = "Subtle",  value = "Subtle"  },
    })
    appCombo:SetSelectedIndex(1)
    appCombo:SetPoint("TOPLEFT", ex3.optionsAnchor, "BOTTOMLEFT", 0, -8)
    appCombo:SetOnSelectionChanged(function(_, _, itm)
        demoBadge:SetAppearance(itm.value)
        ex3.outputLabel:SetText("Appearance: " .. itm.value)
    end)

    stack:AddChild(ex3.block)

    refresh()
end)
