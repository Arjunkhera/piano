---
part: summary
---
# Summary

D2 gets the notes of a song into the app, in two layers.

- **Layer 1, a sheet.** You import a MIDI, MusicXML or .mxl file on the
  iPad. PianoCore reads it into the shared note format. The notes are exact.
- **Layer 2, no sheet.** On your Mac, `piano-listen` records the sound that
  the Mac plays, such as a YouTube piano cover in Safari. It downloads
  nothing. Transkun, a piano model, writes the notes as a MIDI file. You send
  that file to the iPad, and Layer 1 imports it.

So both layers end in the same importer, and D3 gets one kind of input.

```figure
<svg viewBox="0 0 640 170" role="img" aria-label="Layer 2 on the Mac records sound, Transkun writes a MIDI file, the file goes to the iPad. Layer 1 imports a sheet file. Both go to PianoCore, then the song list.">
  <g font-family="var(--mono)" font-size="12" fill="var(--ink)">
    <text x="2" y="16" font-size="11">Mac (Layer 2)</text>
    <rect x="2" y="24" width="120" height="36" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="12" y="47">Mac plays song</text>
    <rect x="142" y="24" width="120" height="36" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="152" y="47">piano-listen</text>
    <rect x="282" y="24" width="120" height="36" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="300" y="47">Transkun</text>
    <text x="2" y="96" font-size="11">iPad (Layer 1)</text>
    <rect x="2" y="104" width="120" height="36" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="12" y="127">sheet file</text>
    <rect x="282" y="104" width="120" height="36" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="296" y="127">.mid file</text>
    <rect x="422" y="104" width="100" height="36" rx="6" fill="var(--accent-bg)" stroke="var(--accent)"/><text x="436" y="127">PianoCore</text>
    <rect x="542" y="104" width="96" height="36" rx="6" fill="var(--card)" stroke="var(--line-strong)"/><text x="552" y="127">Song list</text>
    <text x="410" y="80" font-size="11">AirDrop</text>
  </g>
  <g stroke="var(--line-strong)" fill="none">
    <path d="M122 42 H142"/><path d="M262 42 H282"/><path d="M342 60 V104"/>
    <path d="M122 122 H160 V150 H440 V140"/><path d="M402 122 H422"/><path d="M522 122 H542"/>
  </g>
</svg>
```

A worked example:

| Step | Input | Output |
|---|---|---|
| Layer 1 | "Ode.mxl", bought from a score shop, 2 staves | 212 notes. Staff 1 is the right hand, staff 2 the left. 96 beats a minute, 4 beats a bar |
| Layer 2 | `piano-listen record "Let It Be"`, while a solo piano cover plays in Safari for 4 minutes | "Let It Be.mid" in ~/Music/Piano Songs: about 1,900 notes |
| Import | "Let It Be.mid", by AirDrop to the iPad, then Import song | The song in the list. Keys below middle C go to the left hand |
