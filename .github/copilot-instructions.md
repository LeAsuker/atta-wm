# Copilot Instructions

- Keep changes minimal and focused.
- Prefer editing files inside `configs/`, `templates/`, and `scripts/`.
- Keep the three-folder structure intact: `configs/` for generated configs and data, `templates/` for ERB sources, and `scripts/` for Ruby tooling.
- Use `scripts/generate_all.rb` as the main generation entrypoint; it syncs runtime configs to `$HOME/.config/atta-wm/` and writes `autostart` to `$HOME/.config/herbstluftwm/autostart`.
- Preserve the current formatting style in each config file.
- Do not add new dependencies or large tooling unless requested.
- When changing config values, keep comments concise and practical.
- Update this file whenever a repository structure, workflow, or project convention changes.
