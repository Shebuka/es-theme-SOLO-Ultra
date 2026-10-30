# Project Debug Rules (Non-Obvious Only)

- There is no build/test runner; verify by launching ES with `--windowed` so XML errors appear in the terminal, then reload views with `F5`.
- XML/theme errors fail silently on-screen — check the ES log file, not the rendered UI.
- On Batocera the theme installs to `/userdata/themes/[THEME_SET]/[SYSTEM_THEME]/theme.xml`; the folder name must match the theme set name.
