import PianoCore
import SwiftUI

/// An 88-key keyboard that lights the held keys. It scrolls, and it opens
/// centred on middle C.
struct PianoKeyboardView: View {
    var heldKeys: Set<UInt8>
    /// Colours that win over the lit colour, such as the next key in practice.
    var keyColors: [UInt8: Color] = [:]
    var onTouch: (UInt8, Bool) -> Void

    private let whiteWidth: CGFloat = 34
    private var whiteKeys: [UInt8] { pianoKeys.filter { !KeyName.isBlack($0) } }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                GeometryReader { geometry in
                    let height = geometry.size.height
                    ZStack(alignment: .topLeading) {
                        ForEach(Array(whiteKeys.enumerated()), id: \.element) { index, key in
                            keyShape(key, black: false)
                                .frame(width: whiteWidth - 2, height: height)
                                .offset(x: CGFloat(index) * whiteWidth)
                                .id(key)
                        }
                        ForEach(pianoKeys.filter { KeyName.isBlack($0) }, id: \.self) { key in
                            keyShape(key, black: true)
                                .frame(width: whiteWidth * 0.6, height: height * 0.62)
                                .offset(x: blackOffset(key))
                        }
                    }
                }
                .frame(width: CGFloat(whiteKeys.count) * whiteWidth)
            }
            .onAppear { proxy.scrollTo(UInt8(60), anchor: .center) }
        }
    }

    private func keyShape(_ key: UInt8, black: Bool) -> some View {
        let lit = heldKeys.contains(key)
        let colored = lit || keyColors[key] != nil
        return RoundedRectangle(cornerRadius: 4)
            .fill(keyColors[key] ?? (lit ? Color.accentColor : (black ? Color.black : Color.white)))
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.6)))
            .overlay(alignment: .bottom) {
                if !black && (key % 12 == 0 || colored) {
                    Text(KeyName.name(of: key))
                        .font(.caption2)
                        .foregroundStyle(colored ? .white : .gray)
                        .padding(.bottom, 6)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in if !lit { onTouch(key, true) } }
                    .onEnded { _ in onTouch(key, false) }
            )
            .accessibilityLabel(KeyName.label(of: key))
            .accessibilityAddTraits(lit ? .isSelected : [])
    }

    /// A black key sits on the line between the white key below it and the next one.
    private func blackOffset(_ key: UInt8) -> CGFloat {
        let whiteBelow = whiteKeys.firstIndex(of: key - 1) ?? 0
        return CGFloat(whiteBelow + 1) * whiteWidth - whiteWidth * 0.3
    }
}
