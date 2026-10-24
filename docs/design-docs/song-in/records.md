---
part: records
---
# Records

| Record | Written by | Holds | Kept where |
|---|---|---|---|
| ImportedSong | PianoCore | title, beats a minute, beats a bar, notes | Memory, then JSON |
| Note | PianoCore (from D1) | key, start in beats, length in beats, hand, finger | Inside ImportedSong |
| Song file | The iPad app | One ImportedSong as JSON | Application Support/Songs on the iPad |
| Recording | piano-listen | 16-bit WAV of the Mac's sound | ~/Music/Piano Songs, deleted after Transkun unless `--keep-audio` |
| MIDI file | Transkun | The notes Transkun heard | ~/Music/Piano Songs on the Mac |

A beat is a quarter note in every record.
