---
part: stories
---
# Stories

### US-1: a wrong key, then the right key

**Input:** "Twinkle, Twinkle, Little Star", beginner, part 1, both hands, 60
beats per minute. The part is C C G G A A G, F F E E D D C. The two A notes
are left hand, at A3. Arjun presses D4 first, then C4, then plays the rest
right and on time.

```woodcut wc-sequence
{
  "label": "US-1: a wrong key, then the right key",
  "viewBox": [560, 230],
  "actors": [
    { "id": "arjun", "x": 60, "label": "Arjun" },
    { "id": "reader", "x": 200, "label": "Keyboard reader" },
    { "id": "wait", "x": 360, "label": "Wait mode" },
    { "id": "screen", "x": 500, "label": "Screen" }
  ],
  "messages": [
    { "id": "d4", "from": "arjun", "to": "reader", "y": 70, "label": "press D4" },
    { "id": "wrong", "from": "wait", "to": "screen", "y": 110, "label": "wrong: D4 red", "kind": "return" },
    { "id": "c4", "from": "arjun", "to": "reader", "y": 150, "label": "press C4" },
    { "id": "right", "from": "wait", "to": "screen", "y": 190, "label": "right: next step", "kind": "return" }
  ],
  "scenarios": [{
    "name": "US-1",
    "steps": [
      { "title": "The screen lights C4", "body": "Step 1 of 14 waits for C4.", "active": ["screen", "wait"] },
      { "title": "Arjun presses D4", "body": "D4 is not in the step. Wait mode marks it wrong and stays on step 1.", "active": ["arjun", "d4", "reader", "wrong"] },
      { "title": "Arjun presses C4", "body": "C4 is the only key of step 1. Wait mode marks it right and moves to step 2.", "active": ["c4", "right", "wait"] },
      { "title": "The part ends", "body": "14 notes: 13 right, 1 with a wrong key. The tip says play it again at the same speed or faster.", "active": ["screen"] }
    ]
  }]
}
```

1. Wait mode makes 14 steps from the part, one key in each.
2. D4 is not a key of step 1. The mark is wrong. Step 1 stays.
3. C4 is the key of step 1. The mark is right. Step 2 starts.
4. The other 13 notes come right and on time.

**Output:** the score is "13 of 14 right. 1 wrong key. 0 late." That is 93
percent right with no late note. So the tip is "Well done. Try it at 70
beats per minute." The test `testWrongKeyThenRightKeyGivesTheScoreOfUS1`
holds this example.

### US-2: a chord in an intermediate lesson

**Input:** a step with two keys, C3 and G3, for the left hand. Arjun presses
G3 first, then C3.

```woodcut wc-sequence
{
  "label": "US-2: a chord",
  "viewBox": [460, 190],
  "actors": [
    { "id": "arjun", "x": 70, "label": "Arjun" },
    { "id": "wait", "x": 230, "label": "Wait mode" },
    { "id": "screen", "x": 390, "label": "Screen" }
  ],
  "messages": [
    { "id": "g3", "from": "arjun", "to": "wait", "y": 70, "label": "press G3" },
    { "id": "one", "from": "wait", "to": "screen", "y": 105, "label": "right: C3 still lit", "kind": "return" },
    { "id": "c3", "from": "arjun", "to": "wait", "y": 140, "label": "press C3" },
    { "id": "two", "from": "wait", "to": "screen", "y": 175, "label": "right: next step", "kind": "return" }
  ],
  "scenarios": [{
    "name": "US-2",
    "steps": [
      { "title": "The screen lights C3 and G3", "body": "One step holds both keys.", "active": ["screen"] },
      { "title": "Arjun presses G3", "body": "G3 is right. The step waits for C3.", "active": ["arjun", "g3", "wait", "one"] },
      { "title": "Arjun presses C3", "body": "Each key of the step is pressed, so the next step starts.", "active": ["c3", "two"] }
    ]
  }]
}
```

1. The step holds C3 and G3. The order does not matter.
2. G3 is right. The step waits for C3 only.
3. C3 is right. The step is done.

**Output:** two right marks, and the next step starts. The test
`testChordNeedsEachKeyInAnyOrder` holds this example.

### US-3: a late note

**Input:** 60 beats per minute, so one beat is 1 second. Step 1 is done at
time 10.0 seconds. Step 2 starts 1 beat after step 1. Arjun presses the key
of step 2 at 11.8 seconds.

```woodcut wc-sequence
{
  "label": "US-3: a late note",
  "viewBox": [460, 150],
  "actors": [
    { "id": "arjun", "x": 70, "label": "Arjun" },
    { "id": "wait", "x": 230, "label": "Wait mode" },
    { "id": "score", "x": 390, "label": "Score" }
  ],
  "messages": [
    { "id": "press", "from": "arjun", "to": "wait", "y": 70, "label": "right key at 11.8 s" },
    { "id": "late", "from": "wait", "to": "score", "y": 110, "label": "late: due 11.0, limit 11.5" }
  ],
  "scenarios": [{
    "name": "US-3",
    "steps": [
      { "title": "Step 2 is due", "body": "Step 1 was done at 10.0 s. Step 2 is 1 beat later, so it is due at 11.0 s.", "active": ["wait"] },
      { "title": "Arjun presses at 11.8 s", "body": "Half a beat is allowed, so the limit is 11.5 s. The key is right, but late.", "active": ["arjun", "press", "wait"] },
      { "title": "The score counts it", "body": "The note is right and it counts as late.", "active": ["late", "score"] }
    ]
  }]
}
```

1. Step 2 is due at 10.0 + 1 beat = 11.0 seconds.
2. Half a beat is allowed, so the limit is 11.5 seconds.
3. 11.8 is after the limit.

**Output:** the mark is late. The key shows green, and the score counts 1
late. A press at 11.4 seconds is right, not late. The test
`testRightKeyAfterHalfABeatIsLate` holds this example.
