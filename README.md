# es-theme-SOLO-Ultra

An EmulationStation theme for **Batocera (Plus)**, **RetroBat** and **EmuELEC**, built for the **R36S / R36 Ultra** handhelds.

SOLO Ultra follows the symmetric art direction of the recent Star Wars films: many colours, simple and direct, with a new concept for the SOLO family.

![SOLO Ultra system view](screenshots/0.%20Systems.png)

## Where the assets come from

- **Backgrounds and system logos** — taken from [**Alekfull-SOLO**](https://github.com/fagnerpc/Alekfull-SOLO) (by fagnerpc).
- **Everything else** — re-done from scratch for this theme: all views and layouts, colour schemes, icon sets, localization, per-system metadata and tooling.
- **Sounds** — produced with our own [**es-soundtrack-tool**](https://github.com/shebuka/es-soundtrack-tool), which downloads per-system soundtrack previews from amazing folks at [retro.sx](https://retro.sx/).

## System and game view options

The theme ships with several user-selectable option groups:

| Group | Choices |
|-------|---------|
| Colour scheme | SOLO Dark Red (default), Carbon, Sapphire, Emerald, Amber |
| Logo style | SOLO, Color, White |
| Backgrounds | Light, Dark |
| Help-bar icons | Default, XBox, Famicom, SNES, PSX, Dreamcast, Saturn |
| Video delay | No delay, 1 / 2 / 3 / 5 seconds, Off |
| Text size | Normal, Small |

Game lists are available in **Basic**, **Detailed**, **Grid**, **Boxes**, **Boxes + Details**, **Carousel + Details**, **Tiles + Marquee** and **Fanart** views, and systems are browsed in a **vertical carousel** with an information header.

![Detailed game list view](screenshots/2.%20Detailed.png)

Browse the [screenshot gallery](screenshots/README.md) for every game-list view and the theme settings screen.

### Automatic aspect-ratio adaptation

Layouts adapt on their own — no user option required:

- **1:1 (720×720)** — R36 Ultra, the primary target.
- **4:3** — R36S, the second target.
- **16:9** — baseline fallback for other displays.

## Systems and localization

- One file per system theme name under [`theme/systems/`](theme/systems), covering individual consoles, arcade boards, genres, publisher sets and special collections using the Batocera / RetroBat / EmuELEC naming.
- 10 languages: English (always-loaded fallback), Portuguese, Spanish, Chinese, French, German, Russian, Italian, Japanese and Polish, including translated system descriptions and collection texts.

## Installation

1. Copy this folder to your frontend's theme directory, keeping the folder name:
   - Batocera: `/userdata/themes/es-theme-SOLO-Ultra/`
   - ArkOS: `/roms/themes/es-theme-SOLO-Ultra/`
2. Open **UI Settings → Theme** and select **SOLO Ultra**.

## Important

- This theme is **NOT authorized for commercial use**.
- Compatible with recent **(d)ArkOS4Clones**, **(d)ArkOS**, **Batocera**, **RetroBat** and **EmuELEC** releases.
- **Not** compatible with **Recalbox** (it may work but I didn't test it).
- Because the backgrounds and logos derive from Alekfull-SOLO, the theme is distributed non-commercially with attribution, and derivative artwork keeps the same non-commercial share-alike terms. Logos and trademarks remain the property of their respective owners.

### License

This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/). \
![Creative Commons Licence](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png "Creative Commons Licence")

The full terms are also bundled as [`LICENSE`](LICENSE) and included in every release archive.

ALLOWED:
- Share and duplicate as it is
- Edit, alter, change it

REQUIREMENTS:
- Attribution, give credit to the creators
- Indicate changes to the theme
- Publish the changes under the same license

PROHIBITED:
- Commercial distribution

## Documentation

- [`docs/THEME.md`](docs/THEME.md) — architecture, layout structure and EmulationStation gotchas.
- [`specs/`](specs) — canonical Batocera theme element/property and bindings references.
