# WinUILib — Portability Matrix

> Per-control portability assessment for all WinUI Gallery controls.
> Updated as controls are assessed and ported.
>
> **Portability ratings**: ✅ Direct | ⚠️ Adapted | ❌ Not viable | 🔲 Not assessed
> **Status**: ✅ Implemented | 🔨 In progress | 📋 Assessed | 🔲 Not started

---

## Implemented Controls (Phase 1)

| WinUI Control | Portability | WoW Strategy | Status |
|---|---|---|---|
| Button | ✅ Direct | `Button` widget + token-driven accent/subtle/destructive variants | ✅ Implemented |
| CheckBox | ✅ Direct | `Button` + check texture toggle | ✅ Implemented |
| ComboBox | ✅ Adapted | `Frame` dropdown + FramePool items; combat-guarded | ✅ Implemented |
| ContentDialog | ✅ Adapted | `Frame` DIALOG strata + backdrop; combat-deferred | ✅ Implemented |
| Expander | ✅ Adapted | `Frame` + height animation via Motion | ✅ Implemented |
| InfoBar | ✅ Direct | `Frame` + severity color tokens | ✅ Implemented |
| ProgressBar | ✅ Direct | `Frame` + status bar texture + indeterminate anim | ✅ Implemented |
| ProgressRing | ✅ Adapted | Spinning texture animation | ✅ Implemented |
| RadioButton | ✅ Direct | `Button` in radio group | ✅ Implemented |
| ScrollFrame | ✅ Direct | WoW `ScrollFrame` widget | ✅ Implemented |
| Slider | ✅ Direct | WoW `Slider` widget + tokens | ✅ Implemented |
| StackLayout | ✅ Direct | `Frame` + programmatic anchoring | ✅ Implemented |
| TabView | ✅ Adapted | `Frame` + tab buttons + content switching | ✅ Implemented |
| TextBlock | ✅ Direct | `FontString` wrapper with type ramp | ✅ Implemented |
| TextBox | ✅ Direct | WoW `EditBox` widget | ✅ Implemented |
| ToggleButton | ✅ Direct | `Button` + checked state | ✅ Implemented |
| ToggleSwitch | ✅ Adapted | `Frame` + thumb animation | ✅ Implemented |
| SettingsCard | ✅ Direct | `Frame` with header/description/action layout | ✅ Implemented |
| SettingsExpander | ✅ Adapted | `Frame` + Expander-style height animation | ✅ Implemented |

## Phase 2 — Navigation + Advanced Layout

| WinUI Control | Portability | WoW Strategy | Blockers | Status |
|---|---|---|---|---|
| NavigationView | ⚠️ Adapted | Sidebar `Frame` + item list + content area; no hamburger/compact | No built-in navigation chrome | 🔲 Not started |
| BreadcrumbBar | ⚠️ Adapted | HStack of clickable TextBlocks with separator | No native breadcrumb | 🔲 Not started |
| NumberBox | ⚠️ Adapted | `EditBox` + validation + spinner buttons | Must validate numeric input in Lua | 🔲 Not started |
| Grid | ⚠️ Adapted | `Frame` + computed row/column anchors | No CSS grid; manual layout math | 🔲 Not started |
| SplitView | ⚠️ Adapted | Two-pane Frame with draggable divider | Manual resize handling | 🔲 Not started |

## Phase 3 — Advanced Controls

| WinUI Control | Portability | WoW Strategy | Blockers | Status |
|---|---|---|---|---|
| TeachingTip | ⚠️ Adapted | Tooltip-like `Frame` with pointer + dismiss | No native callout/pointer shape | 🔲 Not started |
| CommandBar | ⚠️ Adapted | HStack of icon buttons + overflow menu | No native toolbar widget | 🔲 Not started |
| TreeView | ⚠️ Adapted | Nested FramePool items with indent + expand | No native tree; manual indentation | 🔲 Not started |
| MenuBar | ⚠️ Adapted | HStack of dropdown-trigger buttons | Manual menu positioning | 🔲 Not started |
| MenuFlyout | ⚠️ Adapted | Popup Frame + FramePool menu items | Combat-guard popups | 🔲 Not started |
| Flyout | ⚠️ Adapted | Tooltip-positioned popup Frame | Combat-guard | 🔲 Not started |
| ToolTip | ✅ Direct | WoW GameTooltip integration or custom frame | WoW has built-in tooltip | 🔲 Not started |
| InfoBadge | ✅ Direct | Small overlay Frame with number/dot | Simple visual overlay | 🔲 Not started |
| RatingControl | ⚠️ Adapted | Row of star buttons/textures | Manual star rendering | 🔲 Not started |
| PipsPager | ⚠️ Adapted | Row of dot indicators | Simple visual | 🔲 Not started |
| SelectorBar | ⚠️ Adapted | HStack of selectable buttons (like tabs) | Similar to TabView header | 🔲 Not started |
| DropDownButton | ✅ Direct | Button + dropdown popup | Extends Button + ComboBox dropdown | 🔲 Not started |
| SplitButton | ⚠️ Adapted | Two-part button (action + dropdown) | Compound frame layout | 🔲 Not started |
| ToggleSplitButton | ⚠️ Adapted | SplitButton + toggle state | Extends SplitButton | 🔲 Not started |
| RepeatButton | ✅ Direct | Button with repeat-fire on hold | OnUpdate while mouse down | 🔲 Not started |
| HyperlinkButton | ✅ Direct | Button styled as hyperlink text | Simple variant | 🔲 Not started |
| PasswordBox | ⚠️ Adapted | EditBox with masked text display | WoW EditBox has no native mask; overlay approach | 🔲 Not started |
| AutoSuggestBox | ⚠️ Adapted | EditBox + dropdown suggestion list | Combines TextBox + ComboBox dropdown | 🔲 Not started |
| ColorPicker | ⚠️ Adapted | HSV picker frame with gradient textures | No native color picker; texture-based | 🔲 Not started |

