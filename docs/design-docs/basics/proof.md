---
part: proof
---
# Test and proof plan

| Piece | Proof | Command |
|---|---|---|
| Course content | Tests: seven lessons in order; ids "lesson.exercise"; keys on the piano; fingers 1 to 5 in order of key; tunes fill whole bars. | `swift test --package-path PianoCore` |
| Pass rule | Tests: US-1 and US-3; each exercise passes when played right and on time; an empty score fails. | `swift test --package-path PianoCore` |
| Gate and progress | Tests: US-2; a failed try keeps a pass; a done course has no next lesson; progress survives JSON. | `swift test --package-path PianoCore` |
| Staff | Tests: lines and spaces of both clefs, black keys, ledger lines. | `swift test --package-path PianoCore` |
| App build | The app check builds the app for the iOS simulator. | `xcodebuild build` in GitHub Actions |
| On the iPad | A TestFlight build. Arjun opens "Basics course" and passes exercise 1.3. | `scripts/testflight.sh` on the Mac |
