---
part: done
---
# Done line

1. `swift test --package-path PianoCore` passes on Linux in CI, with the import tests. Proof: the CI run.
2. The macOS builds workflow passes: piano-listen builds and its tests pass, and the iPad app builds. Proof: the CI run.
3. On Arjun's Mac, install.sh finishes and `piano-listen check` finds Transkun. Proof: the log tail, from a Remote Control session.
4. On Arjun's Mac, `piano-listen transcribe` or `record` writes a MIDI file, and prints the note count. Proof: the log tail.
5. A TestFlight build with Import song exists, and Arjun imports a file. Proof: the build number, and his words.
6. `atlas check` and `atlas design check` pass. Proof: the verifier comment.
