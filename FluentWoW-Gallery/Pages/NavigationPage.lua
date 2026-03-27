--- FluentWoW-Gallery – Pages/NavigationPage.lua
-- Showcases NavigationView and BreadcrumbBar controls.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery
local Icons = lib.Icons

Gallery:RegisterPage("navigation", "Navigation", function(parent)
    local _, _, stack, refresh = Gallery:CreateDemoPage(parent)

    -- Header
    local header = lib:CreateTextBlock(stack)
    header:SetStyle("Header")
    header:SetText("Navigation Controls")
    stack:AddChild(header)

    local desc = lib:CreateTextBlock(stack)
    desc:SetText("NavigationView provides sidebar navigation with collapsible pane. BreadcrumbBar shows hierarchical path breadcrumbs.")
    desc:SetColorKey("Color.Text.Secondary")
    desc:SetWrapping(true)
    desc:SetWidth(680)
    stack:AddChild(desc)

    ---------------------------------------------------------------------------
    -- NavigationView demo
    ---------------------------------------------------------------------------
    local navBlock, navBody = Gallery:CreateExampleBlock(stack, "NavigationView — Sidebar with collapsible pane.", 320)

    local nav = lib:CreateNavigationView(navBody)
    nav:SetPoint("TOPLEFT", navBody, "TOPLEFT", 12, -12)
    nav:SetPoint("BOTTOMRIGHT", navBody, "BOTTOMRIGHT", -12, 12)

    nav:SetItems({
        { key = "home",     label = "Home",     icon = Icons.Home },
        { key = "settings", label = "Settings", icon = Icons.Settings },
        { key = "search",   label = "Search",   icon = Icons.Search },
    })

    -- Create content frames for each page
    for _, key in ipairs({"home", "settings", "search"}) do
        local content = CreateFrame("Frame", nil, nav:GetContentArea())
        local label = lib:CreateTextBlock(content)
        label:SetStyle("Title")
        label:SetText(key:sub(1,1):upper() .. key:sub(2) .. " Page Content")
        label:SetPoint("CENTER")
        nav:SetItemContent(key, content)
    end

    nav:SelectItem("home")
    stack:AddChild(navBlock)

    ---------------------------------------------------------------------------
    -- BreadcrumbBar demo
    ---------------------------------------------------------------------------
    local crumbBlock, crumbBody = Gallery:CreateExampleBlock(stack, "BreadcrumbBar — Hierarchical path trail.", 60)

    local breadcrumb = lib:CreateBreadcrumbBar(crumbBody)
    breadcrumb:SetPoint("LEFT", crumbBody, "LEFT", 16, 0)
    breadcrumb:SetPoint("RIGHT", crumbBody, "RIGHT", -16, 0)
    breadcrumb:SetItems({"Home", "Documents", "Projects", "FluentWoW"})

    local crumbOutput = lib:CreateTextBlock(crumbBody)
    crumbOutput:SetColorKey("Color.Text.Secondary")
    crumbOutput:SetText("Click a breadcrumb to navigate")
    crumbOutput:SetPoint("BOTTOMLEFT", crumbBody, "BOTTOMLEFT", 16, 8)

    breadcrumb:SetOnItemClicked(function(_, index, label)
        crumbOutput:SetText("Navigated to: " .. tostring(label) .. " (index " .. index .. ")")
    end)

    stack:AddChild(crumbBlock)

    refresh()
end)
