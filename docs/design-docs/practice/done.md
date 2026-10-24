---
part: done
---
# Done line

1. `swift test --package-path PianoCore` passes on Linux in CI. It covers
   steps, wait mode, the score and tip, parts and the built-in tunes.
   Proof: the CI run link.
2. US-1, US-2 and US-3 are tests, with the numbers of the stories. Proof: the
   test names in the run log.
3. The new app check builds the app with no error. Proof: the CI run link.
4. The keyboard reader keeps the held keys of each source, reads real
   devices only, and passes events through one queue. Proof: the diff of
   the pull request.
5. The new PianoCore code is in its own files, and `Note.swift` does not
   change. Proof: the diff of the pull request.
6. `atlas check` and `atlas design check` pass. The verifier runs them.
   Proof: the command output.
7. A TestFlight build with the practice screen exists. Proof: the build
   number, posted on the pull request or in the thread.
