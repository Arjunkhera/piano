---
part: records
---
# Records

D1 keeps no stored data. These are the values in memory.

| Record | Written by | Holds |
|---|---|---|
| KeyEvent | PianoCore, from MIDI bytes | kind (key on, key off, pedal), key (21 to 108), force (0 to 127), time |
| Note | PianoCore, shared with D2 to D5 | key, start in beats, length in beats, hand (left or right), finger (1 to 5, optional) |
| Held keys | The app | The set of keys that are down now |
| Connection | The app | The device names that are connected now |
