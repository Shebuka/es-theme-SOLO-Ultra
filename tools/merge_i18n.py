#!/usr/bin/env python3
"""Merge LLM-authored translations into each language's systems file."""
import html
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LANG = os.path.join(ROOT, "theme", "_inc", "lang")
sys.path.insert(0, os.path.join(ROOT, "tools"))

import i18n_de
import i18n_ru
import i18n_it
import i18n_pl
import i18n_jp
import i18n_eszhfr


def parse(xml_text):
    m = re.search(r"<variables>(.*)</variables>", xml_text, re.S)
    if not m:
        return {}
    return {k: html.unescape(v) for k, v in
            re.findall(r"<([A-Za-z0-9_.\-]+)>([^<]*)</\1>", m.group(1))}


def esc(s):
    return html.escape(s, quote=False)


def write_systems(lang, vars_map):
    lines = ["\t<{}>{}</{}>".format(k, esc(vars_map[k]), k)
             for k in sorted(vars_map)]
    out = ('<?xml version="1.0" encoding="UTF-8"?>\n'
           '<theme>\n<formatVersion>7</formatVersion>\n<variables>\n'
           + "\n".join(lines) + '\n</variables>\n</theme>\n')
    with open(os.path.join(LANG, lang + ".systems.xml"), "w", encoding="utf-8") as f:
        f.write(out)


en_vars = parse(open(os.path.join(LANG, "en.systems.xml"), encoding="utf-8-sig").read())

MODULES = {
    "de": i18n_de.TRANS, "ru": i18n_ru.TRANS, "it": i18n_it.TRANS,
    "pl": i18n_pl.TRANS, "jp": i18n_jp.TRANS,
    "es": i18n_eszhfr.ES, "zh": i18n_eszhfr.ZH, "fr": i18n_eszhfr.FR,
}

for lang, trans in MODULES.items():
    cur = parse(open(os.path.join(LANG, lang + ".systems.xml"), encoding="utf-8-sig").read())
    added = 0
    for k, v in trans.items():
        if k in en_vars and k not in cur:
            cur[k] = v
            added += 1
    write_systems(lang, cur)
    print("{}: added {} strings -> {} total".format(lang, added, len(cur)))
print("done")
