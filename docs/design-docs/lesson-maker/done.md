---
part: done
---
# Done line

1. `swift test --package-path PianoCore` passes on Linux in CI. It covers
   the key finder, each level, the checker, and 600 made-up scores at each
   level with no breach. Proof: the CI run link.
2. US-1 is a test, note for note. Proof: the test name in the run log.
3. The new code is in its own files, and `Note.swift` does not change.
   Proof: the diff of the pull request.
4. `atlas check` and `atlas design check` pass. The verifier runs them.
   Proof: the command output.
