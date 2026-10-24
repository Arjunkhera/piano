---
part: stories
---
# Stories

### US-1: a near pass is not a pass

```woodcut wc-sequence
{
  "label": "US-1: a near pass is not a pass",
  "viewBox": [
    520,
    190
  ],
  "actors": [
    {
      "id": "arjun",
      "x": 60,
      "label": "Arjun"
    },
    {
      "id": "wait",
      "x": 200,
      "label": "Wait mode"
    },
    {
      "id": "course",
      "x": 340,
      "label": "Basics course"
    },
    {
      "id": "screen",
      "x": 470,
      "label": "Screen"
    }
  ],
  "messages": [
    {
      "id": "wrong",
      "from": "arjun",
      "to": "wait",
      "y": 70,
      "label": "wrong key, then the rest right"
    },
    {
      "id": "score",
      "from": "wait",
      "to": "course",
      "y": 110,
      "label": "8 of 9 right"
    },
    {
      "id": "verdict",
      "from": "course",
      "to": "screen",
      "y": 150,
      "label": "Not yet",
      "kind": "return"
    }
  ],
  "scenarios": [
    {
      "name": "US-1",
      "steps": [
        {
          "title": "A wrong key on step 4",
          "body": "Wait mode marks it wrong and stays on step 4.",
          "active": [
            "arjun",
            "wrong",
            "wait"
          ]
        },
        {
          "title": "The score",
          "body": "8 of 9 right: 89 percent.",
          "active": [
            "wait",
            "score",
            "course"
          ]
        },
        {
          "title": "Not yet",
          "body": "The pass rule needs 90 percent. No tick.",
          "active": [
            "course",
            "verdict",
            "screen"
          ]
        }
      ]
    }
  ]
}
```

**Input:** exercise 2.2, "Up and down", 9 notes. Arjun presses one wrong
key on the 4th step, then plays the rest right.

1. Wait mode marks the wrong key and stays on step 4.
2. The score is 8 of 9 right, which is 89 percent.
3. The pass rule needs 90 percent. The screen says "Not yet".

**Output:** no tick, and lesson 3 stays shut. The test
`testPassNeedsNinetyPercentRight` holds this example.

### US-2: the gate opens

```woodcut wc-sequence
{
  "label": "US-2: the gate opens",
  "viewBox": [
    520,
    190
  ],
  "actors": [
    {
      "id": "arjun",
      "x": 60,
      "label": "Arjun"
    },
    {
      "id": "wait",
      "x": 200,
      "label": "Wait mode"
    },
    {
      "id": "course",
      "x": 340,
      "label": "Basics course"
    },
    {
      "id": "screen",
      "x": 470,
      "label": "Screen"
    }
  ],
  "messages": [
    {
      "id": "p12",
      "from": "arjun",
      "to": "course",
      "y": 70,
      "label": "pass 1.1, pass 1.2"
    },
    {
      "id": "p3",
      "from": "arjun",
      "to": "course",
      "y": 110,
      "label": "pass 1.3"
    },
    {
      "id": "open",
      "from": "course",
      "to": "screen",
      "y": 150,
      "label": "lesson 2 open",
      "kind": "return"
    }
  ],
  "scenarios": [
    {
      "name": "US-2",
      "steps": [
        {
          "title": "Two passes",
          "body": "1.1 and 1.2 pass. Lesson 2 stays shut: 1.3 is left.",
          "active": [
            "arjun",
            "p12",
            "course"
          ]
        },
        {
          "title": "The last pass",
          "body": "1.3 passes. Lesson 1 is done.",
          "active": [
            "arjun",
            "p3",
            "course"
          ]
        },
        {
          "title": "Lesson 2 opens",
          "body": "The list shows a tick on lesson 1 and a circle on lesson 2.",
          "active": [
            "course",
            "open",
            "screen"
          ]
        }
      ]
    }
  ]
}
```

**Input:** a new install. Arjun passes 1.1 and 1.2, then 1.3.

1. After 1.1 and 1.2, lesson 2 is still shut: one exercise is left.
2. After 1.3, lesson 1 is done, and lesson 2 opens. Lesson 3 stays shut.

