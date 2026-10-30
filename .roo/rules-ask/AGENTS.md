# Project Documentation Rules (Non-Obvious Only)

- Canonical docs are in `specs/` (`batocera_THEMES.md` + `batocera_THEMES_BINDINGS.md`), not `docs/` (currently empty).
- Theme XML uses two variable dialects: `{…}` (runtime bindings) vs `${…}` (load-time static). See `specs/batocera_THEMES_BINDINGS.md` for the available properties.
