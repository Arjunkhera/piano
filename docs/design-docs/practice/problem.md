---
part: problem
---
# Problem today

D1 lights each key you press. D3 makes easy lessons. But nothing joins them:
the app does not show what to play, and it does not say if you played it
right.

```figure
<svg viewBox="0 0 460 80" role="img" aria-label="Today the lesson and the key presses do not meet">
  <g font-family="var(--mono)" font-size="13" fill="var(--ink)">
    <rect x="2" y="20" width="110" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="24" y="45">lesson</text>
    <rect x="320" y="20" width="136" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="338" y="45">key presses</text>
    <text x="150" y="45">no check between</text>
  </g>
  <g stroke="var(--line-strong)" fill="none" stroke-dasharray="4 3"><path d="M112 40 H140"/><path d="M290 40 H320"/></g>
</svg>
```

The D1 security review also found two faults in the keyboard reader. A key
can stay lit when one of two keyboards goes away. Two packets can reach the
screen out of order. Wait mode grades each key, so both faults must go first.
