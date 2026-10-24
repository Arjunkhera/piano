import PianoCore
import SwiftUI

/// A five-line staff with the next notes on it. The first note is the one
/// to play now, in the accent colour. The rest are there to read ahead.
struct StaffView: View {
    var clef: Clef
    /// The keys to show, from left to right. White keys only.
    var keys: [UInt8]

    /// The space between two lines, in points.
    private let gap: CGFloat = 16

    var body: some View {
        Canvas { context, size in
            // The staff, with room for two ledger lines above and below.
            let bottom = size.height / 2 + gap * 2
            func y(_ step: Int) -> CGFloat { bottom - CGFloat(step) * gap / 2 }

            for line in stride(from: 0, through: Staff.topLine, by: 2) {
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y(line)))
                path.addLine(to: CGPoint(x: size.width, y: y(line)))
                context.stroke(path, with: .color(.primary.opacity(0.7)), lineWidth: 1)
            }

            let label = Text(clef == .treble ? "Treble" : "Bass").font(.caption).foregroundStyle(.secondary)
            context.draw(label, at: CGPoint(x: 4, y: y(Staff.topLine) - 6), anchor: .bottomLeading)

            let spacing = min(80, (size.width - 80) / CGFloat(max(keys.count, 1)))
            for (index, key) in keys.enumerated() {
                guard let step = Staff.step(of: key, clef: clef) else { continue }
                let x = 70 + CGFloat(index) * spacing
                for ledger in Staff.ledgerLines(for: step) {
                    var path = Path()
                    path.move(to: CGPoint(x: x - gap, y: y(ledger)))
                    path.addLine(to: CGPoint(x: x + gap, y: y(ledger)))
                    context.stroke(path, with: .color(.primary.opacity(0.7)), lineWidth: 1)
                }
                let head = CGRect(x: x - gap * 0.65, y: y(step) - gap / 2, width: gap * 1.3, height: gap)
                let color: Color = index == 0 ? .accentColor : .primary
                context.fill(Path(ellipseIn: head), with: .color(color))
            }
        }
        .frame(height: gap * 10)
        .accessibilityLabel("A staff with the next notes")
    }
}
