---
part: risks
---
# Risks

| Risk | What we do |
|---|---|
| "Any song" gives wrong notes. Notes from audio (AI transcription) are often wrong for a full band. Notes from a file on the web can be wrong too. | D2 starts with note files, which are more correct than audio. Audio comes later, as a fallback, and the app marks it as "may have errors". You can mark a wrong bar. |
| YouTube terms forbid a download of a video or its sound. | The app never downloads from YouTube. The Mac helper records only what you play on your own Mac, for your own practice. |
| Copyright. Most songs and most note files are owned by someone. | The app does not share or publish any song. You bring the song in for your own practice. We do not put song files in this public repo. |
| The keyboard does not connect. | The keyboard is most likely a Yamaha P-125 (2019). Its USB TO HOST port and the cable Arjun has carry MIDI to the iPad with no driver. D1 proves it first. |
| Native iOS work needs a Mac with Xcode. A cloud session can not run the iPad simulator. | Arjun has a Mac. A Claude session on it can build and run the app. |
| The iPad can not record the sound of another app. | Layer 2 runs on the Mac. On the iPad alone, only the microphone is possible, and it is less accurate. |
| The app teaches songs but not the basics, and you stall. | D5, the basics course, is part of the plan from the start. |
| Popular learning apps, such as Flowkey and the apps from Yamaha, already do much of this. | Accepted. They do not teach any song you ask for. That is the reason to build. We copy what works in them: wait mode and one hand at a time. |
