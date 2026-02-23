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
- `Configs/autostart` uses `feh`, `picom`, `polybar`, and `setxkbmap`, so these tools must stay aligned with installed packages.- The installer requires `ruby` (installed via `apt`) to run `apply_colors.rb` at install time.

## Color theming pipeline
- **`Configs/colors.yml`** is the **single source of truth** for all colors (WM/UI, Rofi, Polybar, Alacritty terminal palette).
- **`Configs/*.template`** files contain `{{key}}` and `{{rgba:key}}` placeholders that reference keys from `colors.yml`.
- **`Configs/apply_colors.rb`** (Ruby, stdlib only — `require 'yaml'`) reads `colors.yml` and renders `*.template` files into final configs by substituting placeholders. Run at install time.
- **`render_defaults.rb`** (repo root) is a developer helper that regenerates the pre-rendered default configs (`Configs/autostart`, `config.ini`, `config.rasi`, `alacritty.toml`) from templates + `colors.yml`. **Must be run before committing** whenever `colors.yml` or any `.template` changes.
- Pre-rendered defaults are shipped in the repo so configs work even without running the Ruby parser.
- Placeholder syntax: `{{key}}` for raw hex values, `{{rgba:key}}` for Rofi `rgba( R, G, B, 100 % )` conversion.
- `picom.conf` has no color placeholders and is not templated.
## Conventions and patterns
- Config paths are always absolute and tied to `$HOME/.config/mikuflavor/` (see `Configs/autostart` and `Configs/config.ini`).
- `polybar`’s `netmanager` module expects the script at `$HOME/.config/mikuflavor/rofi-wifi-menu/rofi-wifi-menu.sh`.
- Changes to keybindings and startup apps should go in `Configs/autostart`, not in the installer.- **Color changes** go in `Configs/colors.yml`, never directly in the pre-rendered configs or templates.
- After editing `colors.yml`, run `ruby render_defaults.rb` from the repo root before committing.
## Workflow notes
- Install is intended to be run without `sudo` (see README). There are no tests/builds; changes are validated by running the installer on a Debian-based, X11 system.
- If you add new configs, ensure the installer creates/downloads them and that `autostart` or `polybar` points to the right paths.
- End users can customize colors by editing `~/.config/mikuflavor/colors.yml` and re-running `ruby apply_colors.rb colors.yml ~/.config/mikuflavor` (plus the herbstluftwm directory).

## Maintaining these instructions
- Whenever you make a change that affects architecture, conventions, config paths, or workflows described above, update this file (`.github/copilot-instructions.md`) in the same commit to keep it accurate.
