-- FluentWoW luacheck configuration
-- Target: WoW addon runtime (Lua 5.1)

std = "lua51"
max_line_length = false
codes = true

-- WoW addon globals are allowed to be read
read_globals = {
    -- WoW frame API
    "CreateFrame",
    "UIParent",
    "GameTooltip",
    "InCombatLockdown",
    "Mixin",
    "MouseIsOver",
    "PlaySound",
    "GetTime",
    "C_Timer",
    "hooksecurefunc",
    "GetScreenWidth",
    "GetScreenHeight",
    "securecall",
    "issecurevariable",
    "geterrorhandler",
    "Clamp",
    "Lerp",
    "PixelUtil",
    "BackdropTemplateMixin",
    "SlashCmdList",

    -- WoW chat
    "DEFAULT_CHAT_FRAME",
    "ChatFontNormal",

    -- WoW sound
    "SOUNDKIT",

    -- WoW font objects
    "GameFontNormal",
    "GameFontNormalSmall",
    "GameFontNormalLarge",
    "GameFontHighlight",
    "GameFontHighlightSmall",
    "STANDARD_TEXT_FONT",
    "NumberFontNormal",
    "SystemFont_Med1",

    -- Blizzard shared utilities
    "wipe",
    "tinsert",
    "tremove",
    "strsplit",
    "strmatch",
    "strfind",
    "strsub",
    "strlen",
    "strupper",
    "strlower",
}

-- FluentWoW owns these globals
globals = {
    "FluentWoW",

    -- XML template script handlers (Controls)
    "FWoWButton_OnLoad",
    "FWoWButton_OnEnter",
    "FWoWButton_OnLeave",
    "FWoWButton_OnMouseDown",
    "FWoWButton_OnMouseUp",
    "FWoWButton_OnClick",
    "FWoWToggleButton_OnLoad",
    "FWoWToggleButton_OnClick",
    "FWoWCheckBox_OnLoad",
    "FWoWCheckBox_OnClick",
    "FWoWCheckBox_OnEnter",
    "FWoWCheckBox_OnLeave",
    "FWoWRadioButton_OnLoad",
    "FWoWRadioButton_OnClick",
    "FWoWRadioButton_OnEnter",
    "FWoWRadioButton_OnLeave",
    "FWoWToggleSwitch_OnLoad",
    "FWoWToggleSwitch_OnClick",
    "FWoWToggleSwitch_OnEnter",
    "FWoWToggleSwitch_OnLeave",
    "FWoWToggleSwitch_OnMouseDown",
    "FWoWTextBlock_OnLoad",
    "FWoWTextBlock_Display_OnLoad",
    "FWoWTextBlock_Title_OnLoad",
    "FWoWTextBlock_Caption_OnLoad",
    "FWoWTextBox_OnLoad",
    "FWoWTextBox_OnEnter",
    "FWoWTextBox_OnLeave",
    "FWoWTextBox_OnTextChanged",
    "FWoWTextBox_OnFocusGained",
    "FWoWTextBox_OnFocusLost",
    "FWoWTextBox_OnEnterPressed",
    "FWoWTextBox_OnEscapePressed",
    "FWoWSearchBox_OnLoad",
    "FWoWSlider_OnLoad",
    "FWoWSlider_OnEnter",
    "FWoWSlider_OnLeave",
    "FWoWSlider_OnMouseDown",
    "FWoWSlider_OnMouseUp",
    "FWoWSlider_OnUpdate",
    "FWoWSlider_OnSizeChanged",
    "FWoWComboBox_OnLoad",
    "FWoWComboBox_OnClick",
    "FWoWComboBox_OnEnter",
    "FWoWComboBox_OnLeave",
    "FWoWComboBoxItem_OnLoad",
    "FWoWComboBoxItem_OnClick",
    "FWoWComboBoxItem_OnEnter",
    "FWoWComboBoxItem_OnLeave",
    "FWoWProgressBar_OnLoad",
    "FWoWProgressBar_OnSizeChanged",
    "FWoWProgressBarIndeterminate_OnLoad",
    "FWoWProgressRing_OnLoad",
    "FWoWProgressRing_OnShow",
    "FWoWProgressRing_OnHide",
    "FWoWInfoBar_OnLoad",
    "FWoWInfoBar_CloseBtn_OnLoad",
    "FWoWInfoBar_CloseBtn_OnClick",
    "FWoWContentDialog_OnLoad",
    "FWoWContentDialog_OnKeyDown",
    "FWoWExpander_OnLoad",
    "FWoWTabView_OnLoad",
    "FWoWTabItem_OnLoad",
    "FWoWTabItem_OnClick",
    "FWoWTabItem_OnEnter",
    "FWoWTabItem_OnLeave",
    "FWoWScrollFrame_OnLoad",
    "FWoWScrollFrame_OnMouseWheel",
    "FWoWScrollFrame_OnScroll",
    "FWoWScrollFrame_OnRangeChanged",

    -- Layout script handlers
    "FWoWStackLayout_OnLoad",
    "FWoWStackLayout_OnSizeChanged",
    "FWoWHStackLayout_OnLoad",

    -- Settings script handlers
    "FWoWSettingsCard_OnLoad",
    "FWoWSettingsCard_OnEnter",
    "FWoWSettingsCard_OnLeave",
    "FWoWSettingsExpander_OnLoad",

    -- Gallery slash commands
    "SLASH_FWOW1",
    "SLASH_FWOW2",
    "SLASH_WINUIGALLERY1",
}

-- Per-file overrides
files["FluentWoW-Gallery/**/*.lua"] = {
    read_globals = {
        "FluentWoW",
    },
}

-- Suppress warnings for unused self in method definitions
self = false
