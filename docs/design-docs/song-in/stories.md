---
part: stories
---
# Stories

### US-1: you import a sheet on the iPad

**Input:** Arjun has "Ode.mxl" in the Files app. It is a two-staff score.

```woodcut wc-sequence
{
  "label": "US-1: you import a sheet on the iPad",
  "viewBox": [560, 230],
  "actors": [
    { "id": "arjun", "x": 60, "label": "Arjun" },
    { "id": "app", "x": 200, "label": "iPad app" },
    { "id": "core", "x": 350, "label": "PianoCore" },
    { "id": "disk", "x": 490, "label": "Song files" }
  ],
  "messages": [
    { "id": "pick", "from": "arjun", "to": "app", "y": 70, "label": "Import song: Ode.mxl" },
    { "id": "read", "from": "app", "to": "core", "y": 105, "label": "bytes" },
    { "id": "song", "from": "core", "to": "app", "y": 140, "label": "ImportedSong", "kind": "return" },
    { "id": "keep", "from": "app", "to": "disk", "y": 175, "label": "song JSON" },
    { "id": "show", "from": "app", "to": "arjun", "y": 210, "label": "Ode in the list", "kind": "return" }
  ],
  "scenarios": [{
    "name": "US-1",
    "steps": [
      { "title": "Arjun picks the file", "body": "He taps Songs, then Import song, and picks Ode.mxl.", "active": ["arjun", "pick", "app"] },
      { "title": "PianoCore reads it", "body": "The bytes start with PK, so it is a zip. It opens the score that container.xml names.", "active": ["read", "core"] },
      { "title": "Hands come from the staves", "body": "Staff 1 is the right hand, staff 2 the left. A tie becomes one long note.", "active": ["song", "core"] },
      { "title": "The app keeps it", "body": "One JSON file in Application Support/Songs. The song shows in the list.", "active": ["keep", "disk", "show"] }
    ]
  }]
}
```

1. Arjun taps Songs, then Import song, and picks "Ode.mxl".
2. PianoCore sees a zip, and opens the score inside it.
3. It reads each note: key, start, length and hand.
4. The app keeps the song as JSON on the iPad, and lists it.

**Output:** "Ode" in the song list: "212 notes: 150 right hand, 62 left hand.
24 bars at 96 beats a minute."

### US-2: you record a cover on the Mac

**Input:** No sheet exists for "Let It Be". Arjun finds a solo piano cover on
YouTube in Safari.

```woodcut wc-sequence
{
  "label": "US-2: you record a cover on the Mac",
  "viewBox": [600, 265],
  "actors": [
    { "id": "arjun", "x": 50, "label": "Arjun" },
    { "id": "listen", "x": 170, "label": "piano-listen" },
    { "id": "sck", "x": 300, "label": "ScreenCaptureKit" },
    { "id": "tk", "x": 420, "label": "Transkun" },
    { "id": "ipad", "x": 540, "label": "iPad app" }
  ],
  "messages": [
    { "id": "start", "from": "arjun", "to": "listen", "y": 70, "label": "record \"Let It Be\" --app Safari" },
    { "id": "sound", "from": "sck", "to": "listen", "y": 105, "label": "sound of Safari", "kind": "return" },
    { "id": "stop", "from": "arjun", "to": "listen", "y": 140, "label": "Return" },
    { "id": "notes", "from": "listen", "to": "tk", "y": 175, "label": "WAV in, MIDI out" },
    { "id": "send", "from": "arjun", "to": "ipad", "y": 210, "label": "AirDrop .mid" },
    { "id": "list", "from": "ipad", "to": "arjun", "y": 245, "label": "song in the list", "kind": "return" }
  ],
  "scenarios": [{
    "name": "US-2",
    "steps": [
      { "title": "Arjun starts the helper", "body": "He runs piano-listen record, then plays the cover in Safari.", "active": ["arjun", "start", "listen"] },
      { "title": "The Mac's sound is recorded", "body": "ScreenCaptureKit passes the sound of Safari only. Nothing is downloaded.", "active": ["sound", "sck"] },
      { "title": "Transkun writes the notes", "body": "Arjun presses Return. Transkun turns the WAV file into Let It Be.mid, and the WAV is deleted.", "active": ["stop", "notes", "tk"] },
      { "title": "The iPad imports it", "body": "Arjun sends the file by AirDrop and imports it, as in US-1.", "active": ["send", "ipad", "list"] }
    ]
  }]
}
```

1. Arjun runs `piano-listen record "Let It Be" --app Safari`.
2. He plays the cover. The helper shows the time and the sound level.
3. He presses Return when the song ends.
4. Transkun writes "Let It Be.mid" in ~/Music/Piano Songs.
5. He sends the file to the iPad and imports it, as in US-1.

**Output:** "Let It Be" in the song list. One track, so keys below middle C
go to the left hand. D3 then makes the levels.
