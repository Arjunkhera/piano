---
part: order
---
# Order and dependencies

```figure
<svg viewBox="0 0 560 150" role="img" aria-label="D1 and D2 start first. D3 waits on D2. D4 waits on D1 and D3. D5 waits on D1.">
  <g font-family="var(--mono)" font-size="12" fill="var(--ink)">
    <rect x="2" y="10" width="150" height="36" rx="6" fill="var(--accent-bg)" stroke="var(--accent)"/><text x="12" y="33">D1 Keyboard link</text>
    <rect x="2" y="100" width="150" height="36" rx="6" fill="var(--accent-bg)" stroke="var(--accent)"/><text x="12" y="123">D2 Song in</text>
    <rect x="202" y="100" width="150" height="36" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="212" y="123">D3 Lesson maker</text>
    <rect x="402" y="55" width="150" height="36" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="412" y="78">D4 Practice</text>
    <rect x="202" y="10" width="150" height="36" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="212" y="33">D5 Basics course</text>
  </g>
  <g stroke="var(--line-strong)" fill="none">
    <path d="M152 118 H202"/><path d="M352 118 H380 V73 H402"/><path d="M152 28 H170 V60 H380 V73"/><path d="M152 28 H202"/>
  </g>
</svg>
```

1. D1, Keyboard link. It comes first, because it is the cheapest test of the
   whole idea. The app shows each key you press, by name, on screen. It
   waits on your keyboard model and the cable.
2. D2, Song in. It starts at the same time as D1. It is a Decide design:
   where the notes come from. It waits on your answer to the first question.
3. D3, Lesson maker. It waits on D2. It turns a full song into easy lessons.
4. D4, Practice and feedback. It waits on D1 and D3. Wait mode, the falling
   notes or sheet view, and the score after each lesson.
5. D5, Basics course. It waits on D1. It uses the same practice screen with
   lessons that we write by hand.
