---
part: risks
---
# Risks

| Risk | What we do |
|---|---|
| The gate stops Arjun on a lesson that Arjun already knows. | Each exercise is short, less than a minute. Arjun can ask for a skip, which is a small change. |
| Wait mode does not mark a key that comes too early, so a half note can be cut short. | The text of lesson 5 says to count. A play-along mode that marks early keys is a later item. |
| The tunes look like song files. | Each is a folk tune or older than 1900, and a few lines of code. No song file is in the repo. |
| The cloud machine has no Swift and no Xcode. | CI runs the PianoCore tests on Linux and builds the app on macOS for each pull request. |
| D2 changes the home screen and the project file at the same time. | D5 keeps its code in new files. It adds one section to the home screen. We rebase before the merge. |
| A TestFlight build needs a new build number. | The build number goes from 2 to 3, and the version to 0.3.0. |
