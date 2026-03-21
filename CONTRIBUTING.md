# Contributing to SpacesGrid

Thank you for taking the time to contribute. All pull requests, bug reports,
and feature ideas are welcome.

## Table of contents

- [Code of conduct](#code-of-conduct)
- [Getting started](#getting-started)
- [How to report a bug](#how-to-report-a-bug)
- [How to suggest a feature](#how-to-suggest-a-feature)
- [Development workflow](#development-workflow)
- [Code style](#code-style)
- [Commit messages](#commit-messages)
- [Pull request checklist](#pull-request-checklist)

---

## Code of conduct

This project follows the [Contributor Covenant](CODE_OF_CONDUCT.md). By
participating, you agree to uphold its standards.

## Getting started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:

   ```bash
   git clone https://github.com/euxhenh/SpacesGrid.git
   cd SpacesGrid
   ```

3. **Verify the build** works on your machine:

   ```bash
   bash build.sh
   open build/SpacesGrid.app
   ```

   You need Xcode Command Line Tools 15+ (`xcode-select --install`).

4. Create a **feature branch** off `main`:

   ```bash
   git checkout -b feature/your-feature-name
   ```

## How to report a bug

Open a [bug report](https://github.com/euxhenh/SpacesGrid/issues/new?template=bug_report.md)
and fill in the template. The most helpful information to include:

- macOS version and chip (Apple Silicon / Intel)
- Number of displays and Spaces you have configured
- Steps to reproduce reliably
- What you expected vs. what actually happened
- Console logs from `Console.app` filtered to "SpacesGrid", if any

**Please do not open a public issue to report a security vulnerability.**
See [SECURITY.md](SECURITY.md) instead.

## How to suggest a feature

Open a [feature request](https://github.com/euxhenh/SpacesGrid/issues/new?template=feature_request.md).
Describe the problem you are trying to solve and, if possible, how you imagine
the solution working. Screenshots or mockups are very helpful.

## Development workflow

The project is intentionally dependency-free. All source files live under
`Sources/` and are compiled with a single `swiftc` invocation in `build.sh`.

| File | Role |
|---|---|
| `Sources/CGSPrivate.swift` | Private CGS API declarations only — no logic |
| `Sources/Preferences.swift` | Settings store; edit here to add a new preference |
| `Sources/PreferencesView.swift` | SwiftUI preferences UI — three-tab panel |
| `Sources/SpacesManager.swift` | All Space/window detection logic |
| `Sources/GridView.swift` | All drawing logic |
| `Sources/AppDelegate.swift` | Wiring: status item, notifications, timers |

**Iterating quickly:**

```bash
pkill -x SpacesGrid; bash build.sh && open build/SpacesGrid.app
```

Or use the Makefile:

```bash
make run
```

### Adding a new preference

1. Add a `@Published` property and its `UserDefaults` key to `Preferences.swift`.
2. Add the corresponding UI row to the appropriate tab in `PreferencesView.swift`.
3. Consume the property in `GridView.draw(_:)` or `AppDelegate`.

No other plumbing is required — `Preferences.didChangeNotification` is already
observed by `AppDelegate` and `GridView` re-reads all values on every draw.

## Code style

- Standard Swift API Design Guidelines naming conventions
- 4-space indentation (no tabs)
- Maximum line length of ~100 characters
- Group related declarations with `// MARK: -` comments
- Keep `CGSPrivate.swift` free of logic — declarations only
- No third-party dependencies

Run `swift-format` if you have it installed; otherwise, match the surrounding
code style.

## Commit messages

Use the imperative mood in the subject line, 72 characters max:

```
Add corner-radius preference to grid cells

Previously the radius was hardcoded to 1.5 pt. This commit adds a
slider in the Appearance tab that saves to UserDefaults under the
key "cornerRadius".
```

Reference related issues with `Fixes #123` or `Closes #123` in the body.

## Pull request checklist

Before opening a PR, please confirm:

- [ ] `bash build.sh` succeeds with zero errors and zero warnings
- [ ] The change has been tested on a real Mac (not just in Simulator)
- [ ] New preferences are persisted to `UserDefaults` and reset by `resetToDefaults()`
- [ ] The PR description explains *why* the change is needed, not just *what* changed
- [ ] `CHANGELOG.md` has an entry under `[Unreleased]`
