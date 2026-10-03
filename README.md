# intermission

A Claude Code plugin that drops you into Quake deathmatch while Claude works, and hands you back when it's done.

This is a fork of [jarrodwatts/intermission](https://github.com/jarrodwatts/intermission). The upstream mod plays Doom (Odamex and Freedoom). This one plays Quake. The install, the pane, and the "hand you back when Claude needs you" behavior are the same.

[![License](https://img.shields.io/github/license/vinniejames/intermission)](LICENSE)

![intermission in action](intermission-preview.png)

When Claude has been working for two seconds, a pane opens beside the
transcript and you drop into a free-for-all on a shared server with everyone
else who is waiting on Claude. When Claude finishes there's a three-second
countdown and you're handed back. If Claude needs you, say for a permission
prompt, you're handed back at once and dropped in again after you answer.

It's [TyrQuake](https://disenchant.net/tyrquake/)'s software NetQuake client,
with id Software's freely redistributable Quake shareware (`pak0.pak`, episode
1). The registered game (`pak1.pak`) is not used. Between turns the client
stays on the server as a non-solid, untouchable spectator, then respawns when
you come back. If the server can't be reached, you get the shareware episode
against monsters instead.

Quake's deathmatch rules remove monsters, so a server with nobody else on it
is quiet. That is different from the Doom server, which left the monsters in.

## Install

1. Install the plugin:

   ```
   /plugin install intermission --marketplace vinniejames/intermission
   ```

2. Turn it on:

   ```
   /intermission
   ```

   The first time, it downloads the game, about 30 MB, from the GitHub release
   for this version. Tag `v0.2.0` (matching `plugin.json`) to have Actions
   build that archive. Until the release exists, the welcome pane says it
   couldn't get the game.

To turn it off again, run `/intermission off`.

## Requirements

- macOS 15 or later, on Apple silicon or Intel
- [Ghostty](https://ghostty.org) or [kitty](https://sw.kovidgoyal.net/kitty/),
  the terminals that can show the game's pixels
- Claude Code 2.1.287 or later

## Controls

Click the game to play. The click also locks the mouse for turning; Esc or ⌘
releases it.

| | |
| :- | :- |
| Move | WASD or the arrow keys |
| Turn | the mouse, once locked |
| Fire | left click |
| Run forward | hold right click |
| Jump | space |
| Weapons | 1 to 8 |

Doors open when you walk into them. If your terminal is too narrow for the
pane to open by itself, a line above the prompt offers it instead: press 1.

## What it connects to

The game connects over UDP to `quake.intermission.invalid` on NetQuake's
default port, 26000, under a random name such as `QueuedRanger42`. Nothing
about your session, project or Claude's work is sent. There is no public
server for this fork yet, so that name does not resolve and you get the
offline episode. To run the shared server, use [`deploy.sh`](deploy.sh) and
then set `SERVER` in [`hooks/register.js`](hooks/register.js) to the host.

Between rounds it stays connected as a silent spectator, and disconnects
after five minutes away.

## How it works

The mod runs TyrQuake without a window. Each frame goes into shared memory,
which the terminal paints into the pane, and the pane passes keys and clicks
back. Terminals report key presses but not releases, so a key counts as held
until its auto-repeat stops. The changes to TyrQuake are in
[`engine/tyrquake.patch`](engine/tyrquake.patch), applied to the commit in
[`engine/tyrquake-commit`](engine/tyrquake-commit).

The dedicated server is that same binary with `-dedicated`.
[`deploy.sh`](deploy.sh) builds and runs it. The shareware pak is extracted
from id's `quake106.zip` by [`engine/extract-pak0.sh`](engine/extract-pak0.sh).

## Build the engine yourself

On Linux, for a dedicated server or a smoke test:

```
git clone https://github.com/sezero/tyrquake.git
git -C tyrquake checkout "$(cat engine/tyrquake-commit)"
git -C tyrquake apply engine/tyrquake.patch
make -C tyrquake bin/tyr-quake USE_SDL=Y CD_TARGET=null
sh engine/extract-pak0.sh /tmp/quake-id1
cp client/intermission.cfg /tmp/quake-id1/
```

Put `pak0.pak` and `intermission.cfg` in `<basedir>/id1/`. The macOS app the
plugin downloads is laid out as `tyr-quake.app` plus `id1/` inside `dist/`.

## Licenses

The mod is MIT, as in [`LICENSE`](LICENSE). It is a fork of Jarrod Watts's
intermission. TyrQuake and the Quake engine are GPL-2.0, and so are the
changes in `engine/`. Quake shareware `pak0.pak` is id Software's freely
redistributable episode 1, not the registered game.
