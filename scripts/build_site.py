#!/usr/bin/env python3
"""Build the Hugo site from the repository's existing article READMEs."""

import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parents[1]


def prepare_content(destination):
    homepage = (ROOT / "README.md").read_text(encoding="utf-8")
    labels = dict(
        (slug, label)
        for label, slug in re.findall(
            r"\[([^\]]+)\]\(/([^/]+)/README\.md\)", homepage
        )
    )
    sources = [ROOT / "README.md", *sorted(ROOT.glob("*/README.md"))]
    for source in sources:
        if source.parent.name == "other":
            continue
        home = source.parent == ROOT
        slug = source.parent.name
        bundle = destination if home else destination / slug
        if not home:
            shutil.copytree(
                source.parent, bundle, ignore=shutil.ignore_patterns("*.md")
            )
        text = source.read_text(encoding="utf-8")
        heading = re.search(r"^# +(\S[^\n]*)", text, re.MULTILINE)
        title = heading.group(1).strip() if heading else labels[slug]
        if not heading:
            text = f"# {title}\n\n{text.lstrip()}"
        metadata = json.dumps({"title": title}, ensure_ascii=False)
        target = bundle / ("_index.md" if home else "index.md")
        target.write_text(f"{metadata}\n\n{text}", encoding="utf-8")


def main():
    with tempfile.TemporaryDirectory(prefix="azure-hugo-") as directory:
        prepare_content(Path(directory))
        subprocess.run(
            ["hugo", "--contentDir", directory, *sys.argv[1:]],
            cwd=ROOT,
            check=True,
        )


if __name__ == "__main__":
    main()
