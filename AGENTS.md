# AGENTS.md

This file provides guidance to agents when working with code in this repository.
Full theme architecture, naming standards, and workflows are documented in [`docs/THEME.md`](docs/THEME.md:1).

## What this repo is
- A Batocera EmulationStation (ES) theme authoring project ("es-theme-SOLO-Ultra"). There is no package.json, build, lint, or test tooling — output is ES theme XML, not compiled code.
- Validate by loading the theme in ES/Batocera, not by running a build.

## Directory map
- `theme/` — the theme being built. `theme/theme.xml` is the root/default theme.
  - `theme/_art/` — artwork: `backgrounds/{light,dark}/`, `logos/{solo,color_logo,white_logo}/`, `controllers/{left,right}/`, `gamelist_icons/`, `sounds/`.
  - `theme/_inc/` — shared: `fonts/`, `lang/{en,es,fr,pt}.xml`, `menu_icons/`.
  - `theme/options/` — user-selectable variants: `colorset/` (5), `text/` (2), `logos/` (3), `backgrounds/` (2), `iconset/` (7), `video/` (6).
  - `theme/systems/` — per-system content (290 files), included via `<include>./systems/${system.theme}.xml</include>`.
- `specs/` — canonical docs: `batocera_THEMES.md` (element/property reference), `batocera_THEMES_BINDINGS.md` (bindings). `docs/` is empty.

## Theme XML gotchas
- `<formatVersion>7</formatVersion>` is required for Batocera ES, including inside every `<include>`d file.
- Two variable syntaxes that are NOT interchangeable: runtime `{game:name}` vs load-time static `${system.theme}`. Dynamic vars cannot be used in `if` attributes (static only) and cannot set `pos`/`size` (NORMALIZED_PAIR is not bindable).
- Aspect-ratio auto-adaptation uses STATIC `${screen.ratio}` / `${screen.width}` in `if` attributes (e.g. `<image if="${screen.ratio} == '1/1'">`). Pattern: baseline block with no `if` (acts as 16:9 fallback) + conditional overrides for `'1/1'` and `'4/3'`.
- In `if` attributes, XML-escape `<` as `<` (e.g. `if="${screen.width} < 800"`).
- Custom elements require `extra="true"` plus a unique name.
- `<view name="…">` and element `name` attributes accept comma/whitespace-separated lists.
- `pos`/`size` are NORMALIZED_PAIR (two decimals, 0..1). COLOR is 6- or 8-digit hex (8th digit = alpha). A PATH starting with `.` resolves relative to the file containing it — subfolder files use `./../` to reach the theme root.
- `<include subset="…" name="…">` creates user-selectable variants; only one include per subset is active at a time.
