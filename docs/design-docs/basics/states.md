---
part: states
---
# States

A lesson has three states. An exercise uses the wait mode states of D4.

```woodcut wc-state-machine
{
  "label": "A lesson",
  "viewBox": [480, 120],
  "states": [
    { "id": "shut", "x": 10, "y": 40, "w": 100, "h": 32, "label": "Shut" },
    { "id": "open", "x": 190, "y": 40, "w": 100, "h": 32, "label": "Open" },
    { "id": "done", "x": 370, "y": 40, "w": 100, "h": 32, "label": "Done", "terminal": true }
  ],
  "transitions": [
    { "id": "unlock", "path": "M 110 56 L 188 56", "tip": [188, 56], "tipDir": [1, 0], "label": "lesson before done", "labelAt": [149, 32] },
    { "id": "pass", "path": "M 290 56 L 368 56", "tip": [368, 56], "tipDir": [1, 0], "label": "last pass", "labelAt": [329, 32] },
    { "id": "try", "path": "M 220 72 C 220 110, 260 110, 260 74", "tip": [260, 74], "tipDir": [0, -1], "label": "a try, pass or not", "labelAt": [240, 112] }
  ]
}
```

| From | Event | To |
|---|---|---|
| Shut | Arjun passes the last exercise of the lesson before it | Open |
| Open | A try that does not pass, or a pass with exercises left | Open |
| Open | A pass of the last exercise that was not passed | Done |
| Done | Any try, pass or not | Done. A pass is never taken away |

Lesson 1 starts Open.
