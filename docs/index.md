# docs/ — the catalog

CLAUDE.md is the map of the repo. This file lists every document under
`docs/`. The Atlas check (`.github/atlas/check.mjs`) fails a file that is not
listed here.

## Designs

| Design | What it is |
|---|---|
| [Learn any song I ask for on piano](design-docs/learn-any-song/index.md) | The requirements design: five smaller designs, the shared decisions and the open questions. |
| [D1 Keyboard link](design-docs/keyboard-link/index.md) | The first app piece: read the P-125 over USB and light each key. |
| [D2 Song in](design-docs/song-in/index.md) | Get the notes of a song: import a sheet file, or record the Mac's sound and let Transkun write the notes. |
| [D3 Lesson maker](design-docs/lesson-maker/index.md) | Rules that make beginner, intermediate and advanced lessons from one master score. |
| [D4 Practice and feedback](design-docs/practice/index.md) | Wait mode, a mark on each key press, and a score with a tip after each part. |
| [D5 Basics course](design-docs/basics/index.md) | Seven short lessons before the first song: middle C, finger numbers, note names, beats, the staff and both hands. |

Parts of that design:
[design.yaml](design-docs/learn-any-song/design.yaml),
[summary](design-docs/learn-any-song/summary.md),
[words](design-docs/learn-any-song/words.md),
[goals](design-docs/learn-any-song/goals.md),
[why](design-docs/learn-any-song/why.md),
[shared decisions](design-docs/learn-any-song/shared-decisions.md),
[order](design-docs/learn-any-song/order.md),
[risks](design-docs/learn-any-song/risks.md),
[done](design-docs/learn-any-song/done.md),
[key](design-docs/learn-any-song/key.md).

Parts of the D1 design:
[design.yaml](design-docs/keyboard-link/design.yaml),
[summary](design-docs/keyboard-link/summary.md),
[words](design-docs/keyboard-link/words.md),
[goals](design-docs/keyboard-link/goals.md),
[problem](design-docs/keyboard-link/problem.md),
[actors](design-docs/keyboard-link/actors.md),
[stories](design-docs/keyboard-link/stories.md),
[edges](design-docs/keyboard-link/edges.md),
[records](design-docs/keyboard-link/records.md),
[risks](design-docs/keyboard-link/risks.md),
[proof](design-docs/keyboard-link/proof.md),
[change](design-docs/keyboard-link/change.md),
[done](design-docs/keyboard-link/done.md),
[key](design-docs/keyboard-link/key.md).

Parts of the D3 design:
[design.yaml](design-docs/lesson-maker/design.yaml),
[summary](design-docs/lesson-maker/summary.md),
[words](design-docs/lesson-maker/words.md),
[goals](design-docs/lesson-maker/goals.md),
[problem](design-docs/lesson-maker/problem.md),
[actors](design-docs/lesson-maker/actors.md),
[stories](design-docs/lesson-maker/stories.md),
[edges](design-docs/lesson-maker/edges.md),
[records and level rules](design-docs/lesson-maker/records.md),
[risks](design-docs/lesson-maker/risks.md),
[proof](design-docs/lesson-maker/proof.md),
[change](design-docs/lesson-maker/change.md),
[done](design-docs/lesson-maker/done.md),
[key](design-docs/lesson-maker/key.md).

Parts of the D4 design:
[design.yaml](design-docs/practice/design.yaml),
[index](design-docs/practice/index.md),
[summary](design-docs/practice/summary.md),
[words](design-docs/practice/words.md),
[goals](design-docs/practice/goals.md),
[problem](design-docs/practice/problem.md),
[actors](design-docs/practice/actors.md),
[stories](design-docs/practice/stories.md),
[states](design-docs/practice/states.md),
[edges](design-docs/practice/edges.md),
[records and score rules](design-docs/practice/records.md),
[risks](design-docs/practice/risks.md),
[proof](design-docs/practice/proof.md),
[change](design-docs/practice/change.md),
[done](design-docs/practice/done.md),
[key](design-docs/practice/key.md).

Parts of the D2 design:
[design.yaml](design-docs/song-in/design.yaml),
[summary](design-docs/song-in/summary.md),
[words](design-docs/song-in/words.md),
[goals](design-docs/song-in/goals.md),
[actors](design-docs/song-in/actors.md),
[stories](design-docs/song-in/stories.md),
[edges](design-docs/song-in/edges.md),
[records](design-docs/song-in/records.md),
[risks](design-docs/song-in/risks.md),
[proof](design-docs/song-in/proof.md),
[change](design-docs/song-in/change.md),
[done](design-docs/song-in/done.md),
[key](design-docs/song-in/key.md).

Parts of the D5 design:
[design.yaml](design-docs/basics/design.yaml),
[index](design-docs/basics/index.md),
[summary](design-docs/basics/summary.md),
[words](design-docs/basics/words.md),
[goals](design-docs/basics/goals.md),
[problem](design-docs/basics/problem.md),
[actors](design-docs/basics/actors.md),
[stories](design-docs/basics/stories.md),
[states](design-docs/basics/states.md),
[edges](design-docs/basics/edges.md),
[records and the pass rule](design-docs/basics/records.md),
[risks](design-docs/basics/risks.md),
[proof](design-docs/basics/proof.md),
[change](design-docs/basics/change.md),
[done](design-docs/basics/done.md),
[key](design-docs/basics/key.md).
