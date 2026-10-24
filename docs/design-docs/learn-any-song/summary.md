---
part: summary
---
# Summary

You ask for a song. The app gets the notes of the song, and makes short
lessons from them. You play on your Yamaha keyboard. The iPad reads each key
over a cable, and tells you at once if the key was right.

This design is the plan for the whole app. It splits the app into five
smaller designs, D1 to D5. It names the decisions that all five share, and
the questions that only you can answer. The hardest part is "any song": the
app needs the correct notes before it can teach them.

Songs come in by two layers. Layer 1: you import a sheet that exists, so the
notes are exact. Layer 2: no sheet exists. A helper app on your Mac records
the song as your Mac plays it. A piano model writes the notes. Rules then make
three levels: beginner, intermediate and advanced.

```figure
<svg viewBox="0 0 640 120" role="img" aria-label="Song name, then notes, then lessons, then practice on the keyboard, then feedback">
  <g font-family="var(--mono)" font-size="13" fill="var(--ink)">
    <rect x="2" y="40" width="110" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="14" y="65">"Let It Be"</text>
    <rect x="132" y="40" width="110" height="40" rx="6" fill="var(--accent-bg)" stroke="var(--accent)"/><text x="160" y="65">Notes</text>
    <rect x="262" y="40" width="110" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="285" y="65">Lessons</text>
    <rect x="392" y="40" width="110" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="410" y="65">You play</text>
    <rect x="522" y="40" width="110" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="540" y="65">Feedback</text>
    <text x="150" y="30" font-size="11">D2</text><text x="280" y="30" font-size="11">D3</text><text x="410" y="30" font-size="11">D1 + D4</text><text x="540" y="30" font-size="11">D4</text>
    <text x="120" y="105" font-size="11">hardest part: the notes must be right</text>
  </g>
  <g stroke="var(--line-strong)" fill="none">
    <path d="M112 60 H132"/><path d="M242 60 H262"/><path d="M372 60 H392"/><path d="M502 60 H522"/>
    <path d="M577 80 V95 H447 V80" stroke-dasharray="4 3"/>
  </g>
</svg>
```

A worked example, from the ask to the feedback:

| Step | Input | Output |
|---|---|---|
| Find the notes | No sheet, so Layer 2. You play a YouTube piano cover of "Let It Be". The Mac helper records it | A master score: 4 minutes, both hands, 1,900 notes |
| Make it easy | The master score, level beginner | The right-hand tune only, in C, at 60 beats per minute |
| Cut it up | The easy tune | 12 lessons of 4 bars each |
| Practise | Lesson 1. You press E, then D | The app lights E and waits. D is wrong, so the key shows red and the app waits for E again |
| Score | 32 key presses | "29 of 32 right. 3 late. Try lesson 1 again at 70 beats per minute?" |
