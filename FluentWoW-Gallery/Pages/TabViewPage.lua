--- FluentWoW-Gallery -- Pages/TabViewPage.lua
-- Mirrors WinUI Gallery TabViewPage.
-------------------------------------------------------------------------------

local lib = LibStub("FluentWoW-1.0")
local T = lib.Tokens
local Icons = lib.Icons
local Gallery = lib._gallery

Gallery:RegisterControlPage("TabView", function(parent, item)
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
    -- Example 1: Basic TabView with icons
    ---------------------------------------------------------------------------
    local ex1 = Gallery:CreateControlExample(stack, {
        headerText = "A TabView with icons and closable tabs.",
        exampleHeight = 260,
        noOutput = true,
        noOptions = true,
    })

    local tv1 = lib:CreateTabView(ex1.example)
    tv1:SetAllPoints(ex1.example)

    local tabCount = 0
    local function makeContent(title)
        local f = CreateFrame("Frame", nil, tv1)
        local label = lib:CreateTextBlock(f)
        label:SetStyle("Body")
        label:SetText("Content for " .. title)
        label:SetPoint("CENTER")
        return f
    end

    tv1:AddTab({ text = "Home",     icon = Icons.Home,     content = makeContent("Home"),     closable = true })
    tv1:AddTab({ text = "Profile",  icon = Icons.Edit,     content = makeContent("Profile"),  closable = true })
    tv1:AddTab({ text = "Settings", icon = Icons.Settings, content = makeContent("Settings"), closable = true })
    tabCount = 3

    tv1:SetAddButtonVisible(true)
    tv1:SetOnAddTab(function()
        tabCount = tabCount + 1
        local name = "Tab " .. tabCount
        tv1:AddTab({ text = name, content = makeContent(name), closable = true })
    end)

    tv1:SelectTab(1)

    stack:AddChild(ex1.block)

    ---------------------------------------------------------------------------
    -- Example 2: TabView with width mode
    ---------------------------------------------------------------------------
    local ex2 = Gallery:CreateControlExample(stack, {
        headerText = "TabView with tab width modes.",
        exampleHeight = 200,
        noOutput = true,
    })

    local tv2 = lib:CreateTabView(ex2.example)
    tv2:SetAllPoints(ex2.example)
    tv2:AddTab({ text = "Short",                content = makeContent("Short")                })
    tv2:AddTab({ text = "A longer tab label",   content = makeContent("A longer tab label")   })
    tv2:AddTab({ text = "Medium",               content = makeContent("Medium")               })
    tv2:SelectTab(1)

    local modeCombo = lib:CreateComboBox(ex2.options)
    modeCombo:SetHeader("Tab width mode")
    modeCombo:SetItems({
        { text = "Equal",         value = "Equal"         },
        { text = "SizeToContent", value = "SizeToContent" },
    })
    modeCombo:SetSelectedIndex(1)
    modeCombo:SetPoint("TOPLEFT", ex2.optionsAnchor, "BOTTOMLEFT", 0, -8)
    modeCombo:SetOnSelectionChanged(function(_, _, itm)
        tv2:SetTabWidthMode(itm.value)
    end)

    stack:AddChild(ex2.block)

    refresh()
end)
