# Changelog

All notable changes to SpacesGrid are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
SpacesGrid uses [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

_Changes that are merged but not yet tagged as a release._

---

## [1.0.0] — 2026-03-21

### Added

- Menu-bar status item with a configurable N × M grid of Space indicators.
- Three visual states per cell: **active** (accent colour fill), **occupied**
  (custom colour fill), and **empty** (border outline).
- Optional fullscreen / Stage Manager badge (small dot in the cell corner).
- **Preferences window** with three tabs:
  - **Appearance** — active colour, occupied colour, empty border colour,
    border width (0.25–4 pt), corner radius (0–8 pt), live grid preview.
  - **Grid** — columns (1–12), rows (1–6), cell width, cell height, gap,
    live grid preview.
  - **Behaviour** — refresh interval (0.5–10 s), fullscreen indicator toggle,
    launch-at-login toggle (`SMAppService`).
- All settings persisted immediately to `UserDefaults`; changes apply without
  restarting the app.
- **Reset to Defaults** button on the Appearance tab.
- Space-switch detection via `NSWorkspace.activeSpaceDidChangeNotification`.
- Window-occupancy detection via private `CGSCopySpacesForWindows` API
  cross-referenced with `CGWindowListCopyWindowInfo`.
- Appearance-change reaction via `AppleInterfaceThemeChangedNotification`.
- `build.sh` supporting native-arch and `--universal` (arm64 + x86\_64) builds.
- Ad-hoc code signing for Apple Silicon compatibility.
- MIT licence.

[Unreleased]: https://github.com/euxhenh/SpacesGrid/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/euxhenh/SpacesGrid/releases/tag/v1.0.0
