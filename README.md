# atta-wm

## Introduction

An integrated personal herbstluftwm retro setup. It includes out-of-the-box themes, theme switching, and locking. There is a bar with scripts that allows one to configure networks and see battery time by clicking on it.

## Aesthetic

Heavily inspired by late 90s and early 2000s technology. Current themes include win2k, BeOS, Thinkpad and more. The main themes with the most features are win2k and Thinkpad. Notably, there is no compositor - I originally created this for my lower-end laptop with an old battery.

## Features

- Themes for all major applications
- Theme switching with one command
- Locking
- Unified clipboard system that works between windows, terminals and Neovim
- Searchable clipboard history
- Themed notifications

## Prerequisites

### Window manager & desktop

| Package | Purpose |
|---|---|
| [herbstluftwm](https://herbstluftwm.org/) | Tiling window manager |
| [polybar](https://github.com/polybar/polybar) | Status bar |
| [rofi](https://github.com/davatorium/rofi) (≥ 1.7.5) | Application launcher |
| [dunst](https://dunst-project.org/) (≥ 1.9) | Notification daemon |
| [greenclip](https://github.com/erebe/greenclip) | Clipboard history daemon (`$Mod-v`) |
| [xss-lock](https://bitbucket.org/raymonad/xss-lock/) | Launches screen locker on X11 idle/suspend hooks |
| [i3lock](https://github.com/i3/i3lock) | Lock screen binary used by xss-lock |
| [flameshot](https://flameshot.org/) | Screenshot tool |
| [NetworkManager](https://networkmanager.dev/) tools | Provides `nm-connection-editor` for network setup |

### Terminal & applications

| Package | Purpose |
|---|---|
| [Kitty](https://sw.kovidgoyal.net/kitty/) | GPU-accelerated terminal emulator |
| [Neovim](https://neovim.io/) | Terminal editor and generated config target (`$Mod-e`) |
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
| Ubuntu Mono | herbstluftwm window titles and UI templates that do not opt into the Nerd Font variant |
| BlexMonoNerdFont | Kitty, and vifm glyphs rendered through Kitty |

Install Ubuntu Mono via your distro's package manager (e.g. `fonts-ubuntu` on Debian/Ubuntu, `ttf-ubuntu-font-family` on Arch).
If you also install BlexMonoNerdFont, Kitty will use it when the selected theme provides `font_nerd`, and vifm will inherit Nerd Font glyph rendering through Kitty; other UI fonts keep using their normal font unless a template explicitly asks for the Nerd Font variant.

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
All scripting and generation logic is written in Ruby.

## Installation

```bash
git clone https://github.com/LeAsuker/atta-wm.git ~/.config/atta-wm
```
## Usage

Generate all configs and install the herbstluftwm autostart:

```bash
ruby ~/.config/atta-wm/scripts/generate_all.rb
```

This renders every template in `templates/` into `configs/wm-configs/` (window manager, Kitty, Polybar, Rofi) and `configs/tool-configs/` (Neovim, vifm, and the generated vifm colorscheme), then copies each to its system location.

Warning: generation replaces Kitty's active config at `~/.config/kitty/kitty.conf`, herbstluftwm's active autostart at `~/.config/herbstluftwm/autostart`, `~/.config/nvim/init.vim`, vifm config at both `~/.vifm/vifmrc` and `~/.config/vifm/vifmrc`, and the generated vifm colorscheme at both `~/.vifm/colors/atta-wm.vifm` and `~/.config/vifm/colors/atta-wm.vifm`. Back up your existing files before running the generator if you want to keep your current setup.

## Clipboard

All copy/paste is routed through the X11 `CLIPBOARD` selection so that yanking in Neovim, selecting in kitty, and copying file paths in vifm all share one buffer.

| Tool | Role |
|---|---|
| `xclip` | Command-line clipboard bridge used by vifm's `:yp` / `:yd` commands |
| `greenclip` | Clipboard history daemon; provides a searchable rofi history at `$Mod-v` |
| Kitty | `copy_on_select clipboard` — mouse selections go straight to CLIPBOARD; `Ctrl+Shift+C/V` for explicit copy/paste |
| Neovim | `set clipboard=unnamedplus` — all yanks and deletes use the `+` register (CLIPBOARD) |
| Vifm | `:yp` copies the selected file's full path; `:yd` copies the current directory path |

## Kitty defaults

The generated Kitty config now enables Kitty's richer UI instead of the previous stripped-down profile: visible tab bar, window borders, shell integration, scrollback tools, URL detection, and window titles when a tab has multiple splits.

Useful default shortcuts in the generated config:

| Shortcut | Action |
|---|---|
| `Ctrl+Shift+T` | Open a new tab in the current working directory |
| `Ctrl+Shift+Enter` | Open a new split in the current working directory |
| `Ctrl+Shift+[ / ]` | Previous / next tab |
| `Ctrl+Shift+H` | Open the scrollback pager |
| `Ctrl+Shift+G` | Show the last command's output |
| `Ctrl+Shift+E` | Open a visible URL with Kitty hints |
| `Ctrl+Shift+F` | Insert a visible path with Kitty hints |
| `Ctrl+Shift+U` | Open a visible URL directly with Kitty hints |

### greenclip

greenclip is started automatically by herbstluftwm at login via `greenclip daemon &` in `templates/autostart.erb`. Its own config (`~/.config/greenclip.toml`) lives outside this repo — to tune history size, max item length, and other options, edit that file directly. A default greenclip.toml is written on first run.

To install greenclip, download the static binary from [github.com/erebe/greenclip/releases](https://github.com/erebe/greenclip/releases) and place it on your `$PATH`:

```bash
sudo install -m755 greenclip /usr/local/bin/greenclip
```

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

# Neovim: make it the default editor
export EDITOR='nvim'
export VISUAL='nvim'
alias vi='nvim'
alias vim='nvim'
alias v='nvim'

# Bat: The preview engine
alias bat='batcat --paging=never'

# Modal-style shell exit
alias :q='exit'

# FZF: The glue
# Use eza to preview directories and bat to preview files in fzf
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
```

These are not generated by atta-wm and must be added to `~/.bashrc` manually.

## Repository structure

```
configs/            Generated config files and color definitions
  colors.yaml       Single-source color palette split by target
  wm-configs/       Window manager and desktop app configs
    autostart         herbstluftwm autostart (generated)
    kitty.conf
    config.ini        Polybar config (generated)
    config.rasi       Rofi config (generated)
    dunstrc           Dunst notification config (generated)
    atta-manual.txt   Auto-generated keybinding reference
  tool-configs/     CLI tool configs
    init.vim          Neovim config with clipboard integration (generated)
    vifmrc            Vifm config with clipboard integration (generated)
    colors/
      atta-wm.vifm    Vifm colorscheme loaded by vifmrc (generated)
templates/          ERB source templates
  autostart.erb       herbstluftwm autostart template
  kitty.conf.erb      Kitty config template
  config.ini.erb      Polybar config template
  config.rasi.erb     Rofi config template
  dunstrc.erb         Dunst config template
  init.vim.erb        Neovim config template
  atta-wm.vifm.erb    Vifm colorscheme template
  vifmrc.erb          Vifm config template
scripts/            Ruby tooling
  generate_all.rb    Main entrypoint — renders configs and syncs to system paths
  render_colors.rb   Renders ERB templates using colors.yaml
  render_keybinds.rb Parses autostart to produce atta-manual.txt
themes/             Preset theme palettes
  beos.yaml
  cde.yaml
  irix.yaml
  matrix.yaml
  thinkpad.yaml
  win2k.yaml
```
