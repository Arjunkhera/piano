---
part: proof
---
# Test and proof plan

| Piece | Proof | Command |
|---|---|---|
| MIDI byte reader | Tests for key on, key off, force 0, running status, three messages in one packet, pedal, and keys out of range. Each test fails if the reader is wrong. | `swift test --package-path PianoCore` (Linux and Mac) |
| Key names | Test: key 60 is C4, key 21 is A0, key 108 is C8, key 61 is C#4. | `swift test --package-path PianoCore` |
| App build | The iPad app builds with no error. | `scripts/testflight.sh <team> --no-upload` on the Mac |
| On the iPad | Arjun plays a C major scale and a C major chord. The screen lights each key. | Arjun, from TestFlight |
