// Private CoreGraphics Services API declarations.
// These are stable undocumented APIs used by many Mac utilities (WhichSpace, Spaces Bar, etc.)
// They have been consistent across macOS 10.x through 14.x.

import CoreGraphics

typealias CGSConnectionID = UInt32
typealias CGSSpaceID = UInt64

/// Returns the default per-process CGS connection.
@_silgen_name("CGSMainConnectionID")
func CGSMainConnectionID() -> CGSConnectionID

/// Returns the ID of the currently active Space on the main display.
@_silgen_name("CGSGetActiveSpace")
func CGSGetActiveSpace(_ cid: CGSConnectionID) -> CGSSpaceID

/// Returns an array of display-space dictionaries describing every managed display
/// and all the Spaces assigned to it. Each dictionary contains:
///   "Spaces"            → [[String: Any]]  list of space dicts
///   "Current Space"     → [String: Any]    currently active space dict
///   "Display Identifier"→ String
/// Each space dict contains at minimum:
///   "id64" → Int   (numeric space ID matching CGSGetActiveSpace)
///   "uuid" → String
///   "type" → Int   (0 = desktop, 2 = fullscreen app)
@_silgen_name("CGSCopyManagedDisplaySpaces")
func CGSCopyManagedDisplaySpaces(_ cid: CGSConnectionID) -> CFArray?

/// Given a CFArray of CGWindowID values (as CFNumber/NSNumber UInt32),
/// returns a CFArray of CGSSpaceID values (as CFNumber) for every Space
/// that contains at least one of those windows.
/// mask = 0xF covers all space types.
@_silgen_name("CGSCopySpacesForWindows")
func CGSCopySpacesForWindows(
    _ cid: CGSConnectionID,
    _ mask: UInt32,
    _ windowIDs: CFArray
) -> CFArray?

