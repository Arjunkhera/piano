---
part: records
---
# Records and the score rules

D4 keeps no stored data yet. These are the values it reads and writes.

| Record | Written by | Holds |
|---|---|---|
| Lesson | D3 | the notes at one level, and the beats in a bar |
| LessonPart | PianoCore | the part number (from 1), the first bar, and the notes that start in its bars |
| Hands | Arjun's pick | right, left or both |
| PracticeStep | PianoCore | the beat where the step starts, the keys to press, and the notes |
| Mark | Wait mode | right, late or wrong |
| Press | Wait mode | the key, the time in seconds, the step, and the mark |
| PracticeScore | PianoCore | notes, right notes, wrong keys, late notes, and the tip |
| Tip | PianoCore | faster, again or slower, and the tempo to try next |

## The rules

1. **Steps.** The notes of the hands you chose, grouped by start. All notes
   that start on the same beat are one step.
2. **Right.** A key of the step that is not pressed yet in this step.
3. **Wrong.** A key that is not in the step. The step stays.
4. **Late.** A right key, pressed more than half a beat after the step was
   due. Step 1 is never late. Step k is due when step k minus 1 is done,
   plus the beats between their starts, at the tempo.
5. **Right notes.** The notes of each step that had no wrong key. A late note
   is still a right note.

## The tip

| When | Tip | Tempo next |
|---|---|---|
| 90 percent or more of the notes are right, and 10 percent or fewer are late | Faster: "Well done. Try it at N beats per minute." | 10 faster, at most 240 |
| 70 percent or more are right | Again: "Play it again at N beats per minute." | the same |
| Less than 70 percent are right | Slower: "Try it slower, at N beats per minute." | 10 slower, at least 30 |
