#!/usr/bin/env bash
# Install piano-listen, the Mac helper of D2 Layer 2, on this Mac.
#
#   MacHelper/install.sh
#
# 1. Puts Transkun (the piano model, MIT licence) in its own Python
#    environment: ~/Library/Application Support/PianoListen/venv.
# 2. Builds piano-listen and links it as ~/.local/bin/piano-listen.
#
# Needs: Xcode (for swift), and Python 3.10 to 3.13 (brew install python@3.12).
# The first install downloads about 1 GB (PyTorch). Run it again to update.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SUPPORT="$HOME/Library/Application Support/PianoListen"
VENV="$SUPPORT/venv"
BIN="$HOME/.local/bin"
# Build outside the repo: a repo under ~/Desktop can sync to iCloud.
SCRATCH="$HOME/Library/Caches/piano-build/listen"

PYTHON=""
for candidate in python3.12 python3.11 python3.13 python3.10 \
    /opt/homebrew/bin/python3.12 /opt/homebrew/bin/python3.11 /opt/homebrew/bin/python3.13 python3; do
  if command -v "$candidate" >/dev/null 2>&1 &&
     "$candidate" -c 'import sys; sys.exit(0 if (3, 10) <= sys.version_info[:2] <= (3, 13) else 1)' 2>/dev/null; then
    PYTHON="$(command -v "$candidate")"
    break
  fi
done
if [[ -z "$PYTHON" ]]; then
  echo "Need Python 3.10 to 3.13. Install it with: brew install python@3.12" >&2
  exit 1
fi

echo "== Transkun, with $("$PYTHON" --version)"
mkdir -p "$SUPPORT"
if [[ ! -x "$VENV/bin/python" ]]; then
  "$PYTHON" -m venv "$VENV"
fi
"$VENV/bin/python" -m pip install --quiet --upgrade pip
# setuptools before 81 keeps pkg_resources, which Transkun 2.0.1 imports.
# audioop-lts puts back the audioop module that Python 3.13 removed (pydub needs it).
"$VENV/bin/python" -m pip install --quiet \
  "transkun==2.0.1" "setuptools<81" "audioop-lts; python_version >= '3.13'"
"$VENV/bin/transkun" --help >/dev/null

echo "== piano-listen"
swift build -c release --package-path "$HERE" --scratch-path "$SCRATCH"
mkdir -p "$BIN"
ln -sf "$SCRATCH/release/piano-listen" "$BIN/piano-listen"

echo "== Done"
"$BIN/piano-listen" check
case ":$PATH:" in
  *":$BIN:"*) ;;
  *) echo "Add $BIN to your PATH, or run $BIN/piano-listen." ;;
esac
echo "The first recording asks for the Screen Recording permission for your terminal app."