## Assessed as Not Viable / Deferred

| WinUI Control | Portability | Reason |
|---|---|---|
| CalendarDatePicker | ❌ Not viable | WoW has no date/time system accessible to addons |
| CalendarView | ❌ Not viable | Same as above |
| DatePicker | ❌ Not viable | No addon-accessible date API |
| TimePicker | ❌ Not viable | Limited; GetGameTime() is only game time |
| MediaPlayerElement | ❌ Not viable | WoW cannot play arbitrary media |
| WebView2 | ❌ Not viable | No web rendering in WoW |
| MapControl | ❌ Not viable | WoW map API is entirely different |
| ConnectedAnimation | ❌ Not viable | No element-to-element animation system |
| ParallaxView | ❌ Not viable | No parallax scrolling support |
| SemanticZoom | ❌ Not viable | No zoom-level concept |
| SwipeControl | ❌ Not viable | No swipe/touch input |
| PullToRefresh | ❌ Not viable | No swipe/touch input |
| Acrylic | ⚠️ Partial | Can approximate with backdrop alpha; no blur |
| SystemBackdrops | ⚠️ Partial | BackdropTemplate only; no Mica/Acrylic |
| ThemeShadow | ⚠️ Partial | No real drop shadows; simulated with border tints |
| AnimatedIcon | ⚠️ Partial | WoW has no Lottie/animated vector; texture anim only |
| AnimatedVisualPlayer | ❌ Not viable | No Lottie/Composition API |
| AppWindow / TitleBar | ❌ Not viable | WoW frames are not OS windows |
| AppNotification | ❌ Not viable | No OS notification system |
| BadgeNotificationManager | ❌ Not viable | No OS badge system |
| ContentIsland | ❌ Not viable | WoW has no content island concept |
| Clipboard | ❌ Not viable | WoW blocks clipboard access |
| StoragePickers | ❌ Not viable | WoW has no file system access |
| Sound | ✅ Direct | WoW PlaySound API | 🔲 Not started |
| XamlCompInterop | ❌ Not viable | XAML-specific |
| XamlUICommand | ❌ Not viable | XAML-specific |
| StandardUICommand | ❌ Not viable | XAML-specific |

## Not Yet Assessed

| WinUI Control | Notes |
|---|---|
| Border | Likely ✅ Direct — backdrop + border texture |
| Canvas | Likely ⚠️ Adapted — absolute-position container |
| FlipView | Likely ⚠️ Adapted — paginated content viewer |
| GridView | Likely ⚠️ Adapted — grid of items with FramePool |
| Image | Likely ✅ Direct — Texture widget |
| ItemsRepeater | Likely ⚠️ Adapted — FramePool-based repeater |
| ItemsView | Likely ⚠️ Adapted — similar to GridView/ListView |
| ListBox | Likely ⚠️ Adapted — scrollable selection list |
| ListView | Likely ⚠️ Adapted — scrollable item list with FramePool |
| PersonPicture | Likely ⚠️ Adapted — circular texture + initials fallback |
| Pivot | Likely ⚠️ Adapted — similar to TabView |
| Popup | Likely ✅ Direct — Frame at high strata |
| RelativePanel | Likely ⚠️ Adapted — constraint-based layout |
| RichEditBox | ❌ Likely not viable — WoW EditBox is plain text only |
| RichTextBlock | ⚠️ Partial — WoW has some escape sequence formatting |
| ScrollView | ✅ Already have ScrollFrame |
| Shape / Line | ⚠️ Partial — texture-based line rendering |
| StackPanel | ✅ Already have StackLayout |
| VariableSizedWrapGrid | ⚠️ Adapted — manual wrap layout calculation |
| Viewbox | ⚠️ Adapted — scale-to-fit container |
| CompactSizing | ✅ Direct — token-based density mode |
| EasingFunction | ✅ Direct — Motion module easing |
| ImplicitTransition | ⚠️ Adapted — auto-animation on property change |
| PageTransition | ✅ Adapted — FadeIn/FadeOut between pages |
| ThemeTransition | ⚠️ Adapted — animate on theme change |
