#!/bin/bash
# Stage the auto-edit runtime that scripts/bundle.sh copies into the app:
#   vendor-src/runtime/{python, bin/ffmpeg, bin/ffprobe, app/{autoedit,ugc,mcpb-autoedit,tests}}
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERVER_REPO="${AUTOEDIT_SERVER_REPO:-$HOME/auto-edit}"          # github.com/LochlanMacQueen/auto-edit checkout
V="$ROOT/vendor-src"; R="$V/runtime"; mkdir -p "$V" "$R/bin" "$R/app"
if [ ! -x "$V/python/bin/python3.12" ]; then
  URL=$(curl -s https://api.github.com/repos/astral-sh/python-build-standalone/releases/latest | python3 -c "import sys,json;print([x['browser_download_url'] for x in json.load(sys.stdin)['assets'] if x['name'].startswith('cpython-3.12') and 'aarch64-apple-darwin-install_only.tar.gz' in x['name'] and not x['name'].endswith('.sha256')][0])")
  curl -sL -o "$V/python.tar.gz" "$URL" && tar -xzf "$V/python.tar.gz" -C "$V"
  "$V/python/bin/python3.12" -m pip install -q --upgrade pip
  "$V/python/bin/python3.12" -m pip install -q -r "$SERVER_REPO/requirements-autoedit.txt"
  "$V/python/bin/python3.12" -m pip uninstall -q -y torch sympy networkx || true   # whisper works without them (~600 MB saved)
fi
for b in ffmpeg ffprobe; do
  [ -x "$V/$b" ] || { curl -sL -o "$V/$b.zip" "https://ffmpeg.martin-riedl.de/redirect/latest/macos/arm64/release/$b.zip" && (cd "$V" && unzip -qo "$b.zip") && chmod +x "$V/$b"; }
done
rm -rf "$R/python"; cp -R "$V/python" "$R/python"; cp "$V/ffmpeg" "$V/ffprobe" "$R/bin/"
rsync -a --delete --exclude __pycache__ --exclude .wda_session --exclude .palmier_session --exclude 'runs/*' --exclude .DS_Store "$SERVER_REPO/autoedit" "$SERVER_REPO/ugc" "$SERVER_REPO/mcpb-autoedit" "$SERVER_REPO/tests" "$SERVER_REPO/requirements-autoedit.txt" "$R/app/"
find "$R" -name __pycache__ -type d -prune -exec rm -rf {} +
echo "runtime staged at $R ($(du -sh "$R" | cut -f1))"
