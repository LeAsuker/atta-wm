# atta-wm

A herbstluftwm rice with templated configs for Kitty, Rofi, Polybar, and the window manager itself. Colors are defined once in `configs/colors.yaml` and rendered into every config via ERB templates.

## Prerequisites

### Window manager & desktop

| Package | Purpose |
|---|---|
| [herbstluftwm](https://herbstluftwm.org/) | Tiling window manager |
| [polybar](https://github.com/polybar/polybar) | Status bar |
| [rofi](https://github.com/davatorium/rofi) (≥ 1.7.5) | Application launcher |
| [NetworkManager](https://networkmanager.dev/) tools | Provides `nm-connection-editor` for network setup |

### Terminal & applications

| Package | Purpose |
|---|---|
| [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated terminal emulator |
| [firefox](https://www.mozilla.org/firefox/) | Web browser (`$Mod-w`) |
| [vifm](https://vifm.info/) | Terminal file manager (`$Mod-n`) |
| [eza](https://github.com/eza-community/eza) | Modern `ls` replacement with icons, Git status, and color support |
| [bat](https://github.com/sharkdp/bat) | `cat` replacement with syntax highlighting and line numbers |
| [bottom](https://github.com/ClementTsang/bottom) | Graphical process/system monitor (`btm`) |
| [atuin](https://github.com/atuinsh/atuin) | Shell history search and sync with SQLite backend |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` that learns your most-used directories |
| [fzf](https://github.com/junegunn/fzf) | General-purpose fuzzy finder for files, history, and more |
| [procs](https://github.com/dalance/procs) | Modern `ps` replacement with color output and search |

### Fonts

| Font | Used in |
|---|---|
| Ubuntu Mono | Kitty, herbstluftwm window titles |

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
git clone https://github.com/LeAsuker/atta-wm.git ~/.config/atta-wm
```
## Usage

Generate all configs and install the herbstluftwm autostart:

```bash
ruby ~/.config/atta-wm/scripts/generate_all.rb
```

This renders every template in `templates/` into `configs/` and copies `configs/autostart` to `~/.config/herbstluftwm/autostart`.

Warning: generation replaces Kitty's active config at `~/.config/kitty/kitty.conf` and herbstluftwm's active autostart at `~/.config/herbstluftwm/autostart`. Back up your existing files before running the generator if you want to keep your current setup.

## Themes

The repository currently includes these preset themes in `themes/`:

| Theme | Description |
|---|---|
| `beos` | Bright BeOS-inspired palette with white panels, blue highlights, and yellow active accents. |
| `cde` | Muted gray desktop theme with purple and sand accents inspired by classic CDE workstations. |
| `irix` | Teal-and-stone SGI-style palette with subdued contrast and cool cyan highlights. |
| `matrix` | Black-and-green high-contrast theme with a terminal-centric retro look. |
| `thinkpad` | Dark charcoal theme with IBM/ThinkPad-style red and blue accents. |
| `win2k` | Blue-gray Windows 2000 inspired palette with classic silver UI surfaces. |

To switch themes, regenerate the configs with the theme file you want:

```bash
ruby ~/.config/atta-wm/scripts/generate_all.rb ~/.config/atta-wm/themes/win2k.yaml
```

This copies the selected theme into `configs/colors.yaml`, re-renders every generated file in `configs/`, updates `~/.config/herbstluftwm/autostart`, and syncs Kitty to `~/.config/kitty/kitty.conf`.

If you want to make one theme the repo default, copy it into `configs/colors.yaml` and then run `generate_all.rb` without arguments.

The generated Polybar config shows built-in `WLAN` and `ETH` status modules. Clicking either label opens `nmtui connect` in Kitty so you can connect to and activate NetworkManager profiles without a separate tray applet.

`nmtui` is part of NetworkManager on most distros.

If you want a Kitty-only Bash prompt that follows the terminal's themed 16-color palette, add this snippet to `~/.bashrc`:

```bash
if [[ $- == *i* ]] && { [ -n "${KITTY_WINDOW_ID:-}" ] || [ "${TERM:-}" = xterm-kitty ]; }; then
  PROMPT_COMMAND='last_exit=$?; if [ "$last_exit" -eq 0 ]; then status="\[\e[92m\][ok]\[\e[0m\]"; prompt="\[\e[95m\]\\$\[\e[0m\]"; else status="\[\e[91m\][$last_exit]\[\e[0m\]"; prompt="\[\e[91m\]\\$\[\e[0m\]"; fi; PS1="\[\e[96m\][\A]\[\e[0m\] \[\e[94m\]\u@\h\[\e[0m\] \[\e[93m\]\w\[\e[0m\] \[\e[90m\]-\[\e[0m\] ${status}\n${prompt} "'
fi
```

The snippet must be added to `~/.bashrc`; it is not generated by atta-wm.

## Shell tool aliases

For a cohesive terminal experience with the CLI tools listed above, add the following to `~/.bashrc`:

```bash
# Eza: The visual engine
alias l='eza --icons --group-directories-first'
alias ll='eza -lh --icons --git --group-directories-first'
alias lt='eza --tree --level 2'

# Bat: The preview engine
alias bat='batcat --paging=never'

# FZF: The glue
# Use eza to preview directories and bat to preview files in fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
```

These are not generated by atta-wm and must be added to `~/.bashrc` manually.

## Repository structure

```
configs/        Generated config files and color definitions
  colors.yaml   Single-source color palette split by target
  autostart     herbstluftwm autostart (generated)
  kitty.conf
  config.ini    Polybar config (generated)
  config.rasi   Rofi config (generated)
  atta-manual.txt  Auto-generated keybinding reference
templates/      ERB source templates
  autostart.erb   herbstluftwm autostart template
  kitty.conf.erb  Kitty config template
  config.ini.erb  Polybar config template
  config.rasi.erb Rofi config template
scripts/        Ruby tooling
  generate_all.rb    Main entrypoint — renders configs and syncs autostart
  render_colors.rb   Renders ERB templates using colors.yaml
  render_keybinds.rb Parses autostart to produce atta-manual.txt
themes/         Preset theme palettes
  beos.yaml
  cde.yaml
  irix.yaml
  matrix.yaml
  thinkpad.yaml
  win2k.yaml
```
