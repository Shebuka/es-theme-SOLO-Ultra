# es-theme-SOLO-Ultra

A Batocera EmulationStation (ES) theme for R36S / R36 Ultra handhelds with a configurable, multi-language, auto-adapting layout.

There is no build system — the theme is authored as ES theme XML and validated by loading it in ES/Batocera.

## Layout

```
theme/
  theme.xml          root: screen + menu views, includes config/system/gamelists
  config.xml         language includes + user-selectable option subsets
  system.xml         system view (vertical carousel + info header)
  gamelists.xml      basic / detailed / grid gamelist view implementations
  _art/              artwork (backgrounds, logos, controllers, gamelist/menu/help icons, sounds, battery)
  _inc/              shared: fonts/, lang/
  options/           user-selectable variants (colorset, text, logos, backgrounds, iconset, video)
  systems/           per-system content (one file per system theme name)
tools/
  i18n_*.py          per-language translation data
  merge_i18n.py      merges translations into lang files
specs/               canonical Batocera theme docs
docs/                this documentation
```

## Configurable options (theme configuration UI)

Declared as `<subset name="…" displayName="…">` parent blocks in [`theme/config.xml`](theme/config.xml:21), each grouping its option `<include>` children. ES flattens these at parse time into the equivalent flat `<include subset="…" subSetDisplayName="…">` form, so both syntaxes are valid:

| Subset | Options |
|--------|---------|
| `colorset` | SOLO Dark Red (default), Carbon, Sapphire, Emerald, Amber |
| `text` | Normal, Small |
| `logos` | SOLO, Color, White |
| `backgrounds` | Light, Dark |
| `iconset` | Default, XBox, Famicom, SNES, PSX, Dreamcast, Saturn |
| `video` | No delay, 1/2/3/5 seconds, Off |

Each option is a pure `<variables>` stylesheet (`colorset`, `text`, `iconset`) or a path/behavior override (`logos`, `backgrounds`, `video`).

## Aspect-ratio auto-adaptation

Layouts adapt automatically — no user option. Static `${screen.ratio}` / `${screen.width}` in `if` attributes select per-ratio positions:

- `1/1` — R36 Ultra (primary target)
- `4/3` — R36S (second target)
- baseline (no `if`) — 16:9 fallback

Pattern: a baseline block with no `if` (16:9 fallback) + conditional overrides for `'1/1'` and `'4/3'`. `<` must be XML-escaped as `<`.

## Variable naming standard

- **System descriptions**: `<stem>_desc` (hardware) or `<stem>_coll` (collection), e.g. `n64_desc`, `atari_coll`.
- **System-type strings**: shared `type_<slug>`, e.g. `type_1996_64_bit_console`, `type_collection`.
- **Config strings**: `snake_case`, e.g. `subset_colorset`, `color_solo_red`, `delay_off`.

## Localization

- 10 languages: `en`, `pt`, `es`, `zh`, `fr`, `de`, `ru`, `it`, `jp`, `pl`.
- Each language has 3 files: `<lang>.xml` (fonts + includes), `<lang>.configs.xml` (config strings), `<lang>.systems.xml` (system descriptions).
- `en` is always loaded as fallback; other languages only override what they translate.
- Full 331-string coverage in all 10 languages.

## Key ES gotchas

- `<formatVersion>7</formatVersion>` is required in **every** included file.
- Runtime `{game:name}` vs load-time `${system.theme}` are not interchangeable; dynamic vars can't set `pos`/`size` and can't be used in `if`.
- Custom elements need `extra="true"` + unique name.
- `pos`/`size` are NORMALIZED_PAIR (0..1); COLOR is 6/8-digit hex; paths starting with `.` resolve relative to the containing file (`./../` from subfolders).
- `<subset name="…" displayName="…" appliesTo="…">` is valid sugar (missing from the community spec): it becomes `subset`/`subSetDisplayName`/`appliesTo` on each child `<include>`, and its own filter attributes (`lang`, `tinyScreen`, …) gate the whole group.

## Commands

```sh
python3 tools/merge_i18n.py       # merge translations into lang files
for f in $(find theme -name '*.xml'); do xmllint --noout "$f" || echo "INVALID: $f"; done
```

## Known limitations / next steps

- `de`/`ru`/`it`/`pl`/`jp` long descriptions were authored by the agent and should be proofread by native speakers.
- Some niche nes-box entries (engines, MAME variants, extra publisher collections) are not yet included; add them as new per-system files following the existing `_desc`/`_coll`/`type_*` conventions.
- Layout coordinates still need visual tuning on real hardware.
