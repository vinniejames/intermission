#!/bin/sh
# Runs on the droplet as root, from deploy.sh: builds tyr-quake at the pinned
# commit and (re)starts it as the intermission service. Safe to rerun.
set -eu

COMMIT="$1"
SRC=/opt/intermission-src
APP=/opt/intermission
PAK_SHA=35a9c55e5e5a284a159ad2a62e0e8def23d829561fe2f54eb402dbc0a9a946af

apt-get update -q
apt-get install -yq build-essential git curl p7zip-full libsdl2-dev

id quake >/dev/null 2>&1 || useradd --system --home-dir "$APP" --shell /usr/sbin/nologin quake
install -d -o quake "$APP/id1"

if [ ! -d "$SRC/.git" ]; then
	git clone https://github.com/sezero/tyrquake.git "$SRC"
fi
git -C "$SRC" fetch -q origin
git -C "$SRC" checkout -fq "$COMMIT"
git -C "$SRC" clean -fdq
git -C "$SRC" apply /tmp/tyrquake.patch

# The dedicated server is the same binary as the client. Sound is not
# started in -dedicated, and the intermission patch allows that.
make -C "$SRC" bin/tyr-quake USE_SDL=Y CD_TARGET=null -j1

if ! echo "$PAK_SHA  $APP/id1/pak0.pak" | sha256sum -c --status 2>/dev/null; then
	sh /tmp/extract-pak0.sh "$APP/id1"
	chown quake:quake "$APP/id1/pak0.pak"
fi

install -m 755 "$SRC/bin/tyr-quake" "$APP/tyr-quake"
install -m 644 /tmp/intermission.cfg "$APP/id1/intermission.cfg"
install -m 644 /tmp/intermission.service /etc/systemd/system/
chown quake:quake "$APP/tyr-quake" "$APP/id1/intermission.cfg"
systemctl daemon-reload
systemctl enable -q intermission
systemctl restart intermission
sleep 2
systemctl --no-pager --lines=12 status intermission