**Output:** the course list shows a tick on lesson 1 and a circle on
lesson 2. The test `testPassingEachExerciseOpensTheNextLesson` holds this
example.

### US-3: time counts from lesson 5

```woodcut wc-sequence
{
  "label": "US-3: time counts from lesson 5",
  "viewBox": [
    520,
    190
  ],
  "actors": [
    {
      "id": "arjun",
      "x": 60,
      "label": "Arjun"
    },
    {
      "id": "wait",
      "x": 200,
      "label": "Wait mode"
    },
    {
      "id": "course",
      "x": 340,
      "label": "Basics course"
    },
    {
      "id": "screen",
      "x": 470,
      "label": "Screen"
    }
  ],
  "messages": [
    {
      "id": "late",
      "from": "arjun",
      "to": "wait",
      "y": 70,
      "label": "26 right keys, 3 late"
    },
    {
      "id": "count",
      "from": "wait",
      "to": "course",
      "y": 110,
      "label": "3 of 26 late"
    },
    {
      "id": "verdict",
      "from": "course",
      "to": "screen",
      "y": 150,
      "label": "Not yet",
      "kind": "return"
    }
  ],
  "scenarios": [
    {
      "name": "US-3",
      "steps": [
        {
          "title": "Three late keys",
          "body": "Each key is right, but 3 of 26 come more than half a beat late.",
          "active": [
            "arjun",
            "late",
            "wait"
          ]
        },
        {
          "title": "Too many late",
          "body": "11.5 percent late. The limit for a timed exercise is 10 percent.",
          "active": [
            "wait",
            "count",
            "course"
          ]
        },
        {
          "title": "Not yet",
          "body": "5.2 does not pass. In lesson 2 the same keys would pass.",
          "active": [
            "course",
            "verdict",
            "screen"
          ]
        }
      ]
    }
  ]
}
```

**Input:** "Mary Had a Little Lamb", 26 notes, exercise 5.2. Arjun plays
each key right, but 3 keys come more than half a beat late.

1. 3 of 26 is 11.5 percent late. The limit is 10 percent.
2. The same 3 late keys in exercise 2.2 do not count, because lesson 2 is
   not timed.

**Output:** 5.2 is "Not yet". With 2 late keys it passes. The test
`testLateKeysCountOnlyInTimedExercises` holds this example.

### US-4: read a note on the staff

```woodcut wc-sequence
{
  "label": "US-4: read a note on the staff",
  "viewBox": [
    520,
    190
  ],
  "actors": [
    {
      "id": "arjun",
      "x": 60,
      "label": "Arjun"
    },
    {
      "id": "wait",
      "x": 200,
      "label": "Wait mode"
    },
    {
      "id": "course",
      "x": 340,
      "label": "Basics course"
    },
    {
      "id": "screen",
      "x": 470,
      "label": "Screen"
    }
  ],
  "messages": [
    {
      "id": "show",
      "from": "course",
      "to": "screen",
      "y": 70,
      "label": "note on the bottom line"
    },
    {
      "id": "press",
      "from": "arjun",
      "to": "wait",
      "y": 110,
      "label": "press E4"
    },
    {
      "id": "right",
      "from": "wait",
      "to": "screen",
      "y": 150,
      "label": "right: next note",
      "kind": "return"
    }
  ],
  "scenarios": [
    {
      "name": "US-4",
      "steps": [
        {
          "title": "A note on the bottom line",
          "body": "The screen shows the staff only. No name, no lit key.",
          "active": [
            "screen",
            "show"
          ]
        },
        {
          "title": "Arjun reads E4",
          "body": "Arjun presses E4.",
          "active": [
            "arjun",
            "press",
            "wait"
          ]
        },
        {
          "title": "Right",
          "body": "E4 shows green. The next note moves to the front.",
          "active": [
            "wait",
            "right",
            "screen"
          ]
        }
      ]
    }
  ]
}
```

**Input:** exercise 6.1. The screen shows a staff with a note on the bottom
line, and no name. The screen keyboard does not light the key.

1. Arjun reads the bottom line of the treble staff: E4.
2. Arjun presses E4. It shows green, and the next note moves to the front.

**Output:** a right mark, with no name shown before the press. The tests in
`StaffTests` hold where each note sits.
