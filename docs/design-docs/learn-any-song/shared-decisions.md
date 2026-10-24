---
part: shared-decisions
---
# Shared decisions

These are proposals. Each one becomes a decision only when you approve it.

| Decision | Why |
|---|---|
| Songs come in by layers. Layer 1: import a sheet (MusicXML or MIDI). Layer 2: a Mac helper records what the Mac plays, and a piano model writes the notes. | Arjun decided this on 24 October 2026. A sheet gives exact notes. YouTube terms forbid a download, and download tools break often. A recording of what the Mac plays avoids both. |
| Prefer a solo piano cover as the Layer 2 input. | A piano model gets about 95 percent of notes right on solo piano, but only 25 to 38 percent on a full band mix. |
| One master score per song. Rules make three levels from it: beginner, intermediate and advanced. | Teaching guides (Alfred, ABRSM) give clear rules for each level. AI difficulty grading is still weak. |
| Claude can later find and play a cover in Chrome. It does not listen. | Claude in Chrome sees the page, not the sound. The Mac helper does the recording. |
| A native app in Swift, with SwiftUI and Core MIDI. Not a web app. | Safari on iPad and iPhone has no Web MIDI. A web page can not read the keyboard. Apple's Core MIDI reads it with no driver. |
| One note format inside the app: a list of notes, each with a key, a start, a length, a hand and a finger. | Every design reads and writes the same thing. MIDI files and MusicXML files both convert into it. |
| The app waits for the right key before it moves on ("wait mode"). Play along at full speed comes later. | A near beginner needs time to find the key. Wait mode is how most learning apps start. |
| Songs and progress stay on the device. No server at first. | One user, no accounts, and no copy of a song leaves your device. |
| The song is made easy before you see it: the tune first, one hand, a simple key. | A full arrangement of a pop song is too hard for a beginner. |
| We install the app on your iPad through TestFlight. Not the App Store. | Arjun already has an Apple developer account. The Mindhold app uses it for TestFlight, so the piano app reuses that setup. |

The open questions behind these decisions are in the tracker. The first
one is where the notes of "any song" come from.
