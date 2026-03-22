import AppKit

/// A lightweight NSView that draws a compact grid of Space indicators.
/// All visual parameters come from `Preferences.shared` and are re-read on
/// every draw cycle, so changes in the Preferences window are reflected
/// immediately without restarting the app.
final class GridView: NSView {

    var spacesManager: SpacesManager!

    // MARK: - Sizing helper

    /// Returns the pixel size the view needs to hold the current grid layout.
    static func idealSize() -> NSSize {
        let p = Preferences.shared
        let w = CGFloat(p.columns) * CGFloat(p.cellWidth)  + CGFloat(p.columns - 1) * CGFloat(p.cellGap)
        let h = CGFloat(p.rows)    * CGFloat(p.cellHeight) + CGFloat(p.rows    - 1) * CGFloat(p.cellGap)
        return NSSize(width: w, height: h)
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        guard let manager = spacesManager else { return }

        let p    = Preferences.shared
        let cols = p.columns
        let rows = p.rows
        let W    = CGFloat(p.cellWidth)
        let H    = CGFloat(p.cellHeight)
        let G    = CGFloat(p.cellGap)
        let R    = CGFloat(p.cornerRadius)
        let BW   = CGFloat(p.borderWidth)

        let spaces = manager.fetchSpaces()

        for (index, space) in spaces.prefix(cols * rows).enumerated() {
            let col = index % cols
            let row = index / cols

            // AppKit origin is bottom-left, so row 0 is at the top visually.
            let x = CGFloat(col) * (W + G)
            let y = bounds.height - CGFloat(row + 1) * H - CGFloat(row) * G

            let rect = NSRect(x: x, y: y, width: W, height: H)
            let path = NSBezierPath(roundedRect: rect, xRadius: R, yRadius: R)

            if space.isActive {
                p.activeColor.setFill()
                path.fill()
            } else if p.showWindowIndicators && space.hasWindows {
                p.occupiedColor.setFill()
                path.fill()
            } else {
                p.emptyBorderColor.setStroke()
                path.lineWidth = BW
                path.stroke()
            }

            // Fullscreen / Stage Manager badge — small orange dot in the top-right corner.
            if p.showFullscreenBadge && space.isFullscreen && !space.isActive {
                let dotSize: CGFloat = 2
                let dot = NSBezierPath(ovalIn: NSRect(
                    x: rect.maxX - dotSize - 0.5,
                    y: rect.maxY - dotSize - 0.5,
                    width:  dotSize,
                    height: dotSize
                ))
                NSColor.systemOrange.withAlphaComponent(0.85).setFill()
                dot.fill()
            }
        }
    }
}
