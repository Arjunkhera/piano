---
part: stories
---
# Stories

### US-1: a beginner lesson of a song in D major

**Input:** the first line of "Twinkle, Twinkle, Little Star" in D major, right
hand: D D A A B B A, G G F# F# E E D. Each note is one beat, and the two A and
D at the phrase ends are two beats.

```woodcut wc-sequence
{
  "label": "US-1: a beginner lesson",
  "viewBox": [560, 230],
  "actors": [
    { "id": "d2", "x": 60, "label": "D2" },
    { "id": "maker", "x": 200, "label": "Lesson maker" },
    { "id": "checker", "x": 360, "label": "Level checker" },
    { "id": "d4", "x": 500, "label": "D4" }
  ],
  "messages": [
    { "id": "score", "from": "d2", "to": "maker", "y": 70, "label": "14 notes, D major" },
    { "id": "lesson", "from": "maker", "to": "checker", "y": 110, "label": "lesson in C" },
    { "id": "ok", "from": "checker", "to": "maker", "y": 150, "label": "no breach", "kind": "return" },
    { "id": "show", "from": "maker", "to": "d4", "y": 190, "label": "beginner lesson" }
  ],
  "scenarios": [{
    "name": "US-1",
    "steps": [
      { "title": "D2 gives the score", "body": "14 notes of the tune in D major.", "active": ["d2", "score", "maker"] },
      { "title": "The maker finds the key", "body": "D major. It moves every note 2 keys down, to C major.", "active": ["maker"] },
      { "title": "The maker places each note", "body": "C to G go to the right hand, fingers 1 to 5. A goes to the left hand, finger 3.", "active": ["maker", "lesson"] },
      { "title": "The checker reads it", "body": "One key at a time, white keys, on the beat, in middle C position: no breach.", "active": ["checker", "ok"] },
      { "title": "D4 gets the lesson", "body": "D4 shows it in wait mode.", "active": ["show", "d4"] }
    ]
  }]
}
```

1. The maker finds the key: D major.
2. It moves each note 2 keys down, so the song is in C major.
3. It places each note in middle C position. C, D, E, F and G go to the right
   hand, fingers 1 to 5. A goes to the left hand at A3, finger 3.
4. The checker finds no breach.

**Output:** C C G G A A G, F F E E D D C. The two A notes are left hand, at
A3. The fingers are 1 1 5 5 3 3 5, 4 4 3 3 2 2 1. The test
`testBeginnerMovesTwinkleFromDToMiddleCPosition` holds this example.

### US-2: an intermediate lesson of a song in E major

**Input:** the same tune in E major, which has 4 sharps.

```woodcut wc-sequence
{
  "label": "US-2: an intermediate lesson",
  "viewBox": [460, 190],
  "actors": [
    { "id": "d2", "x": 70, "label": "D2" },
    { "id": "maker", "x": 230, "label": "Lesson maker" },
    { "id": "checker", "x": 390, "label": "Level checker" }
  ],
  "messages": [
    { "id": "score", "from": "d2", "to": "maker", "y": 70, "label": "tune in E major" },
    { "id": "lesson", "from": "maker", "to": "checker", "y": 115, "label": "lesson in Eb major" },
    { "id": "ok", "from": "checker", "to": "maker", "y": 160, "label": "no breach", "kind": "return" }
  ],
  "scenarios": [{
    "name": "US-2",
    "steps": [
      { "title": "D2 gives the score", "body": "The tune in E major, with 4 sharps.", "active": ["d2", "score", "maker"] },
      { "title": "The maker moves the key", "body": "1 key down, to E flat major, with 3 flats.", "active": ["maker"] },
      { "title": "The maker adds the left hand", "body": "Root and fifth of each bar's chord, held for the bar.", "active": ["maker", "lesson"] },
      { "title": "The checker reads it", "body": "Two keys a hand at most, on the eighth-note grid: no breach.", "active": ["checker", "ok"] }
    ]
  }]
}
```

1. The maker finds the key: E major. The limit at this level is 3 sharps or
   flats.
2. It moves the song 1 key down, to E flat major. That is the smallest move
   to a key in the limit.
3. It snaps each start and end to the eighth note. The right hand keeps its
   top two keys at each start.
4. It finds the chord of each bar. The left hand holds its root and fifth
   for the bar, below the right hand.

**Output:** the tune in E flat major, with root and fifth in the left hand.
The checker finds no breach.

### US-3: the checker finds a bug

**Input:** a lesson that holds a C major chord, at the beginner level.

```woodcut wc-sequence
{
  "label": "US-3: the checker finds a bug",
  "viewBox": [460, 150],
  "actors": [
    { "id": "test", "x": 70, "label": "Test" },
    { "id": "checker", "x": 230, "label": "Level checker" },
    { "id": "ci", "x": 390, "label": "CI" }
  ],
  "messages": [
    { "id": "chord", "from": "test", "to": "checker", "y": 70, "label": "C E G at beat 0" },
    { "id": "breach", "from": "checker", "to": "test", "y": 105, "label": "too many at once", "kind": "return" },
    { "id": "red", "from": "test", "to": "ci", "y": 135, "label": "test fails" }
  ],
  "scenarios": [{
    "name": "US-3",
    "steps": [
      { "title": "A lesson holds a chord", "body": "Three keys at beat 0, at the beginner level.", "active": ["test", "chord", "checker"] },
      { "title": "The checker gives a breach", "body": "A beginner hand plays one key at a time.", "active": ["checker", "breach"] },
      { "title": "The test fails", "body": "CI goes red, so the bug does not reach D4.", "active": ["red", "ci"] }
    ]
  }]
}
```

**Output:** the checker gives a "too many at once" breach, because a
beginner hand plays one key at a time. A test fails, so the bug does not
reach D4.
