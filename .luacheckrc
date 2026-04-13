-- FluentWoW luacheck configuration
-- Target: WoW addon runtime (Lua 5.1)

std = "lua51"
max_line_length = false
codes = true

-- Unused arguments are common in WoW callback signatures (prevState, newState,
-- flag, value, etc.) — suppress the warning globally.
unused_args = false

-- Suppress warnings for unused self in method definitions
self = false

-- Variables prefixed with _ are intentionally unused (Lua convention)
ignore = { "21./_.*", "231/_.*" }

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
    "GetCursorPosition",
    "securecall",
    "issecurevariable",
    "geterrorhandler",
    "Clamp",
    "Lerp",
    "PixelUtil",
    "BackdropTemplateMixin",
    "SlashCmdList",
    "Enum",
    "UISpecialFrames",
    "LibStub",

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

    -- XML template script handlers (Button)
    "FWoWButton_OnLoad",
    "FWoWButton_OnEnter",
    "FWoWButton_OnLeave",
    "FWoWButton_OnMouseDown",
    "FWoWButton_OnMouseUp",
    "FWoWButton_OnClick",
    "FWoWButton_OnEnable",
    "FWoWButton_OnDisable",
    "FWoWButtonSubtle_OnLoad",
    "FWoWButtonDestructive_OnLoad",
    "FWoWIconButton_OnLoad",
    "FWoWToggleButton_OnLoad",
    "FWoWToggleButton_OnClick",

    -- CheckBox
    "FWoWCheckBox_OnLoad",
    "FWoWCheckBox_OnClick",
    "FWoWCheckBox_OnEnter",
    "FWoWCheckBox_OnLeave",

    -- RadioButton
    "FWoWRadioButton_OnLoad",
    "FWoWRadioButton_OnClick",
    "FWoWRadioButton_OnEnter",
    "FWoWRadioButton_OnLeave",

    -- ToggleSwitch
    "FWoWToggleSwitch_OnLoad",
    "FWoWToggleSwitch_OnClick",
    "FWoWToggleSwitch_OnEnter",
    "FWoWToggleSwitch_OnLeave",
    "FWoWToggleSwitch_OnMouseDown",

    -- TextBlock
    "FWoWTextBlock_OnLoad",
    "FWoWTextBlock_Display_OnLoad",
    "FWoWTextBlock_Title_OnLoad",
    "FWoWTextBlock_Caption_OnLoad",

    -- TextBox
    "FWoWTextBox_OnLoad",
    "FWoWTextBox_OnEnter",
    "FWoWTextBox_OnLeave",
    "FWoWTextBox_OnTextChanged",
    "FWoWTextBox_OnFocusGained",
    "FWoWTextBox_OnFocusLost",
    "FWoWTextBox_OnEnterPressed",
    "FWoWTextBox_OnEscapePressed",
    "FWoWTextBox_OnClear",
    "FWoWTextBox_OnMouseDown",
    "FWoWSearchBox_OnLoad",

    -- Slider
    "FWoWSlider_OnLoad",
    "FWoWSlider_OnEnter",
    "FWoWSlider_OnLeave",
    "FWoWSlider_OnMouseDown",
    "FWoWSlider_OnMouseUp",
    "FWoWSlider_OnUpdate",
    "FWoWSlider_OnSizeChanged",
    "FWoWSlider_OnValueChanged",

    -- ComboBox
    "FWoWComboBox_OnLoad",
    "FWoWComboBox_OnClick",
    "FWoWComboBox_OnEnter",
    "FWoWComboBox_OnLeave",
    "FWoWComboBox_OnHide",
    "FWoWComboBoxItem_OnLoad",
    "FWoWComboBoxItem_OnClick",
    "FWoWComboBoxItem_OnEnter",
    "FWoWComboBoxItem_OnLeave",

    -- NumberBox
    "FWoWNumberBox_OnLoad",
    "FWoWNumberBox_OnEnter",
    "FWoWNumberBox_OnLeave",
    "FWoWNumberBox_OnTextChanged",
    "FWoWNumberBox_OnFocusGained",
    "FWoWNumberBox_OnFocusLost",
    "FWoWNumberBox_OnEnterPressed",
    "FWoWNumberBox_OnEscapePressed",
    "FWoWNumberBox_SpinUp_OnClick",
    "FWoWNumberBox_SpinDown_OnClick",
    "FWoWNumberBox_Spin_OnEnter",
    "FWoWNumberBox_Spin_OnLeave",

    -- ProgressBar / ProgressRing
    "FWoWProgressBar_OnLoad",
    "FWoWProgressBar_OnSizeChanged",
    "FWoWProgressBarIndeterminate_OnLoad",
    "FWoWProgressRing_OnLoad",
    "FWoWProgressRing_OnShow",
    "FWoWProgressRing_OnHide",
    "FWoWProgressRing_OnUpdate",

    -- InfoBar
    "FWoWInfoBar_OnLoad",
    "FWoWInfoBar_CloseBtn_OnLoad",
    "FWoWInfoBar_CloseBtn_OnClick",
    "FWoWInfoBar_OnClose",

    -- ContentDialog
    "FWoWContentDialog_OnLoad",
    "FWoWContentDialog_OnKeyDown",
    "FWoWContentDialog_OnCloseClick",
    "FWoWContentDialog_OnOverlayClick",

    -- Expander
    "FWoWExpander_OnLoad",
    "FWoWExpander_OnHeaderClick",
    "FWoWExpander_OnHeaderEnter",
    "FWoWExpander_OnHeaderLeave",

    -- TabView
    "FWoWTabView_OnLoad",
    "FWoWTabItem_OnLoad",
    "FWoWTabItem_OnClick",
    "FWoWTabItem_OnEnter",
    "FWoWTabItem_OnLeave",
    "FWoWTabItem_Close_OnClick",
    "FWoWTabView_AddButton_OnClick",

    -- ScrollFrame
    "FWoWScrollFrame_OnLoad",
    "FWoWScrollFrame_OnMouseWheel",
    "FWoWScrollFrame_OnScroll",
    "FWoWScrollFrame_OnRangeChanged",
    "FWoWScrollFrame_OnScrollLoad",
    "FWoWScrollFrame_OnVerticalScroll",
    "FWoWScrollFrame_Thumb_OnMouseDown",
    "FWoWScrollFrame_Thumb_OnMouseUp",

    -- MainFrame
    "FWoWMainFrame_OnLoad",
    "FWoWMainFrame_OnShow",
    "FWoWMainFrame_OnHide",
    "FWoWMainFrame_OnSizeChanged",
    "FWoWMainFrame_CloseBtn_OnClick",
    "FWoWMainFrame_CloseBtn_OnEnter",
    "FWoWMainFrame_CloseBtn_OnLeave",
    "FWoWMainFrame_TitleBar_OnMouseDown",
    "FWoWMainFrame_TitleBar_OnMouseUp",
    "FWoWMainFrame_SizerE_OnMouseDown",
    "FWoWMainFrame_SizerS_OnMouseDown",
    "FWoWMainFrame_SizerSE_OnMouseDown",
    "FWoWMainFrame_Sizer_OnMouseUp",

    -- NavigationView
    "FWoWNavigationView_OnLoad",
    "FWoWNavItem_OnClick",
    "FWoWNavItem_OnEnter",
    "FWoWNavItem_OnLeave",
    "FWoWNavToggleBtn_OnClick",
    "FWoWNavToggleBtn_OnEnter",
    "FWoWNavToggleBtn_OnLeave",

    -- BreadcrumbBar
    "FWoWBreadcrumbBar_OnLoad",
    "FWoWBreadcrumbItem_OnClick",
    "FWoWBreadcrumbItem_OnEnter",
    "FWoWBreadcrumbItem_OnLeave",

    -- CommandBar
    "FWoWCommandBar_OnLoad",
    "FWoWCommandBarItem_OnClick",
    "FWoWCommandBarItem_OnEnter",
    "FWoWCommandBarItem_OnLeave",
    "FWoWCommandBar_Overflow_OnClick",
    "FWoWCommandBar_Overflow_OnEnter",
    "FWoWCommandBar_Overflow_OnLeave",

    -- SegmentedControl
    "FWoWSegmentedControl_OnLoad",
    "FWoWSegmentItem_OnClick",
    "FWoWSegmentItem_OnEnter",
    "FWoWSegmentItem_OnLeave",

    -- Badge
    "FWoWBadge_OnLoad",

    -- EmptyState
    "FWoWEmptyState_OnLoad",

    -- Skeleton
    "FWoWSkeleton_OnLoad",

    -- TeachingTip
    "FWoWTeachingTip_OnLoad",
    "FWoWTeachingTip_Close_OnClick",

    -- Layout script handlers
    "FWoWStackLayout_OnLoad",
    "FWoWStackLayout_OnSizeChanged",
    "FWoWHStackLayout_OnLoad",

    -- Settings script handlers
    "FWoWSettingsCard_OnLoad",
    "FWoWSettingsCard_OnEnter",
    "FWoWSettingsCard_OnLeave",
    "FWoWSettingsCard_OnMouseDown",
    "FWoWSettingsCard_OnMouseUp",
    "FWoWSettingsExpander_OnLoad",
    "FWoWSettingsExpander_Header_OnClick",
    "FWoWSettingsExpander_Header_OnEnter",
    "FWoWSettingsExpander_Header_OnLeave",

    -- Gallery slash commands
    "SLASH_FWOW1",
    "SLASH_FWOW2",
    "SLASH_WINUIGALLERY1",
}

-- Per-file overrides
files["FluentWoW-Gallery/**/*.lua"] = {
    -- Gallery needs to write SlashCmdList and FluentWoW._gallery
    globals = {
        "FluentWoW",
        "LibStub",
        "SlashCmdList",
        "SLASH_FWOW1",
        "SLASH_FWOW2",
        "SLASH_WINUIGALLERY1",
    },
}

-- Vendored libraries — suppress all style warnings
files["FluentWoW/Libs/**/*.lua"] = {
    ignore = { "" },
}
