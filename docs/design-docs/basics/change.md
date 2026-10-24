---
part: change
---
# Change and undo

| | What |
|---|---|
| Kind | Code. Two new Swift files in PianoCore with tests, three new app screens, one new section on the home screen. |
| Impact | The home screen gets "Start here: Basics course" at the top. The note format and wait mode do not change. The app saves one new value in the user defaults. |
| Undo | Revert the pull request. The saved value stays in the user defaults, but nothing reads it. |
| Tests it changes | None. It adds new tests. |
