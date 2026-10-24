---
part: summary
---
# Summary

D3 is the lesson maker. It takes the master score of a song, which is every
note at full difficulty. It makes three lessons from it: beginner,
intermediate and advanced. Fixed rules make each lesson. The rules come from
the Alfred and ABRSM levelling guides. No AI writes the notes.

A second piece, the level checker, reads each lesson and lists each rule it
breaks. The maker and the checker are separate code. So a bug in the maker
shows as a breach, and a test fails.

Both pieces are plain Swift in PianoCore. They need no screen, no network and
no song file.

```figure
<svg viewBox="0 0 600 150" role="img" aria-label="One master score goes into the lesson maker, which writes three lessons. The level checker reads each lesson.">
  <g font-family="var(--mono)" font-size="13" fill="var(--ink)">
    <rect x="2" y="55" width="120" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="14" y="80">master score</text>
    <rect x="160" y="55" width="130" height="40" rx="6" fill="var(--accent-bg)" stroke="var(--accent)"/><text x="172" y="80">lesson maker</text>
    <rect x="330" y="5" width="120" height="34" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="350" y="27">beginner</text>
    <rect x="330" y="58" width="120" height="34" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="336" y="80">intermediate</text>
    <rect x="330" y="111" width="120" height="34" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="350" y="133">advanced</text>
    <rect x="480" y="55" width="116" height="40" rx="6" fill="var(--accent-bg)" stroke="var(--accent)"/><text x="490" y="80">level checker</text>
  </g>
  <g stroke="var(--line-strong)" fill="none">
    <path d="M122 75 H160"/><path d="M290 75 L330 22"/><path d="M290 75 H330"/><path d="M290 75 L330 128"/>
    <path d="M450 22 L480 75"/><path d="M450 75 H480"/><path d="M450 128 L480 75"/>
  </g>
</svg>
```
