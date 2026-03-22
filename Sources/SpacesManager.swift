import AppKit
import CoreGraphics

struct SpaceInfo {
    let id: CGSSpaceID
    let isActive: Bool
    let hasWindows: Bool
    /// `true` for fullscreen or Stage Manager tiles — shown with an orange badge.
    let isFullscreen: Bool
}

final class SpacesManager {

    // MARK: - Public

    /// Returns ordered space info for the current layout.
    /// Spaces are ordered as they appear in Mission Control (left → right).
    func fetchSpaces() -> [SpaceInfo] {
        let cid      = CGSMainConnectionID()
        let activeID = CGSGetActiveSpace(cid)

        guard let raw = CGSCopyManagedDisplaySpaces(cid) as? [[String: Any]] else { return [] }

        var spaceMeta: [(id: CGSSpaceID, type: Int)] = []
        for display in raw {
            guard let spaces = display["Spaces"] as? [[String: Any]] else { continue }
            for space in spaces {
                guard let rawID = space["id64"] else { continue }
                let id: CGSSpaceID
                if      let v = rawID as? Int    { id = CGSSpaceID(bitPattern: Int64(v)) }
                else if let v = rawID as? UInt64 { id = v }
                else { continue }
                spaceMeta.append((id: id, type: space["type"] as? Int ?? 0))
            }
        }

        let occupied = spacesContainingWindows(cid: cid)

        return spaceMeta.map { meta in
            SpaceInfo(
                id:           meta.id,
                isActive:     meta.id == activeID,
                hasWindows:   occupied.contains(meta.id),
                isFullscreen: meta.type == 2
            )
        }
    }

    // MARK: - Private

    /// Returns the set of Space IDs that contain at least one normal app window.
    /// Windows belonging to system daemons (CursorUIViewService, AutoFill, …)
    /// are excluded via a PID allowlist so they don't cause false positives.
    /// Minimised windows are included — they are still associated with their
    /// space and appear in CGWindowListCopyWindowInfo with .optionAll.
    private func spacesContainingWindows(cid: CGSConnectionID) -> Set<CGSSpaceID> {
        // Only count windows owned by regular user-facing apps.
        let regularPIDs = Set(
            NSWorkspace.shared.runningApplications
                .filter { $0.activationPolicy == .regular }
                .map    { Int($0.processIdentifier) }
        )

        // .optionAll is required — .optionOnScreenOnly scopes to the active
        // Space only, making every other Space appear empty.
        guard
            let list = CGWindowListCopyWindowInfo(
                [.optionAll, .excludeDesktopElements],
                kCGNullWindowID
            ) as? [[String: Any]]
        else { return [] }

        let windowIDs: [NSNumber] = list.compactMap { dict in
            guard
                let wid   = dict[kCGWindowNumber   as String] as? UInt32,
                let layer = dict[kCGWindowLayer    as String] as? Int, layer == 0,
                let pid   = dict[kCGWindowOwnerPID as String] as? Int,
                regularPIDs.contains(pid)
            else { return nil }

            // Drop zero-size phantom windows.
            if let bounds = dict[kCGWindowBounds as String] as? [String: Any],
               let w = bounds["Width"]  as? CGFloat,
               let h = bounds["Height"] as? CGFloat,
               w <= 1 || h <= 1 { return nil }

            return NSNumber(value: wid)
        }

        guard !windowIDs.isEmpty else { return [] }

        guard
            let spacesRef = CGSCopySpacesForWindows(
                cid, 0xF, windowIDs as CFArray
            ) as? [NSNumber]
        else { return [] }

        return Set(spacesRef.map { CGSSpaceID($0.uint64Value) })
    }
}
