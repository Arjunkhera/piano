---
part: proof
---
# Test and proof plan

| Piece | Proof | Command |
|---|---|---|
| MIDI reader | Tests: tempo, meter, title, running status and force 0. Hands by track count, by track name, and by a split at middle C. Drums, keys off the piano and repeated keys. A note still down at the end, a cut-short file, and time in frames. | `swift test --package-path PianoCore` (Linux and macOS) |
| MusicXML reader | Tests: two staves, a chord, a rest, a grace note, a tie, a flat, backup, two parts, 6/8, timewise refused, broken XML. | same |
| .mxl reader | Tests: deflate with dynamic and fixed blocks, a stored zip, the size limit, container.xml. | same |
| piano-listen options | Tests: each option, and each mistake refused. | `swift test --package-path MacHelper` (macOS CI) |
| Builds | piano-listen and the iPad app build with no error. | the macOS tests and App build workflows |
| On the Mac | install.sh runs. `piano-listen record` writes a MIDI file from a cover. | Remote Control on Arjun's Mac |
| On the iPad | Import song adds a file to the list. | Arjun, from TestFlight |
