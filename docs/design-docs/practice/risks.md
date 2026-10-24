---
part: risks
---
# Risks

| Risk | What we do |
|---|---|
| The cloud machine has no Swift and no Xcode, so app code is not built here. | A new check builds the app on a macOS machine of GitHub for each pull request. The Mac then makes the TestFlight build. |
| The time of a key press is read when the packet reaches the app, not when the key went down. | The delay is a few milliseconds. The late limit is half a beat, which is 500 milliseconds at 60 beats per minute. |
| Middle C position splits a tune between hands, so "right hand only" can skip notes of the tune. | Both hands is the default. |
| D2 changes PianoCore and the app at the same time. | D4 keeps its code in new files. It changes only the keyboard reader and the home screen of the app. We rebase before the merge. |
| The three built-in tunes look like song files. | They are free to use, and they are a few lines of code. No song file is in the repo. |
| A TestFlight build needs a new build number. | The build number goes from 1 to 2 in the project file. |
