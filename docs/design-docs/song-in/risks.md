---
part: risks
---
# Risks

| Risk | What we do |
|---|---|
| Transkun or PyTorch does not install on the Mac's Python. | install.sh picks Python 3.10 to 3.13, pins Transkun 2.0.1, and adds setuptools and audioop-lts. A Remote Control session runs it on Arjun's Mac. |
| Transkun writes poor notes from a band mix. | The tool says so in its help. Arjun records solo piano covers. |
| The cloud session can not build Apple code. | A macOS CI job builds piano-listen and the iPad app. PianoCore tests run on Linux and macOS. |
| A song file lands in the public repo. | .gitignore refuses MIDI, MusicXML, .mxl and audio files. Tests use made-up notes written in the test code. |
| D3 works in PianoCore at the same time. | D2 adds new files only, and changes no file D3 needs. |
