---
part: stories
---
# Stories

### US-1: you press middle C

**Input:** the cable is plugged in. Arjun presses middle C with force 100.

```woodcut wc-sequence
{
  "label": "US-1: you press middle C",
  "viewBox": [560, 230],
  "actors": [
    { "id": "arjun", "x": 60, "label": "Arjun" },
    { "id": "p125", "x": 170, "label": "P-125" },
    { "id": "midi", "x": 290, "label": "Core MIDI" },
    { "id": "core", "x": 410, "label": "PianoCore" },
    { "id": "app", "x": 510, "label": "App" }
  ],
  "messages": [
    { "id": "press", "from": "arjun", "to": "p125", "y": 70, "label": "press C4" },
    { "id": "bytes", "from": "p125", "to": "midi", "y": 105, "label": "90 3C 64" },
    { "id": "parse", "from": "midi", "to": "core", "y": 140, "label": "parse bytes" },
    { "id": "event", "from": "core", "to": "app", "y": 175, "label": "key on 60" },
    { "id": "show", "from": "app", "to": "arjun", "y": 210, "label": "C4 lit", "kind": "return" }
  ],
  "scenarios": [{
    "name": "US-1",
    "steps": [
      { "title": "Arjun presses middle C", "body": "The P-125 sends three bytes over USB.", "active": ["arjun", "press", "p125"] },
      { "title": "Core MIDI passes the bytes", "body": "The app gets 90 3C 64 from the input port.", "active": ["bytes", "midi"] },
      { "title": "PianoCore reads them", "body": "90 means key on, 3C is key 60, 64 is force 100.", "active": ["parse", "core"] },
      { "title": "The screen lights the key", "body": "Key 60 lights, and the label says C4, middle C.", "active": ["event", "show", "app"] }
    ]
  }]
}
```

1. Arjun presses middle C.
2. The P-125 sends `90 3C 64`.
3. PianoCore turns it into a key event: key on, key 60, force 100.
4. The app lights key 60.

**Output:** the on-screen key C4 is lit. The label says "C4, middle C".

### US-2: you plug in the cable after the app opens

**Input:** the app is open and shows "Connect your keyboard". Arjun plugs in the cable.

```woodcut wc-sequence
{
  "label": "US-2: plug in late",
  "viewBox": [460, 160],
  "actors": [
    { "id": "arjun", "x": 70, "label": "Arjun" },
    { "id": "midi", "x": 230, "label": "Core MIDI" },
    { "id": "app", "x": 390, "label": "App" }
  ],
  "messages": [
    { "id": "plug", "from": "arjun", "to": "midi", "y": 70, "label": "plug in cable" },
    { "id": "added", "from": "midi", "to": "app", "y": 105, "label": "device added" },
    { "id": "ready", "from": "app", "to": "arjun", "y": 140, "label": "Connected: P-125", "kind": "return" }
  ],
  "scenarios": [{
    "name": "US-2",
    "steps": [
      { "title": "Arjun plugs in the cable", "body": "Core MIDI sees a new source.", "active": ["arjun", "plug", "midi"] },
      { "title": "The app connects", "body": "The app connects its input port to every source.", "active": ["added", "app"] },
      { "title": "The screen says connected", "body": "The banner shows the device name.", "active": ["ready"] }
    ]
  }]
}
```

1. The app shows "Connect your keyboard".
2. Arjun plugs in the cable. Core MIDI tells the app that a device came.
3. The app connects to it, with no tap.

**Output:** the banner says "Connected: Digital Piano" (the name the P-125 gives).

### US-3: you play a chord

**Input:** Arjun presses C4, E4 and G4 at the same time.

```woodcut wc-sequence
{
  "label": "US-3: a chord",
  "viewBox": [460, 160],
  "actors": [
    { "id": "p125", "x": 70, "label": "P-125" },
    { "id": "core", "x": 230, "label": "PianoCore" },
    { "id": "app", "x": 390, "label": "App" }
  ],
  "messages": [
    { "id": "bytes", "from": "p125", "to": "core", "y": 70, "label": "90 3C 50, 90 40 50, 90 43 50" },
    { "id": "events", "from": "core", "to": "app", "y": 105, "label": "3 key on events" },
    { "id": "up", "from": "p125", "to": "core", "y": 140, "label": "80 3C 00 ..." }
  ],
  "scenarios": [{
    "name": "US-3",
    "steps": [
      { "title": "Three keys go down", "body": "One packet can hold three messages. PianoCore reads all of them.", "active": ["bytes", "core"] },
      { "title": "Three keys light", "body": "The app lights C4, E4 and G4 and shows C major.", "active": ["events", "app"] },
      { "title": "The keys come up", "body": "Key off, or key on with force 0, clears each key.", "active": ["up"] }
    ]
  }]
}
```

1. The P-125 sends three key-on messages, maybe in one packet.
2. PianoCore returns three events.
3. When Arjun lifts his hand, each key clears.

**Output:** C4, E4 and G4 are lit while held. All three clear when he lets go.
