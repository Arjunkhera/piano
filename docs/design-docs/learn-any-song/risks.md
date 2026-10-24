---
part: risks
---
# Risks

| Risk | What we do |
|---|---|
| "Any song" gives wrong notes. Notes from audio (AI transcription) are often wrong for a full band. Notes from a file on the web can be wrong too. | D2 starts with note files, which are more correct than audio. Audio comes later, as a fallback, and the app marks it as "may have errors". You can mark a wrong bar. |
| Copyright. Most songs and most note files are owned by someone. | The app does not share or publish any song. You bring the song in for your own practice. We do not put song files in this public repo. |
| The keyboard does not connect. Some older Yamaha models need a driver or a different cable. | D1 is first. We check the model before any other work. A USB MIDI adapter is the fallback. |
| Native iOS work needs a Mac with Xcode. A cloud session can not run the iPad simulator. | Open question. If you have a Mac, a Claude session on it can build and run the app. |
| A free Apple account installs the app for 7 days only. | Open question: a paid Apple developer account (99 US dollars a year) keeps it installed through TestFlight. |
| The app teaches songs but not the basics, and you stall. | D5, the basics course, is part of the plan from the start. |
| Popular learning apps, such as Flowkey and the apps from Yamaha, already do much of this. | Accepted. They do not teach any song you ask for. That is the reason to build. We copy what works in them: wait mode and one hand at a time. |
