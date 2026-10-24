---
part: proof
---
# Test and proof plan

| Piece | Proof | Command |
|---|---|---|
| Steps and hands | Tests: notes on one beat make one step; right, left and both. | `swift test --package-path PianoCore` |
| Wait mode | Tests: US-1, US-2 and US-3, a repeat key, a press after the end, an empty part. | `swift test --package-path PianoCore` |
| Score and tip | Tests: each row of the tip table, and its edges at 90 and 70 percent. | `swift test --package-path PianoCore` |
| Parts | Tests: 4 bars a part, a note at a bar line, a short song. | `swift test --package-path PianoCore` |
| Built-in tunes | Test: each tune makes a lesson at each level with no breach. | `swift test --package-path PianoCore` |
| App build | The new check builds the app for the iOS simulator. | `xcodebuild build` in GitHub Actions |
| On the iPad | A TestFlight build. Arjun plays part 1 of "Twinkle" in wait mode. | `scripts/testflight.sh` on the Mac |
