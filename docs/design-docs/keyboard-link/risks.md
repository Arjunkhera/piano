---
part: risks
---
# Risks

| Risk | What we do |
|---|---|
| The keyboard is not a P-125 and needs a driver. | US-2 proves it on the first install. If it fails, Arjun reads the model on the top panel and we check its manual. |
| The cloud session can not build an iPad app. | PianoCore tests run in the cloud on Linux. The app build and TestFlight upload run on Arjun's Mac through a Remote Control session. |
| The TestFlight setup differs from Mindhold. | We copy the Mindhold build steps. A Remote Control session reads them first. |
| A hand-made Xcode project file breaks in merges. | XcodeGen makes the project from a short project.yml. |
