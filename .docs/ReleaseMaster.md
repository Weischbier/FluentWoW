# WinUILib — Release Master

> Release workflow and packaging checklist.

---

## Versioning

WinUILib uses semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking API changes (must have migration guide)
- **MINOR**: New controls, features, non-breaking additions
- **PATCH**: Bug fixes, doc updates, internal improvements

The version is encoded in `Bootstrap.lua` as `MINOR = MAJOR*10000 + MINOR*100 + PATCH`.
Example: `1.2.3` → `10203`

## Release Checklist

### Pre-Release

- [ ] All design rules pass (run auditor)
- [ ] luacheck passes with no errors
- [ ] Gallery demonstrates all new/changed controls
- [ ] ARCHITECTURE.md control catalog is current
- [ ] `.docs/MasterPlan.md` control inventory is current
- [ ] `.docs/PortabilityMatrix.md` statuses are current

### Version Bump

1. Update `MINOR` in `WinUILib/Core/Bootstrap.lua`:
   ```lua
   local MAJOR, MINOR = "WinUILib", 10200  -- 1.2.0
   ```

2. Update `## Version:` in `WinUILib/WinUILib.toc`:
   ```
   ## Version: 1.2.0
   ```

3. Update `## Version:` in `WinUILib-Gallery/WinUILib-Gallery.toc`:
   ```
   ## Version: 1.2.0
   ```

4. Update version in `ARCHITECTURE.md` header:
   ```
   > Version 1.2.0
   ```

5. Add release entry to `CHANGELOG.md`:
   ```markdown
   ## [1.2.0] - YYYY-MM-DD

   ### Added
   - (list new controls and features)

   ### Changed
   - (list changes)

   ### Fixed
   - (list bug fixes)

   ### Deprecated
   - (list deprecated APIs with removal target)
   ```

### Tag and Release

1. Commit all version bumps: `git commit -am "Release v1.2.0"`
2. Tag: `git tag -a v1.2.0 -m "Release v1.2.0"`
3. Push: `git push origin main --tags`

### CurseForge / Wago Packaging

The `.pkgmeta` file configures the BigWigs packager.

**Package structure**:
- `WinUILib/` — the library (main package)
- Gallery is excluded from the distributable package (dev-only)

**Manual packaging** (if not using CI):
1. Clone the repo
2. Run the BigWigs packager: `./release.sh` or use the CurseForge upload tool
3. Upload the resulting zip to CurseForge and Wago

**CI packaging** (when configured):
- GitHub Actions workflow triggers on tag push `v*`
- Uses BigWigs packager action
- Uploads to CurseForge and Wago via API tokens

### Post-Release

- [ ] Verify package appears on CurseForge / Wago
- [ ] Verify version string in-game: `print(WinUILib.version)`
- [ ] Verify Gallery works with the new version
- [ ] Update `.docs/MasterPlan.md` phase status if a phase milestone was reached

## Deprecation Policy

From ARCHITECTURE.md §14:

- Deprecated APIs are kept for **2 minor versions** after deprecation
- Deprecated methods must:
  1. Print a one-time warning via `lib:Debug()`
  2. Forward to the replacement method
  3. Be documented in CHANGELOG.md under `### Deprecated`
- After 2 minor versions, deprecated methods are removed in the next MINOR or MAJOR release
- Removal is documented in CHANGELOG.md under `### Removed`
