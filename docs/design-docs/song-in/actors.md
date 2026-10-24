---
part: actors
---
# Who and what

| Who | Does | Does not |
|---|---|---|
| Arjun | Picks a file on the iPad. Plays a cover on the Mac and runs `piano-listen`. Sends the MIDI file by AirDrop. | Edit notes by hand. |
| PianoCore | Reads MIDI, MusicXML and .mxl bytes into an ImportedSong. Sets the hand of each note. | Touch files, the screen or the network. |
| iPad app | Shows the song list, opens the file picker, keeps each song as a JSON file on the device. | Send a song anywhere. |
| piano-listen | Records the sound of the Mac, or of one app, with ScreenCaptureKit. Runs Transkun. Prints a summary. | Download a video, or run in the cloud. |
| Transkun | Python piano model (MIT licence). Turns a WAV recording into a MIDI file. | Know the hands, the tempo or the bars. |
| ScreenCaptureKit | Apple code in macOS. Gives the app the sound the Mac plays, after the Screen Recording permission. | Record without that permission. |
