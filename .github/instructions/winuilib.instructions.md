---
applyTo: "FluentWoW/**"
---

# FluentWoW — Cross-Cutting Library Rules

## Source of Truth
- Design rules: `.docs/DesignRules.md`
- Design specs (pixel measurements): `.docs/DesignSpecs.md`
- Architecture: `ARCHITECTURE.md`
- Token reference: `.docs/TokenReference.md`
- Porting guide: `.docs/ControlPortingGuide.md`
- WinUI specs: `.help/.sources/microsoft-ui-xaml-main/specs/`
- WinUI Gallery source: `.help/.sources/WinUI-Gallery-main/`
- Blizzard addon reference: `.help/.helper/AddOns/` (native Blizzard UI source)
- Vendored libraries: `FluentWoW/Libs/` (Ace3, Motion, PureLua)

## Non-Negotiable Rules (ARCHITECTURE.md §16)

1. Never hardcode colour values — always use `Tokens:GetColor()`
2. Never call `Show()` on a protected frame in combat
3. Never use absolute pixel positions — anchor relative to parent
4. Always gate popup/dialog operations with `InCombatLockdown()`
5. Always use `FramePool` for repeated frame creation
6. Always stop `OnUpdate` scripts when the animation completes
7. Never add new Lua globals — everything lives under `FluentWoW.*` (exception: `WUIL*` XML handlers)
8. Always expose `OnStateChanged` so theming can react to state
9. Never remove or rename a public API without a deprecation cycle (2 minor versions)
10. Always test at UIParent scale 0.64 and 1.5

## Coding Conventions

- All Lua files start with a header comment: `--- FluentWoW – <Module>/<File>.lua`
- Use `---@param` and `---@return` annotations for public API methods
- Use `local` for all file-scoped variables and functions
- Global functions are ONLY allowed for XML script handlers (`WUIL<Name>_<Event>`)
- Callbacks from consumers should be invoked via `lib.Utils.SafeCall()`
- All colors, spacing, fonts, and timing values must come from the token system
- Prefer `Tokens:GetColor()`, `Tokens:GetSpacing()`, `Tokens:GetFont()`, `Tokens:Get()`

## Combat Safety

- Any control that creates popup/overlay frames (ComboBox dropdown, ContentDialog, Flyout) MUST:
  - Check `InCombatLockdown()` before `Show()`
  - Either block the operation or defer it to `PLAYER_REGEN_ENABLED`
  - Log a debug message when blocked

## Global Namespace

- The ONLY allowed global is `FluentWoW`
- XML script handlers use global functions: `WUIL<ControlName>_<Event>`
- Everything else MUST be local or attached to `FluentWoW.*`

## Pixel-Fidelity Rule

Every spacing, padding, margin, gap, and size value in FluentWoW controls MUST match
the WinUI design spec pixel values exactly. No approximations. See `.docs/DesignSpecs.md`
for the authoritative measurements extracted from WinUI Gallery design images.

- Always cross-reference `.help/.sources/microsoft-ui-xaml-main/specs/` for control-specific measurements
- Always cross-reference `.help/.sources/WinUI-Gallery-main/WinUIGallery/Assets/Design/` for visual measurements
- Map pixel values to spacing tokens where one exists (e.g., 16px → `Spacing.XL`)
- Use literal pixel values only where no matching token exists — document the value

## Vendored Libraries

- `Libs/Ace3/` — Full Ace3 suite (LibStub, CallbackHandler, AceAddon, AceDB, AceEvent, AceGUI, etc.)
- `Libs/Motion/` — flux (tween engine), knife.base, knife.timer
- `Libs/PureLua/` — 30log (OOP), dkjson (JSON), i18n (localization), inspect (debug), lume (utils), serpent (serialization)
- All Motion/PureLua libs use `__MetroLib_Load()` wrapper pattern for WoW embedding
- Libs load BEFORE Core in the TOC — they're available to all FluentWoW modules
- **Do NOT modify**: vendored lib files must not be rewritten, altered, or adapted — use them as-is

## Reference Directories

- `.help/.helper/AddOns/` — All native Blizzard addon source for API reference
- `.help/.helper/Libs/` — Original library sources (copied into `FluentWoW/Libs/`)
- `.help/.sources/microsoft-ui-xaml-main/specs/` — WinUI control specifications with measurements
- `.help/.sources/WinUI-Gallery-main/` — WinUI Gallery XAML source + design images
