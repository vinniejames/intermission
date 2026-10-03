#!/bin/sh
# Builds and (re)starts the intermission game server on the droplet.
# Usage: ./deploy.sh [user@host]
set -eu
cd "$(dirname "$0")"

HOST="${1:-}"
if [ -z "$HOST" ]; then
	echo "usage: ./deploy.sh user@host" >&2
	echo "The upstream Doom server is not reused. After it is up, set SERVER in hooks/register.js to that host." >&2
	exit 1
fi

scp -q server/intermission.cfg server/intermission.service engine/tyrquake.patch engine/extract-pak0.sh "$HOST:/tmp/"
ssh "$HOST" sh -s "$(cat engine/tyrquake-commit)" < server/setup.sh
