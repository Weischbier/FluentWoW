--- FluentWoW-Gallery -- Pages/NavigationViewPage.lua
-- Mirrors WinUI Gallery NavigationViewPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Icons = lib.Icons
local Gallery = lib._gallery

Gallery:RegisterControlPage("NavigationView", function(parent, item)
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
    -- Example 1: NavigationView with pages
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A NavigationView with page-switching content.",
        exampleHeight = 320,
        noOutput = true,
        noOptions = true,
    })

    local nav = lib:CreateNavigationView(ex1.example)
    nav:SetAllPoints(ex1.example)

    local contentArea = nav:GetContentArea()

    local pageItems = {
        { key = "home",     label = "Home",     icon = Icons.Home },
        { key = "settings", label = "Settings", icon = Icons.Settings },
        { key = "profile",  label = "Profile",  icon = Icons.Edit },
    }

    nav:SetItems(pageItems)

    for _, pi in ipairs(pageItems) do
        local page = CreateFrame("Frame", nil, contentArea)
        page:SetAllPoints(contentArea)
        page:Hide()

        local pageLabel = lib:CreateTextBlock(page)
        pageLabel:SetStyle("Subtitle")
        pageLabel:SetText(pi.label .. " Page")
        pageLabel:SetPoint("CENTER")
        nav:SetItemContent(pi.key, page)
    end

    nav:SelectItem("home")

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Pane toggle
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "Toggle the NavigationView pane open/closed.",
        exampleHeight = 260,
        noOutput = true,
    })

    local nav2 = lib:CreateNavigationView(ex2.example)
    nav2:SetAllPoints(ex2.example)
    nav2:SetItems({
        { key = "a", label = "Page A", icon = Icons.FolderOpen },
        { key = "b", label = "Page B", icon = Icons.Search },
    })
    nav2:SelectItem("a")

    local contentA = nav2:GetContentArea()
    local labelA = lib:CreateTextBlock(contentA)
    labelA:SetStyle("Body")
    labelA:SetText("Content area adjusts when pane collapses.")
    labelA:SetPoint("CENTER")

    local expandCheck = lib:CreateCheckBox(ex2.options)
    expandCheck:SetText("Pane expanded")
    expandCheck:SetChecked(true)
    expandCheck:SetPoint("TOPLEFT", ex2.optionsAnchor, "BOTTOMLEFT", 0, -8)
    expandCheck:SetOnChanged(function(_, checked)
        nav2:SetPaneExpanded(checked)
    end)

    stack:AddChild(ex2.block)

    refresh()
end)
