#!/bin/sh
# Extract id Software's freely redistributable Quake 1.06 shareware pak0.pak.
# The registered game (pak1.pak) is not downloaded.
# Usage: extract-pak0.sh <output-directory>
set -eu

OUT="${1:-.}"
URL="${QUAKE106_URL:-https://github.com/Jason2Brownlee/QuakeOfficialArchive/raw/main/bin/quake106.zip}"
ZIP_SHA=ec6c9d34b1ae0252ac0066045b6611a7919c2a0d78a3a66d9387a8f597553239
PAK_SHA=35a9c55e5e5a284a159ad2a62e0e8def23d829561fe2f54eb402dbc0a9a946af

sha256_of() {
	if command -v sha256sum >/dev/null 2>&1; then
		sha256sum "$1" | awk '{print $1}'
	else
		shasum -a 256 "$1" | awk '{print $1}'
	fi
}

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

curl -fsSL -o "$work/quake106.zip" "$URL"
got=$(sha256_of "$work/quake106.zip")
test "$got" = "$ZIP_SHA"

sevenzip() {
	if command -v 7z >/dev/null 2>&1; then
		7z "$@"
	elif command -v 7zz >/dev/null 2>&1; then
		7zz "$@"
	else
		echo "7z is required (p7zip or 7zip)" >&2
		exit 1
	fi
}
sevenzip x -y -o"$work/zip" "$work/quake106.zip" >/dev/null
sevenzip x -y -o"$work/res" "$work/zip/resource.1" >/dev/null
pak=$(find "$work/res" -iname 'pak0.pak' -print -quit)
test -n "$pak"
got=$(sha256_of "$pak")
test "$got" = "$PAK_SHA"

mkdir -p "$OUT"
cp "$pak" "$OUT/pak0.pak"
# Shareware license that ships beside the installer, when present
for license in SLICNSE.TXT README.TXT LICINFO.TXT; do
	found=$(find "$work/res" -iname "$license" -print -quit || true)
	if [ -n "$found" ]; then
		cp "$found" "$OUT/$(echo "$license" | tr 'A-Z' 'a-z')"
	fi
done
