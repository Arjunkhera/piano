---
part: records
---
# Records and the level rules

D3 keeps no stored data. These are the values it reads and writes.

| Record | Written by | Holds |
|---|---|---|
| Note | D2, and the lesson maker | key, start in beats, length in beats, hand, finger (from D1) |
| Level | PianoCore | beginner, intermediate or advanced, and its rules |
| MusicKey | The lesson maker | the key note (0 is C, up to 11 for B) and major or minor |
| Lesson | The lesson maker | the level, the notes, the key after the move, the move in keys, the beats in a bar |
| Breach | The level checker | the rule, the note when one note breaks it, and one line on what is wrong |

A Lesson converts to and from JSON, so D4 can store it with the song on the
device.

## The level rules


The rules come from the level table in the research report. Alfred's
levelling guide and ABRSM's sight-reading table are its sources. The code
holds them in `Level.rules`, and the checker reads the same values.

| Rule | Beginner | Intermediate | Advanced |
|---|---|---|---|
| Keys one hand holds at once | 1 | 2 | 5 |
| Widest reach of one hand | a 5th (7 keys) | an octave (12 keys) | a 9th (14 keys) |
| Rhythm grid | the beat | the eighth note | any |
| Shortest note | 1 beat | half a beat | a 32nd note (1/8 beat) |
| Longest note | 4 beats, and never past the bar line | any | any |
| Key | C major or A minor | 3 or fewer sharps or flats | as written |
| Black keys | none | any | any |
| Hand position | middle C: right hand C4 to G4, left hand F3 to B3 | any | any |
| Left hand | tune notes A and B only | root and fifth of each bar's chord | as written |

How the maker meets each rule:

```figure
<svg viewBox="0 0 600 130" role="img" aria-label="The steps of the maker: clean, find the key, move, then the level steps, then sort">
  <g font-family="var(--mono)" font-size="12" fill="var(--ink)">
    <rect x="2" y="45" width="90" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="22" y="69">clean</text>
    <rect x="112" y="45" width="100" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="124" y="69">find key</text>
    <rect x="232" y="45" width="90" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="256" y="69">move</text>
    <rect x="342" y="45" width="130" height="40" rx="6" fill="var(--accent-bg)" stroke="var(--accent)"/><text x="354" y="69">level steps</text>
    <rect x="492" y="45" width="100" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="522" y="69">sort</text>
    <text x="342" y="110" font-size="11">snap, top keys, place, fit hands</text>
    <text x="112" y="30" font-size="11">Krumhansl-Kessler</text>
  </g>
  <g stroke="var(--line-strong)" fill="none"><path d="M92 65 H112"/><path d="M212 65 H232"/><path d="M322 65 H342"/><path d="M472 65 H492"/></g>
</svg>
```

1. **Clean.** Drop notes with no length, a start before beat 0, or a key off
   the 88-key piano.
2. **Find the key.** Count each pitch class by its length. The key whose
   Krumhansl-Kessler profile fits best wins.
3. **Move.** Beginner: to C major or A minor, by 6 keys or fewer.
   Intermediate: by the fewest keys to a key with 3 or fewer sharps or
   flats. E major goes 1 key down to E flat major. Advanced: no move.
4. **Level steps.**
   - Beginner: snap each start to the beat. The top key at each beat is the
     tune. A black key becomes the white key below it. Each note moves by
     octaves into middle C position. Each note ends at the next note, at the
     bar line, or after 4 beats.
   - Intermediate: snap each start and end to the eighth note. The right
     hand keeps its top two keys inside an octave. For each bar, the maker
     finds the major or minor chord that fits the notes best. The left hand
     holds its root and fifth for the bar, an octave lower if they reach the
     right hand.
   - Advanced: drop notes shorter than a 32nd note. Each hand keeps its top
     (right) or bottom (left) five keys inside a 9th.
5. **Fit the hands.** A held note that breaks a limit of its hand ends where
   the new notes start.
6. **Sort** by start, then by key.
