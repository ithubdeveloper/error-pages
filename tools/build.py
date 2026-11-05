#!/usr/bin/env python3
"""Generate all error pages from src/page.html.tpl and src/pages.json."""
import html, json, pathlib

root = pathlib.Path(__file__).resolve().parent.parent
tpl = (root / "src" / "page.html.tpl").read_text()
pages = json.loads((root / "src" / "pages.json").read_text())

for p in pages:
    out = tpl
    for key, val in {
        "TITLE": p["title"], "DESC": p["desc"], "CODE": p["code"],
        "HAPPENED": p["happened"], "TODO": p["todo"], "ADMIN": p["admin"],
    }.items():
        out = out.replace("{{%s}}" % key, html.escape(str(val), quote=True))
    (root / p["file"]).write_text(out)
print("built %d pages" % len(pages))
