---
part: states
---
# States

```woodcut wc-state-machine
{
  "label": "Wait mode",
  "viewBox": [480, 120],
  "states": [
    { "id": "ready", "x": 10, "y": 40, "w": 100, "h": 32, "label": "Ready" },
    { "id": "waiting", "x": 190, "y": 40, "w": 110, "h": 32, "label": "Waiting" },
    { "id": "done", "x": 370, "y": 40, "w": 100, "h": 32, "label": "Done", "terminal": true }
  ],
  "transitions": [
    { "id": "start", "path": "M 110 56 L 188 56", "tip": [188, 56], "tipDir": [1, 0], "label": "part picked", "labelAt": [149, 32] },
    { "id": "last", "path": "M 300 56 L 368 56", "tip": [368, 56], "tipDir": [1, 0], "label": "last step done", "labelAt": [334, 32] },
    { "id": "next", "path": "M 220 72 C 220 110, 270 110, 270 74", "tip": [270, 74], "tipDir": [0, -1], "label": "step done, or wrong key", "labelAt": [245, 112] }
  ]
}
```

| From | Event | To |
|---|---|---|
| Ready | Arjun picks a part with at least one note | Waiting, at step 1 |
| Ready | Arjun picks a part with no notes for the hands he chose | Done, with an empty score |
| Waiting | A wrong key | Waiting, at the same step |
| Waiting | A right key, and the step still has a key to press | Waiting, at the same step |
| Waiting | The last key of a step that is not the last step | Waiting, at the next step |
| Waiting | The last key of the last step | Done |
| Done | Arjun taps "Again" or picks another part | Ready |
