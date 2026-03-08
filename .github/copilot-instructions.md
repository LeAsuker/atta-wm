# Copilot Instructions

- Keep changes minimal and focused.
- Prefer editing files inside `configs/`, `templates/`, and `scripts/`.
- Keep the three-folder structure intact: `configs/` for generated configs and data, `templates/` for ERB sources, and `scripts/` for Ruby tooling.
- Keep `configs/colors.yaml` split by target (`kitty`, `rofi`, `polybar`, `hlwm`) and update matching templates/scripts together when changing colors.
- Recommend installing by cloning `atta-wm` into `$HOME/.config/atta-wm`.
- Use `scripts/generate_all.rb` as the main generation entrypoint; it keeps generated files in `configs/` inside the repo checkout and writes `autostart` to `$HOME/.config/herbstluftwm/autostart`.
- Runtime paths referenced from `autostart` should point at `$HOME/.config/atta-wm/configs/`.
- Bash prompt snippets should be documented for the user's `.bashrc` rather than generated into the repo.
- Preserve the current formatting style in each config file.
- Do not add new dependencies or large tooling unless requested.
- When changing config values, keep comments concise and practical.
- Update this file whenever a repository structure, workflow, or project convention changes.
