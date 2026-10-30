# Project Architecture Rules (Non-Obvious Only)

- ES theme-set layout: a default `theme.xml` at the set root plus optional per-system subfolders. ES checks `[SYSTEM]/theme.xml` first, then falls back to the set root.
- `theme/_inc/` holds shared resources (fonts, lang, menu_icons); `theme/_art/` holds artwork.
- The root `theme.xml` should `<include>./config.xml</include>` to declare language + subset (colorset/iconset/systemview) variations.
