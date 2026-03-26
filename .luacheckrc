-- WinUILib luacheck configuration
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

-- WinUILib owns these globals
globals = {
    "WinUILib",

    -- XML template script handlers (Controls)
    "WUILButton_OnLoad",
    "WUILButton_OnEnter",
    "WUILButton_OnLeave",
    "WUILButton_OnMouseDown",
    "WUILButton_OnMouseUp",
    "WUILButton_OnClick",
    "WUILToggleButton_OnLoad",
    "WUILToggleButton_OnClick",
    "WUILCheckBox_OnLoad",
    "WUILCheckBox_OnClick",
    "WUILCheckBox_OnEnter",
    "WUILCheckBox_OnLeave",
    "WUILRadioButton_OnLoad",
    "WUILRadioButton_OnClick",
    "WUILRadioButton_OnEnter",
    "WUILRadioButton_OnLeave",
    "WUILToggleSwitch_OnLoad",
    "WUILToggleSwitch_OnClick",
    "WUILToggleSwitch_OnEnter",
    "WUILToggleSwitch_OnLeave",
    "WUILToggleSwitch_OnMouseDown",
    "WUILTextBlock_OnLoad",
    "WUILTextBlock_Display_OnLoad",
    "WUILTextBlock_Title_OnLoad",
    "WUILTextBlock_Caption_OnLoad",
    "WUILTextBox_OnLoad",
    "WUILTextBox_OnEnter",
    "WUILTextBox_OnLeave",
    "WUILTextBox_OnTextChanged",
    "WUILTextBox_OnFocusGained",
    "WUILTextBox_OnFocusLost",
    "WUILTextBox_OnEnterPressed",
    "WUILTextBox_OnEscapePressed",
    "WUILSearchBox_OnLoad",
    "WUILSlider_OnLoad",
    "WUILSlider_OnEnter",
    "WUILSlider_OnLeave",
    "WUILSlider_OnMouseDown",
    "WUILSlider_OnMouseUp",
    "WUILSlider_OnUpdate",
    "WUILSlider_OnSizeChanged",
    "WUILComboBox_OnLoad",
    "WUILComboBox_OnClick",
    "WUILComboBox_OnEnter",
    "WUILComboBox_OnLeave",
    "WUILComboBoxItem_OnLoad",
    "WUILComboBoxItem_OnClick",
    "WUILComboBoxItem_OnEnter",
    "WUILComboBoxItem_OnLeave",
    "WUILProgressBar_OnLoad",
    "WUILProgressBar_OnSizeChanged",
    "WUILProgressBarIndeterminate_OnLoad",
    "WUILProgressRing_OnLoad",
    "WUILProgressRing_OnShow",
    "WUILProgressRing_OnHide",
    "WUILInfoBar_OnLoad",
    "WUILInfoBar_CloseBtn_OnLoad",
    "WUILInfoBar_CloseBtn_OnClick",
    "WUILContentDialog_OnLoad",
    "WUILContentDialog_OnKeyDown",
    "WUILExpander_OnLoad",
    "WUILTabView_OnLoad",
    "WUILTabItem_OnLoad",
    "WUILTabItem_OnClick",
    "WUILTabItem_OnEnter",
    "WUILTabItem_OnLeave",
    "WUILScrollFrame_OnLoad",
    "WUILScrollFrame_OnMouseWheel",
    "WUILScrollFrame_OnScroll",
    "WUILScrollFrame_OnRangeChanged",

    -- Layout script handlers
    "WUILStackLayout_OnLoad",
    "WUILStackLayout_OnSizeChanged",
    "WUILHStackLayout_OnLoad",

    -- Settings script handlers
    "WUILSettingsCard_OnLoad",
    "WUILSettingsCard_OnEnter",
    "WUILSettingsCard_OnLeave",
    "WUILSettingsExpander_OnLoad",

    -- Gallery slash commands
    "SLASH_WUIL1",
    "SLASH_WUIL2",
    "SLASH_WINUIGALLERY1",
}

-- Per-file overrides
files["WinUILib-Gallery/**/*.lua"] = {
    read_globals = {
        "WinUILib",
    },
}

-- Suppress warnings for unused self in method definitions
self = false
