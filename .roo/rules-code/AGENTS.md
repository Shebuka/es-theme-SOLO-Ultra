# Project Coding Rules (Non-Obvious Only)

- Theme XML lives in `theme/`; per-system subfolders under it override the default `theme/theme.xml`.
- Include files (`theme/_inc/*.xml`, `colorsets/`, `iconsets/`, `systemview/`) each need their own `<formatVersion>7</formatVersion>`.
- Use `${system.theme}` for per-system file naming (e.g. `_art/logos/solo/${system.theme}.png`, `_art/sounds/${system.theme}.mp3`).
- Define shared values in a `<variables>` block (custom `${name}` static variables) and reference them instead of hardcoding.
