#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-node_modules/three}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
cat "$HERE"/three-r185-min-runtime.tgz.b64.part-* | base64 --decode > "$TMP/three-r185-min-runtime.tgz"
EXPECTED="$(node -e "console.log(require('$HERE/manifest.json').archiveSha256)")"
ACTUAL="$(sha256sum "$TMP/three-r185-min-runtime.tgz" | awk '{print $1}')"
test "$ACTUAL" = "$EXPECTED"
mkdir -p "$(dirname "$TARGET")"
rm -rf "$TARGET"
tar -xzf "$TMP/three-r185-min-runtime.tgz" -C "$TMP"
mv "$TMP/package" "$TARGET"
node -e "const p=require('./$TARGET/package.json'); if(p.name!=='three'||p.version!=='0.185.1') process.exit(1); console.log('restored three@'+p.version)"
