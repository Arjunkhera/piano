---
part: proof
---
# Test and proof plan

| Piece | Proof | Command |
|---|---|---|
| Key finder | Tests: C, D and E major scales, an A minor tune, no notes, sharps and flats per key. | `swift test --package-path PianoCore` |
| Beginner | Tests: US-1 note for note, the top key of a chord, off-beat notes, the bar line. | `swift test --package-path PianoCore` |
| Intermediate | Tests: US-2 key move, root and fifth, top two keys, the eighth-note grid. | `swift test --package-path PianoCore` |
| Advanced | Tests: short notes dropped, the 9th limit, a held note that ends. | `swift test --package-path PianoCore` |
| Level checker | Tests: each rule finds its breach (US-3), and a clean lesson has none. | `swift test --package-path PianoCore` |
| Every level | 600 made-up scores at each level and with 4 bar lengths: no breach, and the same lesson each time. | `swift test --package-path PianoCore` |
