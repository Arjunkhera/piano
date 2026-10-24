---
part: shared-decisions
---
# Shared decisions

These are proposals. Each one becomes a decision only when you approve it.

| Decision | Why |
|---|---|
| A native app in Swift, with SwiftUI and Core MIDI. Not a web app. | Safari on iPad and iPhone has no Web MIDI. A web page can not read the keyboard. Apple's Core MIDI reads it with no driver. |
| One note format inside the app: a list of notes, each with a key, a start, a length, a hand and a finger. | Every design reads and writes the same thing. MIDI files and MusicXML files both convert into it. |
| The app waits for the right key before it moves on ("wait mode"). Play along at full speed comes later. | A near beginner needs time to find the key. Wait mode is how most learning apps start. |
| Songs and progress stay on the device. No server at first. | One user, no accounts, and no copy of a song leaves your device. |
| The song is made easy before you see it: the tune first, one hand, a simple key. | A full arrangement of a pop song is too hard for a beginner. |
| We install the app on your iPad from Xcode or TestFlight. Not the App Store. | Faster, and no Apple review. It needs a Mac and an Apple developer account (open question). |

The open questions behind these decisions are in the tracker. The first
one is where the notes of "any song" come from.
