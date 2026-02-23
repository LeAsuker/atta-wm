# Copilot instructions for Miku-Flavor

## Big picture
- This repo is a “rice” installer: the Bash script installs packages via `apt`, downloads config files from GitHub raw URLs, and sets up a fixed config layout in the user’s home directory.
- Runtime configuration lives in `$HOME/.config/mikuflavor/` with one exception: the herbstluftwm `autostart` is placed in `$HOME/.config/herbstluftwm/`.

## Key entry points
- Installer script: `miku_flavor_install.sh` (package install, downloads, wallpaper setup).
- WM config: `Configs/autostart` (keybinds, theme, startup apps like `picom`, `polybar`).
- Polybar config: `Configs/config.ini` (modules, custom `netmanager` script hook).
- Wi‑Fi menu script: `Configs/rofi-wifi-menu/rofi-wifi-menu.sh` (invoked by Polybar module).

## Critical flow and dependencies
- The installer pulls configs from GitHub raw URLs (not from local `Configs/`). If you change configs in this repo, update the raw links in `miku_flavor_install.sh` or the installer won’t pick them up.
- `Configs/autostart` uses `feh`, `picom`, `polybar`, and `setxkbmap`, so these tools must stay aligned with installed packages.

## Conventions and patterns
- Config paths are always absolute and tied to `$HOME/.config/mikuflavor/` (see `Configs/autostart` and `Configs/config.ini`).
- `polybar`’s `netmanager` module expects the script at `$HOME/.config/mikuflavor/rofi-wifi-menu/rofi-wifi-menu.sh`.
- Changes to keybindings and startup apps should go in `Configs/autostart`, not in the installer.

## Workflow notes
- Install is intended to be run without `sudo` (see README). There are no tests/builds; changes are validated by running the installer on a Debian-based, X11 system.
- If you add new configs, ensure the installer creates/downloads them and that `autostart` or `polybar` points to the right paths.

## Maintaining these instructions
- Whenever you make a change that affects architecture, conventions, config paths, or workflows described above, update this file (`.github/copilot-instructions.md`) in the same commit to keep it accurate.
