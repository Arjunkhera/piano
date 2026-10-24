---
part: done
---
# Done line

1. `swift test --package-path PianoCore` passes on Linux in CI. It covers
   the course content, the pass rule, the gate and the staff. Proof: the CI
   run link.
2. US-1, US-2 and US-3 are tests, with the names given in the stories.
   Proof: the test names in the run log.
3. The app check builds the app with no error. Proof: the CI run link.
4. The new code is in new files. Only the home screen and the project file
   change in old files, and `Note.swift` and `WaitMode.swift` do not change.
   Proof: the diff of the pull request.
5. `atlas check` and `atlas design check` pass. The verifier runs them.
   Proof: the command output.
6. A TestFlight build with the basics course exists. Proof: the build
   number, posted on the pull request or in the thread.
