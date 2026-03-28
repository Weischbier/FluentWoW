--- FluentWoW-Gallery -- Pages/BreadcrumbBarPage.lua
-- Mirrors WinUI Gallery BreadcrumbBarPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Gallery = lib._gallery

Gallery:RegisterControlPage("BreadcrumbBar", function(parent, item)
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
    -- Example 1: Basic BreadcrumbBar
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A basic BreadcrumbBar showing a path.",
        exampleHeight = 100,
        noOptions = true,
    })

    local bc1 = lib:CreateBreadcrumbBar(ex1.example)
    bc1:SetItems({ "Home", "Documents", "Design", "Layouts" })
    bc1:SetPoint("TOPLEFT", ex1.example, "TOPLEFT", 16, -16)

    ex1.outputLabel:SetText("")
    bc1:SetOnItemClicked(function(_, idx, label)
        ex1.outputLabel:SetText("Clicked: " .. label .. " (index " .. idx .. ")")
    end)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: Dynamic breadcrumb navigation
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "A BreadcrumbBar that updates as you navigate deeper.",
        exampleHeight = 160,
        noOutput = true,
        noOptions = true,
    })

    local crumbs = { "Root" }

    local bc2 = lib:CreateBreadcrumbBar(ex2.example)
    bc2:SetItems(crumbs)
    bc2:SetPoint("TOPLEFT", ex2.example, "TOPLEFT", 16, -16)

    local addBtn = lib:CreateButton(ex2.example, nil, "Accent")
    addBtn:SetText("Go deeper")
    addBtn:SetPoint("TOPLEFT", bc2, "BOTTOMLEFT", 0, -16)

    addBtn:SetOnClick(function()
        table.insert(crumbs, "Folder " .. #crumbs)
        bc2:SetItems(crumbs)
    end)

    bc2:SetOnItemClicked(function(_, idx)
        -- Trim crumbs to the clicked level
        while #crumbs > idx do
            table.remove(crumbs)
        end
        bc2:SetItems(crumbs)
    end)

    stack:AddChild(ex2.block)

    refresh()
end)
