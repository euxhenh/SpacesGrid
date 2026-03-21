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
        let occupied = spacesContainingWindows(cid: cid)

        guard let raw = CGSCopyManagedDisplaySpaces(cid) as? [[String: Any]] else { return [] }

        var result: [SpaceInfo] = []
        for display in raw {
            guard let spaces = display["Spaces"] as? [[String: Any]] else { continue }
            for space in spaces {
                guard let rawID = space["id64"] else { continue }

                let id: CGSSpaceID
                if      let v = rawID as? Int    { id = CGSSpaceID(bitPattern: Int64(v)) }
                else if let v = rawID as? UInt64 { id = v }
                else { continue }

                let type = space["type"] as? Int ?? 0
                result.append(SpaceInfo(
                    id:           id,
                    isActive:     id == activeID,
                    hasWindows:   occupied.contains(id),
                    isFullscreen: type == 2
                ))
            }
        }
        return result
    }

    // MARK: - Private

    /// Returns the set of Space IDs that contain at least one normal app window.
    private func spacesContainingWindows(cid: CGSConnectionID) -> Set<CGSSpaceID> {
        guard
            let list = CGWindowListCopyWindowInfo(
                [.optionAll, .excludeDesktopElements],
                kCGNullWindowID
            ) as? [[String: Any]]
        else { return [] }

        // Keep only on-screen, normal-layer windows (layer 0).
        let windowIDs: [NSNumber] = list.compactMap { dict in
            guard
                let wid   = dict[kCGWindowNumber as String] as? UInt32,
                let layer = dict[kCGWindowLayer  as String] as? Int,
                layer == 0
            else { return nil }
            return NSNumber(value: wid)
        }

        guard !windowIDs.isEmpty else { return [] }

        guard
            let spacesRef = CGSCopySpacesForWindows(cid, 0xF, windowIDs as CFArray) as? [NSNumber]
        else { return [] }

        return Set(spacesRef.map { CGSSpaceID($0.uint64Value) })
    }
}
