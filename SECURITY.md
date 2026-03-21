# Security Policy

## Supported Versions

Only the latest release of SpacesGrid receives security fixes.

| Version | Supported |
|---|---|
| 1.x (latest) | Yes |
| < 1.0 | No |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability — for example, one that allows an
attacker to escalate privileges or exfiltrate data via SpacesGrid — please
report it privately:

1. Go to the repository's **Security** tab on GitHub.
2. Click **"Report a vulnerability"** to open a private advisory draft.
3. Describe the issue, steps to reproduce, and any proof-of-concept code.

You will receive an acknowledgement within 48 hours. We aim to release a fix
within 14 days of confirmation, depending on complexity.

## Scope

SpacesGrid is a local menu-bar utility with no network access and no server
component. The primary security surface is the use of private CGS APIs and
`CGWindowListCopyWindowInfo`, which read window metadata from other processes.
Reports related to these APIs are in scope.

## Out of Scope

- Theoretical vulnerabilities without a realistic attack scenario
- Issues in third-party dependencies that are not yet exploitable in this project
- macOS kernel or system-level vulnerabilities unrelated to SpacesGrid
