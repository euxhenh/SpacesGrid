import SwiftUI
import AppKit

// MARK: - Live grid preview

/// Draws a miniature version of the menu-bar grid using current preference values.
/// First cell = active, second = occupied, rest = empty — so all three states are
/// always visible regardless of how many real Spaces the user has.
private struct GridPreview: View {
    @ObservedObject var prefs: Preferences

    var body: some View {
        let cols   = prefs.columns
        let rows   = prefs.rows
        let cw     = prefs.cellWidth
        let ch     = prefs.cellHeight
        let gap    = prefs.cellGap
        let radius = prefs.cornerRadius
        let bw     = prefs.borderWidth

        let totalW = Double(cols) * cw + Double(cols - 1) * gap
        let totalH = Double(rows) * ch + Double(rows - 1) * gap

        Canvas { ctx, _ in
            var idx = 0
            for row in 0..<rows {
                for col in 0..<cols {
                    let x    = Double(col) * (cw + gap)
                    let y    = Double(row) * (ch + gap)
                    let rect = CGRect(x: x, y: y, width: cw, height: ch)
                    let path = Path(roundedRect: rect, cornerRadius: radius)

                    switch idx {
                    case 0:   // active
                        ctx.fill(path, with: .color(Color(prefs.activeColor)))
                    case 1:   // occupied
                        ctx.fill(path, with: .color(Color(prefs.occupiedColor)))
                    default:  // empty
                        ctx.stroke(
                            path,
                            with: .color(Color(prefs.emptyBorderColor)),
                            lineWidth: bw
                        )
                    }
                    idx += 1
                }
            }
        }
        .frame(width: totalW, height: totalH)
        .padding(12)
        .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 0.5)
        )
    }
}

// MARK: - Reusable row components

private struct ColorRow: View {
    let label: String
    let help: String
    @Binding var color: NSColor

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(label)
                Text(help)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            ColorPicker(
                "",
                selection: Binding(
                    get: { Color(color) },
                    set: { color = NSColor($0) }
                ),
                supportsOpacity: true
            )
            .labelsHidden()
        }
    }
}

private struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double.Stride
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(label)
                Spacer()
                Text("\(value, specifier: step < 1 ? "%.1f" : "%.0f") \(unit)")
                    .foregroundColor(.secondary)
                    .monospacedDigit()
                    .frame(width: 52, alignment: .trailing)
            }
            Slider(value: $value, in: range, step: step)
        }
    }
}

private struct StepperRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Stepper(value: $value, in: range) {
                Text("\(value)")
                    .monospacedDigit()
                    .frame(width: 24, alignment: .trailing)
            }
        }
    }
}

// MARK: - Appearance tab

private struct AppearanceTab: View {
    @ObservedObject var prefs: Preferences

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            // Live preview
            HStack {
                Spacer()
                VStack(spacing: 6) {
                    Text("Preview  ·  1st cell = active, 2nd = occupied, rest = empty")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    GridPreview(prefs: prefs)
                }
                Spacer()
            }

            GroupBox("Colors") {
                VStack(spacing: 12) {
                    ColorRow(
                        label: "Active space",
                        help: "The space you are currently working in",
                        color: Binding(get: { prefs.activeColor },
                                       set: { prefs.activeColor = $0 })
                    )
                    Divider()
                    ColorRow(
                        label: "Occupied space",
                        help: "A space that has at least one open window",
                        color: Binding(get: { prefs.occupiedColor },
                                       set: { prefs.occupiedColor = $0 })
                    )
                    Divider()
                    ColorRow(
                        label: "Empty space border",
                        help: "A space with no open windows",
                        color: Binding(get: { prefs.emptyBorderColor },
                                       set: { prefs.emptyBorderColor = $0 })
                    )
                }
                .padding(10)
            }

            GroupBox("Shape") {
                VStack(spacing: 12) {
                    SliderRow(label: "Border width",  value: Binding(get: { prefs.borderWidth },   set: { prefs.borderWidth = $0 }),
                              range: 0.25...4, step: 0.25, unit: "pt")
                    Divider()
                    SliderRow(label: "Corner radius", value: Binding(get: { prefs.cornerRadius }, set: { prefs.cornerRadius = $0 }),
                              range: 0...8,    step: 0.5,  unit: "pt")
                }
                .padding(10)
            }

