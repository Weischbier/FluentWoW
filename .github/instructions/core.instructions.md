---
applyTo: "FluentWoW/Core/**"
---

# Core Runtime Module Rules

## Architecture Invariants

### Bootstrap.lua
- **Version negotiation is untouchable** without explicit maintainer review
- The guard `if FluentWoW and (FluentWoW.version or 0) >= MINOR then return end` ensures multi-embed safety
- Never change the version encoding scheme (`MAJOR*10000 + MINOR*100 + PATCH`)
- `FluentWoW:RegisterModule(name, tbl)` is the only way sub-modules attach themselves

### Utils.lua
- All helper functions are pure and combat-safe
- `Utils.SafeCall()` must be used for all consumer callbacks — never raw `pcall`
- Adding new utility functions is safe; modifying existing ones requires review

### EventBus.lua
- Pub/sub must remain synchronous (no deferred delivery)
- Event names are strings; no enum or validation required
- `Emit`, `On`, `Off`, `Once` is the complete public API

### StateMachine.lua
- Valid states: `Normal`, `Hover`, `Pressed`, `Disabled`, `Focused`, `Selected`, `Checked`, `Expanded`, `Error`, `Warning`
- Adding new states requires updating this list and `.docs/DesignRules.md`
- `SetState()` fires handlers AND calls `control.OnStateChanged` via SafeCall

### FramePool.lua
- `Acquire()` returns a recycled frame or creates a new one
- `Release()` hides the frame and resets it
- All list-like controls (ComboBox dropdown, future ListView, GridView) MUST use FramePool

## Vendored Libraries

- Vendored libs (`FluentWoW/Libs/`) load BEFORE Core in the TOC
- Core modules must NOT depend on vendored libs directly (Core is the lowest layer)
- Other modules (Controls, Motion, Settings) may use vendored libs freely
- Vendored lib files must NOT be modified — use as-is

## Prohibited Actions in Core/

- No `CreateFrame()` calls in Core modules (except FramePool internals)
- No token lookups in Core modules (Core is below the Tokens layer)
- No UI-specific logic in Core modules
- No external addon dependencies
