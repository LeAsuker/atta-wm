#!/usr/bin/env bash
set -eu

KITTY_CONFIG="$HOME/.config/atta-wm/configs/kitty.conf"

if command -v nm-connection-editor >/dev/null 2>&1; then
  exec nm-connection-editor
fi

if command -v kitty >/dev/null 2>&1 && command -v nmtui >/dev/null 2>&1; then
  exec kitty --config "$KITTY_CONFIG" -e nmtui
fi

if command -v nmtui >/dev/null 2>&1; then
  exec xterm -e nmtui
fi

if command -v xmessage >/dev/null 2>&1; then
  exec xmessage "No NetworkManager UI found. Install network-manager-applet, nm-connection-editor, or nmtui."
fi

exit 1