            HStack {
                Spacer()
                Button("Reset to Defaults") { prefs.resetToDefaults() }
                    .buttonStyle(.bordered)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Grid tab

private struct GridTab: View {
    @ObservedObject var prefs: Preferences

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                Spacer()
                VStack(spacing: 6) {
                    Text("Preview")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    GridPreview(prefs: prefs)
                }
                Spacer()
            }

            GroupBox("Layout") {
                VStack(spacing: 10) {
                    StepperRow(label: "Columns",
                               value: Binding(get: { prefs.columns }, set: { prefs.columns = $0 }),
                               range: 1...12)
                    Divider()
                    StepperRow(label: "Rows",
                               value: Binding(get: { prefs.rows }, set: { prefs.rows = $0 }),
                               range: 1...6)
                }
                .padding(10)
            }

            GroupBox("Cell Size") {
                VStack(spacing: 12) {
                    SliderRow(label: "Cell width",  value: Binding(get: { prefs.cellWidth },  set: { prefs.cellWidth = $0 }),
                              range: 6...24, step: 1, unit: "pt")
                    Divider()
                    SliderRow(label: "Cell height", value: Binding(get: { prefs.cellHeight }, set: { prefs.cellHeight = $0 }),
                              range: 4...16, step: 1, unit: "pt")
                    Divider()
                    SliderRow(label: "Gap",         value: Binding(get: { prefs.cellGap },    set: { prefs.cellGap = $0 }),
                              range: 0...6,  step: 0.5, unit: "pt")
                }
                .padding(10)
            }
        }
        .padding(.top, 4)
    }
}

// MARK: - Behaviour tab

private struct BehaviourTab: View {
    @ObservedObject var prefs: Preferences
    // launchAtLogin is backed by SMAppService (not @Published), so we mirror it in local @State.
    @State private var launchAtLogin: Bool = Preferences.shared.launchAtLogin

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            GroupBox("Updates") {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Refresh interval")
                            Text("How often to recheck which spaces have open windows")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Picker("", selection: Binding(
                            get: { prefs.refreshInterval },
                            set: { prefs.refreshInterval = $0 }
                        )) {
                            Text("0.5 s").tag(0.5)
                            Text("1 s").tag(1.0)
                            Text("2 s").tag(2.0)
                            Text("5 s").tag(5.0)
                            Text("10 s").tag(10.0)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 80)
                    }
                }
                .padding(10)
            }

            GroupBox("Display") {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: Binding(
                        get: { prefs.showFullscreenBadge },
                        set: { prefs.showFullscreenBadge = $0 }
                    )) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Show fullscreen indicator")
                            Text("Marks fullscreen or Stage Manager spaces with an orange dot")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
            }

            GroupBox("System") {
                VStack(alignment: .leading, spacing: 10) {
                    Toggle(isOn: $launchAtLogin) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Launch at login")
                            Text("Automatically start SpacesGrid when you log in")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .onChange(of: launchAtLogin) { newValue in
                        prefs.launchAtLogin = newValue
                    }
                }
                .padding(10)
            }

            Spacer()
        }
        .padding(.top, 4)
    }
}

// MARK: - Root preferences view

struct PreferencesView: View {
    @ObservedObject var prefs: Preferences = .shared

    var body: some View {
        TabView {
            AppearanceTab(prefs: prefs)
                .tabItem { Label("Appearance", systemImage: "paintbrush.fill") }
                .padding(20)

            GridTab(prefs: prefs)
                .tabItem { Label("Grid", systemImage: "grid") }
                .padding(20)

            BehaviourTab(prefs: prefs)
                .tabItem { Label("Behaviour", systemImage: "gearshape.fill") }
                .padding(20)
        }
        .frame(width: 420, height: 520)
    }
}

// MARK: - Window controller

final class PreferencesWindowController: NSWindowController {

    static let shared = PreferencesWindowController()

    private init() {
        let hosting = NSHostingController(rootView: PreferencesView())

        let window = NSPanel(
            contentRect: .zero,
            styleMask:   [.titled, .closable, .miniaturizable],
            backing:     .buffered,
            defer:       false
        )
        window.title = "SpacesGrid Preferences"
        window.contentViewController = hosting
        window.isReleasedWhenClosed  = false
        window.center()

        super.init(window: window)
    }

    required init?(coder: NSCoder) { fatalError("not implemented") }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }
}
