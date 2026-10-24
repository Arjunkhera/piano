---
part: summary
---
# Summary

D1 is the first piece of the piano app. You connect the Yamaha P-125 to the
iPad with your USB cable. You press a key. The app lights that key on an
on-screen keyboard and shows its name, such as "C4, middle C".

D1 also lays the base for D2 to D5. It adds the Xcode app and the tests. It
adds the shared note format, in a Swift package called PianoCore. It adds the
TestFlight build that puts the app on your iPad.

```figure
<svg viewBox="0 0 600 110" role="img" aria-label="P-125 key press goes over USB to Core MIDI, then PianoCore, then the screen">
  <g font-family="var(--mono)" font-size="13" fill="var(--ink)">
    <rect x="2" y="35" width="120" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="22" y="60">P-125 key</text>
    <rect x="160" y="35" width="120" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="178" y="60">USB cable</text>
    <rect x="318" y="35" width="120" height="40" rx="6" fill="var(--accent-bg)" stroke="var(--accent)"/><text x="335" y="60">PianoCore</text>
    <rect x="476" y="35" width="120" height="40" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="490" y="60">Lit key "C4"</text>
    <text x="160" y="25" font-size="11">3 bytes: 90 3C 64</text><text x="318" y="25" font-size="11">key on, 60, force 100</text>
  </g>
  <g stroke="var(--line-strong)" fill="none"><path d="M122 55 H160"/><path d="M280 55 H318"/><path d="M438 55 H476"/></g>
</svg>
```
