---
part: summary
---
# Summary

D4 is the practice screen. You pick a song, a level, a part of 4 bars and
the hands. The screen lights the next key.

The screen waits until you press that
key. A right key shows green, and the screen moves on. A wrong key shows
red, and the screen waits again. At the end of the part, you get a score and
one tip, such as "Try it again at 70 beats per minute".

The rules are plain Swift in PianoCore, with tests. The screen in the app
only shows what the rules decide.

```figure
<svg viewBox="0 0 620 130" role="img" aria-label="A lesson is cut into parts. Wait mode reads each key press and gives right, late or wrong. The score comes at the end of the part.">
  <g font-family="var(--mono)" font-size="13" fill="var(--ink)">
    <rect x="2" y="45" width="100" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="24" y="70">lesson</text>
    <rect x="132" y="45" width="110" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="150" y="70">4-bar part</text>
    <rect x="272" y="45" width="120" height="40" rx="6" fill="var(--accent-bg)" stroke="var(--accent)"/><text x="292" y="70">wait mode</text>
    <rect x="422" y="45" width="90" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="446" y="70">score</text>
    <rect x="532" y="45" width="84" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="558" y="70">tip</text>
    <text x="270" y="20" font-size="11">key press: right, late or wrong</text>
    <text x="272" y="115" font-size="11">waits for the right key</text>
  </g>
  <g stroke="var(--line-strong)" fill="none">
    <path d="M102 65 H132"/><path d="M242 65 H272"/><path d="M392 65 H422"/><path d="M512 65 H532"/>
    <path d="M332 30 V45" stroke-dasharray="4 3"/>
  </g>
</svg>
```

A worked example:

| Step | Input | Output |
|---|---|---|
| Pick | "Twinkle, Twinkle, Little Star", beginner, part 1, both hands, 60 beats per minute | 4 bars, 14 notes |
| Play | The screen lights C4. You press D4 | D4 shows red. One wrong key is counted. The screen still waits for C4 |
| Play | You press C4 | C4 shows green. The screen lights the next C4 |
| End | 14 notes. 1 wrong key on one note. 1 note late | "13 of 14 right. 1 wrong key. 1 late." Tip: "Well done. Try it at 70 beats per minute." |
