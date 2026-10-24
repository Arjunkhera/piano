---
part: edges
---
# Edge cases

| Case | What happens |
|---|---|
| No keyboard is plugged in | The banner says "Connect your keyboard". The on-screen keys still respond to touch, for a test. |
| The cable comes out while a key is down | The app clears every lit key and shows "Connect your keyboard". |
| Key on with force 0 | PianoCore treats it as key off. Many keyboards send this. |
| Running status (no status byte on the next message) | PianoCore keeps the last status byte and reads the message. |
| Other messages: pedal, clock, active sensing | PianoCore reads the pedal as an event and drops the rest. |
| Two MIDI devices | The app reads both. The banner names the first one. |
| A key outside 21 to 108 | PianoCore drops it. An 88-key piano has keys 21 to 108. |
