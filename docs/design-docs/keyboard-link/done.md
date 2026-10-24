---
part: done
---
# Done line

1. `swift test --package-path PianoCore` passes on Linux in CI. It covers the 7 byte cases and the 4 key names. Proof: the CI run link.
2. The Mac build script builds the iPad app with no error. A Remote Control session runs it. Proof: the build log tail on the pull request.
3. A TestFlight build of the app exists for Arjun. Proof: the build number in App Store Connect, posted on the pull request.
4. Arjun plays a C major scale on the P-125. Each key lights on the iPad,
   with its name. A C major chord lights three keys. Proof: his words or a screenshot in the thread.
5. `atlas check` and `atlas design check` pass. The verifier runs them. Proof: the command output.
