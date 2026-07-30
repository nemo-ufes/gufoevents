#!/usr/bin/env python3
"""Regenerate the gUFOevents documentation in docs/.

This reproduces the documentation pipeline used for gUFO:

1. the reference documentation is generated from gufoevents.ttl with pyLODE
   (ontdoc profile, external stylesheet), so that every class and property is
   documented from the rdfs:label and rdfs:comment annotations in the ontology;
2. the usage guide in overview.md is rendered to HTML and injected into the
   ``<section id="overview">`` placeholder that pyLODE produces;
3. the ontology logo is added and a copy of the ontology is placed alongside
   index.html, so that the published documentation is self-contained.

Requirements: ``pip install "pylode==2.13.2" markdown``.

Usage: ``python docs/build.py`` (from anywhere; paths are resolved relative to
this file).
"""

import re
import shutil
from pathlib import Path

import markdown
from pylode import MakeDocco

DOCS = Path(__file__).resolve().parent
ROOT = DOCS.parent

ONTOLOGY = ROOT / "gufoevents.ttl"
OVERVIEW = DOCS / "overview.md"
INDEX = DOCS / "index.html"
LOGO = "ufo-logo.png"

# pyLODE emits a placeholder overview section; we replace it wholesale.
OVERVIEW_PLACEHOLDER = re.compile(
    r'<section id="overview">.*?</section>', re.DOTALL
)
TOC_SECTION = re.compile(r'<section id="toc">.*?</section>', re.DOTALL)
PYLODE_CREDIT = '<div id="pylode">'


def render_overview() -> str:
    """Render overview.md, keeping the raw HTML anchors it contains."""
    html = markdown.markdown(
        OVERVIEW.read_text(encoding="utf-8"),
        extensions=["tables", "md_in_html"],
    )
    return '<section id="overview">\n' + html + "\n</section>"


def main() -> None:
    html = MakeDocco(
        input_data_file=str(ONTOLOGY),
        outputformat="html",
        include_css=False,
    ).document()

    # 1. inject the usage guide in place of pyLODE's placeholder
    html, n = OVERVIEW_PLACEHOLDER.subn(
        lambda _: render_overview(), html, count=1
    )
    if n != 1:
        raise SystemExit("could not find the overview placeholder in pyLODE output")

    # 2. put the usage guide ahead of the reference table of contents, as in gUFO
    overview = OVERVIEW_PLACEHOLDER.search(html)
    toc = TOC_SECTION.search(html)
    if overview and toc and toc.start() < overview.start():
        block = html[overview.start():overview.end()]
        html = html[:overview.start()] + html[overview.end():]
        toc = TOC_SECTION.search(html)
        html = html[:toc.start()] + block + "\n" + html[toc.start():]

    # 3. add the UFO logo just below the pyLODE credit
    logo = f'<img src="{LOGO}" title="Unified Foundational Ontology Logo" width="25%" height="25%"/>'
    if PYLODE_CREDIT not in html:
        raise SystemExit("could not find the pyLODE credit div in pyLODE output")
    head, _, tail = html.partition("</div>")
    html = head + "</div>\n" + logo + tail

    INDEX.write_text(html, encoding="utf-8")

    # 4. publish a copy of the ontology next to the documentation
    shutil.copyfile(ONTOLOGY, DOCS / ONTOLOGY.name)

    print(f"wrote {INDEX.relative_to(ROOT)} ({len(html.splitlines())} lines)")


if __name__ == "__main__":
    main()
