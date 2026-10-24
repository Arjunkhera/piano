---
part: actors
---
# Who and what

| Who | Does | Does not |
|---|---|---|
| Arjun | Plugs in the cable. Plays keys. Installs from TestFlight. | Pick a MIDI device by hand. |
| P-125 | Sends a MIDI message for each key down and key up, over USB. | Need a driver. |
| Core MIDI | Apple code in iPadOS. Tells the app when a device comes or goes, and passes each message. | Know about notes or names. |
| PianoCore | Swift package. Turns MIDI bytes into key events, and names keys. | Touch the screen or Core MIDI. |
| App | Joins Core MIDI to PianoCore and draws the keyboard. | Keep any data. |
| Mac build script | Builds the app on Arjun's Mac and sends it to TestFlight. | Run in the cloud. |
