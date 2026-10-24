---
part: edges
---
# Edge cases

| Case | What happens |
|---|---|
| A key that the step already has | No new mark. A repeat of a right key does not count as wrong. |
| A key release, or the pedal | No mark. Wait mode reads key presses only. |
| A press after the part is done | No mark. |
| Two wrong keys on one note | 2 wrong keys are counted, but the note counts once as not right. |
| A part with no notes for the hands you chose | The part is done at once. The score says "No notes to play." |
| The first step of a part | It is never late. You start when you are ready. |
| A tempo out of range | Wait mode keeps it between 30 and 240 beats per minute. |
| Two keyboards, and one is unplugged | Only the keys of that keyboard go dark. The other keyboard's held keys stay. |
| An app on the iPad makes a virtual MIDI source | The keyboard reader does not read it. Only real devices count. |
| Many packets in a short time | They reach wait mode in the order they came, through one queue. |
| A song shorter than 4 bars | It has one part. |
| A note that starts in one part and ends in the next | It belongs to the part where it starts. |
