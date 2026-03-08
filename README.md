# atta-wm

A herbstluftwm rice with templated configs for Alacritty, Rofi, Polybar, and the window manager itself. Colors are defined once in `configs/colors.yaml` and rendered into every config via ERB templates.

## Prerequisites

### Window manager & desktop

| Package | Purpose |
|---|---|
| [herbstluftwm](https://herbstluftwm.org/) | Tiling window manager |
| [polybar](https://github.com/polybar/polybar) | Status bar |
| [rofi](https://github.com/davatorium/rofi) (≥ 1.7.5) | Application launcher |

### Terminal & applications

| Package | Purpose |
|---|---|
| [alacritty](https://alacritty.org/) | GPU-accelerated terminal emulator |
| [firefox](https://www.mozilla.org/firefox/) | Web browser (`$Mod-w`) |
| [vifm](https://vifm.info/) | Terminal file manager (`$Mod-n`) |

### Fonts

| Font | Used in |
|---|---|
| Ubuntu Mono | Alacritty, herbstluftwm window titles |

Install via your distro's package manager (e.g. `fonts-ubuntu` on Debian/Ubuntu, `ttf-ubuntu-font-family` on Arch).

### X11 utilities

| Package | Purpose |
|---|---|
| [feh](https://feh.finalrewind.org/) | Lightweight image viewer / wallpaper setter |
| xsetroot | Sets the root window background color |
| setxkbmap | Keyboard layout switching (us, cz) |

These are typically part of `xorg-xsetroot` and `xorg-setxkbmap` (Arch) or `x11-xserver-utils` (Debian/Ubuntu).

### Build / generation tooling

| Package | Purpose |
|---|---|
| [Ruby](https://www.ruby-lang.org/) (≥ 2.7) | Runs the ERB template renderer and keybind exporter |

Only the Ruby standard library is used (`erb`, `yaml`, `pathname`, `fileutils`, `shellwords`) — no gems required.

## Installation

```bash
git clone <repo-url> ~/.config/atta-wm
```

## Usage

Generate all configs and install the herbstluftwm autostart:

```bash
ruby ~/.config/atta-wm/scripts/generate_all.rb
```

This renders every template in `templates/` into `configs/` and copies `configs/autostart` to `~/.config/herbstluftwm/autostart`.

## Repository structure

```
configs/        Generated config files and color definitions
  colors.yaml   Single-source color palette split by target
  autostart     herbstluftwm autostart (generated)
  alacritty.toml
  config.ini    Polybar config (generated)
  config.rasi   Rofi config (generated)
  atta-manual.txt  Auto-generated keybinding reference
templates/      ERB source templates
scripts/        Ruby tooling
  generate_all.rb    Main entrypoint — renders configs and syncs autostart
  render_colors.rb   Renders ERB templates using colors.yaml
  render_keybinds.rb Parses autostart to produce atta-manual.txt
```
