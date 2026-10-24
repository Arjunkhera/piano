---
part: edges
---
# Edge cases

| Case | What happens |
|---|---|
| The file is not MIDI, MusicXML or .mxl | The app says "This is not a MIDI, MusicXML or .mxl file." |
| The file is cut short or broken | The app says "The file is damaged", with where. |
| MIDI time in frames, not beats (SMPTE) | Refused as not supported. Such files are rare. |
| MIDI format 2 | Refused as not supported: it holds separate songs. |
| MIDI drums on channel 10 | Dropped. |
| A key outside A0 to C8 | Dropped. |
| A MIDI track named "Left hand", "LH" or "Bass" | All its notes go to the left hand. |
| A score with two staves | Staff 1 is the right hand, staff 2 the left. |
| Grace notes | Left out: MusicXML gives them no length. |
| Tied notes | Joined into one long note. |
| Repeats | Not followed. The song plays once, as written. |
| Timewise MusicXML | Refused. Apps save partwise MusicXML by default. |
| A hostile .mxl that unpacks to a huge size | Refused above 64 MB. |
| The recording is silent | piano-listen says so after 5 seconds, and refuses to write notes at the end. |
| Transkun is not installed | piano-listen still records, keeps the WAV file, and prints the command to run later. |
| Python 3.13 has no audioop module | install.sh adds audioop-lts, which puts it back. |
